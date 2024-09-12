local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ApplicationDropDown"
obj.version = "1.0"
obj.author = "purajit"
obj.homepage = ""
obj.license = ""

obj.application_bundle_id = nil
obj.application_window_title = nil

function obj:bindHotkey(mods, key)
  hs.hotkey.bind(mods, key, function ()
      -- grab at activation time to get running application
      local application = hs.application.get(self.application_bundle_id)
      -- launch if not yet open
      if application == nil then
        application = hs.application.launchOrFocusByBundleID(self.application_bundle_id)
        return
      elseif application:isFrontmost() then
        application:hide()
        return
      end
      local win = application:mainWindow()
      hs.spaces.moveWindowToSpace(win, hs.spaces.activeSpaceOnScreen())
      win:focus()
  end)

  -- Hide application when unfocused
  hs.window.filter.new{self.application_window_title}:subscribe(hs.window.filter.windowUnfocused, function(window, appName)
    hs.application.get(self.application_bundle_id):hide()
  end)
end

return obj
