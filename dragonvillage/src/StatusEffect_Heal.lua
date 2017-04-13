local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Heal
-------------------------------------
StatusEffect_Heal = class(PARENT, {
		m_healType = '',
		m_healRate = '',
		m_healAbs = '', 
		m_healInterval = '',
		m_healTimer = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Heal:init(file_name, body)
end

-------------------------------------
-- function init_skill
-------------------------------------
function StatusEffect_Heal:init_heal(char, t_status_effect, status_effect_value, duration)
	self.m_owner = char
	self.m_healType = t_status_effect['val_1']
	self.m_healRate = (status_effect_value/100)
	self.m_healInterval = t_status_effect['dot_interval']
	self.m_healTimer = self.m_healInterval

	-- 절대수치 힐의 경우
	if (t_status_effect['abs_switch'] == 1) or (self.m_healType == 'hp_abs') then
		self.m_healAbs = (status_effect_value)
	end
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Heal:initState()
    self:addState('start', StatusEffect.st_start, 'center_start', false)
    self:addState('idle', StatusEffect_Heal.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect.st_end, 'center_end', false)
	self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function onStart_StatusEffect
-------------------------------------
function StatusEffect_Heal:onStart_StatusEffect()
	-- @TODO hael 애니메이션으로 인한 구조적 문제에 대한 임시방편 처리
	self.m_durationTimer = self.m_durationTimer + self.m_animator:getDuration()
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_Heal.st_idle(owner, dt)
	if (owner.m_owner.m_bDead) and (owner.m_state ~= 'end') then
        owner:changeState('end')
    end
	
    owner.m_healTimer = owner.m_healTimer + dt
    if (owner.m_healTimer > owner.m_healInterval) then
		owner:doHeal()
        owner.m_healTimer = owner.m_healTimer - owner.m_healInterval
    end
end

-------------------------------------
-- function doHeal
-------------------------------------
function StatusEffect_Heal:doHeal()
	-- 상대 체력의 n% 회복
	if (self.m_healType == 'hp_target') then 
		self.m_owner:healPercent(self.m_caster, self.m_healRate, false)

	-- 절대값 회복
	elseif (self.m_healType == 'hp_abs') then 
		self.m_owner:healAbs(self.m_caster, self.m_healAbs, false)

	-- 시전자의 데미지의 n% 회복
	elseif (self.m_healType == 'atk') then 
		local atk_dmg = self.m_caster:getStat('atk')
		local heal = HealCalc_M(atk_dmg)
		heal = (heal * self.m_healRate)
		self.m_owner:healAbs(self.m_caster, heal, false)
	end
end