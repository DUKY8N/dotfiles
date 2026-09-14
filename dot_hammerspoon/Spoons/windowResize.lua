-- Configuration
local config = {
    mod = { 'ctrl', 'alt' },
    resizeMod = { 'shift', 'ctrl', 'alt' },
    animationDuration = 0.125,
    moveStep = 100, -- 이동 거리 (포인트)
    resizeStep = 50, -- 중심 기준 한쪽 가장자리 이동량 (포인트)
    resizeFactors = { increase = 1.1, decrease = 0.9 },
    tolerance = 0.01, -- 레이아웃 판정 허용 오차 (화면 비율)
    cycleTimeout = 0.5, -- 연속 입력 판정 시간 (초)
}

local lastCycle -- {windowID, key, time, index}

-- Frame geometry
local function clamp(value, lower, upper)
    return math.min(upper, math.max(lower, value))
end

local function constrainFrameToScreen(frame, screen)
    local w = clamp(frame.w, 1, screen.w)
    local h = clamp(frame.h, 1, screen.h)
    return {
        x = clamp(frame.x, screen.x, screen.x + screen.w - w),
        y = clamp(frame.y, screen.y, screen.y + screen.h - h),
        w = w,
        h = h,
    }
end

local function calculateFrame(screen, layout)
    local x, y, w, h = table.unpack(layout)
    -- 인접한 레이아웃이 같은 경계를 공유하도록 끝 좌표에서 크기를 계산
    local left = math.floor(screen.w * x)
    local top = math.floor(screen.h * y)
    local right = math.floor(screen.w * (x + w))
    local bottom = math.floor(screen.h * (y + h))
    return {
        x = screen.x + left,
        y = screen.y + top,
        w = right - left,
        h = bottom - top,
    }
end

local function matchesFrame(frame, expected, screen)
    local horizontalTolerance = screen.w * config.tolerance
    local verticalTolerance = screen.h * config.tolerance
    return math.abs(frame.x - expected.x) < horizontalTolerance
        and math.abs(frame.y - expected.y) < verticalTolerance
        and math.abs(frame.w - expected.w) < horizontalTolerance
        and math.abs(frame.h - expected.h) < verticalTolerance
end

-- Window operations (the focused window is resolved once by bind)
local function resizeWindowCentered(win, frame, widthChange, heightChange)
    local screen = win:screen():frame()
    -- 크기를 먼저 제한하고 실제 변화량을 기준으로 중심점을 유지
    local w = clamp(frame.w + widthChange, 1, screen.w)
    local h = clamp(frame.h + heightChange, 1, screen.h)
    local newFrame = {
        x = frame.x + (frame.w - w) / 2,
        y = frame.y + (frame.h - h) / 2,
        w = w,
        h = h,
    }
    win:setFrame(constrainFrameToScreen(newFrame, screen), config.animationDuration)
end

local function cycleWindowSize(win, key, layouts)
    local now = hs.timer.absoluteTime() / 1e9
    local windowID = win:id()
    local screen = win:screen():frame()
    local currentIndex = 0

    if
        lastCycle
        and lastCycle.windowID == windowID
        and lastCycle.key == key
        and (now - lastCycle.time) <= config.cycleTimeout
    then
        currentIndex = lastCycle.index
    else
        local frame = win:frame()
        for i, layout in ipairs(layouts) do
            if matchesFrame(frame, calculateFrame(screen, layout), screen) then
                currentIndex = i
                break
            end
        end
    end

    local index = (currentIndex % #layouts) + 1
    win:setFrame(calculateFrame(screen, layouts[index]), config.animationDuration)
    lastCycle = { windowID = windowID, key = key, time = now, index = index }
end

-- Key bindings: focus lookup, cycle reset, and key repeat are handled here.
local function bind(key, fn, options)
    options = options or {}
    local function run()
        if not options.isCycle then
            lastCycle = nil
        end
        local win = hs.window.focusedWindow()
        if win then
            fn(win)
        end
    end
    hs.hotkey.bind(options.mod or config.mod, key, run, nil, options.repeatable and run or nil)
end

-- Layouts use {x, y, w, h} relative to the usable screen frame.
for key, layouts in pairs {
    h = {
        { 0, 0, 0.5, 1 },
        { 0, 0, 0.33, 1 },
        { 0, 0, 0.67, 1 },
    },
    l = {
        { 0.5, 0, 0.5, 1 },
        { 0.67, 0, 0.33, 1 },
        { 0.33, 0, 0.67, 1 },
    },
} do
    bind(key, function(win)
        cycleWindowSize(win, key, layouts)
    end, { isCycle = true })
end

for key, layout in pairs {
    -- Halves
    k = { 0, 0, 1, 0.5 },
    j = { 0, 0.5, 1, 0.5 },
    -- Quarters
    u = { 0, 0, 0.5, 0.5 },
    i = { 0.5, 0, 0.5, 0.5 },
    m = { 0, 0.5, 0.5, 0.5 },
    [','] = { 0.5, 0.5, 0.5, 0.5 },
    -- Thirds
    ['7'] = { 0, 0, 0.33, 1 },
    ['8'] = { 0.33, 0, 0.34, 1 },
    ['9'] = { 0.67, 0, 0.33, 1 },
    -- Centered
    ['\\'] = { 0.1, 0.1, 0.8, 0.8 },
    delete = { 0.2, 0.2, 0.6, 0.6 },
} do
    bind(key, function(win)
        win:setFrame(calculateFrame(win:screen():frame(), layout), config.animationDuration)
    end)
end

-- Movement
for key, direction in pairs { left = { -1, 0 }, right = { 1, 0 }, up = { 0, -1 }, down = { 0, 1 } } do
    bind(key, function(win)
        local frame = win:frame()
        local screen = win:screen():frame()
        frame.x = frame.x + direction[1] * config.moveStep
        frame.y = frame.y + direction[2] * config.moveStep
        win:setFrame(constrainFrameToScreen(frame, screen), config.animationDuration)
    end, { repeatable = true })
end

-- Centered resizing
for key, direction in pairs { h = { -1, 0 }, l = { 1, 0 }, k = { 0, -1 }, j = { 0, 1 } } do
    bind(key, function(win)
        resizeWindowCentered(
            win,
            win:frame(),
            direction[1] * config.resizeStep * 2,
            direction[2] * config.resizeStep * 2
        )
    end, { mod = config.resizeMod, repeatable = true })
end

for key, factor in pairs { ['='] = config.resizeFactors.increase, ['-'] = config.resizeFactors.decrease } do
    bind(key, function(win)
        local frame = win:frame()
        resizeWindowCentered(win, frame, frame.w * (factor - 1), frame.h * (factor - 1))
    end, { repeatable = true })
end

-- Screens
for key, direction in pairs { ['['] = 'previous', [']'] = 'next' } do
    bind(key, function(win)
        local screen = win:screen()
        local target = direction == 'next' and screen:next() or screen:previous()
        win:moveToScreen(target, false, true, config.animationDuration)
    end)
end

-- Controls
bind('return', function(win)
    win:maximize(config.animationDuration)
end)

bind('0', function(win)
    win:minimize()
end)

bind('space', function(win)
    local frame = win:frame()
    frame.center = win:screen():frame().center
    win:setFrame(frame, config.animationDuration)
end)

-- absoluteTime은 절전 시간을 제외하므로 복귀 시 순환 상태 초기화
-- require() 반환값으로 watcher를 유지해 GC로 중단되는 것을 방지
return hs.caffeinate.watcher
    .new(function(event)
        if event == hs.caffeinate.watcher.systemDidWake then
            lastCycle = nil
        end
    end)
    :start()
