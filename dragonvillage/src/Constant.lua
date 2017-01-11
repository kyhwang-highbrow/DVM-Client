DMG_TYPE_NONE = 0
DMG_TYPE_PHYSICAL = 1
DMG_TYPE_MAGICAL = 2

DMG_TYPE_STR = {}
DMG_TYPE_STR['physical'] = DMG_TYPE_PHYSICAL
DMG_TYPE_STR['magical'] = DMG_TYPE_MAGICAL

-- 기준 해상도 (16:9 비율)
CRITERIA_RESOLUTION_X = 1280
CRITERIA_RESOLUTION_Y = 720

-- 최대 해상도
MAX_RESOLUTION_X = 1280
MAX_RESOLUTION_Y = 810

-- 최소 해상도
MIN_RESOLUTION_X = 1080
MIN_RESOLUTION_Y = 720

-- (1280 / 1080) * 810
GAME_RESOLUTION_X = 960

-- For Debuging
CHECK_UI_LOAD_TIME = false

POSTONE_CODE_RUN = isWin32()

-- KEY CODE .. 윈도우에서 사용
KEY_LEFT_ARROW = 23
KEY_RIGHT_ARROW = 24
KEY_UP_ARROW = 25
KEY_DOWN_ARROW = 26

KEY_0 = 73
KEY_1 = 74
KEY_2 = 75
KEY_3 = 76
KEY_4 = 77
KEY_5 = 78
KEY_6 = 79
KEY_7 = 80
KEY_8 = 81
KEY_9 = 82

KEY_A = 121
KEY_B = 122
KEY_C = 123
KEY_D = 124
KEY_E = 125

KEY_F = 126
KEY_G = 127
KEY_H = 128
KEY_I = 129
KEY_J = 130

KEY_K = 131
KEY_L = 132
KEY_M = 133
KEY_N = 134
KEY_O = 135

KEY_P = 136
KEY_Q = 137
KEY_R = 138
KEY_S = 139
KEY_T = 140

KEY_U = 141
KEY_V = 142
KEY_W = 143
KEY_X = 144
KEY_Y = 145

KEY_Z = 146

-- COLOR
COLOR_RED = cc.c3b(255, 0, 0)
COLOR_CYAN = cc.c3b(0, 255, 255)
COLOR_GREEN = cc.c3b(0, 0, 255)
COLOR_BALCK = cc.c3b(0, 0, 0)
COLOR_WHITE = cc.c3b(255, 255, 255)

-- TEMP
UNDER_LINE_PNG = 'res/common/underline.png'
EMPTY_PNG = 'res/common/empty.png'
EMPTY_TABLE = {}
CENTER_POINT = cc.p(0.5, 0.5)

MAX_DRAGON_GRADE = 6
MAX_DRAGON_ECLV = 15
DEV_STAGE_ID = 99999

-- 게임 모드
GAME_MODE_ADVENTURE = 1
GAME_MODE_NEST_DUNGEON = 2
GAME_MODE_COLOSSEUM = 3

-- 네스트 던전 하위 던전 모드
NEST_DUNGEON_DRAGON = 1
NEST_DUNGEON_NIGHTMARE = 2
NEST_DUNGEON_TREE = 3

-- state priority
PRIORITY =
{
	STUN = 2,
	STUN_ESC = 2,
	DYING = 9,
	DEAD = 10,
}

-------------------------------------
-- function monsterRarityStrToNum
-- @brief 
-------------------------------------
function monsterRarityStrToNum(rarity_str)
    if (type(rarity_str) == 'number') then
        return rarity_str
    end

    if (rarity_str == 'common') then
        return 1
    elseif (rarity_str == 'elite') then
        return 2
    elseif (rarity_str == 'subboss') then
        return 3
    elseif (rarity_str == 'boss') then
        return 4
    else
        error('rarity_str: ' .. rarity_str)
    end
end

-------------------------------------
-- function getMonsterSlicePerDamageRate
-- @brief 
-- 일반 = 1.5%
-- 엘리트 = 0.05%
-- 중간보스 = 0.05%
-- 보스 = 0.02%
-------------------------------------
function getMonsterSlicePerDamageRate(rarity_num)
    if (rarity_num == 1) then
        return 0.03
    elseif (rarity_num == 2) then
        return 0.005
    elseif (rarity_num == 3) then
        return 0.005
    elseif (rarity_num == 4) then
        return 0.002
    else
        error('rarity_num: ' .. rarity_num)
    end
end

-------------------------------------
-- function isDragon
-- @brief id를 가지고 dragon인지 판별
-------------------------------------
function isDragon(id)
    return ( math_floor(id / 10000) == 12 )
end

-------------------------------------
-- function isMonster
-- @brief id를 가지고 monster인지 판별
-------------------------------------
function isMonster(id)
    return ( math_floor(id / 10000) == 13 )
end
