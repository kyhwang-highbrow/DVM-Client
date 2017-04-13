local PARENT = StatusEffect_DotDmg

-------------------------------------
-- class StatusEffect_DotDmg_Bleed
-------------------------------------
StatusEffect_DotDmg_Bleed = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_DotDmg_Bleed:init(file_name, body)
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_DotDmg_Bleed:update(dt)
	local ret = PARENT.update(self, dt)

	if (self.m_state ~= 'end') then 
		if (self.m_owner.m_bDead) then
			self:changeState('end')
		end

		-- 반복
		self.m_dotTimer = self.m_dotTimer + dt
		if (self.m_dotTimer > self.m_dotInterval) then
			self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, self.m_dotDmg, nil)
			self.m_dotTimer = self.m_dotTimer - self.m_dotInterval
			self:changeState('start')
		end
	end

	return ret
end
