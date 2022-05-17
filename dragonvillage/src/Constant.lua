-- 기준 해상도 (16:9 비율)
CRITERIA_RESOLUTION_X = 1280
CRITERIA_RESOLUTION_Y = 720

-- 최대 해상도
MAX_RESOLUTION_X = 1480
MAX_RESOLUTION_Y = 960

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

KEY_F1 = 44
KEY_F2 = 45
KEY_F3 = 46
KEY_F4 = 47

KEY_ESCAPE = 6
KEY_SPACE = 56
KEY_LEFT_BRACKET = 116
KEY_BACK_SLASH = 117
KEY_RIGHT_BRACKET = 118
KEY_UNDERSCORE = 119
KEY_GRAVE = 120
KEY_SEMICOLON = 84

-- TEMP
UNDER_LINE_PNG = 'res/common/underline.png'
EMPTY_PNG = 'res/common/empty.png'
EMPTY_TABLE = {}
ZERO_POINT = cc.p(0, 0)
TOP_CENTER = cc.p(0.5, 1.0)
CENTER_POINT = cc.p(0.5, 0.5)
BOT_CENTER = cc.p(0.5, 0)
BOT_RIGHT = cc.p(1, 0)
--ONE_POINT = cc.p(1, 1)
TOP_LEFT = cc.p(0, 1)
TOP_RIGHT = cc.p(1, 1)

EQUATION_FUNC = {}

-- # 1 frame
ONE_FRAME = 1/30

FRIEND_MATCH_STAGE_ID = 80000
ARENA_FRIEND_MATCH_STAGE_ID = 80001
COLOSSEUM_STAGE_ID = 90000
ARENA_STAGE_ID = 90001
CHALLENGE_MODE_STAGE_ID = 90002
GRAND_ARENA_STAGE_ID = 90003 -- 그랜드 콜로세움 (이벤트 PvP 10대10)
CLAN_WAR_STAGE_ID = 90004

ARENA_NEW_STAGE_ID = 90005

PRESET_STAGE_ID = -999999
DEV_STAGE_ID = 999999

INTRO_STAGE_ID = 1010001
CLAN_RAID_STAGE_ID = 1500100
EVENT_GOLD_STAGE_ID = 1900001
ANCIENT_RUIN_STAGE_ID = 1600001

GOLD_DUNGEON_ALWAYS_OPEN = false

-- # deck명칭 임시 (20180917 sgkim)
DECK_CHALLENGE_MODE = 'challenge'

--------------------------------------------------------------------------
-- PhysKey 상수
--------------------------------------------------------------------------
PHYS = {
	HERO = 'hero',
    HERO_TOP = 'hero_top',
    HERO_BOTTOM = 'hero_bottom',

	ENEMY = 'enemy',
    ENEMY_TOP = 'enemy_top',
    ENEMY_BOTTOM = 'enemy_bottom',

	EFFECT = 'effect',
	MISSILE = {
		HERO = 'missile_h',
        HERO_TOP = 'missile_h_t',
        HERO_BOTTOM = 'missile_h_b',

		ENEMY = 'missile_e',
        ENEMY_TOP = 'missile_e_t',
        ENEMY_BOTTOM = 'missile_e_b'
	},
    TAMER = 'tamer',
}

--------------------------------------------
-- State priority
--------------------------------------------
PRIORITY =
{
	STUN = 2,
    SUCCESS_POSE = 8,
	DYING = 9,
	DEAD = 10,
}

--------------------------------------------
-- World Z-Order Priority
--------------------------------------------
WORLD_Z_ORDER = 
{
    TAMER = -1,
    MISSILE = 0,
    BOSS = 10,
    ENEMY = 20,
    HERO = 30,
	SE_EFFECT = 40,
    FRONT_EFFECT = 50,
    CASTING = 100,
}
--------------------------------------------
-- INGAME_LAYER_Z_ORDER
--------------------------------------------
INGAME_LAYER_Z_ORDER = 
{
    BG_LAYER = 0,
    DARK_LAYER = 1,
    DRAGON_SKILL_BG_LAYER = 2,
    GROUND_LAYER = 3,
    GRID_LAYER = 4,
    BOTTOM_LAYER = 5,
    WORLD_LAYER = 6,
    MISSILE_LAYER = 7,

    UNIT_STATUS_LAYER = 8,
    UNIT_INFO_LAYER = 9,
    ENEMY_SPEECH_LAYER = 10,

    DRAGON_INFO_LAYER = 11,
    DRAGON_SPEECH_LAYER = 12,

    LOCK_ON_LAYER = 13,
}

--------------------------------------------
-- INGAME_ACTION_TAG
--------------------------------------------
CHARACTER_ACTION_TAG__ROAM = 0
CHARACTER_ACTION_TAG__SHAKE = 1
CHARACTER_ACTION_TAG__KNOCKBACK = 2
CHARACTER_ACTION_TAG__SHADER = 3
CHARACTER_ACTION_TAG__FLOATING = 4
CHARACTER_ACTION_TAG__SCALE = 5
CHARACTER_ACTION_TAG__DYING = 9
TAMER_ACTION_TAG__MOVE_Z = 10
ANIMATOR_ACTION_TAG__END = 999

--------------------------------------------
-- INGAME_PAUSE_TAG
--------------------------------------------
INGAME_PAUSE__TUTORIAL_TALK = 1
INGAME_PAUSE__ACTIVE_SKILL = 2
INGAME_PAUSE__INDICATOR = 3
INGAME_PAUSE__NEXT_FRAME = 99


-- 스킬 시전후 스킬 시전 범위 나타내는 이펙트..빨간색
RES_RANGE = 'res/effect/skill_range/skill_range.vrp'

-- 상태효과가 걸렸음을 가시적으로 표현하는 모션스트릭
RES_SE_MS = 'res/effect/motion_streak/motion_streak_feedback.png'

--------------------------------------------
-- SERVER_NAME
--------------------------------------------
SERVER_NAME = {
    KOREA = 'Korea',
    AMERICA = 'America',
    ASIA = 'Asia',
    JAPAN = 'Japan',
    EUROPE = 'Europe',
    GLOBAL = 'Global',

    DEV = 'DEV',
    QA = 'QA', 
    DVM2_DEV = 'DVM2_DEV'
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
    local id  = math_floor(id / 10000)
    return (id == 13 or id == 14 or id == 15 or id == 20 or id == 21 or id == 30)
end


-------------------------------------
-- function isJako
-- @brief table_dragon, table_dragon_evolution에서 진화형이 없고 드래곤이 아닌 종류를 통칭
-------------------------------------
function isJako(id)
    local id  = math_floor(id / 10000)
    return (id == 18)
end

-------------------------------------
-- function isSummonObject
-- @brief id를 가지고 소환체인지 판별
-------------------------------------
function isSummonObject(id)
    local id  = math_floor(id / 10000)
    return (id == 90)
end

-------------------------------------
-- function getRelationItemId
-- @brief 드래곤 아이디(did)로부터 해당 드래곤 인연 포인트 아이템id를 얻음
-------------------------------------
function getRelationItemId(id)
    return (id + 640000)
end

