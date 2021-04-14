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
function StatusEffectUnit_Dot_Damage:init()
    self.m_dotDmg = self:calculateDotDmg()
end

-------------------------------------
-- function doDot
-------------------------------------
function StatusEffectUnit_Dot_Damage:doDot()
    -- 진형에 따른 데미지 배율
    local damage_rate = CalcDamageRateDueToFormation(self.m_owner)

    local damage = self.m_dotDmg * damage_rate

    self.m_owner:setDamage(nil, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, damage, nil)

	-- @LOG_CHAR : 공격자 데미지
	self.m_caster.m_charLogRecorder:recordLog('damage', damage)
	
	-- 화상 사운드
	if (self.m_statusEffectName == 'burn') then
		SoundMgr:playEffect('EFX', 'efx_burn')
    -- 중독 사운드
	elseif (self.m_statusEffectName == 'poison') then
        SoundMgr:playEffect('EFX', 'efx_poison')
    -- 출혈 사운드
	elseif (self.m_statusEffectName == 'bleed') then
        SoundMgr:playEffect('EFX', 'efx_bleed')
    end
end

-------------------------------------
-- function calculateDotDmg
-------------------------------------
function StatusEffectUnit_Dot_Damage:calculateDotDmg()
    local t_status_effect = TableStatusEffect():get(self.m_statusEffectName)
    local unit_type = self.m_owner.m_charTable['type']
	local damage_org
    local damage
    local dungeon_id = g_dmgateData:getDungeonID(self.m_owner.m_world.m_stageID)

    -----------------------------------------------------------
    -- 데미지 계산
    -----------------------------------------------------------
    if (isInstanceOf(self.m_owner, Monster_AncientRuinDragon) or isInstanceOf(self.m_owner, Monster_AncientRuinDragonBodyPart)) then
        -- 고대 유적 보스의 경우는 고정 데미지 3000으로 설정
        damage_org = 3000

    elseif (isInstanceOf(self.m_owner, Monster_ClanRaidBoss)) then
        -- 클랜 던전 보스의 경우는 고정 데미지 3000으로 설정
        damage_org = 3000

    elseif (isExistValue(unit_type, 'event_gmandragora')) then
        -- 이벤트 금화 던전의 만드라고라의 경우는 고정 데미지 3000으로 설정
        damage_org = 3000

    elseif (t_status_effect['abs_switch'] == 1) then 
		damage_org = self.m_value

    elseif (self.m_owner:isBoss() and dungeon_id == GAME_MODE_DIMENSION_GATE) then
        -- 상대가 보스고 
        -- 차원문에 있는 놈이면
        damage_org = 10000

	else
		-- 데미지 계산, 방어는 무시
	    local atk_dmg = self:getStandardStat()
	    local def_pwr = 0

	    damage_org = math_floor(DamageCalc_P(atk_dmg, def_pwr, false, true))
        damage_org = damage_org * (self.m_value / 100)
    end

    -- 게임 모드에 따른 데미지 배율 적용
    damage_org = damage_org * CalcDamageRateDueToGameMode(self.m_owner)

    -- 속성 효과
    --[[
	local t_attr_effect = self.m_owner:checkAttributeCounter(self.m_caster)
	if t_attr_effect['damage'] then
		damage = damage_org * (1 + (t_attr_effect['damage'] / 100))
	else
		damage = damage_org
	end
    ]]--
    damage = damage_org

    -- 최소 데미지는 1로 세팅
    damage = math_max(1, damage)

    return damage
end

-------------------------------------
-- function onChangeValue
-- @brief 적용값이 변경되었을 경우 호출(StatusEffect_Modify를 통한 적용값 변경 시)
-------------------------------------
function StatusEffectUnit_Dot_Damage:onChangeValue(new_value)
    PARENT.onChangeValue(self, new_value)

    self.m_dotDmg = self:calculateDotDmg()
end