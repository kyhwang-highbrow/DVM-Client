local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Resist
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_Resist = class(PARENT, {
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
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Resist:getTriggerFunction()
	local trigger_func = function(t_event)
		self.m_animator:changeAni('hit', false)
        self:addAniHandler(function()
            self.m_animator:changeAni('idle', true)
        end)
	end

	return trigger_func
end
