local fcitx = require("fcitx")

local EN_IME = "keyboard-us"

fcitx.watchEvent(fcitx.EventType.KeyEvent, "onKey")

function onKey(sym, state, release)
  if release then return false end

  -- Esc(65307)
  if sym == 65307 then
    fcitx.setCurrentInputMethod(EN_IME)
  end

  return false
end

