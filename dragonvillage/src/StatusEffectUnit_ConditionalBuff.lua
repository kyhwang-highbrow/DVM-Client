local PARENT = StatusEffectUnit


-------------------------------------
-- class StatusEffectUnit_ConditionalBuff
-------------------------------------
StatusEffectUnit_ConditionalBuff = class(PARENT, {
    m_chance = 'string'
})

-------------------------------------
-- function init
-------------------------------------
function StatusEffectUnit_ConditionalBuff:init(name, owner, caster, skill_id, value, source, duration, add_param)
    self.m_bExceptInDie = true

    local t_status_effect = TableStatusEffect():get(name)

    -- 변경할 상태효과를 구분하기 위한 조건 정보를 저장
    self.m_chance = t_status_effect['val_1']
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

-------------------------------------
-- function checkCondition
-------------------------------------
function StatusEffectUnit_ConditionalBuff:checkCondition()
    if (not UNIT_PASSIVE_CONDITION_FUNC[self.m_chance]) then
        return true
    end

    return UNIT_PASSIVE_CONDITION_FUNC[self.m_chance](self)
end