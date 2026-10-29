-- mod-version:3
--
-- reopen_tab: Ctrl+Shift+T reopens the last closed tab in its split and tab
-- position, with its cursor and scroll position. Repeat to go further back;
-- tabs closed with "Close All" come back too. Only files on disk are kept.
-- Written for lite-xl 2.1.x.

local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local Object = require "core.object"
local Node = require "core.node"
local DocView = require "core.docview"
local EmptyView = require "core.emptyview"

local ClosedTab = Object:extend()

function ClosedTab:new(view, node)
  self.path = view.doc.abs_filename
  self.selection = { view.doc:get_selection() }
  self.scroll = { x = view.scroll.to.x, y = view.scroll.to.y }
  -- weak: a split that was closed still lists its last tab; it must not keep
  -- that tab's document in memory
  self.split = setmetatable({ node }, { __mode = "v" })
  for i, v in ipairs(node.views) do
    if v == view then self.index = i break end
  end
end

-- The split it was in, if still there; else the current one.
function ClosedTab:node()
  local node = self.split[1]
  if node and node.type == "leaf" and not node.locked and node.views[1]
     and core.root_view.root_node:get_node_for_view(node.views[1]) == node then
    return node
  end
  return core.root_view:get_active_node_default()
end

function ClosedTab:restore()
  local node = self:node()
  local count = node.views[1]:is(EmptyView) and 0 or #node.views
  local view = DocView(core.open_doc(self.path))
  node:add_view(view, math.min(self.index or math.huge, count + 1))
  -- cursor and scroll the way the workspace plugin restores them, so the
  -- view doesn't jump to the cursor on its next update
  view.doc:set_selection(table.unpack(self.selection))
  view.last_line1, view.last_col1, view.last_line2, view.last_col2 = view.doc:get_selection()
  view.scroll.x, view.scroll.to.x = self.scroll.x, self.scroll.x
  view.scroll.y, view.scroll.to.y = self.scroll.y, self.scroll.y
end

-- Closed tabs, newest last; one entry per file.
local history = { limit = 50 }

function history:push(view, node)
  node = node or core.root_view.root_node:get_node_for_view(view)
  if not (node and view:is(DocView) and view.doc.abs_filename) then return end
  for i = #self, 1, -1 do
    if self[i].path == view.doc.abs_filename then table.remove(self, i) end
  end
  table.insert(self, ClosedTab(view, node))
  if #self > self.limit then table.remove(self, 1) end
end

function history:reopen()
  while #self > 0 do
    local tab = table.remove(self)
    local info = system.get_file_info(tab.path)
    if info and info.type == "file" then
      for _, view in ipairs(core.root_view.root_node:get_children()) do
        if view.doc and view.doc.abs_filename == tab.path then -- opened again meanwhile
          return core.root_view.root_node:get_node_for_view(view):set_active_view(view)
        end
      end
      return tab:restore()
    end
  end
  core.log("No closed tab to reopen")
end

-- Ctrl+W, middle click, the x: recorded only when the tab really closes,
-- not when "Unsaved Changes" is cancelled.
local try_close = DocView.try_close
function DocView:try_close(do_close)
  return try_close(self, function()
    history:push(self)
    do_close()
  end)
end

-- "Close All", "Close All Others": recorded right to left, so the tabs come
-- back left to right, each at its own position.
local close_all_docviews = Node.close_all_docviews
function Node:close_all_docviews(keep_active)
  if self.type == "leaf" then
    for i = #self.views, 1, -1 do
      local view = self.views[i]
      if view.context == "session" and (not keep_active or view ~= self.active_view) then
        history:push(view, self)
      end
    end
  end
  return close_all_docviews(self, keep_active)
end

command.add(nil, { ["reopen-tab:reopen"] = function() history:reopen() end })
keymap.add { ["ctrl+shift+t"] = "reopen-tab:reopen" }
