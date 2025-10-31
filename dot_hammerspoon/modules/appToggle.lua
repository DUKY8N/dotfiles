local hyper = { "ctrl", "alt", "shift", "cmd" }

-- 앱 검색 경로
local APP_SEARCH_PATHS = {
	"/Applications/",
	"/System/Applications/",
}

-- 단축키 설정
local appList = {
	{ key = "'", app = "Calendar" },
	{ key = ",", app = "ChatGPT" },
	{ key = "0", app = "Raindrop.io" },
	{ key = "8", app = "Zen" },
	{ key = "9", app = "ChatGPT Atlas" },
	{ key = ";", app = "Things3" },
	{ key = "i", app = "iPhone Mirroring" },
	{ key = "j", app = "RunJS" },
	{ key = "k", app = "KakaoTalk" },
	{ key = "n", app = "Notes" },
	{ key = "o", app = "Obsidian" },
	{ key = "return", app = "Ghostty" },
}

-- Bundle ID 캐시
local bundleIDCache = {}

-- 앱 이름으로 Bundle ID 찾기
local function getBundleIDFromAppName(appName)
	for _, basePath in ipairs(APP_SEARCH_PATHS) do
		local appPath = basePath .. appName .. ".app"
		local appInfo = hs.application.infoForBundlePath(appPath)
		if appInfo and appInfo.CFBundleIdentifier then
			return appInfo.CFBundleIdentifier
		end
	end
	return nil
end

-- 앱 토글 함수
local function toggleApp(appName)
	local bundleID = bundleIDCache[appName]
	if not bundleID then
		return
	end

	local frontApp = hs.application.frontmostApplication()

	if frontApp and frontApp:bundleID() == bundleID then
		frontApp:hide()
	else
		hs.application.launchOrFocusByBundleID(bundleID)
	end
end

-- 초기화: Bundle ID 캐싱
for _, config in ipairs(appList) do
	local bundleID = getBundleIDFromAppName(config.app)
	if bundleID then
		bundleIDCache[config.app] = bundleID
	end
end

-- 단축키 바인딩
for _, config in ipairs(appList) do
	hs.hotkey.bind(hyper, config.key, function()
		toggleApp(config.app)
	end)
end
