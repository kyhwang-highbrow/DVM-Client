local PARENT = StatusEffectUnit_Dot

-------------------------------------
-- class StatusEffectUnit_Dot_Heal
-------------------------------------
StatusEffectUnit_Dot_Heal = class(PARENT, {
        m_healType = '',
		m_healRate = '',
		m_healAbs = '', 
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_Dot_Heal:init(name, owner, caster, skill_id, value, duration)
    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]

    self.m_healType = t_status_effect['val_1']
	self.m_healRate = (self.m_value / 100)
	
	-- 절대수치 힐의 경우
	if (t_status_effect['abs_switch'] == 1) or (self.m_healType == 'hp_abs') then
		self.m_healAbs = (self.m_value)
	end
end

-------------------------------------
-- function doDot
-------------------------------------
function StatusEffectUnit_Dot_Heal:doDot()
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
