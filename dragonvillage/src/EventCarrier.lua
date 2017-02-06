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
