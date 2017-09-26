local PARENT = StatusEffectUnit


-------------------------------------
-- class StatusEffectUnit_ConditionalBuff
-------------------------------------
StatusEffectUnit_ConditionalBuff = class(PARENT, {})

-------------------------------------
-- function addStatMulti
-------------------------------------
function StatusEffectUnit_ConditionalBuff:addStatMulti(key, value, is_passive)
    -- 패시브 여부에 상관없이 항상 버프로 처리
    self.m_owner.m_statusCalc:addBuffMulti(key, value)
end

-------------------------------------
-- function addStatAdd
-------------------------------------
function StatusEffectUnit_ConditionalBuff:addStatAdd(key, value, is_passive)
    -- 패시브 여부에 상관없이 항상 버프로 처리
    self.m_owner.m_statusCalc:addBuffAdd(key, value)
end