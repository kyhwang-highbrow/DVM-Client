local PARENT = class(StatusEffect_DotDmg, IEventListener:getCloneTable())

-------------------------------------
-- class StatusEffect_DotDmg_Bleed
-------------------------------------
StatusEffect_DotDmg_Bleed = class(PARENT, {
		-- 횟수
		m_maxDotCount = 'num',
		m_dotCount = 'num',

		m_trigger = 'str',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_DotDmg_Bleed:init(file_name, body)
	self.m_trigger = 'under_atk'
end

-------------------------------------
-- function init_dotDmg
-------------------------------------
function StatusEffect_DotDmg_Bleed:init_dotDmg(char, caster, t_status_effect, status_effect_value)
	PARENT.init_dotDmg(self, char, caster, t_status_effect, status_effect_value)

	-- 횟수 변수
	self.m_maxDotCount = t_status_effect['duration']
	self.m_dotCount = 0
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect_DotDmg_Bleed:onEvent(event_name, t_event, ...)
	if (event_name == self.m_trigger) then
		self:doDotDmg()
		self.m_dotCount = self.m_dotCount + 1
		if (self.m_dotCount >= self.m_maxDotCount) then
			self:changeState('end')
		end
	end
end

-------------------------------------
-- function onStart_StatusEffect
-------------------------------------
function StatusEffect_DotDmg_Bleed:onStart_StatusEffect()
	-- listner 등록
	self.m_owner:addListener(self.m_trigger, self)
end

-------------------------------------
-- function onEnd_StatusEffect
-------------------------------------
function StatusEffect_DotDmg_Bleed:onEnd_StatusEffect()
	-- listener 해제
	self.m_owner:removeListener(self.m_trigger, self)
end
