local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_DotDmg
-------------------------------------
StatusEffect_DotDmg = class(PARENT, {
		m_dotDmg = '',
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
function StatusEffect_DotDmg:init_dotDmg(char, t_status_effect, status_effect_value, caster_activity_carrier)
	self.m_owner = char
	local damage = 0

	if string.find(t_status_effect['name'], '_abs') then 
		-- 테이블 값이 절대값
		damage = t_status_effect['dot_dmg']
	else
		-- 데미지 계산
		local atk_dmg_stat = caster_activity_carrier:getAtkDmgStat()
		local atk_dmg = caster_activity_carrier:getStat(atk_dmg_stat)
		local def_pwr = 0 -- 방어 무관
		local damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr))
		-- 속성 효과
		local t_attr_effect = char:checkAttributeCounter(caster_activity_carrier)
		if t_attr_effect['damage'] then
			damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
		end
		damage = damage * (t_status_effect['dot_dmg'] / 100)
	end

	self.m_dotDmg = damage * (status_effect_value / 100)
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
			self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, self.m_dotDmg, nil)
			self.m_dotTimer = self.m_dotTimer - self.m_dotInterval
			self:changeState('start')
		end
	end

	return ret
end
