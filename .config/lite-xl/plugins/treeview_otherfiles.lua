-- mod-version:3
--
-- treeview_otherfiles: Ctrl+H hides or shows the files you don't edit in
-- the treeview (images, PDFs, archives, ...: see `extensions`). The choice
-- is kept after a restart. Works with or without treeview_projects.

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"
local TreeView = require "plugins.treeview"

config.plugins.treeview_otherfiles = common.merge({
  extensions = { "png", "jpg", "jpeg", "gif", "bmp", "ico", "webp", "avif", "heic", "tif", "tiff",
    "psd", "xcf", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "odt", "ods", "odp",
    "zip", "tar", "gz", "tgz", "bz2", "xz", "zst", "7z", "rar", "jar", "deb", "rpm", "iso",
    "mp3", "wav", "flac", "ogg", "opus", "m4a", "mp4", "mkv", "avi", "mov", "webm",
    "ttf", "otf", "woff", "woff2", "o", "a", "so", "exe", "dll", "class", "pyc", "db", "sqlite" },
}, config.plugins.treeview_otherfiles)

local Other = { file = USERDIR .. PATHSEP .. "treeview_otherfiles_state.lua", hidden = false, set = {},
                -- the extension of a name ("a.png", not ".png" or "a.d/b")
                ext = "[^" .. PATHSEP .. "]%.([^." .. PATHSEP .. "]+)$" }

-- runs for every row on every redraw: the answer is kept on the row
function Other:hides(item)
  if not self.hidden or item.type ~= "file" then return false end
  local list = config.plugins.treeview_otherfiles.extensions
  if self.list ~= list then
    self.list, self.set = list, {}
    for _, ext in ipairs(list) do self.set[ext:lower()] = true end
  end
  if item.tf_list ~= list then
    local ext = item.filename:match(self.ext)
    item.tf_list, item.tf_other = list, ext ~= nil and self.set[ext:lower()] == true
  end
  return item.tf_other
end

function Other:save()
  local fp = io.open(self.file, "w")
  if not fp then return core.error("Cannot write %s", self.file) end
  fp:write("return ", common.serialize({ hidden = self.hidden }), "\n")
  fp:close()
end

function Other:toggle()
  self.hidden = not self.hidden
  self:save()
  -- rows that left the tree can't stay selected or hovered: the Delete key
  -- acts on the hovered row
  for _, k in ipairs({ "selected_item", "hovered_item" }) do
    if TreeView[k] and self:hides(TreeView[k]) then TreeView[k] = nil end
  end
  core.log("Other files: %s", self.hidden and "hidden" or "shown")
  core.redraw = true
end

do -- treeview_projects kept the choice before this plugin: taken over once
  local load = loadfile(Other.file)
  local ok, data = pcall(load or loadfile(USERDIR .. PATHSEP .. "treeview_projects_list.lua") or function() end)
  Other.hidden = ok and type(data) == "table" and (data.hidden or data.hide_other) == true
  if not load then Other:save() end
end

-- The rows without the hidden files, moved up to close the gaps.
local each_item = TreeView.each_item
function TreeView:each_item()
  local rows = each_item(self)
  if not Other.hidden then return rows end
  return coroutine.wrap(function()
    local gone, shift = 0, 0
    for item, x, y, w, h in rows do
      if Other:hides(item) then
        gone, shift = gone + 1, shift + h
      else
        coroutine.yield(item, x, y - shift, w, h)
      end
    end
    if self.count_lines then self.count_lines = self.count_lines - gone end
  end)
end

command.add(nil, { ["treeview-otherfiles:toggle"] = function() Other:toggle() end })
keymap.add { ["ctrl+h"] = "treeview-otherfiles:toggle" }
