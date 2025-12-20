local hyper = { 'ctrl', 'alt', 'shift', 'cmd' }

-- 앱 검색 경로
local APP_SEARCH_PATHS = {
    '/Applications/',
    '/System/Applications/',
}

-- 단축키 설정
local appList = {
    { key = "'", app = 'Calendar' },
    { key = ',', app = 'ChatGPT' },
    { key = '0', app = 'Zen' },
    { key = '8', app = 'Raindrop.io' },
    { key = '9', app = 'ChatGPT Atlas' },
    { key = ';', app = 'Things3' },
    { key = 'i', app = 'iPhone Mirroring' },
    { key = 'j', app = 'RunJS' },
    { key = 'k', app = 'KakaoTalk' },
    { key = 'l', app = 'Logseq' },
    { key = 'n', app = 'Notes' },
    { key = 'o', app = 'Obsidian' },
    { key = 'return', app = 'Ghostty' },
    { key = 'space', app = 'Zed' },
}

-- Bundle ID 캐시
local bundleIDCache = {}

-- 앱 이름으로 Bundle ID 찾기
local function getBundleIDFromAppName(appName)
    local cached = bundleIDCache[appName]
    if cached ~= nil then
        return cached or nil
    end

    for _, basePath in ipairs(APP_SEARCH_PATHS) do
        local appPath = basePath .. appName .. '.app'
        local appInfo = hs.application.infoForBundlePath(appPath)
        if appInfo and appInfo.CFBundleIdentifier then
            bundleIDCache[appName] = appInfo.CFBundleIdentifier
            return appInfo.CFBundleIdentifier
        end
    end

    bundleIDCache[appName] = false
    return nil
end

-- 앱 토글 함수
local function toggleApp(appName)
    local bundleID = getBundleIDFromAppName(appName)
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

-- 단축키 바인딩
for _, config in ipairs(appList) do
    hs.hotkey.bind(hyper, config.key, function()
        toggleApp(config.app)
    end)
end
