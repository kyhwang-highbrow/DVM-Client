local PARENT = StatusEffect_DotDmg

-------------------------------------
-- class StatusEffect_DotDmg_Burn
-------------------------------------
StatusEffect_DotDmg_Burn = class(PARENT, {
		-- 시간
		m_dotInterval = '',
		m_dotTimer = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_DotDmg_Burn:init(file_name, body)
end

-------------------------------------
-- function init_dotDmg
-------------------------------------
function StatusEffect_DotDmg_Burn:init_dotDmg(char, caster, t_status_effect, status_effect_value)
	PARENT.init_dotDmg(self, char, caster, t_status_effect, status_effect_value)

	-- 시간 변수 (지속 시간은 외부에서 duration으로)
	self.m_dotInterval = t_status_effect['dot_interval']
	self.m_dotTimer = self.m_dotInterval
end

-------------------------------------
-- function onIdle
-------------------------------------
function StatusEffect_DotDmg_Burn:onIdle(dt)
	if (self.m_owner.m_bDead) then
		self:changeState('end')
	end

	-- 반복
	self.m_dotTimer = self.m_dotTimer + dt
	if (self.m_dotTimer > self.m_dotInterval) then
		self:doDotDmg()
		self.m_dotTimer = self.m_dotTimer - self.m_dotInterval
	end
end