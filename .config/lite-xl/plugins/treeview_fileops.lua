-- mod-version:3
--
-- treeview_fileops: safer file operations in the treeview.
--
-- Right click adds Open in Terminal, Duplicate, Copy Name and Copy Path.
-- Rename and Duplicate never replace a file without asking and never
-- replace folders; open tabs follow a renamed file or folder. Delete
-- removes a link to a folder, never what is inside the folder it points
-- to, never goes into another drive, and refuses the top folders of the
-- tree and any folder that holds your home folder.
--
-- cp, mv and rm do the work, in the background, so a big copy or delete
-- doesn't freeze the editor. Works with or without treeview_projects.
-- Written for lite-xl 2.1.x on Linux.

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local TreeView = require "plugins.treeview"

config.plugins.treeview_fileops = common.merge({
  terminal = "",
  config_spec = {
    name = "Treeview File Operations",
    { label = "Terminal", path = "terminal", type = "string", default = "",
      description = "Command for Open in Terminal. Empty: $TERMINAL, else the first one "
        .. "installed of foot, kitty, alacritty, wezterm, ghostty, konsole, ..." },
  }
}, config.plugins.treeview_fileops)

---------------------------------------------------------------------------
-- Paths
---------------------------------------------------------------------------

local SEP = PATHSEP:byte()

