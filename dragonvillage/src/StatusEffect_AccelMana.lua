local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AccelMana
-------------------------------------
StatusEffect_AccelMana = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AccelMana:init(file_name, body)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_AccelMana:onApplyOverlab(unit)
    local duration = unit:getDuration()

    self.m_world:startManaAccel(self.m_owner, duration)

    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end