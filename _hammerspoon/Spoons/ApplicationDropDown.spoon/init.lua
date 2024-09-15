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
obj.current_screen = nil
-- the last geometry used on each screen
obj.screen_configs = {}
obj.hide_when_unfocused = {}

function obj:bindHotkey(mods, key)
  hs.hotkey.bind(mods, key, function ()
      -- grab at activation time to get running application
      local application = hs.application.get(self.application_bundle_id)
      -- launch if not yet open; hide if already focused
      if application == nil then
        application = hs.application.launchOrFocusByBundleID(self.application_bundle_id)
        return
      elseif application:isFrontmost() then
        application:hide()
        return
      end

      local window = application:mainWindow()
      local main_screen = hs.mouse.getCurrentScreen()

      if main_screen ~= self.current_screen then
        local known_screen_config = self.screen_configs[main_screen:getUUID()]
        if known_screen_config then
          local window_frame = window:frame()
          local screen_frame = main_screen:frame()
          window_frame.y = screen_frame.y + known_screen_config.relative_y
          window_frame.x = screen_frame.x + known_screen_config.relative_x
          window_frame.w = known_screen_config.w
          window_frame.h = known_screen_config.h
          window:setFrame(window_frame)
        else
          window:maximize()
        end
      end

      -- TODO: investigate if both are needed, or just moving to space is enough
      hs.spaces.moveWindowToSpace(window, hs.spaces.activeSpaceOnScreen(main_screen))
      window:moveToScreen(main_screen, false, true)
      self.current_screen = main_screen;
      window:focus()
  end)

  -- save window position config when resized
  hs.window.filter.new{self.application_window_title}:subscribe(
    hs.window.filter.windowMoved, function(window, appName)
      local window_frame = window:frame()
      local screen_frame = window:screen():frame()
      -- when monitors are attached, screen geometries (x,y) are changed, so we need to use
      -- relative positioning to keep the windows in the same places when a monitor changes
      self.screen_configs[window:screen():getUUID()] = {
        ["w"] = window_frame.w,
        ["h"] = window_frame.h,
        ["relative_x"] = window_frame.x - screen_frame.x,
        ["relative_y"] = window_frame.y - screen_frame.y,
      }
  end)

  -- hide application when unfocused
  if self.hide_when_unfocused then
    hs.window.filter.new{self.application_window_title}:subscribe(
      hs.window.filter.windowUnfocused, function(window, appName)
        hs.application.get(self.application_bundle_id):hide()
    end)
  end
end

return obj
