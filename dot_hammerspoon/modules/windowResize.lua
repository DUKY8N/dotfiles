--------------------------
-- Configuration & State
--------------------------
local config = {
	mod = { "ctrl", "alt" },
	resizeMod = { "shift", "ctrl", "alt" }, -- 크기 조절용 수식 키
	animationDuration = 0.125,
	moveStep = 100, -- 픽셀 단위 이동 거리
	resizeStep = 50, -- 픽셀 단위 크기 조절
	resizeFactors = {
		increase = 1.1, -- 10% 증가
		decrease = 0.9, -- 10% 감소
	},
	tolerance = 0.01, -- 픽셀 완벽 정렬을 위한 허용 오차
	cycleTimeout = 0.5, -- 빠른 재클릭 감지 시간 (초)
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
		local targetScreen = direction == "next" and win:screen():next() or win:screen():previous()
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

local function cycleWindowSize(op)
	withFocusedWindow(function(win)
		local now = hs.timer.secondsSinceEpoch()
		local layouts = op.layouts
		local layoutCount = #layouts
		local layoutIndex

		-- 빠른 재클릭: 이전 인덱스에서 계속
		if lastCycle.key == op.key and (now - lastCycle.time) <= config.cycleTimeout then
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

		lastCycle.key = op.key
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

-- Control action handler
local function handleControlAction(op)
	local action = controlActions[op.action]
	if action then
		withFocusedWindow(action)
	end
end

--------------------------
-- Operation Handlers
--------------------------
local handlers = {
	cycle = cycleWindowSize,
	layout = function(op)
		local rect = op.rect
		setWindowPosition(rect.x, rect.y, rect.w, rect.h)
	end,
	move = function(op)
		local delta = op.delta
		moveWindow(delta.x, delta.y)
	end,
	resize = function(op)
		local size = op.size
		resizeByDirection(size.w, size.h)
	end,
	scale = function(op)
		resizeByPercent(op.factor)
	end,
	screen = function(op)
		moveToScreen(op.direction)
	end,
	control = handleControlAction,
}

--------------------------
-- Factory Functions for Operations
--------------------------
local function cycle(key, side, layouts)
	local layoutsWithDesc = {}
	for i, layout in ipairs(layouts) do
		table.insert(layoutsWithDesc, {
			x = layout[1],
			y = layout[2],
			w = layout[3],
			h = layout[4],
			desc = layout.desc or string.format("Layout %d", i),
		})
	end
	return {
		key = key,
		mod = config.mod,
		type = "cycle",
		name = side .. " Side Cycle",
		layouts = layoutsWithDesc,
	}
end

local function layout(key, name, x, y, w, h)
	return {
		key = key,
		mod = config.mod,
		type = "layout",
		name = name,
		rect = { x = x, y = y, w = w, h = h },
	}
end

local function move(key, direction, dx, dy)
	return {
		key = key,
		mod = config.mod,
		type = "move",
		name = "Move " .. direction,
		delta = { x = dx, y = dy },
		repeatable = true,
	}
end

local function resize(key, action, dw, dh)
	return {
		key = key,
		mod = config.resizeMod,
		type = "resize",
		name = action,
		size = { w = dw, h = dh },
		repeatable = true,
	}
end

local function scale(key, direction, factor)
	return {
		key = key,
		mod = config.mod,
		type = "scale",
		name = "Scale " .. direction,
		factor = factor,
		repeatable = true,
	}
end

local function screen(key, direction)
	return {
		key = key,
		mod = config.mod,
		type = "screen",
		name = direction:gsub("^%l", string.upper) .. " Screen",
		direction = direction,
	}
end

local function control(key, action)
	local names = {
		maximize = "Maximize",
		minimize = "Minimize",
		center = "Center",
	}
	return {
		key = key,
		mod = config.mod,
		type = "control",
		name = names[action] or action,
		action = action,
	}
end

--------------------------
-- Unified Window Operations Table
--------------------------
local windowOps = {
	cycle("h", "Left", {
		{ 0, 0, 0.5, 1, desc = "Half" },
		{ 0, 0, 0.33, 1, desc = "Third" },
		{ 0, 0, 0.67, 1, desc = "Two-thirds" },
	}),
	cycle("l", "Right", {
		{ 0.5, 0, 0.5, 1, desc = "Half" },
		{ 0.67, 0, 0.33, 1, desc = "Third" },
		{ 0.33, 0, 0.67, 1, desc = "Two-thirds" },
	}),

	-- Halves
	layout("k", "Top Half", 0, 0, 1, 0.5),
	layout("j", "Bottom Half", 0, 0.5, 1, 0.5),

	-- Quarters
	layout("u", "Top-Left Quarter", 0, 0, 0.5, 0.5),
	layout("i", "Top-Right Quarter", 0.5, 0, 0.5, 0.5),
	layout("m", "Bottom-Left Quarter", 0, 0.5, 0.5, 0.5),
	layout(",", "Bottom-Right Quarter", 0.5, 0.5, 0.5, 0.5),

	-- Thirds
	layout("7", "Left Third", 0, 0, 0.33, 1),
	layout("8", "Center Third", 0.33, 0, 0.34, 1),
	layout("9", "Right Third", 0.67, 0, 0.33, 1),

	-- Centered
	layout("\\", "80% Centered", 0.1, 0.1, 0.8, 0.8),
	layout("delete", "60% Centered", 0.2, 0.2, 0.6, 0.6),

	move("left", "Left", -1, 0),
	move("right", "Right", 1, 0),
	move("up", "Up", 0, -1),
	move("down", "Down", 0, 1),

	resize("left", "Shrink Width", -1, 0),
	resize("right", "Expand Width", 1, 0),
	resize("up", "Expand Height", 0, 1),
	resize("down", "Shrink Height", 0, -1),

	scale("=", "Up", config.resizeFactors.increase),
	scale("-", "Down", config.resizeFactors.decrease),

	-- ==================== SCREEN OPERATIONS ====================
	screen("[", "previous"),
	screen("]", "next"),

	-- ==================== CONTROL OPERATIONS ====================
	control("return", "maximize"),
	control("0", "minimize"),
	control("space", "center"),
}

--------------------------
-- Unified Key Binding
--------------------------
for _, op in ipairs(windowOps) do
	local handler = function()
		handlers[op.type](op)
	end

	if op.repeatable then
		bindRepeatKey(op.mod, op.key, handler)
	else
		hs.hotkey.bind(op.mod, op.key, handler)
	end
end
