local function triggerSystemSleep()
    hs.caffeinate.systemSleep()
end

-- Bind the hotkey: ctrl+alt+shift+cmd+backspace (keycode 51)
hs.hotkey.bind({ 'ctrl', 'alt', 'shift', 'cmd' }, 51, triggerSystemSleep)
