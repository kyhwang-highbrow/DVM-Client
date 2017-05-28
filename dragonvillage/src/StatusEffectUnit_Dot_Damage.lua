local PARENT = StatusEffectUnit_Dot

-------------------------------------
-- class StatusEffectUnit_Dot_Damage
-------------------------------------
StatusEffectUnit_Dot_Damage = class(PARENT, {
    m_dotDmg = 'number',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_Dot_Damage:init(name, owner, caster, skill_id, value, duration)
    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]

    -- 데미지 계산
    if (t_status_effect['abs_switch'] == 1) then 
		-- 절대 수치
		self.m_dotDmg = self.m_value
	else
		-- 상대 수치
		self.m_dotDmg = self:calculateDotDmg()
	end
end

-------------------------------------
-- function doDot
-------------------------------------
function StatusEffectUnit_Dot_Damage:doDot()
    self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, self.m_dotDmg, nil)

	-- @LOG_CHAR : 공격자 데미지
	self.m_caster.m_charLogRecorder:recordLog('damage', self.m_dotDmg)
	-- @LOG_CHAR : 방어자 피해량
	self.m_owner.m_charLogRecorder:recordLog('be_damaged', self.m_dotDmg)
end

-------------------------------------
-- function calculateDotDmg
-------------------------------------
function StatusEffectUnit_Dot_Damage:calculateDotDmg()
    local damage

	-- 데미지 계산, 방어는 무시
	local atk_dmg = self.m_caster:getStat('atk')
	local def_pwr = 0
	local damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr))

	-- 속성 효과
	local t_attr_effect = self.m_owner:checkAttributeCounter(self.m_caster)
	if t_attr_effect['damage'] then
		damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
	else
		damage = damage_org
	end

	-- 가중치 적용 시키면서 최소 데미지는 1로 세팅
	return math_max(1, damage * (self.m_value / 100))
end
