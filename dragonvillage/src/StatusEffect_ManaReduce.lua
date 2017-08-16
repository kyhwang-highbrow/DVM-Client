local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ManaReduce
-------------------------------------
StatusEffect_ManaReduce = class(PARENT, {
    m_reduceValue = 'number',
    m_originValue = 'number',
    m_isInCondition = 'boolean',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ManaReduce:init(file_name, body)
    self.m_isInCondition = false
end

-------------------------------------
-- function init_status
-------------------------------------
function StatusEffect_ManaReduce:init_status(reduceValue)
    self.m_reduceValue = reduceValue 
end

-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_ManaReduce:onStart()
    -- 중첩된 유닛이 없는 경우에 해당 드래곤의 마나를 reduceValue(add_option_value_1)만큼 감소시킨다.
    if (self.m_owner.m_charType == 'dragon' and type(self.m_owner:getSkillIndivisualInfo('active')) == 'table') then
        self.m_isInCondition = true

        self.m_originValue = self.m_owner.m_activeSkillManaCost
        self.m_owner.m_activeSkillManaCost = self.m_owner.m_activeSkillManaCost - self.m_reduceValue 
        if(self.m_owner.m_activeSkillManaCost < 1) then
            self.m_owner.m_activeSkillManaCost = 1
        end
        local t_event = {}
        t_event['value'] = self.m_owner.m_activeSkillManaCost
        self.m_owner:dispatch('dragon_mana_reduce', t_event)
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_ManaReduce:onEnd()
    if (self.m_isInCondition) then
        self.m_owner.m_activeSkillManaCost = self.m_originValue
        local t_event = {}
        t_event['value'] = self.m_owner.m_activeSkillManaCost
        self.m_owner:dispatch('dragon_mana_reduce_finish', t_event)
    end
end
