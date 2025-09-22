local timer, app

hs.hotkey.bind("cmd", "q", function()
	if timer and timer:running() then
		app:kill()
		timer:stop()
	else
		app = hs.application.frontmostApplication()
		hs.alert.show("⌘Q again to quit " .. app:name(), 0.8)
		timer = hs.timer.doAfter(1, function() end)
	end
end)

