-- COLOR

COLOR = {
	-- 무채색
	white = cc.c3b(255, 255, 255),
	light_gray = cc.c3b(210, 210, 210),
	gray = cc.c3b(180, 180, 180),
	deep_gray = cc.c3b(100, 100, 100),
	deep_dark_gray = cc.c3b(50, 50, 50),
	black = cc.c3b(0, 0, 0),
	
	-- 빨강
	red = cc.c3b(255, 0, 0),
	light_red = cc.c3b(255, 44, 44),
	pink = cc.c3b(255, 150, 150),

	-- 노랑
	yellow = cc.c3b(255, 255, 0),
	orange = cc.c3b(250, 120, 0),
	mustard = cc.c3b(255, 231, 48),
	apricot = cc.c3b(240, 215, 159),
	chick = cc.c3b(255, 234, 91),

	-- 초록
	green = cc.c3b(0, 255, 0),
	light_green = cc.c3b(50, 255, 0),
	grass_green = cc.c3b(165, 224, 0),
	
	-- 파랑
	blue = cc.c3b(0, 0, 255),
	sky_blue = cc.c3b(0, 191, 255),
	cyan = cc.c3b(0, 255, 255),

	-- 보라
	purple = cc.c3b(255, 0, 255),
	violet = cc.c3b(155, 0, 255), 

    -- text 용 c4b
    diff_normal = cc.c4b(105, 236, 87, 255),
    diff_hard = cc.c4b(255, 115, 53, 255),
    diff_hell = cc.c4b(233, 88, 255, 255),

    ['w'] = cc.c3b(0xff,0xff,0xff),   -- white
    ['g'] = cc.c3b(0x7f,0x7f,0x7f),   -- gray
    ['b'] = cc.c3b(0x00,0x00,0x00),   -- black
    ['R'] = cc.c3b(0xff,0x00,0x00),   -- RED
    ['G'] = cc.c3b(0x00,0xf8,0x0f),   -- GREEN
    ['B'] = cc.c3b(0x00,0x00,0xff),   -- BLUE
    ['S'] = cc.c3b(0x10,0xc0,0xff),   -- Sky Blue
    ['Y'] = cc.c3b(0xff,0xff,0x00),   -- Yellow
    ['C'] = cc.c3b(0x00,0xff,0xff),   -- CYAN
    ['O'] = cc.c3b(0xff,0x7f,0x0f),   -- Orange
    ['V'] = cc.c3b(0x9f,0x30,0xcf),   -- Violet
    ['P'] = cc.c3b(0xff,0xbf,0xff),   -- Purple
    ['D'] = cc.c3b(0xcf,0xf8,0x9f),
    ['E'] = cc.c3b(0xff,0xf8,0x9f),
    ['F'] = cc.c3b(0xff,0x98,0x60),
    ['L'] = cc.c3b(0xa0,0xa0,0xa0),
    ['y'] = cc.c3b(0x7f,0x7f,0x00),
    ['M'] = cc.c3b(0x00,0xc0,0xff),
    ['d'] = cc.c3b(0x80,0xe7,0xaf),
    ['U'] = cc.c3b(0, 0, 0),
}

-- 명조 색상
COLOR['BLACK'] = cc.c3b(0, 0, 0)
COLOR['DEEPGRAY'] = cc.c3b(100,100,100)
COLOR['GRAY'] = cc.c3b(150,150,150)
COLOR['LIGHTGRAY'] = cc.c3b(192,192,102)
COLOR['WHITE'] = cc.c3b(255,255,255)

-- 유채색
COLOR['ORANGE'] = cc.c3b(255,165,0)
COLOR['GOLD'] = cc.c3b(255,215,0)
COLOR['TAN'] = cc.c3b(210,180,140)
COLOR['DEEPSKYBLUE'] = cc.c3b(0,191,255)

COLOR['LIGHTGREEN'] = cc.c3b(165, 224, 0)
COLOR['MUSTARD'] = cc.c3b(255, 231, 48)
COLOR['ROSE'] = cc.c3b(255, 48, 48)

COLOR['YELLOW'] = cc.c3b(255,255,0)
COLOR['RED'] = cc.c3b(255,0,0)
COLOR['BLUE'] = cc.c3b(0,0,255)
	
-- 일반 텍스트 사용 색상
COLOR['DESC'] = cc.c3b(240, 215, 160)	-- 밝음
COLOR['DESC2'] = cc.c3b(161, 125, 93)	-- 어두움

-- 인게임 사용 색상
COLOR['SKILL_NAME'] = cc.c3b(255, 145, 0)	-- 오렌지
--COLOR['SKILL_DESC'] = cc.c3b(245, 233, 220)	-- 허~연색
COLOR['SKILL_DESC'] = COLOR['DESC2']
COLOR['SKILL_VALUE'] = COLOR['MUSTARD']

-- 특수
COLOR['rune_sopt'] = cc.c3b(240, 215, 159)
COLOR['rune_set'] = cc.c3b(255, 234, 91)

-- 가능, 불가능 색상
COLOR['possible'] = cc.c3b(150, 255, 65)
COLOR['impossible'] = cc.c3b(255, 44, 44)

-- 기능별 색상
COLOR['subject'] = COLOR['ROSE']
COLOR['condition'] = COLOR['ROSE']
COLOR['item_name'] = COLOR['DEEPSKYBLUE']
COLOR['count'] = COLOR['MUSTARD']

-- 룬 세트 색상
COLOR['r_set_blue'] = cc.c3b(0, 162, 255)
COLOR['r_set_purple'] = cc.c3b(208, 80, 255)
COLOR['r_set_pink'] = cc.c3b(255, 0, 228)
COLOR['r_set_red'] = cc.c3b(255, 52, 52)
COLOR['r_set_bluegreen'] = cc.c3b(23, 253, 133)
COLOR['r_set_green'] = cc.c3b(147, 253, 53)
COLOR['r_set_orange'] = cc.c3b(253, 166, 53)
COLOR['r_set_yellow'] = cc.c3b(253, 241, 53)