-- true if `path` is `dir` or inside it
local function within(path, dir)
  local n = #dir
  if dir:byte(n) ~= SEP then n = n + 1 end
  return path == dir or (#path > n and path:byte(n) == SEP and path:find(dir, 1, true) == 1)
end

local function normalize(path)
  return (common.normalize_path(common.home_expand(path)):gsub("^//+", "/"))
end

---------------------------------------------------------------------------
-- Files
---------------------------------------------------------------------------

local Files = {}

-- Runs `args`; then done(ok, error text).
function Files.run(args, done)
  core.add_thread(function()
    local ok, proc = pcall(process.start, args, { stdin = process.REDIRECT_DISCARD,
                                                  stdout = process.REDIRECT_DISCARD })
    if not ok then return done(false, tostring(proc)) end
    local out = {}
    repeat
      local running = proc:running()
      table.insert(out, proc:read_stderr() or "")
      if running then coroutine.yield(0.05) end
    until not running
    done(proc:returncode() == 0, (table.concat(out):gsub("%s+$", "")))
  end)
end

-- A file or folder was moved: its open tabs follow. Other plugins add to
-- this (treeview_projects: bookmarks and projects follow too).
function Files.moved(from, to)
  for _, doc in ipairs(core.docs) do
    local p = doc.abs_filename
    if p and within(p, from) then
      p = to .. p:sub(#from + 1)
      doc:set_filename(core.normalize_to_project_dir(p), p)
    end
  end
end

-- Move (rename) or copy `src` to `dst` (absolute).
function Files.transfer(src, dst, move)
  local verb = move and "move" or "copy"
  local ok, path = pcall(normalize, dst)
  if not ok then return core.error("Invalid path: %s", dst) end
  dst = path
  local s, d = system.get_file_info(src), system.get_file_info(dst)
  local parent = common.dirname(dst) or PATHSEP
  if not s then return core.error("Cannot %s %s: it no longer exists", verb, src) end
  if dst == src and move then return end -- renamed to its own name: nothing to do
  if dst == src or (d and system.absolute_path(dst) == system.absolute_path(src)) then
    return core.error("Cannot %s %s onto itself", verb, src)
  end
  if s.type == "dir" and within(dst, src) then
    return core.error("Cannot %s a folder into itself: %s", verb, dst)
  end
  local p = system.get_file_info(parent)
  if not (p and p.type == "dir") then return core.error("No such folder: %s", parent) end

  local function go(replace)
    local args = move and { "mv", "-T", replace and "-f" or "-n", "--", src, dst }
      or { "cp", "-a", "-T", replace and "--remove-destination" or "-n", "--", src, dst }
    Files.run(args, function(success, err)
      success = success and system.get_file_info(dst) ~= nil
        and not (move and system.get_file_info(src))
      if not success then
        return core.error("Cannot %s %s to %s: %s", verb, src, dst, err ~= "" and err or "it exists")
      end
      if move then Files.moved(src, dst) end
      core.log("%s %s to %s", move and "Moved" or "Copied", common.home_encode(src), common.home_encode(dst))
      if not move and s.type == "file" then core.root_view:open_doc(core.open_doc(dst)) end
    end)
  end

  if not d then return go(false) end
  if d.type == "dir" or s.type == "dir" then
    return core.error("Cannot %s %s: %s already exists", verb, src, dst)
  end
  core.nag_view:show("Replace File",
    string.format("%s already exists. Replace it?", dst),
    { { text = "Replace", default_yes = true }, { text = "Cancel", default_no = true } },
    function(choice) if choice.text == "Replace" then go(true) end end)
end

-- Asks for a path; a relative one is taken from `base`.
function Files.ask(label, text, base, action)
  core.command_view:enter(label, {
    text = text,
    submit = function(input)
      if input == "" then return end
      input = common.home_expand(input)
      action(common.is_absolute_path(input) and input or base .. PATHSEP .. input)
    end,
    suggest = function(t) return common.path_suggest(t, base) end,
  })
end

function Files.rename(item)
  Files.ask("Rename", item.filename, item.dir_name,
    function(dst) Files.transfer(item.abs_filename, dst, true) end)
end

function Files.duplicate(item)
  local name = common.basename(item.abs_filename)
  local stem, ext = name:match("^(.+)(%.[^.]+)$")
  Files.ask("Duplicate As", item.type == "file" and stem and stem .. " copy" .. ext or name .. " copy",
    common.dirname(item.abs_filename), function(dst) Files.transfer(item.abs_filename, dst, false) end)
end

-- true if the home folder is `path` or inside it, by name or behind links
function Files.holds_home(path)
  local home = HOME and normalize(HOME)
  return home ~= nil and (within(home, path)
    or within(system.absolute_path(home) or home, system.absolute_path(path) or path))
end

function Files.delete(item)
  local path = item.abs_filename
  if Files.holds_home(path) then
    return core.error("Not deleting %s: your home folder is inside it", path)
  end
  local info = system.get_file_info(path) -- follows links; nil for a broken one
  local kind = info and info.type == "dir" and (info.symlink and "link to a folder" or "folder") or "file"
  core.nag_view:show("Delete", string.format("Delete this %s?\n%s", kind, path),
    { { text = "Yes", default_yes = true }, { text = "No", default_no = true } },
    function(choice)
      if choice.text ~= "Yes" then return end
      -- rm removes a link itself, never what it points to, and stays off
      -- drives mounted in the folder or at it
      Files.run({ "rm", "-rf", "--one-file-system", "--preserve-root=all", "--", path }, function(ok, err)
        if ok and not system.get_file_info(path) then core.log("Deleted %s", path)
        else core.error("Cannot delete %s: %s", path, err) end
      end)
    end)
end

function Files.terminal()
  for _, t in ipairs({ config.plugins.treeview_fileops.terminal, os.getenv("TERMINAL") }) do
    if t and t ~= "" then return t end
  end
  for _, name in ipairs({ "foot", "kitty", "alacritty", "wezterm", "ghostty", "konsole",
                          "gnome-terminal", "xfce4-terminal", "tilix", "xterm" }) do
    for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
      if system.get_file_info(dir .. "/" .. name) then return name end
    end
  end
end

---------------------------------------------------------------------------
-- Commands and the right-click menu
---------------------------------------------------------------------------

local function tree_item()
  local item = TreeView.hovered_item or TreeView.selected_item
  return core.active_view == TreeView and item ~= nil, item
end

-- not the top folders
local function inner_item()
  local ok, item = tree_item()
  return ok and item.depth > 0, item
end

command.add(tree_item, {
  -- a terminal in the folder (in the file's folder, for a file)
  ["treeview-fileops:open-in-terminal"] = function(item)
    local term = Files.terminal()
    if not term then return core.error("No terminal found: set one in Settings > Treeview File Operations") end
    local dir = item.type == "dir" and item.abs_filename or common.dirname(item.abs_filename)
    system.exec("cd '" .. dir:gsub("'", "'\\''") .. "' && exec " .. term)
  end,
  ["treeview-fileops:copy-name"] = function(item) system.set_clipboard(common.basename(item.abs_filename)) end,
  ["treeview-fileops:copy-path"] = function(item) system.set_clipboard(item.abs_filename) end,
})

command.add(inner_item, { ["treeview-fileops:duplicate"] = Files.duplicate })

-- Rename and Delete: the safe versions, never on a top folder of the tree
-- (the Delete key included).
for name, safe in pairs({ ["treeview:rename"] = Files.rename, ["treeview:delete"] = Files.delete }) do
  local cmd = command.map[name]
  if cmd then
    cmd.perform = function(item)
      if type(item) == "table" and item.depth and item.depth > 0 then safe(item) end
    end
  end
end

if TreeView.contextmenu then
  local menu = TreeView.contextmenu
  -- `items` in the group that starts with `first` (behind its first item),
  -- or as a group of their own right after it
  local function add_menu(first, predicate, items, own_group)
    for i, set in ipairs(menu.itemset) do
      if set.items[1] and set.items[1].command == first then
        if own_group then
          menu:register(predicate, items)
          table.insert(menu.itemset, i + 1, table.remove(menu.itemset))
        else
          menu:register(set.predicate, { set.items[1], items[1], table.unpack(set.items, 2) })
          menu.itemset[i] = table.remove(menu.itemset)
        end
        return
      end
    end
    menu:register(predicate, items)
  end
  add_menu("treeview:open-in-system", tree_item,
    { { text = "Open in Terminal", command = "treeview-fileops:open-in-terminal" } })
  add_menu("treeview:rename", inner_item, { { text = "Duplicate", command = "treeview-fileops:duplicate" } }, true)
  add_menu("treeview-fileops:duplicate", tree_item, {
    { text = "Copy Name", command = "treeview-fileops:copy-name" },
    { text = "Copy Path", command = "treeview-fileops:copy-path" },
  }, true)
end

return Files
