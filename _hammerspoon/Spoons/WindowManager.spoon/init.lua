--- Inspired by https://github.com/miromannino/miro-windows-manager

local obj={}
obj.__index = obj

-- Metadata
obj.name = "WindowManager"
obj.version = "1.0"
obj.author = "purajit"
obj.homepage = ""
obj.license = ""

-- number of cells to divide the screen into, in both directions
-- 6 is chosen as the default since it can divide as halfs and thirds
obj.grid = 6

--- the number of cells windows are allowed to occupy
--- this is a mapping of previousSize -> nextSize, and should be circular,
--- with an additional 0 element that shows the first size to use
obj.sizes = {[0]=3, [3]=2, [2]=4, [4]=3}

-- the modifier keys to trigger Window Manager
obj.windowManagerKey = {"cmd", "alt"}

function obj:_nextStep(dim, movingToFarSide, cb)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()
    local cell = hs.grid.get(win, screen)

    local axis = dim == 'w' and 'x' or 'y'
    local oppositeAxis = axis == 'x' and 'y' or 'x'
    local oppositeDim = dim == 'w' and 'h' or 'w'

    local movingFromNearToFarSide = movingToFarSide and cell[axis] == 0
    local movingFromFarToNearSide = (not movingToFarSide) and cell[axis] + cell[dim] == self.grid
    local movingToOppositeSide = movingFromNearToFarSide or movingFromFarToNearSide

    -- use the starting size if we're moving to the opposite side or haven't adjusted it before
    local nextSize = movingToOppositeSide and self.sizes[0] or (self.sizes[cell[dim]] or self.sizes[0])

    cell[dim] = nextSize
    cell[axis] = movingToFarSide and (self.grid - nextSize) / 1.0 or 0
    hs.grid.set(win, cell, screen)
  end
end

function obj:_goFullscreen()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    hs.grid.maximizeWindow(win)
  end
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

  hs.hotkey.bind(self.windowManagerKey, mapping.left, function ()
    self:_nextStep('w', false)
  end)

  hs.hotkey.bind(self.windowManagerKey, mapping.right, function ()
    self:_nextStep('w', true)
  end)

  hs.hotkey.bind(self.windowManagerKey, mapping.up, function ()
    self:_nextStep('h', false)
  end)

  hs.hotkey.bind(self.windowManagerKey, mapping.down, function ()
    self:_nextStep('h', true)
  end)

  hs.hotkey.bind(self.windowManagerKey, mapping.fullscreen, function ()
    self:_goFullscreen()
  end)

end

function obj:init()
  print("Initializing Window Manager")
  hs.grid.setGrid(self.grid .. 'x' .. obj.grid)
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

return obj
