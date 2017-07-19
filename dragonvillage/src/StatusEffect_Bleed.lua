local PARENT = StatusEffect

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
    self.m_dmg = 0
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Bleed:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:addTrigger('under_atk', function(t_event, ...)
        self:doDamage()
    end)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_Bleed:onApplyOverlab(unit)
    -- 데미지 계산, 방어는 무시
    local caster = unit:getCaster()
    local damage
	local damage_org

    if (self.m_bAbs) then
        damage_org = unit:getValue()
    else
        local atk_dmg = unit:getStandardStat()
	    local def_pwr = 0

        damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr))
        damage_org = damage_org * (unit:getValue() / 100)
    end

	-- 속성 효과
	local t_attr_effect = self.m_owner:checkAttributeCounter(caster)
	if t_attr_effect['damage'] then
		damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
	else
		damage = damage_org
	end

    -- 최소 데미지는 1로 세팅
    damage = math_max(1, damage)

    -- 해당 정보를 임시 저장
    unit:setParam('damage', damage)
	
    -- 데미지 가산
	self.m_dmg = self.m_dmg + damage
end

-------------------------------------
-- function onUnapplyOverlab
-- @brief 해당 상태효과가 중첩 해제될시마다 호출
-------------------------------------
function StatusEffect_Bleed:onUnapplyOverlab(unit)
    -- 데미지 감산
    local damage = unit:getParam('damage')

    self.m_dmg = self.m_dmg - damage
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

	-- 화상 사운드
	if (self.m_statusEffectName == 'poison') then
		SoundMgr:playEffect('EFX', 'efx_poison')

	elseif (self.m_statusEffectName == 'bleed') then
		SoundMgr:playEffect('EFX', 'efx_bleed')

	end
end