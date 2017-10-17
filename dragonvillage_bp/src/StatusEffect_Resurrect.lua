local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Resurrect
-------------------------------------
StatusEffect_Resurrect = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Resurrect:init(file_name, body)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_Resurrect:onApplyOverlab(unit)
    local hp_rate = unit:getValue() / 100
        
    self.m_owner:doRevive(hp_rate, unit:getCaster())
end
