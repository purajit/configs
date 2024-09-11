-- Based on https://gist.github.com/truebit/31396bb2f48c75285d724c9e9e037bcd

local obj={}
obj.__index = obj

-- Metadata
obj.name = "AlacrittyDropDown"
obj.version = "1.0"
obj.author = "purajit"
obj.homepage = "https://gist.github.com/truebit/31396bb2f48c75285d724c9e9e037bcd"
obj.license = ""

obj.alacritty_bundle_id = "org.alacritty"

-- move Alacritty to active space
function obj:_moveWindow(alacritty, activeSpace, activeScreen)
  local win = nil
  while win == nil do
    win = alacritty:mainWindow()
  end
  winFrame = win:frame()
  scrFrame = activeScreen:fullFrame()
  winFrame.w = scrFrame.w
  winFrame.y = scrFrame.y
  winFrame.x = scrFrame.x
  win:setFrame(winFrame, 0)
  hs.spaces.moveWindowToSpace(win, activeSpace)
  win:focus()
end

function obj:bindHotkey(mods, key)

  hs.hotkey.bind(mods, key, function ()
      -- has to be grabbed at runtime to get the running application
      local alacritty = hs.application.get(self.alacritty_bundle_id)
      if alacritty == nil then
        print("Launch it")
        alacritty = hs.application.launchOrFocusByBundleID(self.alacritty_bundle_id)
        return
      end
      if alacritty:isFrontmost() then
        alacritty:hide()
        return
      end
      local activeSpace = hs.spaces.activeSpaceOnScreen()
      local activeScreen = hs.mouse.getCurrentScreen()
      self:_moveWindow(alacritty, activeSpace, activeScreen)
  end)
end

return obj
