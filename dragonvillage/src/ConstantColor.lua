-- COLOR

COLOR = {

    -- 채팅에서 사용함
    ['w'] = cc.c3b(0xff,0xff,0xff),   -- white     (255, 255, 255)
    ['g'] = cc.c3b(0x7f,0x7f,0x7f),   -- gray      (127, 127, 127)
    ['b'] = cc.c3b(0x00,0x00,0x00),   -- black     (0, 0, 0)
    ['R'] = cc.c3b(0xff,0x00,0x00),   -- RED       (255, 0, 0)
    ['G'] = cc.c3b(0x00,0xf8,0x0f),   -- GREEN     (0, 248, 15) 
    ['B'] = cc.c3b(0x00,0x00,0xff),   -- BLUE      (0, 0, 255)
    ['S'] = cc.c3b(0x10,0xc0,0xff),   -- Sky Blue  (16, 192, 255)
    ['Y'] = cc.c3b(0xff,0xff,0x00),   -- Yellow    (255, 255, 0)
    ['C'] = cc.c3b(0x00,0xff,0xff),   -- CYAN      (0, 255, 255)
    ['O'] = cc.c3b(0xff,0x7f,0x0f),   -- Orange    (255, 127, 15)
    ['V'] = cc.c3b(0x9f,0x30,0xcf),   -- Violet    (159, 48, 207)
    ['P'] = cc.c3b(0xff,0xbf,0xff),   -- Purple    (255, 191, 255)
    ['D'] = cc.c3b(0xcf,0xf8,0x9f),   --           (207, 248, 159)
    ['E'] = cc.c3b(0xff,0xf8,0x9f),   --           (255, 248, 159)
    ['F'] = cc.c3b(0xff,0x98,0x60),   --           (255, 152, 96)
    ['L'] = cc.c3b(0xa0,0xa0,0xa0),   --           (160, 160, 160)
    ['y'] = cc.c3b(0x7f,0x7f,0x00),   --           (127, 127, 0)
    ['M'] = cc.c3b(0x00,0xc0,0xff),   --           (0, 192, 255)
    ['d'] = cc.c3b(0x80,0xe7,0xaf),   --           (128, 231, 175)
    ['U'] = cc.c3b(0, 0, 0),

	-- 무채색
	['white'] = cc.c3b(255, 255, 255),
	['light_gray'] = cc.c3b(210, 210, 210),
	['gray'] = cc.c3b(180, 180, 180),
	['deep_gray'] = cc.c3b(100, 100, 100),
	['deep_dark_gray'] = cc.c3b(50, 50, 50),
	['black'] = cc.c3b(0, 0, 0),
	
	-- 빨강
	['red'] = cc.c3b(255, 0, 0),
	['light_red'] = cc.c3b(255, 44, 44),
	['pink'] = cc.c3b(255, 150, 150),

	-- 노랑
	['yellow'] = cc.c3b(255, 255, 0),
	['orange'] = cc.c3b(250, 120, 0),
	['mustard'] = cc.c3b(255, 231, 48),
	['apricot'] = cc.c3b(240, 215, 159),
	['chick'] = cc.c3b(255, 234, 91),

	-- 초록
	['green'] = cc.c3b(0, 255, 0),
	['light_green'] = cc.c3b(50, 255, 0),
	['grass_green'] = cc.c3b(165, 224, 0),
	['blue_green'] = cc.c3b(45, 255, 107),
	
	-- 파랑
	['blue'] = cc.c3b(0, 0, 255),
	['sky_blue'] = cc.c3b(0, 191, 255),
	['cyan'] = cc.c3b(0, 255, 255),

	-- 보라
	['purple'] = cc.c3b(255, 0, 255),
	['violet'] = cc.c3b(155, 0, 255), 
    
    -- 상아
    ['ivory'] =  cc.c3b(255, 243, 217),

    -- 갈색
    ['dark_brown'] = cc.c3b(145, 119, 96), 
    ['wood'] = cc.c3b(100, 77, 56),
    
    -- 대문자로 재정의
    -- 명조 색상
    ['BLACK'] = cc.c3b(0, 0, 0),
    ['DEEPGRAY'] = cc.c3b(100,100,100),
    ['GRAY'] = cc.c3b(150,150,150),
    ['LIGHTGRAY'] = cc.c3b(192,192,102),
    ['WHITE'] = cc.c3b(255,255,255),

    -- 유채색
    ['ORANGE'] = cc.c3b(255,165,0),
    ['GOLD'] = cc.c3b(255,215,0),
    ['TAN'] = cc.c3b(210,180,140),
    ['DEEPSKYBLUE'] = cc.c3b(0,191,255),
    ['LIGHTGREEN'] = cc.c3b(165, 224, 0),
    ['MUSTARD'] = cc.c3b(255, 231, 48),
    ['MUSTARD2'] = cc.c3b(255, 177, 1),
    ['ROSE'] = cc.c3b(255, 48, 48),
    ['YELLOW'] = cc.c3b(255,255,0),
    ['RED'] = cc.c3b(255,0,0),
    ['BLUE'] = cc.c3b(0,0,255),
    ['AQUA'] = cc.c3b(0,255,246),

    -- text 용 c4b
    -- 모험 난이도 대표 색상
    ['diff_easy'] = cc.c4b(255, 255, 255, 255),
    ['diff_normal'] = cc.c4b(105, 236, 87, 255),
    ['diff_hard'] = cc.c4b(255, 115, 53, 255),
    ['diff_hell'] = cc.c4b(233, 88, 255, 255),
    ['diff_hellfire'] = cc.c4b(255,51,56,255),
    ['diff_abyss_0'] = cc.c4b(81,77,255,255),
    ['diff_abyss_1'] = cc.c4b(81,77,255,255),


    ['proofreading'] = cc.c4b(255, 100, 100, 255),


    -- 클랜
    ['clan_name'] = cc.c3b(237, 114, 255),
    ['clan_master'] = cc.c3b(255, 177, 1),
    ['clan_manager'] = cc.c3b(178, 223, 226),
    ['clan_member'] = cc.c3b(145, 119, 96), 
    
    -- 유저 정보
    ['user_title'] = cc.c3b(255, 215, 0),

    -- 일반 텍스트 사용 색상
    ['DESC'] = cc.c3b(240, 215, 159),	-- 밝음
    ['DESC2'] = cc.c3b(161, 125, 93),	-- 어두움
    ['sub_msg'] = cc.c3b(255, 104, 32),	-- 붉은??색의 설명 텍스트

    -- 인게임 사용 색상
    ['SKILL_NAME'] = cc.c3b(255, 145, 0),	-- 오렌지

    -- UI 스킬 텍스트
    ['SKILL_VALUE'] = cc.c3b(244, 151, 5),
    ['SKILL_VALUE_MOD'] = cc.c3b(255, 240, 0),
    ['SKILL_DESC_ENHANCE'] = cc.c3b(99, 235, 255),
    ['CURR_LV'] = cc.c3b(244, 191, 5),

    -- 특수
    ['rune_sopt'] = cc.c3b(240, 215, 159),
    ['rune_set'] = cc.c3b(255, 234, 91),

    -- 가능, 불가능 색상
    ['possible'] = cc.c3b(150, 255, 65),
    ['impossible'] = cc.c3b(255, 44, 44),

    -- 룬 세트 색상
    ['r_set_blue'] = cc.c3b(0, 162, 255),
    ['r_set_purple'] = cc.c3b(208, 80, 255),
    ['r_set_pink'] = cc.c3b(255, 0, 228),
    ['r_set_red'] = cc.c3b(255, 52, 52),
    ['r_set_bluegreen'] = cc.c3b(23, 253, 133),
    ['r_set_green'] = cc.c3b(147, 253, 53),
    ['r_set_orange'] = cc.c3b(253, 166, 53),
    ['r_set_yellow'] = cc.c3b(253, 241, 53),

    ['r_set_blackred'] = cc.c3b(255, 132, 132),
    ['r_set_blackblue'] = cc.c3b(88, 229, 255),
    ['r_set_blackyellow'] = cc.c3b(255, 199, 90),
    ['r_set_blackwhite'] = cc.c3b(255, 255, 255),
    ['r_set_blackgreen'] = cc.c3b(170, 255, 107),
    ['r_set_blackpurple'] = cc.c3b(250, 119, 255),

    ['r_set_none'] = cc.c3b(255, 255, 255),
    
    -- 룬 옵션 선택 색상
    ['r_opt_selected'] = cc.c3b(255, 250, 190),

    -- 속성별
    ['earth'] = cc.c3b(88,234,102),
    ['water'] = cc.c3b(76,215,255),
    ['fire'] = cc.c3b(255,105,105),
    ['light'] = cc.c3b(255,226,65),
    ['dark'] = cc.c3b(218,104,255),

    -- 희귀도
    ['myth'] = cc.c3b(255,44,44),
	['legend'] = cc.c3b(255,232,100),
	['hero'] = cc.c3b(218,137,254),
	['rare'] = cc.c3b(170,203,253),
	['common'] = cc.c3b(214,214,214),
    
    -- 특정 색상 (그림자 신전 순위 변동 화살표 색깔로 이용)
    ['light_blue'] = cc.c3b(0,84,224),
    
    -- 그림자 신전 유저의 서버 라벨 색깔
    ['server_name'] = cc.c3b(127,255,212),

    -- 등락 표시 색상 ▲, ▼
    ['rank_up'] = cc.c3b(255,53,53),
    ['rank_down'] = cc.c3b(28,119,255),

    -- 전광판 아이템 표기용 색상
    ['item_highlight'] = cc.c3b(230,150,255),
}

-- 재정의 색상들
COLOR['SKILL_DESC'] = COLOR['DESC2']
COLOR['SKILL_DESC_MOD'] = COLOR['DESC']

-- 기능별 색상
COLOR['subject'] = COLOR['ROSE']
COLOR['condition'] = COLOR['ROSE']
COLOR['item_name'] = COLOR['DEEPSKYBLUE']
COLOR['count'] = COLOR['MUSTARD']
COLOR['emphasis'] = COLOR['ROSE']
COLOR['available'] = COLOR['light_green']

-- 임의로 사용되는 색상
COLOR['alphabet_wild'] = cc.c3b(240, 255, 0)