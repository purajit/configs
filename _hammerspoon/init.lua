-- configure hammerspoon itself
hs.console.toolbar(nil)
hs.console.consoleFont { name = "Mononoki Nerd Font Propo", size = 14.0 }
hs.console.darkMode(true)
hs.console.outputBackgroundColor { white = 0.05 }
hs.console.windowBackgroundColor { white = 0.05 }
hs.console.consoleCommandColor { white = 1 }
hs.console.consoleResultColor(hs.drawing.color.asRGB { hex = "#8ec07c" })

-- set up hammerspoon automations
hs.loadSpoon("AlacrittyDropDown")
spoon.AlacrittyDropDown:bindHotkey({"control", "shift"}, "space")

hs.loadSpoon("WindowManager")
hs.window.animationDuration = 0
spoon.WindowManager:bindHotkeys({
  right = "right",
  left = "left",
  fullscreen = "f",
  up = "up",
  down = "down",
})
