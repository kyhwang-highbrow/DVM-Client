local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Bleed
-------------------------------------
StatusEffect_Bleed = class(PARENT, {
    m_dmg   = 'number',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Bleed:init(file_name, body)
    self.m_statusEffectInterval = 0

    self.m_triggerName = 'under_atk'
    self.m_triggerFunc = function()
        self:doDamage()
    end

    self.m_dmg = 0
end

-------------------------------------
-- function onApplyOverlab
-- @brief 중첩될때마다 적용되어야하는 효과를 적용
-------------------------------------
function StatusEffect_Bleed:onApplyOverlab(unit)
    local b = PARENT.onApplyOverlab(self, unit)

    -- 데미지 계산, 방어는 무시
    local caster = unit:getCaster()
    local damage
	local atk_dmg = caster:getStat('atk')
	local def_pwr = 0
	local damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr))

	-- 속성 효과
	local t_attr_effect = self.m_owner:checkAttributeCounter(caster)
	if t_attr_effect['damage'] then
		damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
	else
		damage = damage_org
	end

    -- 가중치 적용 시키면서 최소 데미지는 1로 세팅
    damage = math_max(1, damage * (unit:getValue() / 100))

    -- 해당 정보를 임시 저장
    unit:setParam('damage', damage)
	
    -- 데미지 가산
	self.m_dmg = self.m_dmg + damage
            
    return b
end

-------------------------------------
-- function onUnapplyOverlab
-- @brief 중첩될때마다 적용되어야하는 효과를 해제
-------------------------------------
function StatusEffect_Bleed:onUnapplyOverlab(unit)
    local b = PARENT.onUnapplyOverlab(self, unit)

     -- 데미지 감산
    local damage = unit:getParam('damage')

    self.m_dmg = self.m_dmg - damage
            
    return b
end

-------------------------------------
-- function doDamage
-------------------------------------
function StatusEffect_Bleed:doDamage()
	self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, self.m_dmg, nil)

    -- 중첩별 로그 처리
    for _, list in pairs(self.m_mUnit) do
        for i, unit in ipairs(list) do
            -- @LOG_CHAR : 공격자 데미지
            local damage = unit:getParam('damage')
            local caster = unit:getCaster()
	        caster.m_charLogRecorder:recordLog('damage', damage)
        end
    end

    -- @LOG_CHAR : 방어자 피해량
	self.m_owner.m_charLogRecorder:recordLog('be_damaged', self.m_dmg)
end