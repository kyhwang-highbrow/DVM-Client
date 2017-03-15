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

-- 사운드 파일이 없을 경우 그냥 넘어감
PASS_NO_SOUND_FILE = true

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
COLOR_BLACK = cc.c3b(0, 0, 0)
COLOR_WHITE = cc.c3b(255, 255, 255)

COLOR_3 = {}
COLOR_3['white'] = COLOR_WHITE
COLOR_3['red'] = COLOR_RED
COLOR_3['blue'] = cc.c3b(0, 0, 255)

COLOR_4 = {}
COLOR_4['white'] = cc.c4b(255, 255, 255, 255)
COLOR_4['red'] = cc.c4b(255, 0, 0, 255)
COLOR_4['blue'] = cc.c4b(0, 0, 255, 255)
COLOR_4['black'] = cc.c4b(0, 0, 0, 255)

-- TEMP
UNDER_LINE_PNG = 'res/common/underline.png'
EMPTY_PNG = 'res/common/empty.png'
EMPTY_TABLE = {}
CENTER_POINT = cc.p(0.5, 0.5)

-- # 1 frame
ONE_FRAME = 1/30

MAX_DRAGON_GRADE = 6
MAX_DRAGON_ECLV = 15

COLOSSEUM_STAGE_ID = 90000
DEV_STAGE_ID = 99999

--------------------------------------------------------------------------
-- PhysKey 상수
--------------------------------------------------------------------------
PHYS = {
	HERO = 'hero',
	ENEMY = 'enemy',
	EFFECT = 'effect',
	MISSILE = {
		HERO = 'missile_h',
		ENEMY = 'missile_e'
	}
}

--------------------------------------------
-- State priority
--------------------------------------------
PRIORITY =
{
	STUN = 2,
	STUN_ESC = 2,
	DYING = 9,
	DEAD = 10,
}
--------------------------------------------
-- World Z-Order Priority
--------------------------------------------
WORLD_Z_ORDER = 
{
	MISSILE = 0,
	ENEMY = 10,
    HERO = 11,
    TAMER = 12,
	SE_EFFECT = 13,
    CASTING = 20,
}

--------------------------------------------
-- 인디케이터 리소스 경로
--------------------------------------------
RES_INDICATOR = 
{
	STRAIGHT = 'res/indicator/indicator_type_straight/indicator_type_straight.vrp',
    STRAIGHT_WIDTH = 'res/indicator/indicator_type_straight_wide/indicator_type_straight_wide.vrp',
	HEALING_WIND = 'res/indicator/indicator_healing_wind/indicator_healing_wind.vrp',
	
	CONE20 = 'res/indicator/indicator_type_cone_20/indicator_type_cone_20.vrp',
	CONE30 = 'res/indicator/indicator_type_cone_30/indicator_type_cone_30.vrp',
	CONE40 = 'res/indicator/indicator_type_cone_40/indicator_type_cone_40.vrp',

	RANGE = 'res/indicator/indicator_type_range/indicator_type_range.vrp', --> 과거에 서펀트 드래곤이 사정거리 표시할때 사용하던 인디케이터
	BEZIER = 'res/indicator/indicator_bezier/indicator_bezier.vrp',
	X = 'res/indicator/indicator_type_x/indicator_type_x.vrp',

	COMMON = 'res/indicator/indicator_common/indicator_common.vrp',
	TARGET = 'res/indicator/indicator_type_target/indicator_type_target.vrp',
	EFFECT = 'res/indicator/indicator_effect_target/indicator_effect_target.vrp',
}

-- 스킬 시전후 스킬 시전 범위 나타내는 이펙트..빨간색
RES_RANGE = 'res/effect/skill_range/skill_range.vrp'

-- 상태효과가 걸렸음을 가시적으로 표현하는 모션스트릭
RES_SE_MS = 'res/effect/motion_streak/motion_streak_feedback.png'

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

-------------------------------------
-- function playDragonVoice
-- @brief id를 가지고 dragon인지 판별
-------------------------------------
function playDragonVoice(type)
    local name = 'vo_' .. type

    if (SoundMgr:isExistSound('VOICE', name)) then
        SoundMgr:playEffect('VOICE', name)
    else
        SoundMgr:playEffect('VOICE', 'vo_silent')
    end
end

-------------------------------------
-- function getRelationItemId
-- @brief 드래곤 아이디(did)로부터 해당 드래곤 인연 포인트 아이템id를 얻음
-------------------------------------
function getRelationItemId(id)
    return (id + 640000)
end
