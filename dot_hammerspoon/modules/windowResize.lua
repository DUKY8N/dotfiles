local mod = { "ctrl", "alt" }
local shiftMod = { "shift", "ctrl", "alt" }

-- hs.grid 초기화
hs.grid.setGrid("3x3")
hs.grid.setMargins({ x = 0, y = 0 })
hs.grid.ui.textSize = 50
hs.grid.ui.cellStrokeWidth = 3

-- 사이클링을 위한 인덱스 저장
local cycleIndex = {}

-- 모든 레이아웃 정의 (테이블 기반)
local layouts = {
	-- 사이클링 레이아웃
	h = {
		{ x = 0, y = 0, w = 1.5, h = 3 }, -- 왼쪽 1/2
		{ x = 0, y = 0, w = 1, h = 3 }, -- 왼쪽 1/3
		{ x = 0, y = 0, w = 2, h = 3 }, -- 왼쪽 2/3
	},
	l = {
		{ x = 1.5, y = 0, w = 1.5, h = 3 }, -- 오른쪽 1/2
		{ x = 2, y = 0, w = 1, h = 3 }, -- 오른쪽 1/3
		{ x = 1, y = 0, w = 2, h = 3 }, -- 오른쪽 2/3
	},

	-- 고정 레이아웃
	k = { x = 0, y = 0, w = 3, h = 1.5 }, -- 위쪽 1/2
	j = { x = 0, y = 1.5, w = 3, h = 1.5 }, -- 아래쪽 1/2

	-- 1/4 분할
	u = { x = 0, y = 0, w = 1.5, h = 1.5 }, -- 좌상단
	i = { x = 1.5, y = 0, w = 1.5, h = 1.5 }, -- 우상단
	m = { x = 0, y = 1.5, w = 1.5, h = 1.5 }, -- 좌하단
	[","] = { x = 1.5, y = 1.5, w = 1.5, h = 1.5 }, -- 우하단

	-- 1/3 분할
	["7"] = { x = 0, y = 0, w = 1, h = 3 }, -- 왼쪽 1/3
	["8"] = { x = 1, y = 0, w = 1, h = 3 }, -- 중앙 1/3
	["9"] = { x = 2, y = 0, w = 1, h = 3 }, -- 오른쪽 1/3

	-- 중앙 정렬
	["\\"] = { x = 0.3, y = 0.3, w = 2.4, h = 2.4 }, -- 80%
	["delete"] = { x = 0.6, y = 0.6, w = 1.8, h = 1.8 }, -- 60%
}

-- 단순화된 창 조작 함수
local function applyLayout(layout)
	local win = hs.window.focusedWindow()
	if win and layout then
		hs.grid.set(win, layout, win:screen())
	end
end

-- 단순화된 사이클링 함수
local function cycleLayout(key)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local positions = layouts[key]
	if type(positions) ~= "table" or not positions[1] then
		return
	end

	-- 인덱스 증가 및 순환
	cycleIndex[key] = ((cycleIndex[key] or 0) % #positions) + 1
	applyLayout(positions[cycleIndex[key]])
end

-- 키 바인딩 (루프 기반)
for key, layout in pairs(layouts) do
	hs.hotkey.bind(mod, key, function()
		if type(layout) == "table" and layout[1] then
			-- 배열이면 사이클링
			cycleLayout(key)
		else
			-- 단일 레이아웃
			applyLayout(layout)
		end
	end)
end

-- 특별 기능들
hs.hotkey.bind(mod, "return", function()
	local win = hs.window.focusedWindow()
	if win then
		hs.grid.maximizeWindow(win)
	end
end)

hs.hotkey.bind(mod, "0", function()
	local win = hs.window.focusedWindow()
	if win then
		win:minimize()
	end
end)

hs.hotkey.bind(mod, "space", function()
	local win = hs.window.focusedWindow()
	if win then
		-- 창을 현재 크기 유지하며 화면 중앙으로
		local f = win:frame()
		local s = win:screen():frame()
		f.x = s.x + (s.w - f.w) / 2
		f.y = s.y + (s.h - f.h) / 2
		win:setFrame(f)
	end
end)

-- 시각적 그리드 선택기
hs.hotkey.bind(mod, "g", hs.grid.show)

-- 화면 이동
hs.hotkey.bind(mod, "[", function()
	local win = hs.window.focusedWindow()
	if win then
		win:moveToScreen(win:screen():previous())
	end
end)

hs.hotkey.bind(mod, "]", function()
	local win = hs.window.focusedWindow()
	if win then
		win:moveToScreen(win:screen():next())
	end
end)

-- hs.grid 내장 이동 기능
hs.hotkey.bind(shiftMod, "h", hs.grid.pushWindowLeft)
hs.hotkey.bind(shiftMod, "l", hs.grid.pushWindowRight)
hs.hotkey.bind(shiftMod, "k", hs.grid.pushWindowUp)
hs.hotkey.bind(shiftMod, "j", hs.grid.pushWindowDown)

-- hs.grid 내장 크기 조절
hs.hotkey.bind(shiftMod, "=", hs.grid.resizeWindowWider)
hs.hotkey.bind(shiftMod, "-", hs.grid.resizeWindowThinner)
hs.hotkey.bind(shiftMod, "up", hs.grid.resizeWindowTaller)
hs.hotkey.bind(shiftMod, "down", hs.grid.resizeWindowShorter)
