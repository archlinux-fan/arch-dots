-- mod-version:3
--
-- treeview_projects: rearranges the treeview into three parts.
--
--   [/] Root, [~] Home   click to open the folder in place, click to close
--   ---------------
--   bookmarks            same; right click a folder > Add/Remove Bookmark,
--   ---------------      Rename Bookmark. Bookmarked folders show a star.
--   projects             same; right click a folder > Add/Remove Project,
--   ---------------      Rename Project. Project folders show a briefcase.
--   tab folders          the main folders of the open tabs (folders inside
--                        another listed folder are shown inside it)
--
-- Bookmarks are for browsing, like Root and Home: the tabs stay as they are
-- and their files are shown in the tab folders. A folder that is both is
-- listed once, as a project.
--
-- A file inside a project is shown in its deepest project instead of a tab
-- folder. Only the folder of the current tab opens automatically, down to
-- the file, which gets selected; it closes again on a tab switch unless the
-- user opened it. Closing a folder closes everything inside it.
--
-- While a project is open, the tab bar shows only the files inside it and
-- the tab folders are hidden; with all projects closed, the tab bar shows
-- only the files outside every project. Hidden tabs stay open. Opening or
-- closing a project in the tree switches to its last edited tab.
--
-- Goes with treeview_fileops (safe Rename and Delete, Duplicate, ...: open
-- tabs, bookmarks and projects follow a rename) and treeview_otherfiles
-- (Ctrl+H); each of them also works on its own.
--
-- The folder lite-xl was started in never changes, so autoreload, workspace
-- restore and relative paths keep working. Written for lite-xl 2.1.x on Linux.

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local style = require "core.style"
local Object = require "core.object"
local Doc = require "core.doc"
local DocView = require "core.docview"
local EmptyView = require "core.emptyview"
local RootView = require "core.rootview"
local TreeView = require "plugins.treeview"

if package.loaded["plugins.treeview_folders"] ~= nil then
  core.error("treeview_projects replaces treeview_folders: delete plugins/treeview_folders.lua")
  return
end

local function toggle_spec(label, path, description)
  return { label = label, path = path, description = description, type = "toggle", default = true }
end

config.plugins.treeview_projects = common.merge({
  enabled = true,
  project_tabs = true,
  select_current_file = true,
  show_root = true,
  show_home = true,
  config_spec = {
    name = "Treeview Projects",
    toggle_spec("Follow Open Files", "enabled", "List the folders of open tabs in the treeview."),
    toggle_spec("Only Project Tabs", "project_tabs",
      "While a project is open, show only its tabs and hide the tab folders; "
      .. "with all projects closed, show only the tabs outside every project."),
    toggle_spec("Select Current File", "select_current_file",
      "When you switch tabs, select the file in the tree and scroll to it."),
    toggle_spec("Show Root Entry", "show_root", "Entry at the top of the tree to browse /."),
    toggle_spec("Show Home Entry", "show_home", "Entry at the top of the tree to browse your home folder."),
  }
}, config.plugins.treeview_projects)

local function cfg() return config.plugins.treeview_projects end

---------------------------------------------------------------------------
-- Paths
---------------------------------------------------------------------------

local SEP = PATHSEP:byte()

-- true if `path` is strictly inside `dir`; makes no new strings, as it
-- runs for every tab a few times a second
local function is_inside(path, dir)
  local n = #dir
  if dir:byte(n) ~= SEP then n = n + 1 end
  return #path > n and path:byte(n) == SEP and path:find(dir, 1, true) == 1
end

local function within(path, dir) return path == dir or is_inside(path, dir) end

