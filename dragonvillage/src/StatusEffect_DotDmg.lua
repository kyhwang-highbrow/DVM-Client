local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_DotDmg
-------------------------------------
StatusEffect_DotDmg = class(PARENT, {
		m_dotDmg = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_DotDmg:init(file_name, body)
end

-------------------------------------
-- function init_dotDmg
-------------------------------------
function StatusEffect_DotDmg:init_dotDmg(char, caster, t_status_effect, status_effect_value)
	self.m_owner = char
	
	-- 데미지 계산
	if (t_status_effect['abs_switch'] == 1) then 
		-- 절대 수치
		self.m_dotDmg = status_effect_value
	else
		-- 상대 수치
		self.m_dotDmg = self:calculateDotDmg(caster, t_status_effect, status_effect_value)
	end

end

-------------------------------------
-- function initState
-----------------/--------------------
function StatusEffect_DotDmg:initState()
	self:addState('start', StatusEffect_DotDmg.st_start, 'center_start', false)
    self:addState('idle', StatusEffect_DotDmg.st_idle, 'center_idle', true)
	self:addState('end', StatusEffect_DotDmg.st_end, 'center_end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function calculateDotDmg
-------------------------------------
function StatusEffect_DotDmg:calculateDotDmg(caster, t_status_effect, status_effect_value)
	local damage

	-- 데미지 계산, 방어는 무시
	local atk_dmg = caster:getStat('atk')
	local def_pwr = 0
	local damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr))

	-- 속성 효과
	local t_attr_effect = self.m_owner:checkAttributeCounter(caster:getAttribute())
	if t_attr_effect['damage'] then
		damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
	else
		damage = damage_org
	end

	-- 가중치 적용 시키면서 최소 데미지는 1로 세팅
	return math_max(1, damage * (status_effect_value / 100))
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_DotDmg.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
    end
	owner:onIdle(dt)
end

-------------------------------------
-- function onIdle
-------------------------------------
function StatusEffect_DotDmg:onIdle(dt)
end

-------------------------------------
-- function doDotDmg
-------------------------------------
function StatusEffect_DotDmg:doDotDmg()
	self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, self.m_dotDmg, nil)

	-- @LOG_CHAR : 공격자 데미지
	self.m_caster.m_charLogRecorder:recordLog('damage', self.m_dotDmg)
	-- @LOG_CHAR : 방어자 피해량
	self.m_owner.m_charLogRecorder:recordLog('be_damaged', self.m_dotDmg)
end