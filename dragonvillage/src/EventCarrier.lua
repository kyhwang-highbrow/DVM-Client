------------------------------
-- event EVENT_CARRIER
-- @brief Event dispatcher & listener 에서 사용할 Event 구조체
------------------------------
EVENT_CARRIER = {}
EVENT_CARRIER['type'] = 'event'
EVENT_CARRIER['is_handled'] = false

------------------------------
-- event hit
-- @brief hit, undergoAttack 관련 이벤트에서 사용
------------------------------
EVENT_HIT_CARRIER = clone(EVENT_CARRIER)
EVENT_HIT_CARRIER['damage'] = 0
EVENT_HIT_CARRIER['reduced_damage'] = 0
EVENT_HIT_CARRIER['is_critical'] = false
EVENT_HIT_CARRIER['attacker'] = ''
EVENT_HIT_CARRIER['defender'] = ''
EVENT_HIT_CARRIER['i_x'] = 0
EVENT_HIT_CARRIER['i_y'] = 0

------------------------------
-- event change hp
-- @brief hp 변동
------------------------------
EVENT_CHANGE_HP_CARRIER = clone(EVENT_CARRIER)
EVENT_CHANGE_HP_CARRIER['owner'] = ''
EVENT_CHANGE_HP_CARRIER['hp'] = 0
EVENT_CHANGE_HP_CARRIER['max_hp'] = 0

------------------------------
-- event EVENT_DRAGON_SKILL_GAUGE
-- @brief 드래곤 스킬 게이지 변동
------------------------------
EVENT_DRAGON_SKILL_GAUGE = clone(EVENT_CARRIER)
EVENT_DRAGON_SKILL_GAUGE['owner'] = ''
EVENT_DRAGON_SKILL_GAUGE['percentage'] = 0