--------------------------
-- Configuration & State
--------------------------

-- 기본 설정
local config = {
	mod = { "ctrl", "alt" },
	shiftMod = { "shift", "ctrl", "alt" },
	animationDuration = 0.125,
	moveStep = 150, -- 픽셀 단위 이동 거리
	resizeStep = 50, -- 픽셀 단위 크기 조절
	minWidth = 200, -- 최소 너비
	minHeight = 150, -- 최소 높이
	resizeFactors = {
		increase = 1.1, -- 10% 증가
		decrease = 0.9, -- 10% 감소
	},
	cycleTimeout = 1000, -- 사이클링 타임아웃 (밀리초)
}

-- 사이클링 상태
local cycleState = {
	left = { index = 1, lastTime = 0 },
	right = { index = 1, lastTime = 0 },
}

-- 사이클링 레이아웃
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

-- 정적 레이아웃
local layouts = {
	-- 절반 분할 (h, l은 사이클링 사용으로 제외)
	k = { 0, 0, 1, 0.5 }, -- 위쪽 절반
	j = { 0, 0.5, 1, 0.5 }, -- 아래쪽 절반

	-- 1/4 분할
	u = { 0, 0, 0.5, 0.5 }, -- 좌상단
	i = { 0.5, 0, 0.5, 0.5 }, -- 우상단
	m = { 0, 0.5, 0.5, 0.5 }, -- 좌하단
	[","] = { 0.5, 0.5, 0.5, 0.5 }, -- 우하단

	-- 1/3 분할
	["7"] = { 0, 0, 0.33, 1 }, -- 왼쪽 1/3
	["8"] = { 0.33, 0, 0.34, 1 }, -- 중앙 1/3
	["9"] = { 0.67, 0, 0.33, 1 }, -- 오른쪽 1/3

	-- 중앙 정렬
	["\\"] = { 0.1, 0.1, 0.8, 0.8 }, -- 80% 크기
	["delete"] = { 0.2, 0.2, 0.6, 0.6 }, -- 60% 크기
}

-- 방향 정의
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

-- 포커스된 윈도우에 함수 실행
local function withFocusedWindow(fn)
	local win = hs.window.focusedWindow()
	if win then
		return fn(win)
	end
end

-- 프레임을 화면 경계 내로 제한
local function constrainFrameToScreen(frame, screen)
	local constrained = {
		w = math.max(config.minWidth, math.min(screen.w, frame.w)),
		h = math.max(config.minHeight, math.min(screen.h, frame.h)),
	}

	-- 위치 조정 (화면 밖으로 나가지 않도록)
	constrained.x = math.max(screen.x, math.min(screen.x + screen.w - constrained.w, frame.x))
	constrained.y = math.max(screen.y, math.min(screen.y + screen.h - constrained.h, frame.y))

	return constrained
end

--------------------------
-- Core Functions
--------------------------

