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

local lastCycle = { time = 0 } -- {direction, time, index}
local cycleLayouts = {
	left = {
		{ 0, 0, 0.5, 1 }, -- 1/2
		{ 0, 0, 0.33, 1 }, -- 1/3
		{ 0, 0, 0.67, 1 }, -- 2/3
	},
	right = {
		{ 0.5, 0, 0.5, 1 }, -- 1/2 (오른쪽)
		{ 0.67, 0, 0.33, 1 }, -- 1/3 (오른쪽)
		{ 0.33, 0, 0.67, 1 }, -- 2/3 (오른쪽)
	},
}

local layouts = {
	-- h, l은 사이클링으로 처리됨
	k = { 0, 0, 1, 0.5 }, -- 위쪽 절반
	j = { 0, 0.5, 1, 0.5 }, -- 아래쪽 절반

	-- 1/4 분할
	u = { 0, 0, 0.5, 0.5 }, -- 좌상단
	i = { 0.5, 0, 0.5, 0.5 }, -- 우상단
	m = { 0, 0.5, 0.5, 0.5 }, -- 좌하단
	[","] = { 0.5, 0.5, 0.5, 0.5 }, -- 우하단

	-- 1/3 분할
	["7"] = { 0, 0, 0.33, 1 }, -- 왼쪽 1/3
	["8"] = { 0.33, 0, 0.34, 1 }, -- 중앙 1/3 (0.34로 반올림 오차 보정)
	["9"] = { 0.67, 0, 0.33, 1 }, -- 오른쪽 1/3

	-- 중앙 정렬
	["\\"] = { 0.1, 0.1, 0.8, 0.8 }, -- 80% 크기
	["delete"] = { 0.2, 0.2, 0.6, 0.6 }, -- 60% 크기
}

-- 창 이동 방향
local moveDirections = {
	left = { dx = -1, dy = 0 },
	right = { dx = 1, dy = 0 },
	up = { dx = 0, dy = -1 },
	down = { dx = 0, dy = 1 },
}

-- 창 크기 조절 방향 (중심점 기준)
local resizeDirections = {
	left = { dw = -1, dh = 0 }, -- 너비 감소
	right = { dw = 1, dh = 0 }, -- 너비 증가
	up = { dw = 0, dh = 1 }, -- 높이 증가
	down = { dw = 0, dh = -1 }, -- 높이 감소
}

--------------------------
-- Utility Functions
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
-- Core Functions
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

local function cycleWindowSize(direction)
	withFocusedWindow(function(win)
		local now = hs.timer.secondsSinceEpoch()
		local layoutCount = #cycleLayouts[direction]
		local layoutIndex

		-- 빠른 재클릭: 이전 인덱스에서 계속
		if lastCycle.direction == direction and (now - lastCycle.time) <= config.cycleTimeout then
			layoutIndex = (lastCycle.index % layoutCount) + 1
		else
			-- 현재 창 상태 감지
			local frame = win:frame()
			local screen = win:screen():frame()
			local normalizedX = (frame.x - screen.x) / screen.w
			local normalizedWidth = frame.w / screen.w

			layoutIndex = 1 -- 기본값
			for i, layout in ipairs(cycleLayouts[direction]) do
				if isWithinTolerance(normalizedX, layout[1]) and isWithinTolerance(normalizedWidth, layout[3]) then
					layoutIndex = (i % layoutCount) + 1
					break
				end
			end
		end

		setWindowPosition(table.unpack(cycleLayouts[direction][layoutIndex]))

		lastCycle.direction = direction
		lastCycle.time = now
		lastCycle.index = layoutIndex
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

--------------------------
-- Key Bindings
--------------------------

-- 사이클 위치 지정
hs.hotkey.bind(config.mod, "h", function()
	cycleWindowSize("left")
end)
hs.hotkey.bind(config.mod, "l", function()
	cycleWindowSize("right")
end)

-- 레이아웃 지정
for key, layout in pairs(layouts) do
	hs.hotkey.bind(config.mod, key, function()
		setWindowPosition(table.unpack(layout))
	end)
end

-- 창 이동 (반복 키 지원)
for key, direction in pairs(moveDirections) do
	bindRepeatKey(config.mod, key, function()
		moveWindow(direction.dx, direction.dy)
	end)
end

-- 화면 이동
hs.hotkey.bind(config.mod, "[", function()
	moveToScreen("previous")
end)
hs.hotkey.bind(config.mod, "]", function()
	moveToScreen("next")
end)

-- 창 크기 조절 (반복 키 지원)
for key, direction in pairs(resizeDirections) do
	bindRepeatKey(config.resizeMod, key, function()
		resizeByDirection(direction.dw, direction.dh)
	end)
end

-- 퍼센트 크기 조절 (반복 키 지원)
bindRepeatKey(config.mod, "=", function()
	resizeByPercent(config.resizeFactors.increase)
end)
bindRepeatKey(config.mod, "-", function()
	resizeByPercent(config.resizeFactors.decrease)
end)

-- 창 제어
hs.hotkey.bind(config.mod, "return", function()
	withFocusedWindow(function(win)
		win:maximize(config.animationDuration)
	end)
end)
hs.hotkey.bind(config.mod, "0", function()
	withFocusedWindow(function(win)
		win:minimize()
	end)
end)
hs.hotkey.bind(config.mod, "space", function()
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()
		frame.x = screen.x + (screen.w - frame.w) / 2
		frame.y = screen.y + (screen.h - frame.h) / 2
		win:setFrame(frame, config.animationDuration)
	end)
end)
