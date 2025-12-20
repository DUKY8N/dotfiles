--------------------------
-- Configuration & State
--------------------------
local config = {
    mod = { 'ctrl', 'alt' },
    resizeMod = { 'shift', 'ctrl', 'alt' }, -- 크기 조절용 수식 키
    animationDuration = 0.125,
    moveStep = 100,                         -- 픽셀 단위 이동 거리
    resizeStep = 50,                        -- 픽셀 단위 크기 조절
    resizeFactors = {
        increase = 1.1,                     -- 10% 증가
        decrease = 0.9,                     -- 10% 감소
    },
    tolerance = 0.01,                       -- 픽셀 완벽 정렬을 위한 허용 오차
    cycleTimeout = 0.5,                     -- 빠른 재클릭 감지 시간 (초)
}

local lastCycle = { time = 0 } -- {key, time, index}

--------------------------
-- Base Utility Functions
--------------------------
local function isWithinTolerance(value1, value2)
    return math.abs(value1 - value2) < config.tolerance
end

local function withFocusedWindow(fn)
    local win = hs.window.focusedWindow()
    if win then
        return fn(win)
    end
end

-- 반복 키 바인딩을 위한 헬퍼 함수
local function bindRepeatKey(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
end

--------------------------
-- Screen Utility Functions
--------------------------
local function constrainFrameToScreen(frame, screen)
    local w = math.min(screen.w, frame.w)
    local h = math.min(screen.h, frame.h)
    return {
        w = w,
        h = h,
        x = math.max(screen.x, math.min(screen.x + screen.w - w, frame.x)),
        y = math.max(screen.y, math.min(screen.y + screen.h - h, frame.y)),
    }
end

--------------------------
-- Core Window Functions
--------------------------

-- 프레임 계산을 위한 헬퍼 함수
local function calculateFrame(screen, x, y, w, h)
    local frame = {
        x = screen.x + math.floor(screen.w * x),
        y = screen.y + math.floor(screen.h * y),
        w = math.floor(screen.w * w),
        h = math.floor(screen.h * h),
    }

    -- 화면 끝까지 차지해야 할 때 픽셀 완벽 정렬
    if isWithinTolerance(x + w, 1.0) then
        frame.w = screen.x + screen.w - frame.x
    end

    if isWithinTolerance(y + h, 1.0) then
        frame.h = screen.y + screen.h - frame.y
    end

    return frame
end

local function setWindowPosition(x, y, w, h)
    withFocusedWindow(function(win)
        local screen = win:screen():frame()
        local newFrame = calculateFrame(screen, x, y, w, h)
        win:setFrame(newFrame, config.animationDuration)
    end)
end

local function moveWindow(dx, dy)
    withFocusedWindow(function(win)
        local frame = win:frame()
        local screen = win:screen():frame()

        local newFrame = {
            x = frame.x + dx * config.moveStep,
            y = frame.y + dy * config.moveStep,
            w = frame.w,
            h = frame.h,
        }

        win:setFrame(constrainFrameToScreen(newFrame, screen), config.animationDuration)
    end)
end

local function moveToScreen(direction)
    withFocusedWindow(function(win)
        local targetScreen = direction == 'next' and win:screen():next() or win:screen():previous()
        win:moveToScreen(targetScreen, false, true, config.animationDuration)
    end)
end

-- 중심점 기준 크기 조절 공통 함수
local function resizeWindowCentered(widthChange, heightChange)
    withFocusedWindow(function(win)
        local frame = win:frame()
        local screen = win:screen():frame()
        local newFrame = {
            w = frame.w + widthChange,
            h = frame.h + heightChange,
            x = frame.x - widthChange / 2,
            y = frame.y - heightChange / 2,
        }
        win:setFrame(constrainFrameToScreen(newFrame, screen), config.animationDuration)
    end)
end

local function resizeByDirection(dw, dh)
    resizeWindowCentered(dw * config.resizeStep * 2, dh * config.resizeStep * 2)
end

local function resizeByPercent(factor)
    withFocusedWindow(function(win)
        local frame = win:frame()
        resizeWindowCentered(frame.w * (factor - 1), frame.h * (factor - 1))
    end)
end

local function cycleWindowSize(key, layouts)
    withFocusedWindow(function(win)
        local now = hs.timer.secondsSinceEpoch()
        local layoutCount = #layouts
        local layoutIndex

        -- 빠른 재클릭: 이전 인덱스에서 계속
        if lastCycle.key == key and (now - lastCycle.time) <= config.cycleTimeout then
            layoutIndex = (lastCycle.index % layoutCount) + 1
        else
            -- 현재 창 상태 감지
            local frame = win:frame()
            local screen = win:screen():frame()
            local normalizedX = (frame.x - screen.x) / screen.w
            local normalizedWidth = frame.w / screen.w

            layoutIndex = 1 -- 기본값
            for i, layout in ipairs(layouts) do
                if isWithinTolerance(normalizedX, layout.x) and isWithinTolerance(normalizedWidth, layout.w) then
                    layoutIndex = (i % layoutCount) + 1
                    break
                end
            end
        end

        local layout = layouts[layoutIndex]
        setWindowPosition(layout.x, layout.y, layout.w, layout.h)

        lastCycle.key = key
        lastCycle.time = now
        lastCycle.index = layoutIndex
    end)
end

-- Control actions table
local controlActions = {
    maximize = function(win)
        win:maximize(config.animationDuration)
    end,

    minimize = function(win)
        win:minimize()
    end,

    center = function(win)
        local frame = win:frame()
        local screen = win:screen():frame()
        frame.x = screen.x + (screen.w - frame.w) / 2
        frame.y = screen.y + (screen.h - frame.h) / 2
        win:setFrame(frame, config.animationDuration)
    end,
}

--------------------------
-- Factory Functions for Operations
--------------------------
local function cycle(key, layouts)
    local layoutsWithDesc = {}
    for _, layout in ipairs(layouts) do
        table.insert(layoutsWithDesc, {
            x = layout[1],
            y = layout[2],
            w = layout[3],
            h = layout[4],
        })
    end
    return {
        key = key,
        mod = config.mod,
        run = function()
            cycleWindowSize(key, layoutsWithDesc)
        end,
    }
end

local function layout(key, x, y, w, h)
    return {
        key = key,
        mod = config.mod,
        run = function()
            setWindowPosition(x, y, w, h)
        end,
    }
end

local function move(key, dx, dy)
    return {
        key = key,
        mod = config.mod,
        repeatable = true,
        run = function()
            moveWindow(dx, dy)
        end,
    }
end

local function resize(key, dw, dh)
    return {
        key = key,
        mod = config.resizeMod,
        repeatable = true,
        run = function()
            resizeByDirection(dw, dh)
        end,
    }
end

local function scale(key, factor)
    return {
        key = key,
        mod = config.mod,
        repeatable = true,
        run = function()
            resizeByPercent(factor)
        end,
    }
end

local function screen(key, direction)
    return {
        key = key,
        mod = config.mod,
        run = function()
            moveToScreen(direction)
        end,
    }
end

local function control(key, action)
    return {
        key = key,
        mod = config.mod,
        run = function()
            local handler = controlActions[action]
            if handler then
                withFocusedWindow(handler)
            end
        end,
    }
end

--------------------------
-- Unified Window Operations Table
--------------------------
local windowOps = {
    cycle('h', {
        { 0, 0, 0.5,  1 },
        { 0, 0, 0.33, 1 },
        { 0, 0, 0.67, 1 },
    }),
    cycle('l', {
        { 0.5,  0, 0.5,  1 },
        { 0.67, 0, 0.33, 1 },
        { 0.33, 0, 0.67, 1 },
    }),

    -- Halves
    layout('k', 0, 0, 1, 0.5),
    layout('j', 0, 0.5, 1, 0.5),

    -- Quarters
    layout('u', 0, 0, 0.5, 0.5),
    layout('i', 0.5, 0, 0.5, 0.5),
    layout('m', 0, 0.5, 0.5, 0.5),
    layout(',', 0.5, 0.5, 0.5, 0.5),

    -- Thirds
    layout('7', 0, 0, 0.33, 1),
    layout('8', 0.33, 0, 0.34, 1),
    layout('9', 0.67, 0, 0.33, 1),

    -- Centered
    layout('\\', 0.1, 0.1, 0.8, 0.8),
    layout('delete', 0.2, 0.2, 0.6, 0.6),

    move('left', -1, 0),
    move('right', 1, 0),
    move('up', 0, -1),
    move('down', 0, 1),

    resize('h', -1, 0),
    resize('l', 1, 0),
    resize('k', 0, 1),
    resize('j', 0, -1),

    scale('=', config.resizeFactors.increase),
    scale('-', config.resizeFactors.decrease),

    -- ==================== SCREEN OPERATIONS ====================
    screen('[', 'previous'),
    screen(']', 'next'),

    -- ==================== CONTROL OPERATIONS ====================
    control('return', 'maximize'),
    control('0', 'minimize'),
    control('space', 'center'),
}

--------------------------
-- Unified Key Binding
--------------------------
for _, op in ipairs(windowOps) do
    if op.repeatable then
        bindRepeatKey(op.mod, op.key, op.run)
    else
        hs.hotkey.bind(op.mod, op.key, op.run)
    end
end
