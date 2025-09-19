--------------------------
-- Configuration & State
--------------------------

-- 기본 설정
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
	tolerance = 0.01, -- 통합 허용 오차 (1%) - 상태 감지 및 가장자리 정렬에 사용
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

-- 두 값이 허용 오차 내에 있는지 확인하는 공통 함수
local function isWithinTolerance(value1, value2)
	return math.abs(value1 - value2) < config.tolerance
end

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
		w = math.min(screen.w, frame.w),
		h = math.min(screen.h, frame.h),
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
			x = screen.x + math.floor(screen.w * x),
			y = screen.y + math.floor(screen.h * y),
			w = math.floor(screen.w * w),
			h = math.floor(screen.h * h),
		}

		-- 오른쪽 정렬 감지 및 수정 (x + w가 거의 1.0인 경우)
		if isWithinTolerance(x + w, 1.0) then
			-- 너비를 화면 끝까지 확장
			newFrame.w = screen.w - (newFrame.x - screen.x)
		end

		-- 아래쪽 정렬 감지 및 수정 (y + h가 거의 1.0인 경우)
		if isWithinTolerance(y + h, 1.0) then
			-- 높이를 화면 끝까지 확장
			newFrame.h = screen.h - (newFrame.y - screen.y)
		end

		win:setFrame(newFrame, config.animationDuration)
	end)
end

-- 창의 현재 상태를 감지하는 함수
local function detectWindowState(win, direction)
	local frame = win:frame()
	local screen = win:screen():frame()

	-- 현재 창의 상대적 위치와 크기 계산
	local relX = (frame.x - screen.x) / screen.w
	local relW = frame.w / screen.w

	-- 각 레이아웃과 비교하여 현재 상태 찾기
	local layouts = cycleLayouts[direction]
	for i, layout in ipairs(layouts) do
		local layoutX = layout[1]
		local layoutW = layout[3]

		-- 위치와 너비가 모두 허용 오차 내에 있는지 확인
		if isWithinTolerance(relX, layoutX) and isWithinTolerance(relW, layoutW) then
			return i
		end
	end

	-- 매칭되는 상태가 없으면 nil 반환
	return nil
end

local function cycleWindowSize(direction)
	withFocusedWindow(function(win)
		-- 현재 창 상태 감지
		local currentIndex = detectWindowState(win, direction)
		local nextIndex

		if currentIndex then
			-- 다음 인덱스로 순환
			nextIndex = (currentIndex % #cycleLayouts[direction]) + 1
		else
			-- 현재 상태를 감지할 수 없으면 첫 번째 레이아웃으로
			nextIndex = 1
		end

		-- 레이아웃 적용
		local layout = cycleLayouts[direction][nextIndex]
		moveWindow(layout[1], layout[2], layout[3], layout[4])
	end)
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

local function minimizeWindow()
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

local function centerWindow()
	withFocusedWindow(function(win)
		local frame = win:frame()
		local screen = win:screen():frame()

		-- 크기는 유지하고 위치만 중앙으로
		frame.x = screen.x + (screen.w - frame.w) / 2
		frame.y = screen.y + (screen.h - frame.h) / 2

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

-- 특수 크기
hs.hotkey.bind(config.mod, "return", maximizeWindow)
hs.hotkey.bind(config.mod, "0", minimizeWindow)

-- 위치만 중앙 정렬 (크기 유지)
hs.hotkey.bind(config.mod, "space", centerWindow)
