local PARENT = StatusEffect

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
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Resist:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:addTrigger('hit_barrier', self:getTriggerFunction())
end

-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect_Resist:init_top(file_name)
	-- top을 찍지 않는다
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
