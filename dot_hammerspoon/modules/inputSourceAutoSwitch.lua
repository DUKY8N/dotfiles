local appInputMethods = {
    ['Xcode'] = 'com.apple.keylayout.ABC',
    ['Visual Studio Code'] = 'com.apple.keylayout.ABC',
    ['Ghostty'] = 'com.apple.keylayout.ABC',
    ['RunJS'] = 'com.apple.keylayout.ABC',
    ['IntelliJ IDEA CE'] = 'com.apple.keylayout.ABC',
    ['Things'] = 'com.apple.inputmethod.Korean.2SetKorean',
    ['KakaoTalk'] = 'com.apple.inputmethod.Korean.2SetKorean',
}

hs.application.watcher
    .new(function(appName, eventType)
        if eventType == hs.application.watcher.activated and appInputMethods[appName] then
            hs.keycodes.currentSourceID(appInputMethods[appName])
        end
    end)
    :start()
