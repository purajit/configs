-- Actions
function scrollDown(spoonObj)
  hs.eventtap.scrollWheel({0, spoonObj.scroll_tick}, {}, "pixel")
end

function moveRight(spoonObj)
  hs.eventtap.keyStroke({}, "right")
end

function scrollUp(spoonObj)
  hs.eventtap.scrollWheel({0, 250}, {}, "pixel")
end

function pressF(spoonObj)
  hs.eventtap.keyStroke({}, "f")
end

-- Utils
function string:endswith(ending)
    return ending == "" or self:sub(-#ending) == ending
end

-- Actual Spoon
local obj = {}

obj.scroll_tick = -10
obj.scroll_delay = 0.03
obj.default_actions = {
  ["tss"] = "scrollDown",
  ["pop"] = "scrollUp",
}
obj.actions = {}

function obj:startTss(action)
  if self.tss_timer == nil then
    self.tss_timer = hs.timer.doEvery(self.scroll_delay, function()
      action(self)
    end)
  end
end

function obj:stopTss()
  if self.tss_timer then
    self.tss_timer:stop()
    self.tss_timer = nil
  end
end

function obj:scrollHandler(evNum)
  local action_to_use = self.default_actions
  if hs.window.focusedWindow():title():endswith("- YouTube") then
    action_to_use = self.actions["YouTube"] or action_to_use
  end

  if evNum == 1 and action_to_use["tss"] then
    self:startTss(self.actions_to_functions[action_to_use["tss"]])
  elseif evNum == 2 then
    self:stopTss()
  elseif evNum == 3 and action_to_use["pop"] then
    self.actions_to_functions[action_to_use["pop"]](self)
  end
end

function obj:popClickToggle()
  if not self.pop_click_listening then
    self.listener:start()
    hs.alert.show("listening")
  else
    self.listener:stop()
    hs.alert.show("stopped listening")
  end
  self.pop_click_listening = not self.pop_click_listening
end

function obj:bindHotkey(mods, key)
  self.pop_click_listening = false
  self.listening = false
  self.tss_timer = nil
  self.actions_to_functions = {
    ["scrollDown"] = scrollDown,
    ["scrollUp"] = scrollUp,
    ["moveRight"] = moveRight,
    ["pressF"] = pressF,
  }

  self.listener = hs.noises.new(function(evNum)
    self:scrollHandler(evNum)
  end)
  hs.hotkey.bind(mods, key, function ()
    self:popClickToggle()
  end)
end

return obj
