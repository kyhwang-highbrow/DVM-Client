local PARENT = StatusEffectUnit

-------------------------------------
-- class StatusEffectUnit_Dot
-------------------------------------
StatusEffectUnit_Dot = class(PARENT, {
        -- 시간
		m_dotInterval = '',
		m_dotTimer = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_Dot:init(name, owner, caster, skill_id, value, source, duration)
    local t_status_effect = TableStatusEffect():get(self.m_statusEffectName)

    self.m_dotInterval = t_status_effect['dot_interval']
	self.m_dotTimer = 0
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectUnit_Dot:update(dt, modified_dt)
    self.m_dotTimer = self.m_dotTimer + modified_dt

	if (self.m_dotTimer > self.m_dotInterval) then
		self:doDot()
		self.m_dotTimer = self.m_dotTimer - self.m_dotInterval
	end
    
    return PARENT.update(self, dt, modified_dt)
end

-------------------------------------
-- function doDot
-------------------------------------
function StatusEffectUnit_Dot:doDot()
end