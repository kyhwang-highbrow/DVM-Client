local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Resist
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_Resist = class(PARENT, {
		m_resistRate = 'number', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Resist:init(file_name, body, ...)
    -- 보호막은 트리거 쿨타임을 적용하지 않는다.
	self.m_statusEffectInterval = 0

    self.m_triggerName = 'hit_barrier'

    self.m_resistRate = 0
end


-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect_Resist:init_top(file_name)
	-- top을 찍지 않는다
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Resist:initState()
    PARENT.initState(self)

	self:addState('start', PARENT.st_start, 'appear', false)
    self:addState('idle', PARENT.st_idle, 'idle', true)
	self:addState('end', PARENT.st_end, 'disappear', false)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_Resist:onApplyOverlab(unit)
    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]
    local adj_value = t_status_effect['dmg_adj_rate'] * (unit:getValue() / 100)
	local resist_rate = (adj_value / 100)

    -- 해당 정보를 임시 저장
    unit:setParam('resist_rate', resist_rate)

    -- 저항력 가산
    self.m_resistRate = self.m_resistRate + resist_rate
end

-------------------------------------
-- function onUnapplyOverlab
-- @brief 해당 상태효과가 중첩 해제될시마다 호출
-------------------------------------
function StatusEffect_Resist:onUnapplyOverlab(unit)
    -- 저항력 감산
    local resist_rate = unit:getParam('resist_rate')

    self.m_resistRate = self.m_resistRate - resist_rate
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Resist:getTriggerFunction()
	local trigger_func = function(t_event)
		self.m_animator:changeAni('hit', false)
        self:addAniHandler(function()
            self.m_animator:changeAni('idle', true)
        end)

        -- 1. 데미지를 직접 경감
		local damage = t_event['damage']
   		damage = damage * (1 + self.m_resistRate)
		t_event['damage'] = damage
		t_event['is_handled'] = true
	end

	return trigger_func
end
