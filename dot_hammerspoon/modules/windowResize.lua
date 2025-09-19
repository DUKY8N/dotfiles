--------------------------
-- Configuration & State
--------------------------
local config = {
	mod = { "ctrl", "alt" },
	shiftMod = { "shift", "ctrl", "alt" },
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

local lastCycle = nil -- {direction, time, index}
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

local directions = {
	left = { -1, 0 },
	right = { 1, 0 },
	up = { 0, -1 },
	down = { 0, 1 },
}

local resizeDirections = {
	left = { -1, 0 }, -- 너비 감소
	right = { 1, 0 }, -- 너비 증가
	up = { 0, 1 }, -- 높이 증가
	down = { 0, -1 }, -- 높이 감소
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

local function constrainFrameToScreen(frame, screen)
	local constrained = {
		w = math.min(screen.w, frame.w),
		h = math.min(screen.h, frame.h),
	}

	constrained.x = math.max(screen.x, math.min(screen.x + screen.w - constrained.w, frame.x))
	constrained.y = math.max(screen.y, math.min(screen.y + screen.h - constrained.h, frame.y))

	return constrained
end

--------------------------
-- Core Functions
--------------------------

local function moveWindow(x, y, w, h)
	withFocusedWindow(function(win)
		local screen = win:screen():frame()
		local newFrame = {
			x = screen.x + math.floor(screen.w * x),
			y = screen.y + math.floor(screen.h * y),
			w = math.floor(screen.w * w),
			h = math.floor(screen.h * h),
		}

		-- 가장자리 픽셀 보정: 0.99 이상을 1.0으로 처리
		if isWithinTolerance(x + w, 1.0) then
			newFrame.w = screen.w - (newFrame.x - screen.x)
		end

		if isWithinTolerance(y + h, 1.0) then
			newFrame.h = screen.h - (newFrame.y - screen.y)
		end

		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function detectWindowState(win, direction)
	local frame = win:frame()
	local screen = win:screen():frame()

	local relX = (frame.x - screen.x) / screen.w
	local relW = frame.w / screen.w

	local layouts = cycleLayouts[direction]
	for i, layout in ipairs(layouts) do
		local layoutX = layout[1]
		local layoutW = layout[3]

		if isWithinTolerance(relX, layoutX) and isWithinTolerance(relW, layoutW) then
			return i
		end
	end

	return nil
end

local function cycleWindowSize(direction)
	withFocusedWindow(function(win)
		local now = hs.timer.secondsSinceEpoch()
		local layoutIndex

		-- 빠른 재클릭 시 1→2→3 순서로 강제 진행
		if lastCycle and lastCycle.direction == direction and (now - lastCycle.time) <= config.cycleTimeout then
			layoutIndex = (lastCycle.index % #cycleLayouts[direction]) + 1
		else
			-- 현재 크기 인식 후 다음으로
			local currentIndex = detectWindowState(win, direction)
			if currentIndex then
				layoutIndex = (currentIndex % #cycleLayouts[direction]) + 1
			else
				layoutIndex = 1
			end
		end

		local layout = cycleLayouts[direction][layoutIndex]
		moveWindow(layout[1], layout[2], layout[3], layout[4])
		lastCycle = {
			direction = direction,
			time = now,
			index = layoutIndex,
		}
	end)
end

local function moveByDirection(dx, dy)
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		local newFrame = {
			x = frame.x + dx * config.moveStep,
			y = frame.y + dy * config.moveStep,
			w = frame.w,
			h = frame.h,
		}

		newFrame = constrainFrameToScreen(newFrame, screen)
		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function moveToScreen(direction)
	withFocusedWindow(function(win)
		local targetScreen = direction == "next" and win:screen():next() or win:screen():previous()
		win:moveToScreen(targetScreen, false, true, config.animationDuration)
	end)
end

local function resizeByDirection(dw, dh)
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		-- 창 중심점 유지하며 크기 조절
		local widthChange = dw * config.resizeStep * 2
		local heightChange = dh * config.resizeStep * 2

		local newFrame = {
			w = frame.w + widthChange,
			h = frame.h + heightChange,
			x = frame.x - widthChange / 2,
			y = frame.y - heightChange / 2,
		}

		newFrame = constrainFrameToScreen(newFrame, screen)
		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function resizeByPercent(factor)
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		local newFrame = {
			w = frame.w * factor,
			h = frame.h * factor,
			x = frame.x - (frame.w * factor - frame.w) / 2,
			y = frame.y - (frame.h * factor - frame.h) / 2,
		}

		newFrame = constrainFrameToScreen(newFrame, screen)
		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function maximizeWindow()
	withFocusedWindow(function(win)
		win:maximize(config.animationDuration)
	end)
end

local function minimizeWindow()
	withFocusedWindow(function(win)
		local screen = win:screen():frame()
		-- 1x1 픽셀로 축소 (실제 최소화가 아닌 극단적 크기 축소)
		local frame = {
			w = 1,
			h = 1,
			x = screen.x + (screen.w - 1) / 2,
			y = screen.y + (screen.h - 1) / 2,
		}
		win:setFrame(frame, config.animationDuration)
	end)
end

local function centerWindow()
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		frame.x = screen.x + (screen.w - frame.w) / 2
		frame.y = screen.y + (screen.h - frame.h) / 2

		win:setFrame(frame, config.animationDuration)
	end)
end

--------------------------
-- Key Bindings
--------------------------

hs.hotkey.bind(config.mod, "h", function()
	cycleWindowSize("left")
end)
hs.hotkey.bind(config.mod, "l", function()
	cycleWindowSize("right")
end)

for key, layout in pairs(layouts) do
	hs.hotkey.bind(config.mod, key, function()
		moveWindow(layout[1], layout[2], layout[3], layout[4])
	end)
end

for key, direction in pairs(directions) do
	local fn = function()
		moveByDirection(direction[1], direction[2])
	end
	hs.hotkey.bind(config.mod, key, fn, nil, fn)
end

hs.hotkey.bind(config.mod, "[", function()
	moveToScreen("previous")
end)
hs.hotkey.bind(config.mod, "]", function()
	moveToScreen("next")
end)

for key, direction in pairs(resizeDirections) do
	local fn = function()
		resizeByDirection(direction[1], direction[2])
	end
	hs.hotkey.bind(config.shiftMod, key, fn, nil, fn)
end

hs.hotkey.bind(
	config.mod,
	"=",
	function()
		resizeByPercent(config.resizeFactors.increase)
	end,
	nil,
	function()
		resizeByPercent(config.resizeFactors.increase)
	end
)
hs.hotkey.bind(
	config.mod,
	"-",
	function()
		resizeByPercent(config.resizeFactors.decrease)
	end,
	nil,
	function()
		resizeByPercent(config.resizeFactors.decrease)
	end
)

hs.hotkey.bind(config.mod, "return", maximizeWindow)
hs.hotkey.bind(config.mod, "0", minimizeWindow)
hs.hotkey.bind(config.mod, "space", centerWindow)
