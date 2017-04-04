--------------------------------------------------------------------------
-- Status Effect 발동 조건
-- TODO: 차후 다시 한번 논의해서 정리해야 함(패시브 스킬의 Status Effect는 일괄적으로 none으로 쓰던지...)
--------------------------------------------------------------------------
-- #    always: 웨이브 시작시 발동 -> 캐릭터가 사망할 때 까지 유지. 해제 불가
-- #    wave_start: 웨이브 시작 시 발동

-- #    none : 발동하지 않음
STATUS_EFFECT_CON__NONE = 'none'

-- #    skill_action: 스킬 사용시 발동
STATUS_EFFECT_CON__SKILL_START = 'skill_start'
-- #    skill_end: 스킬이 종료된 후 발동
STATUS_EFFECT_CON__SKILL_END = 'skill_end'
-- #    hit: 자신의 공격이 적에게 적중 했을 때 발동
STATUS_EFFECT_CON__SKILL_HIT = 'hit'

-- =========구현되지 않음===============================
-- #    hit_cri: 자신의 공격이 치명타로 적중 했을 때 발동
STATUS_EFFECT_CON__SKILL_HIT_CRI = 'hit_cri'
-- #    slain: 자신의 공격으로 적 처치 시 발동
STATUS_EFFECT_CON__SKILL_SLAIN = 'slain'
-- #    undergo_attack: 자신이 공격 당했을 때 발동
-- #    dead: 자신이 죽을 경우 발동
-- #    avoid: 적의 공격을 회피 했을 때 발동
-- ===================================================



-- 변수명 고민중...
CON_SKILL_START = 'skill_start'
CON_SKILL_HIT = 'skill_hit'
CON_SKILL_END = 'skill_end'