-- 레이아웃 관련
local function moveWindow(x, y, w, h)
	withFocusedWindow(function(win)
		local screen = win:screen():frame()
		local newFrame = {
			x = screen.x + (screen.w * x),
			y = screen.y + (screen.h * y),
			w = screen.w * w,
			h = screen.h * h,
		}
		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function cycleWindowSize(direction)
	local currentTime = hs.timer.secondsSinceEpoch() * 1000
	local state = cycleState[direction]

	-- 타임아웃 체크 (1초 이상 지났으면 리셋)
	if currentTime - state.lastTime > config.cycleTimeout then
		state.index = 1
	else
		-- 다음 사이즈로 이동
		state.index = (state.index % #cycleLayouts[direction]) + 1
	end

	state.lastTime = currentTime

	-- 레이아웃 적용
	local layout = cycleLayouts[direction][state.index]
	moveWindow(layout[1], layout[2], layout[3], layout[4])
end

-- 이동 관련
local function moveByDirection(dx, dy)
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		-- 경계 체크하며 이동
		frame.x = math.max(screen.x, math.min(screen.x + screen.w - frame.w, frame.x + dx * config.moveStep))
		frame.y = math.max(screen.y, math.min(screen.y + screen.h - frame.h, frame.y + dy * config.moveStep))

		win:setFrame(frame, config.animationDuration)
	end)
end

local function moveToScreen(direction)
	withFocusedWindow(function(win)
		local targetScreen = direction == "next" and win:screen():next() or win:screen():previous()
		win:moveToScreen(targetScreen, false, true, config.animationDuration)
	end)
end

-- 크기 조절 관련
local function resizeByDirection(dw, dh)
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		-- 새로운 크기 계산 (중심 유지)
		local widthChange = dw * config.resizeStep * 2
		local heightChange = dh * config.resizeStep * 2

		local newFrame = {
			w = frame.w + widthChange,
			h = frame.h + heightChange,
			x = frame.x - widthChange / 2,
			y = frame.y - heightChange / 2,
		}

		-- 화면 경계 내로 제한
		newFrame = constrainFrameToScreen(newFrame, screen)
		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function resizeByPercent(factor)
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		-- 중심 유지하면서 크기 조절
		local newFrame = {
			w = frame.w * factor,
			h = frame.h * factor,
			x = frame.x - (frame.w * factor - frame.w) / 2,
			y = frame.y - (frame.h * factor - frame.h) / 2,
		}

		-- 화면 경계 내로 제한
		newFrame = constrainFrameToScreen(newFrame, screen)
		win:setFrame(newFrame, config.animationDuration)
	end)
end

local function maximizeWindow()
	withFocusedWindow(function(win)
		win:maximize(config.animationDuration)
	end)
end

local function minimizeToSmallest()
	withFocusedWindow(function(win)
		local screen = win:screen():frame()
		local frame = {
			w = 1,
			h = 1,
			x = screen.x + (screen.w - 1) / 2,
			y = screen.y + (screen.h - 1) / 2,
		}
		win:setFrame(frame, config.animationDuration)
	end)
end

--------------------------
-- Key Bindings
--------------------------

-- 레이아웃 바인딩
-- 사이클링 (h, l)
hs.hotkey.bind(config.mod, "h", function()
	cycleWindowSize("left")
end)

hs.hotkey.bind(config.mod, "l", function()
	cycleWindowSize("right")
end)

-- 정적 레이아웃
for key, layout in pairs(layouts) do
	hs.hotkey.bind(config.mod, key, function()
		moveWindow(layout[1], layout[2], layout[3], layout[4])
	end)
end

-- 이동 바인딩
-- 위치 이동 (방향키)
for key, direction in pairs(directions) do
	local fn = function()
		moveByDirection(direction[1], direction[2])
	end
	hs.hotkey.bind(config.mod, key, fn, nil, fn)
end

-- 모니터 이동
hs.hotkey.bind(config.mod, "[", function()
	moveToScreen("previous")
end)

hs.hotkey.bind(config.mod, "]", function()
	moveToScreen("next")
end)

-- 크기 조절 바인딩
-- 방향 크기 조절 (Shift+방향키)
for key, direction in pairs(resizeDirections) do
	local fn = function()
		resizeByDirection(direction[1], direction[2])
	end
	hs.hotkey.bind(config.shiftMod, key, fn, nil, fn)
end

-- 퍼센트 크기 조절
local increaseSize = function()
	resizeByPercent(config.resizeFactors.increase)
end
local decreaseSize = function()
	resizeByPercent(config.resizeFactors.decrease)
end

hs.hotkey.bind(config.mod, "=", increaseSize, nil, increaseSize)
hs.hotkey.bind(config.mod, "-", decreaseSize, nil, decreaseSize)

-- 특수 크기
hs.hotkey.bind(config.mod, "return", maximizeWindow)
hs.hotkey.bind(config.mod, "0", minimizeToSmallest)
