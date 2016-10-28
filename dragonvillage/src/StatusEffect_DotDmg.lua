local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_DotDmg
-------------------------------------
StatusEffect_DotDmg = class(PARENT, {
		m_dotlRate = '',
		m_dotInterval = '',
		m_dotTimer = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_DotDmg:init(file_name, body)
	self:initState()
end

-------------------------------------
-- function init_dotDmg
-------------------------------------
function StatusEffect_DotDmg:init_dotDmg(char, t_status_effect)	
	self.m_owner = char
	self.m_dotlRate = t_status_effect['dot_dmg'] / 100
	self.m_dotInterval = t_status_effect['dot_interval']
	
	-- 첫 틱에 데미지 들어가도록..
	self.m_dotTimer = self.m_dotInterval
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_DotDmg:initState()
    self:addState('start', StatusEffect.st_start, 'center_start', false)
    self:addState('idle', StatusEffect.st_idle, 'center_idle', false)
    self:addState('end', StatusEffect.st_end, 'center_end', false)
	self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_DotDmg:update(dt)
	local ret = PARENT.update(self, dt)

	if (self.m_state ~= 'end') then 
		if (self.m_owner.m_bDead) then
			self:changeState('end')
		end

		-- 반복
		self.m_dotTimer = self.m_dotTimer + dt
		if (self.m_dotTimer > self.m_dotInterval) then
			-- 트루퍼뎀 
			self.m_owner:dealPercent(self.m_dotlRate)
			self.m_dotTimer = self.m_dotTimer - self.m_dotInterval
			self:changeState('start')
		end
	end

	return ret
end
