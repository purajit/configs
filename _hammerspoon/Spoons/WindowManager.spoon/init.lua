local obj = {}
obj.__index = obj

-- Metadata
obj.name = "WindowManager"
obj.version = "1.0"
obj.author = "purajit"
obj.homepage = ""
obj.license = ""

-- number of cells to divide the screen into, in both directions
-- 6 is chosen as the default since it can divide into halfs and thirds
obj.grid = 6

--- the number of cells windows are allowed to occupy
--- this is a mapping of previousSize -> nextSize, and should be circular,
--- with an additional 0 element that shows the first size to use
obj.sizes = {[0]=3, [3]=2, [2]=4, [4]=3}

-- the modifier keys to trigger Window Manager
obj.window_manager_key = {"cmd", "alt"}

local direction_to_dimension = {
  ["left"] = "w",
  ["right"] = "w",
  ["up"] = "h",
  ["down"] = "h",
}

-- the "far" side is the side away from the (0,0) origin
-- the origin is the top left of the screen
-- for the horizontal x axis, "right" is the far side
-- for the vertical y axis, "down" is the far side
local direction_is_far_side = {
  ["left"] = false,
  ["right"] = true,
  ["up"] = false,
  ["down"] = true,
}

function obj:_next_step(direction)
  if not hs.window.focusedWindow() then
    return
  end

  local dim = direction_to_dimension[direction]
  local moving_to_far_side = direction_is_far_side[direction]
  local axis = dim == "w" and "x" or "y"

  local window = hs.window.frontmostWindow()
  local screen = window:screen()
  local cell = hs.grid.get(window, screen)

  local moving_from_near_to_far_side = moving_to_far_side and cell[axis] == 0
  local moving_from_far_to_near_side = (not moving_to_far_side) and cell[axis] + cell[dim] == self.grid
  local moving_to_opposite_side = moving_from_near_to_far_side or moving_from_far_to_near_side

  -- shape the window the default size,
  -- unless the current size already conforms to our grid AND
  -- * we're moving to the opposite size (keep the same size)
  -- * we're staying on the same side (go to the next step)
  local next_size = self.sizes[0]
  if self.sizes[cell[dim]] and moving_to_opposite_side then
    next_size = cell[dim]
  elseif self.sizes[cell[dim]] and not moving_to_opposite_side then
    next_size = self.sizes[cell[dim]]
  end

  cell[dim] = next_size
  cell[axis] = moving_to_far_side and (self.grid - next_size) or 0
  hs.grid.set(window, cell, screen)
end

function obj:_go_fullscreen()
  if not hs.window.focusedWindow() then
    return
  end
  hs.grid.maximizeWindow(hs.window.frontmostWindow())
end

--- Example:
--- spoon.WindowManager:bindHotkeys({
---   up = "up",
---   right = "right",
---   down = "down",
---   left = "left",
---   fullscreen = "f",
--- })
function obj:bindHotkeys(mapping)
  hs.inspect(mapping)
  print("Bind hotkeys for Window Manager")

  hs.hotkey.bind(self.window_manager_key, mapping.left, function ()
    self:_next_step("left")
  end)

  hs.hotkey.bind(self.window_manager_key, mapping.right, function ()
    self:_next_step("right")
  end)

  hs.hotkey.bind(self.window_manager_key, mapping.up, function ()
    self:_next_step("up")
  end)

  hs.hotkey.bind(self.window_manager_key, mapping.down, function ()
    self:_next_step("down")
  end)

  hs.hotkey.bind(self.window_manager_key, mapping.fullscreen, function ()
    self:_go_fullscreen()
  end)
end

function obj:init()
  print("Initializing Window Manager")
  hs.grid.setGrid(self.grid .. "x" .. obj.grid)
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

return obj
