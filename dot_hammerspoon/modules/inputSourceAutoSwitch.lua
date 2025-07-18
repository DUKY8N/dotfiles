-- 앱별 입력 소스 설정
local appInputMethods = {
	["Xcode"] = "com.apple.keylayout.ABC",
	["Visual Studio Code"] = "com.apple.keylayout.ABC",
	["Ghostty"] = "com.apple.keylayout.ABC",
	["RunJS"] = "com.apple.keylayout.ABC",
	["IntelliJ IDEA CE"] = "com.apple.keylayout.ABC",
	["Things"] = "com.apple.inputmethod.Korean.2SetKorean",
	["KakaoTalk"] = "com.apple.inputmethod.Korean.2SetKorean",
}

-- 앱 전환 감지 및 입력 소스 변경
function applicationWatcher(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		local targetInputMethod = appInputMethods[appName]
		if targetInputMethod then
			hs.keycodes.currentSourceID(targetInputMethod)
		end
	end
end

-- 와처 시작
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- 콘솔에서 인풋 소스 확인하는 코드
-- print(hs.keycodes.currentSourceID())