local function relative(path, dir)
  return path == dir and "" or path:sub(#dir + (dir:byte(#dir) == SEP and 1 or 2))
end

-- `path` with its `from` part replaced by `to` (a moved file or folder)
local function rebase(path, from, to)
  return within(path, from) and to .. path:sub(#from + 1) or path
end

-- With "/" open in the tree, the treeview names its items "//etc/..."; lite-xl
-- doesn't clean that up, so the same file could be opened twice.
local function fix_root(path)
  return PATHSEP == "/" and (path:gsub("^//+", "/")) or path
end

local function normalize(path)
  return fix_root(common.normalize_path(common.home_expand(path)))
end

local function is_dir(path)
  local info = system.get_file_info(path)
  return info ~= nil and info.type == "dir"
end

local function has_entry(dir, rel, kind)
  for _, f in ipairs(dir and dir.files or {}) do
    if f.filename == rel and f.type == kind then return true end
  end
  return false
end

local function doc_folder(doc)
  return doc.abs_filename and common.dirname(doc.abs_filename)
end

local function is_open_doc(doc)
  for _, d in ipairs(core.docs) do if d == doc then return true end end
  return false
end

---------------------------------------------------------------------------
-- Folders: a list of folders the user keeps (bookmarks, projects)
---------------------------------------------------------------------------

local Folders = Object:extend()
Folders.version = 0 -- of all the lists: what the tree shows is rebuilt when it changes

function Folders:new(name, glyph)
  self.name, self.glyph, self.kind = name, glyph, name:lower()
  self.list, self.set, self.names = {}, {}, {} -- names: path -> the name the user gave it
  self.command, self.rename_command = "treeview-projects:toggle-" .. self.kind, "treeview-projects:rename-" .. self.kind
end

function Folders:add(path)
  if path and not self.set[path] then
    table.insert(self.list, path)
    self.set[path], Folders.version = true, Folders.version + 1
  end
end

function Folders:remove(path)
  for i, p in ipairs(self.list) do
    if p == path then table.remove(self.list, i) break end
  end
  self.set[path], self.names[path], Folders.version = nil, nil, Folders.version + 1
end

-- The name shown in the tree: the one the user gave it, else the folder's.
function Folders:label(path) return self.names[path] or common.basename(path) end

-- An empty name, or the folder's own, goes back to the folder's name.
function Folders:rename(path, name)
  name = name:match("^%s*(.-)%s*$")
  self.names[path] = name ~= "" and name ~= common.basename(path) and name or nil
  Folders.version = Folders.version + 1
end

function Folders:load(list, names)
  for _, p in ipairs(type(list) == "table" and list or {}) do
    local valid, path = pcall(normalize, p ~= "" and p) -- skips anything but a valid path
    if valid then
      self:add(path)
      local name = type(names) == "table" and names[p]
      if type(name) == "string" then self.names[path] = name end
    end
  end
end

-- A folder was moved or renamed: the ones in it move along. true if any did.
function Folders:move(from, to)
  local old, names, changed = self.list, self.names, false
  self.list, self.set, self.names = {}, {}, {}
  for _, p in ipairs(old) do
    local new = rebase(p, from, to)
    changed = changed or new ~= p
    self:add(new)
    self.names[new] = self.names[new] or names[p]
  end
  return changed
end

local Bookmarks, Projects = Folders("Bookmark", "\u{e94c}"), Folders("Project", "\u{e85c}")

-- Both lists and the names given to their folders, in one file. Projects
-- are the list itself, as before bookmarks came back.
local Store = { file = USERDIR .. PATHSEP .. "treeview_projects_list.lua" }

function Store:save()
  local fp = io.open(self.file, "w")
  if not fp then return core.error("Cannot write %s", self.file) end
  local data = { bookmarks = Bookmarks.list, names = { bookmark = Bookmarks.names, project = Projects.names } }
  for i, p in ipairs(Projects.list) do data[i] = p end
  fp:write("return ", common.serialize(data), "\n")
  fp:close()
end

do
  local load = loadfile(Store.file)
  local old = not load and loadfile(USERDIR .. PATHSEP .. "treeview_folders_bookmarks.lua")
  local ok, data = pcall(load or old or function() end)
  data = ok and type(data) == "table" and data or {}
  local names = type(data.names) == "table" and data.names or {}
  Projects:load(data, names.project)
  Bookmarks:load(data.bookmarks, names.bookmark)
  if old then Store:save() end -- taken over from treeview_folders
end

---------------------------------------------------------------------------
-- Entries: Root and Home ("places"), bookmarks and projects, with their
-- tree rows
---------------------------------------------------------------------------

local Entries = { time = 0, places = {}, bookmarks = {}, projects = {}, kind = {}, project_set = {}, rows = {} }

-- Rebuilt when the settings or lists change, and every 2 seconds (folders
-- may appear or disappear); each_item calls this on every redraw. `kind`:
-- path -> "place", "bookmark" or "project"; `key` changes when the listed
-- folders do.
function Entries:get()
  local c, now = cfg(), system.get_time()
  if self.version == Folders.version and self.root == c.show_root
     and self.home == c.show_home and now - self.time < 2 then
    return self
  end
  self.version, self.root, self.home, self.time = Folders.version, c.show_root, c.show_home, now

  local rows, keys = {}, {}
  self.kind, self.places, self.project_set = {}, {}, {}
  local function entry(path, label, kind)
    local row = self.rows[path] or { entry = true, type = "dir", depth = 0, expanded = false,
                                     abs_filename = path, dir_name = path }
    row.name, row.filename, row.kind = label, label, kind
    rows[path], self.kind[path] = row, kind
    table.insert(keys, path)
    return { path = path, label = label, row = row }
  end

  -- the folders of a list that exist and aren't listed yet, by name; a name
  -- used twice also shows where it is
  local function section(folders)
    local paths, count, list = {}, {}, {}
    for _, p in ipairs(folders.list) do
      if not self.kind[p] and is_dir(p) then
        local name = folders:label(p)
        count[name] = (count[name] or 0) + 1
        table.insert(paths, p)
      end
    end
    for _, p in ipairs(paths) do
      local label = folders:label(p)
      if count[label] > 1 then
        label = label .. " (" .. common.home_encode(common.dirname(p) or PATHSEP) .. ")"
      end
      table.insert(list, entry(p, label, folders.kind))
    end
    table.sort(list, function(a, b) return a.label:lower() < b.label:lower() end)
    return list
  end

  local home = HOME and normalize(HOME)
  if c.show_root then table.insert(self.places, entry(PATHSEP, "[/] Root", "place")) end
  if c.show_home and home and is_dir(home) then table.insert(self.places, entry(home, "[~] Home", "place")) end
  self.projects, self.bookmarks = section(Projects), section(Bookmarks)
  for _, q in ipairs(self.projects) do self.project_set[q.path] = true end
  self.rows, self.key = rows, table.concat(keys, "\n")
  return self
end

-- The deepest project that contains `folder`, if any.
function Entries:owner(folder)
  local best
  if folder then
    for p in pairs(self:get().project_set) do
      if within(folder, p) and (not best or #p > #best) then best = p end
    end
  end
  return best
end

---------------------------------------------------------------------------
-- FolderView: one way a top folder is shown. A tab folder uses the
-- treeview's own cache; an entry has a cache of its own, so the same folder
-- can be open at its entry and as a tab folder independently, while lite-xl
-- reads and watches it only once.
---------------------------------------------------------------------------

local views = { tab = {}, entry = {} }

local FolderView = Object:extend()

function FolderView:new(name, is_entry)
  self.name, self.is_entry, self.label = name, is_entry, common.basename(name)
  self.cache = is_entry and { [name] = {} } or nil
  self.pinned = {} -- rel -> true: opened by the user
  self.auto = {}   -- rel -> true: opened for the current tab
end

function FolderView:dir() return core.project_dir_by_name(self.name) end

function FolderView:other()
  return (self.is_entry and views.tab or views.entry)[self.name]
end

-- The treeview's cached item for a folder ("" = the top folder) or file.
function FolderView:item(rel, kind)
  local dir = self:dir()
  if not dir then return nil end
  local real = TreeView.cache
  TreeView.cache = self.cache or real
  local ok, t = pcall(TreeView.get_cached, TreeView, dir,
    rel == "" and dir.item or { filename = rel, type = kind or "dir" }, dir.name)
  TreeView.cache = real
  if not ok then error(t, 0) end
  t.tf_view = self
  return t
end

function FolderView:is_open(rel)
  local c = (self.cache or TreeView.cache)[self.name]
  return c ~= nil and c[rel] ~= nil and c[rel].expanded == true
end

-- Open/close a folder like a click in the tree; false if the tree doesn't
-- list it (e.g. ignored folders).
function FolderView:set_open(rel, value)
  local dir = self:dir()
  if not dir or (rel ~= "" and not has_entry(dir, rel, "dir")) then return false end
  local item = self:item(rel)
  if (item.expanded == true) ~= value then
    item.expanded = value
    -- big folders only read open subfolders: keep reading while the other
    -- view of the same folder shows it
    local other = self:other()
    if rel ~= "" and dir.files_limit and (value or not (other and other:is_open(rel))) then
      core.update_project_subdir(dir, rel, value)
    end
  end
  return true
end

-- Close folders (a list of rel), deepest first.
function FolderView:close(list)
  table.sort(list, function(a, b) return #a > #b end)
  for _, rel in ipairs(list) do
    self:set_open(rel, false)
    self.pinned[rel], self.auto[rel] = nil, nil
  end
end

function FolderView:close_inside(rel)
  local prefix, open = rel == "" and "" or rel .. PATHSEP, {}
  for _, t in pairs((self.cache or TreeView.cache)[self.name] or {}) do
    if t.type == "dir" and t.depth > 0 and t.expanded and t.filename:sub(1, #prefix) == prefix then
      table.insert(open, t.filename)
    end
  end
  self:close(open)
end

-- Close the auto-opened folders, except `keep` (rel -> true).
function FolderView:close_auto(keep)
  local old = {}
  for rel in pairs(self.auto) do
    if not keep[rel] and not self.pinned[rel] then table.insert(old, rel) end
  end
  self:close(old)
  self.auto = keep
end

function FolderView:destroy()
  self:close_inside("")
  if not self.cache then TreeView.cache[self.name] = nil end
  -- its rows can't stay selected or hovered: the Delete key acts on the
  -- hovered row
  for _, k in ipairs({ "selected_item", "hovered_item" }) do
    if TreeView[k] and TreeView[k].tf_view == self then TreeView[k] = nil end
  end
end

local function entry_view(path)
  views.entry[path] = views.entry[path] or FolderView(path, true)
  return views.entry[path]
end

---------------------------------------------------------------------------
-- Tree: which folders the tree shows
---------------------------------------------------------------------------

local Tree = {
  browse = {},       -- path -> true: entries opened by the user
  auto_entry = nil,  -- project opened for the current tab
  tabs = {},         -- tab folders, sorted
  dismissed = {},    -- tab folders removed by the user (right click)
  last = setmetatable({}, { __mode = "v" }), -- .doc: tab followed last
  pending = nil,     -- tab change to follow on the next frame
  from_tree = false, -- true while the tree opens a file
}

function Tree:is_open(path)
  return self.browse[path] or self.auto_entry == path
end

-- path -> true for the open projects; nil when tabs aren't filtered
function Tree:open_projects()
  if not (cfg().enabled and cfg().project_tabs) then return nil end
  local open = {}
  for p in pairs(Entries:get().project_set) do
    if self:is_open(p) then open[p] = true end
  end
  return open
end

---------------------------------------------------------------------------
-- Tabs: the tab bar shows the files of the open projects, or with none
-- open, the files outside every project. New files and other views always
-- stay, and so does a split's current tab, unless a project was opened or
-- closed in the tree. Hidden tabs stay open: they are taken out of their
-- split and put back in their place later.
---------------------------------------------------------------------------

local Tabs = {
  hidden = {}, -- view -> { at = weak { node, prev, next }, index, last }
  edited = setmetatable({}, { __mode = "k" }), -- doc -> time of its last edit
}

local on_text_change = Doc.on_text_change
function Doc:on_text_change(...)
  Tabs.edited[self] = system.get_time()
  return on_text_change(self, ...)
end

-- the last edited of `list`, else the first
function Tabs:latest(list)
  local best, time = list[1], -1
  for _, v in ipairs(list) do
    local t = v.doc and self.edited[v.doc] or 0
    if t > time then best, time = v, t end
  end
  return best
end

-- the splits that hold tabs
function Tabs.leaves(node, out)
  if node.type ~= "leaf" then
    Tabs.leaves(node.a, out)
    Tabs.leaves(node.b, out)
  elseif not node.locked then
    table.insert(out, node)
  end
  return out
end

-- `open`: the open projects (see Tree:open_projects)
function Tabs.shows(view, node, open, also, switch)
  if open == nil or (view == node.active_view and not switch) or view == also
     or not (view:is(DocView) and view.doc.abs_filename) then
    return true
  end
  local folder = doc_folder(view.doc)
  if next(open) == nil then return Entries:owner(folder) == nil end
  for p in pairs(open) do
    if within(folder, p) then return true end
  end
  return false
end

-- Where a hidden tab goes back: before the tab that followed it, else after
-- the one before it, else at its old index.
function Tabs.place(tabs, h)
  if h.last then return #tabs + 1 end
  local after
  for i, v in ipairs(tabs) do
    if v == h.at.next then return i end
    if v == h.at.prev then after = i + 1 end
  end
  return after or math.min(h.index, #tabs + 1)
end

-- true if no tab has to be hidden or shown (the usual case)
function Tabs:settled(nodes, open, also, switch)
  for view, h in pairs(self.hidden) do
    local node, alive = h.at.node, false
    for _, n in ipairs(nodes) do alive = alive or n == node end
    if not alive or Tabs.shows(view, node, open, also, switch) then return false end
    for _, v in ipairs(node.views) do
      if v.doc == view.doc then return false end -- its file got a new tab: one tab per file
    end
  end
  for _, node in ipairs(nodes) do
    for _, view in ipairs(node.views) do
      if not Tabs.shows(view, node, open, also, switch) then return false end
    end
  end
  return true
end

-- `all`: show every tab (on quit, so the workspace plugin saves them);
-- `also`: a tab to show as well; `switch`: the current tab may go too.
function Tabs:update(all, also, switch)
  if core.root_view.dragged_node and not all then return end -- tab indexes in use
  local open = not all and Tree:open_projects() or nil
  local nodes = Tabs.leaves(core.root_view.root_node, {})
  if self:settled(nodes, open, also, switch) then return end
  local back = {}
  for _, node in ipairs(nodes) do back[node] = {} end
  for view, h in pairs(self.hidden) do
    local list = back[h.at.node]
    if not list then -- its split was closed
      list, h.last = back[core.root_view:get_primary_node()], true
    end
    h.view = view
    table.insert(list, h)
  end
  self.hidden = {}

  for _, node in ipairs(nodes) do
    -- all tabs in order: hidden ones back in their place (last first, so
    -- each finds the tab that followed it), once per file
    local tabs, has = {}, {}
    for _, v in ipairs(node.views) do
      table.insert(tabs, v)
      if v.doc then has[v.doc] = true end
    end
    table.sort(back[node], function(a, b) return a.index > b.index end)
    for _, h in ipairs(back[node]) do
      if not has[h.view.doc] then
        table.insert(tabs, Tabs.place(tabs, h), h.view)
        has[h.view.doc] = true
      end
    end
    local shown = {}
    for i, view in ipairs(tabs) do
      if Tabs.shows(view, node, open, also, switch) then
        table.insert(shown, view)
      else
        self.hidden[view] = { index = i, last = i == #tabs,
          at = setmetatable({ node = node, prev = tabs[i - 1], next = tabs[i + 1] }, { __mode = "v" }) }
      end
    end
    for i = #shown, 1, -1 do -- an empty split's placeholder goes when tabs come back
      if #shown > 1 and shown[i]:is(EmptyView) then table.remove(shown, i) end
    end
    if #shown == 0 then shown[1] = EmptyView() end
    local changed, kept = false, false
    for i = 1, math.max(#shown, #node.views) do changed = changed or shown[i] ~= node.views[i] end
    for _, v in ipairs(shown) do kept = kept or v == node.active_view end
    if changed then
      node.views, node.tab_offset = shown, 1
      if not kept then -- the current tab went: the last edited one takes over
        local active, best = core.active_view, self:latest(shown)
        if active == node.active_view or active == TreeView then node:set_active_view(best)
        else node.active_view = best end
      end
      core.redraw = true
    end
  end
end

-- Hidden tabs keep their files open (lite-xl closes files without a view).
local get_views_referencing_doc = core.get_views_referencing_doc
function core.get_views_referencing_doc(doc)
  local res = get_views_referencing_doc(doc)
  for view in pairs(Tabs.hidden) do
    if view.doc == doc then table.insert(res, view) end
  end
  return res
end

-- Opening a file whose tab is hidden brings that tab back in its place.
local root_open_doc = RootView.open_doc
function RootView:open_doc(doc)
  local node = self:get_active_node_default()
  for view, h in pairs(Tabs.hidden) do
    if view.doc == doc and h.at.node == node then Tabs:update(false, view) break end
  end
  return root_open_doc(self, doc)
end

---------------------------------------------------------------------------
-- Tree: keeping up with the open files
---------------------------------------------------------------------------

-- Drop the views of closed entries.
function Tree:prune()
  for path, view in pairs(views.entry) do
    if not self:is_open(path) then
      view:destroy()
      views.entry[path] = nil
    end
  end
end

function Tree:sync(switch)
  local E = Entries:get()
  -- folders of open files: in a project (owned), or main tab folders
  local owned, rest, seen, mains, main_set = {}, {}, {}, {}, {}
  for _, doc in ipairs(core.docs) do
    local d = doc_folder(doc)
    if d and not seen[d] then
      seen[d] = true
      local p = E:owner(d)
      if p then owned[p] = true else table.insert(rest, d) end
    end
  end
  for _, d in ipairs(rest) do
    local nested = false
    for _, other in ipairs(rest) do
      if is_inside(d, other) then nested = true break end
    end
    if not nested then table.insert(mains, d) main_set[d] = true end
  end
  table.sort(mains, function(a, b) return a:lower() < b:lower() end)

  for p in pairs(self.browse) do -- removed from its list, or Root/Home hidden
    if not E.kind[p] then self.browse[p] = nil end
  end
  if self.auto_entry and not owned[self.auto_entry] then self.auto_entry = nil end
  for d in pairs(self.dismissed) do
    if not main_set[d] then self.dismissed[d] = nil end
  end
  self.tabs = {}
  for _, d in ipairs(mains) do
    if not self.dismissed[d] then table.insert(self.tabs, d) end
  end

  -- drop views first (they stop big folders reading subfolders), then folders
  self:prune()
  local want = {}
  for _, d in ipairs(self.tabs) do want[d] = true end
  for name, view in pairs(views.tab) do
    if not want[name] then view:destroy() views.tab[name] = nil end
  end
  for p in pairs(self.browse) do want[p] = true end
  for p in pairs(owned) do want[p] = true end -- kept while closed: no rescans
  for i = #core.project_directories, 1, -1 do
    local name = core.project_directories[i].name
    if not want[name] then
      table.remove(core.project_directories, i)
      TreeView.cache[name] = nil
    end
  end
  for p in pairs(want) do
    if not core.project_dir_by_name(p) then core.add_project_directory(p) end
  end
  -- stable order for find-file and project search results
  table.sort(core.project_directories, function(a, b) return a.name < b.name end)
  for _, d in ipairs(self.tabs) do
    if not views.tab[d] then
      views.tab[d] = FolderView(d, false)
      views.tab[d]:set_open("", false) -- tab folders start closed
    end
  end
  Tabs:update(false, nil, switch)
  core.redraw = true
end

-- Open the current tab's folder down to the file; close what was opened
-- for the previous tab.
function Tree:reveal(doc, select_file)
  local folder = doc_folder(doc)
  local owner = Entries:owner(folder)
  self.auto_entry = owner and not self.browse[owner] and owner or nil
  self:prune()

  local view
  if owner then
    view = entry_view(owner)
  elseif folder then
    for _, name in ipairs(self.tabs) do
      if within(folder, name) then view = views.tab[name] break end
    end
  end

  local chain = {}
  if view and view:set_open("", true) then
    if not view.is_entry then chain[""] = true end
    local prefix = ""
    for part in relative(folder, view.name):gmatch("[^" .. PATHSEP .. "]+") do
      prefix = prefix == "" and part or prefix .. PATHSEP .. part
      if not view:set_open(prefix, true) then break end
      chain[prefix] = true
    end
  end
  for _, list in ipairs({ views.tab, views.entry }) do
    for _, v in pairs(list) do v:close_auto(v == view and chain or {}) end
  end
  Tabs:update()

  if select_file and view then
    local rel = relative(doc.abs_filename, view.name)
    if has_entry(view:dir(), rel, "file") then
      local target = view:item(rel, "file")
      for it, _, y in TreeView:each_item() do
        if it == target then TreeView:set_selection(it, y) break end
      end
    end
  end
  core.redraw = true
end

-- Several tab changes can come in one go (a file opened from the tree, the
-- workspace restored on start): the last one is followed, a frame later.
function Tree:follow(doc)
  if self.pending then
    self.pending.doc, self.pending.from_tree = doc, self.pending.from_tree or self.from_tree
    return
  end
  self.pending = { doc = doc, from_tree = self.from_tree }
  core.add_thread(function()
    local p = self.pending
    self.pending = nil
    -- returning to the same tab (from the tree, the command palette) is no
    -- tab change: folders the user closed stay closed
    if not cfg().enabled or p.doc == self.last.doc or not is_open_doc(p.doc) then return end
    local folder = doc_folder(p.doc)
    for d in pairs(self.dismissed) do
      if folder and within(folder, d) then self.dismissed[d] = nil end
    end
    self:sync()
    self.last.doc = p.doc
    self:reveal(p.doc, cfg().select_current_file and not p.from_tree)
  end)
end

local set_active_view = core.set_active_view
function core.set_active_view(view)
  set_active_view(view)
  if cfg().enabled and view.doc and view:is(DocView) then Tree:follow(view.doc) end
end

-- Files opened, closed or saved elsewhere, Root/Home switched in the
-- settings, project folders created or removed: checked a few times a
-- second, without new strings or tables while nothing changes.
core.add_thread(function()
  local files, count, key = setmetatable({}, { __mode = "k" }), -1, nil -- doc -> abs_filename
  while true do
    if cfg().enabled then
      local changed = #core.docs ~= count or Entries:get().key ~= key
      for _, doc in ipairs(core.docs) do changed = changed or files[doc] ~= doc.abs_filename end
      if changed then
        count, key = #core.docs, Entries.key
        for _, doc in ipairs(core.docs) do files[doc] = doc.abs_filename end
        Tree:sync()
      end
    end
    Tabs:update()
    coroutine.yield(0.25)
  end
end)

---------------------------------------------------------------------------
-- Tree: user actions
---------------------------------------------------------------------------

function Tree:open_entry(path)
  if not is_dir(path) then return core.error("Folder does not exist: %s", path) end
  self.browse[path] = true
  self:sync(Entries:get().project_set[path])
  entry_view(path):set_open("", true)
end

function Tree:close_entry(path)
  self.browse[path] = nil
  if self.auto_entry == path then self.auto_entry = nil end -- until its tab is selected again
  self:sync(Entries:get().project_set[path])
end

-- Add or remove a bookmark or project (right click).
function Tree:toggle(folders, path)
  local add = not folders.set[path]
  if add then folders:add(path) else folders:remove(path) end
  Store:save()
  core.log("%s %s: %s", folders.name, add and "added" or "removed", common.home_encode(path))
  self:sync()
  local doc = self.last.doc -- the current file may now belong elsewhere
  if doc and is_open_doc(doc) then self:reveal(doc, false) end
end

-- A file or folder was moved (treeview_fileops): bookmarks, projects and
-- open entries follow.
function Tree:moved(from, to)
  local moved_projects, moved_bookmarks = Projects:move(from, to), Bookmarks:move(from, to)
  if moved_projects or moved_bookmarks then Store:save() end
  local browse = {}
  for p in pairs(self.browse) do browse[rebase(p, from, to)] = true end
  self.browse = browse
  self.auto_entry = self.auto_entry and rebase(self.auto_entry, from, to)
  self:sync()
end

-- "Change Project Folder": start from scratch.
function Tree:reset()
  for _, list in pairs(views) do
    for _, view in pairs(list) do view:destroy() end
  end
  views.tab, views.entry = {}, {}
  self.browse, self.dismissed, self.tabs, self.auto_entry, self.last.doc = {}, {}, {}, nil, nil
end

-- "Remove directory" (right click) on a tab folder, or called by others.
function core.remove_project_directory(path)
  if views.tab[path] then
    Tree.dismissed[path] = true -- back when a tab inside it is selected
    Tree:sync()
  elseif Tree:is_open(path) then
    Tree:close_entry(path)
  else
    return false
  end
  return true
end

---------------------------------------------------------------------------
-- Treeview hooks
---------------------------------------------------------------------------

-- runs for every row on every redraw: check bytes, no new strings
local get_cached = TreeView.get_cached
function TreeView:get_cached(dir, item, dirname)
  local t = get_cached(self, dir, item, dirname)
  local p = t.abs_filename
  if p and p:byte(2) == 47 and p:byte(1) == 47 then t.abs_filename = fix_root(p) end
  return t
end

local open_doc = core.open_doc
function core.open_doc(filename, ...)
  return open_doc(type(filename) == "string" and fix_root(filename) or filename, ...)
end

local dividers = {} -- row -> true: line above it

local each_item = TreeView.each_item
function TreeView:each_item()
  if not cfg().enabled then return each_item(self) end
  return coroutine.wrap(function()
    local full = core.project_directories
    -- the treeview's "changed on disk" bookkeeping, for both caches
    for _, dir in ipairs(full) do
      if dir.is_dirty then
        local entry = views.entry[dir.name]
        for _, c in pairs({ self.cache[dir.name], entry and entry.cache[dir.name] }) do
          for _, t in pairs(c) do t.skip = nil end
        end
        dir.is_dirty = false
      end
    end

    dividers = {}
    local ox, oy = self:get_content_offset()
    local w, h = self.size.x, self:get_item_height()
    local y, lines, divide = oy + style.padding.y, 0, false

    local function emit(item, x, ih)
      if divide then dividers[item], divide = true, false end
      local iy = y
      lines, y = lines + 1, y + ih
      coroutine.yield(item, x, iy, w, ih)
    end

    -- Rows of one view, from the treeview's own iterator. What it changes
    -- while running is restored after every row, so stopping halfway (as
    -- mouse moves do) leaves nothing changed.
    local function emit_view(view, label)
      local dir = view:dir()
      if not dir then return end
      local it, list = each_item(self), { dir }
      while true do
        local cache, count = self.cache, self.count_lines
        core.project_directories, self.cache = list, view.cache or cache
        local ok, item, x, _, _, ih = pcall(it)
        core.project_directories, self.cache, self.count_lines = full, cache, count
        if not ok then error(item, 0) end
        if not item then return end
        item.tf_view = view
        if item.depth == 0 then item.name = label or view.label end
        emit(item, x, ih)
      end
    end

    local E, project_open = Entries:get(), false
    for _, section in ipairs({ E.places, E.bookmarks, E.projects }) do
      divide = divide or lines > 0
      for _, q in ipairs(section) do
        if Tree:is_open(q.path) then
          project_open = project_open or section == E.projects
          emit_view(entry_view(q.path), q.label)
        else
          emit(q.row, ox, h)
        end
      end
    end
    divide = divide or lines > 0
    if not (project_open and cfg().project_tabs) then -- tab folders: hidden while a project is open
      for _, name in ipairs(Tree.tabs) do
        if views.tab[name] then emit_view(views.tab[name]) end
      end
    end
    self.count_lines = lines
  end)
end

local toggle_expand = TreeView.toggle_expand
function TreeView:toggle_expand(toggle)
  local item = self.selected_item
  if not (cfg().enabled and item) then return toggle_expand(self, toggle) end
  local view, rel = item.tf_view, item.depth == 0 and "" or item.filename
  if item.entry or (view and view.is_entry and rel == "") then -- an entry: open in place, or close
    local path, hovered = item.dir_name, self.hovered_item == item
    if item.entry and toggle ~= false then Tree:open_entry(path)
    elseif not item.entry and toggle ~= true then Tree:close_entry(path) end
    -- its row is a new one now: still selected, and under the mouse if it
    -- was, so the next click needs no mouse move
    self.selected_item = views.entry[path] and views.entry[path]:item("") or Entries:get().rows[path]
    if hovered then self.hovered_item = self.selected_item end
    return
  end
  if not view or item.type ~= "dir" then return toggle_expand(self, toggle) end

  local was_open = item.expanded
  toggle_expand(self, toggle)
  if item.expanded then
    view.pinned[rel] = true
    -- opening something inside a project opened for the tab keeps it open
    if view.is_entry and Tree.auto_entry == view.name then Tree.browse[view.name] = true end
  elseif was_open then
    view.pinned[rel], view.auto[rel] = nil, nil
    -- the treeview stopped reading the subfolder; the other view may show it
    local dir, other = view:dir(), view:other()
    if rel ~= "" and dir and dir.files_limit and other and other:is_open(rel) then
      core.update_project_subdir(dir, rel, true)
    end
    view:close_inside(rel)
  end
end

---------------------------------------------------------------------------
-- Marker: the star and the briefcase, in the tree and in the menu. The
-- glyphs come from the devicons font if installed, else "*" and "P".
---------------------------------------------------------------------------

local Marker = { plain = { ["\u{e94c}"] = "*", ["\u{e85c}"] = "P" } }

function Marker:get(glyph)
  local size = style.font:get_size()
  if self.size ~= size then
    self.size, self.font, self.icons = size, style.font, false
    for _, path in ipairs({ "/fonts/devicons.ttf", "/fonts/font_devicons/devicons.ttf" }) do
      local ok, font = pcall(renderer.font.load, USERDIR .. path, size * 0.8)
      if ok and font then
        self.font, self.icons = font, true
        break
      end
    end
  end
  return self.font, self.icons and glyph or self.plain[glyph]
end

---------------------------------------------------------------------------
-- Commands and the right-click menu
---------------------------------------------------------------------------

local function is_place_row(item)
  if item.entry then return item.kind == "place" end
  return item.tf_view ~= nil and item.tf_view.is_entry and item.depth == 0
    and Entries:get().kind[item.dir_name] == "place"
end

-- the folder Add/Remove Bookmark/Project acts on
local function folder_target()
  local item = TreeView.hovered_item or TreeView.selected_item
  return cfg().enabled and core.active_view == TreeView and item ~= nil and item.type == "dir"
    and not is_place_row(item), item
end

command.add(nil, {
  ["treeview-projects:toggle"] = function()
    cfg().enabled = not cfg().enabled
    core.log("Treeview projects: %s", cfg().enabled and "on" or "off")
  end,
})

for _, folders in ipairs({ Bookmarks, Projects }) do
  -- Rename: the folder as it is listed (a folder that is both: the project)
  folders.can_rename = function()
    local ok, item = folder_target()
    return ok and Entries:get().kind[item.abs_filename] == folders.kind, item
  end
  command.add(folder_target, {
    [folders.command] = function(item) Tree:toggle(folders, item.abs_filename) end,
  })
  command.add(folders.can_rename, {
    [folders.rename_command] = function(item)
      local path = item.abs_filename
      core.command_view:enter("Rename " .. folders.name, {
        text = folders:label(path),
        submit = function(name)
          folders:rename(path, name)
          Store:save()
        end,
      })
    end,
  })
end

-- Add/Remove and Rename Bookmark, then Project, at the end of the menu,
-- each with its marker on the left.
if TreeView.contextmenu then
  local menu = TreeView.contextmenu
  local function item(text, cmd, glyph)
    local font, g = Marker:get(glyph) -- spaces in the text make room for it
    local room = math.ceil((font:get_width(g) + style.padding.x / 2) / style.font:get_width(" "))
    return { { text = string.rep(" ", room) .. text, command = cmd, icon = glyph } }
  end
  for _, folders in ipairs({ Bookmarks, Projects }) do
    for _, add in ipairs({ true, false }) do
      menu:register(function()
        local ok, it = folder_target()
        return ok and (not folders.set[it.abs_filename]) == add
      end, item((add and "Add " or "Remove ") .. folders.name, folders.command, folders.glyph))
    end
    menu:register(folders.can_rename, item("Rename " .. folders.name, folders.rename_command, folders.glyph))
  end
  local draw = menu.draw_context_menu
  function menu:draw_context_menu()
    draw(self)
    if not self.items then return end
    for _, it, x, y, _, h in self:each_item() do
      if it.icon then
        local font, glyph = Marker:get(it.icon)
        common.draw_text(font, style.text, glyph, nil, x + style.padding.x, y, 0, h)
      end
    end
  end
end

-- Closed entries aren't real folders, and the top folders can't be renamed
-- or deleted: these commands aren't there for them (the menu leaves them
-- out, the Delete key does nothing).
for name, rows in pairs({ ["treeview:rename"] = "top", ["treeview:delete"] = "top",
                          ["treeview:new-file"] = "closed", ["treeview:new-folder"] = "closed",
                          ["treeview:search-in-directory"] = "closed",
                          ["treeview:remove-project-directory"] = "closed" }) do
  local cmd = command.map[name]
  if cmd then
    local predicate = cmd.predicate
    cmd.predicate = function(...)
      local item = TreeView.hovered_item or TreeView.selected_item
      if item and (item.entry or (rows == "top" and item.depth == 0)) then return false end
      return predicate(...)
    end
  end
end

-- A file opened from the tree is already visible there: the tree's
-- selection stays.
if command.map["treeview:open"] then
  local open = command.map["treeview:open"].perform
  command.map["treeview:open"].perform = function(...)
    local row = TreeView.selected_item
    Tree.from_tree = row ~= nil and row.type == "file"
    local ok, err = pcall(open, ...)
    Tree.from_tree = false
    if not ok then error(err, 0) end
  end
end

---------------------------------------------------------------------------
-- Drawing: the markers and the lines between the parts
---------------------------------------------------------------------------

-- Always the same quiet color: markers, not buttons.
local draw_item_text = TreeView.draw_item_text
function TreeView:draw_item_text(item, active, hovered, x, y, w, h)
  draw_item_text(self, item, active, hovered, x, y, w, h)
  local path = item.abs_filename
  if cfg().enabled and item.type == "dir" and (Bookmarks.set[path] or Projects.set[path])
     and not is_place_row(item) then
    local text, font = self:get_item_text(item, active, hovered)
    x = x + font:get_width(text)
    for _, folders in ipairs({ Bookmarks, Projects }) do
      if folders.set[path] then
        local mfont, glyph = Marker:get(folders.glyph)
        x = common.draw_text(mfont, style.dim, glyph, nil, x + style.padding.x / 2, y, 0, h)
      end
    end
  end
end

local draw_item = TreeView.draw_item
function TreeView:draw_item(item, active, hovered, x, y, w, h)
  draw_item(self, item, active, hovered, x, y, w, h)
  if dividers[item] then
    renderer.draw_rect(x, y, w, math.max(1, style.divider_size or 1), style.dim)
  end
end

---------------------------------------------------------------------------
-- Start and quit
---------------------------------------------------------------------------

-- Once lite-xl runs, all plugins are loaded: treeview_fileops can be hooked,
-- and the quit hook goes before the workspace plugin's own, so that saves
-- every tab, hidden ones too, and not the tree's folders (they would be
-- rescanned on the next start; they are rebuilt anyway).
core.add_thread(function()
  local Files = package.loaded["plugins.treeview_fileops"]
  if type(Files) == "table" then -- a rename there: bookmarks and projects follow
    local moved = Files.moved
    function Files.moved(from, to)
      moved(from, to)
      Tree:moved(from, to)
    end
  end
  local on_quit_project = core.on_quit_project
  function core.on_quit_project(...)
    Tabs:update(true)
    if cfg().enabled then core.project_directories = {} end
    return on_quit_project(...)
  end
end)

local on_enter_project = core.on_enter_project
function core.on_enter_project(...)
  Tree:reset()
  return on_enter_project(...)
end
