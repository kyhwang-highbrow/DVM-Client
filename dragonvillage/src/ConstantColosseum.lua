-- # 콜로세움 게임 속도
COLOSSEUM__TIME_SCALE = 1

-- # 콜로세움 적군 캐스팅 시간
COLOSSEUM__ENEMY_CASTING_TIME = 2

-- 스킬(드래그)들의 AI 속성
SKILL_AI_ATTR__ATTACK = 'attack'
SKILL_AI_ATTR__BUFF = 'buff'
SKILL_AI_ATTR__DEBUFF = 'debuff'
SKILL_AI_ATTR__RECOVERY = 'recovery'
SKILL_AI_ATTR__DISPELL = 'dispell'
SKILL_AI_ATTR__HEAL = 'heal'
SKILL_AI_ATTR__GUARDIAN = 'guardian'

-- 스킬(드래그)들의 AI 속성별 타겟 타입
SKILL_AI_ATTR_TARGET = {}
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__ATTACK] = 'enemy_random'
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__BUFF] = 'ally_random'
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__DEBUFF] = 'enemy_random'
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__RECOVERY] = 'enemy_random'
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__DISPELL] = 'ally_debuff'
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__HEAL] = 'ally_hp_low'
SKILL_AI_ATTR_TARGET[SKILL_AI_ATTR__GUARDIAN] = 'teammate_hp_low'


-- 스킬 사용 불가 시 원인 타입
REASON_TO_DO_NOT_USE_SKILL = {
    DEAD            = 1,
    NO_INDICATOR    = 2,
    COOL_TIME       = 3,
    MANA_LACK       = 4,
    NO_MANA         = 5,
    STATUS_EFFECT   = 6,
    USING_SKILL     = 7,
    NO_ENABLE       = 8,
    LOCK            = 9,
}