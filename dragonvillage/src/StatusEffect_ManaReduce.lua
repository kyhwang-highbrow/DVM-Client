local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ManaReduce
-------------------------------------
StatusEffect_ManaReduce = class(PARENT, {
    m_reduceValue = 'number',
    m_isInCondition = 'boolean',

    m_bUseCount = 'boolean',    -- 횟수 사용 여부
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ManaReduce:init(file_name, body)
    self.m_isInCondition = false
    self.m_bUseCount = false
end


-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_ManaReduce:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self.m_bUseCount = self:hasCount()

    if (self.m_bUseCount) then
        self:addTrigger('dragon_active_skill', self:getTriggerFunction())
    end
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
    if (not self.m_owner:isDragon()) then
        return
    end

    if (not self.m_owner:getSkillIndivisualInfo('active')) then
        return
    end

    -- 해당 드래곤의 마나를 reduceValue(add_option_value_1)만큼 감소시킨다.
    self.m_isInCondition = true

    if (self.m_owner:getStatusEffectCountBySubject('mana_reduce') == 1) then
        local originValue = self.m_owner:getOriginSkillManaCost()

        local new_mana_cost = originValue - self.m_reduceValue
        new_mana_cost = math_max(new_mana_cost, 1)
        
        self.m_owner:setSkillManaCost(new_mana_cost)
                
        local t_event = {}
        t_event['value'] = new_mana_cost
        self.m_owner:dispatch('dragon_mana_reduce', t_event)
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_ManaReduce:onEnd()
    if (not self.m_isInCondition) then return end

    if (self.m_owner:getStatusEffectCountBySubject('mana_reduce') <= 1) then
        local originValue = self.m_owner:getOriginSkillManaCost()

        self.m_owner:setSkillManaCost(originValue)

        local t_event = {}
        t_event['value'] = originValue
        self.m_owner:dispatch('dragon_mana_reduce_finish', t_event)
    end
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_ManaReduce:getTriggerFunction()
	local trigger_func = function(t_event)
        -- 1회만 사용되는 걸로 가정
        self:changeState('end')
	end

	return trigger_func
end


-------------------------------------
-- function isCountShield
-------------------------------------
function StatusEffect_ManaReduce:hasCount()
    local t_status_effect = self.m_statusEffectTable

    if (type(t_status_effect['val_1']) ~= 'string') then
        return false
    end

    return (t_status_effect['val_1'] == 'use_abs')
end