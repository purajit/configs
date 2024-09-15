local obj = {}

obj.listener = nil
obj.popClickListening = false
obj.tssScrollDown = { delay = 0.03, tick = -10, timer = nil }

function obj:startScroll()
  if self.tssScrollDown.timer == nil then
    self.tssScrollDown.timer = hs.timer.doEvery(self.tssScrollDown.delay, function()
      hs.eventtap.scrollWheel({0, self.tssScrollDown.tick}, {}, "pixel")
    end)
  end
end

function obj:stopScroll()
  if self.tssScrollDown.timer then
    self.tssScrollDown.timer:stop()
    self.tssScrollDown.timer = nil
  end
end

function obj:scrollHandler(evNum)
  if evNum == 1 then
    self:startScroll()
  elseif evNum == 2 then
    self:stopScroll()
  elseif evNum == 3 then
    hs.eventtap.scrollWheel({0, 250}, {}, "pixel")
  end
end

function obj:popClickToggle()
  if not self.popClickListening then
    self.listener:start()
    hs.alert.show("listening")
  else
    self.listener:stop()
    hs.alert.show("stopped listening")
  end
  self.popClickListening = not self.popClickListening
end

function obj:bindHotkey(mods, key)
  self.popClickListening = false
  self.listening = false
  self.listener = hs.noises.new(function(evNum)
    self:scrollHandler(evNum)
  end)
  hs.hotkey.bind(mods, key, function ()
    self:popClickToggle()
  end)
end

return obj
