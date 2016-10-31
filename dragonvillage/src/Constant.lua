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

-- 윈도우에서 사용
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

UNDER_LINE_PNG = 'res/common/underline.png'
EMPTY_PNG = 'res/common/empty.png'
EMPTY_TABLE = {}

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
-- function dragonRoleName
-- @brief 
-------------------------------------
function dragonRoleName(role_type)
    if (role_type == 'dealer') then
        return Str('공격형')
    elseif (role_type == 'tanker') then
        return Str('방어형')
    elseif (role_type == 'supporter') then
        return Str('지원형')
    else
        error('role_type: ' .. role_type)
    end
end

-------------------------------------
-- function dragonAttackTypeName
-- @brief 
-------------------------------------
function dragonAttackTypeName(attack_type)
    if (attack_type == 'physical') then
        return Str('물리공격형')
    elseif (attack_type == 'magical') then
        return Str('마법공격형')
    else
        error('attack_type: ' .. attack_type)
    end
end