local PARENT = StatusEffectUnit


-------------------------------------
-- class StatusEffectUnit_ConditionalBuff
-------------------------------------
StatusEffectUnit_ConditionalBuff = class(PARENT, {})

function StatusEffectUnit_ConditionalBuff:init(name, owner, caster, skill_id, value, source, duration, add_param)
    self.m_bExceptInDie = true

end


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