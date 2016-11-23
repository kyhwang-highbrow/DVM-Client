local CHARACTER_ACTION_TAG__SHAKE = 1
local CHARACTER_ACTION_TAG__KNOCKBACK = 2
local CHARACTER_ACTION_TAG__SHADER = 3
local CHARACTER_ACTION_TAG__FLOATING = 4

-------------------------------------
-- class Character
-------------------------------------
Character = class(Entity, IEventDispatcher:getCloneTable(), IDragonSkillManager:getCloneTable(), {
        m_bDead = '',
        m_maxHp = '',
        m_hp = '',

        m_statusCalc = '',
        m_stateDelegate = 'CharacterStateDelegate',

        -- @ for FormationMgr
        m_bLeftFormation = 'boolean',   -- 왼쪽 진형일 경우 true, 오른쪽 진형일 경우 false
        m_currFormation = '',
        m_cbChangePos = 'function',

        -- @ 공격 속도
        m_chargeDuration = 'number',
        m_attackAnimaDuration = 'number',
        m_attackPeriod = 'number',

        -- @ attack상태 관리하는 변수들
        m_bLuanchMissile = 'boolean',       -- MissileLauncher생성 여부
        m_bFinishAttack = 'boolean',        -- MissileLauncher가 공격을 완료했는지 여부
        m_bFinishAnimation = 'boolean',     -- 'attack'에니메이션 재생 완료 여부
        m_bFirstAttack = 'boolean',         -- 최초의 공격일 경우

        -- @ 예약된 skill 정보
        m_reservedSkillId = 'number',
        m_reservedSkillCastTime = 'number',
        m_reservedSkillAniEventTime = 'number', -- 스킬 애니메이션에서의 attack 이벤트 시간
        m_isAddSkill = 'bool', -- 드래곤이 에약한 스킬이 basic_rate나 basic_turn 인 경우

        -- @ target
        m_targetChar = 'Character',

        -- @hp UI
        m_hpNode = '',
        m_hpGauge = '',
        m_hpGauge2 = '',
        m_hpUIOffset = '',

        -- @casting UI
        m_castingNode = '',
        m_castingGauge = '',
        m_castingEffect = '',

        m_castingUI = '',
        m_castingMarkGauge = '',
        m_castingSpeechVisual = '',

        -- @이동 관련
        m_isOnTheMove = 'boolean',

		-- @TODO - 향후에 삭제 해야 함. 인터페이스로 대체 
        m_hpEventListener = 'list',
        m_undergoAttackEventListener = 'list',
        m_damagedEventListener = 'list',   -- 데미지를 입었을 때 이벤트

        -- @ 위치 관련(전투 중 기본 위치)
        m_orgHomePosX = 'number',
        m_orgHomePosY = 'number',
        m_homePosX = 'number',
        m_homePosY = 'number',

        -- 보호막 스킬
        m_buffProtection = 'Buff_Protection',
        m_lProtectionList = 'list',

        m_attackOffsetX = 'number',
        m_attackOffsetY = 'number',

        m_aiParam = '',
        m_aiParamNum = '',
        m_sortValue = '',				-- 타겟 찾기 등의 정렬에서 임의로 사용
        m_sortRandomIdx = '',			-- 타겟 찾기 등의 정렬에서 임의로 사용
        m_chargeSkill = '',

        m_targetEffect = '',

        m_lActivedSkill = '',

		m_lStatusEffect = 'table',
        m_tOverlabStatusEffect = 'table',
		m_lStatusIcon = 'sprite table',
        m_comebackNextState = 'state',

        -- 피격시 경직 관련
        m_bEnableSpasticity = 'boolean',-- 경직 가능 활성화 여부
        m_isSpasticity = 'boolean',     -- 경직 중 여부
        m_delaySpasticity = 'number',   -- 경직 남은 시간
     })

local SpasticityTime = 0.2

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Character:init(file_name, body, ...)
    self.m_bDead = false

    self.m_chargeDuration = 0
    self.m_attackAnimaDuration = 0
    self.m_isOnTheMove = false

	self.m_undergoAttackEventListener = {}
    self.m_tOverlabStatusEffect = {}
	self.m_lStatusEffect = {}
	self.m_lStatusIcon = {}

    self.m_bEnableSpasticity = true
    self.m_isSpasticity = false
    self.m_delaySpasticity = 0
end

-------------------------------------
-- function setDead
-------------------------------------
function Character:setDead()
    self.m_bDead = true
    self:dispatch('character_dead', self)

    -- 사망 처리 시 StateDelegate Kill!
    self:killStateDelegate()
end

-------------------------------------
-- function getTargetList
-- @brief skill table을 인자로 받는 경우..
-------------------------------------
function Character:getTargetList(t_skill)
	local target_type = t_skill['target_type']
    return self:getTargetListByType(target_type)
end

-------------------------------------
-- function getTargetListByType
-------------------------------------
function Character:getTargetListByType(target_type)
	if (target_type == 'x') then 
		error('타겟 타입이 x인데요? 테이블 수정해주세요')
	end

    local table_skill_target = TABLE:get('skill_target')
    local t_skill_target = table_skill_target[target_type]

    local target_team = t_skill_target['fof']
    local target_formation = self.m_charTable['target_formation']
    local target_rule = t_skill_target['rule']

    local t_ret = self.m_world:getTargetList(self, self.pos.x, self.pos.y, target_team, target_formation, target_rule)
    return t_ret
end

-------------------------------------
-- function checkTarget
-------------------------------------
function Character:checkTarget(t_skill)
    local t_ret = self:getTargetList(t_skill)
    self.m_targetChar = t_ret[1]
end


-------------------------------------
-- function initStatus
-------------------------------------
function Character:initStatus(t_char, level, grade, evolution, doid)
    local level = level or 1
    self.m_charTable = t_char
	
    -- 능력치 계산기
    local grade = (grade or 1)
    local evolution = (evolution or 1)

    if (self.m_charType == 'dragon') then
       self.m_statusCalc = MakeOwnDragonStatusCalculator(doid)
    elseif (self.m_charType == 'enemy') then
        self.m_statusCalc = StatusCalculator(self.m_charType, self.m_charTable['mid'], level, grade, evolution)
    else
        error('self.m_charType : ' .. self.m_charType)
    end

    local hp = self.m_statusCalc:getFinalStat('hp')
    self.m_maxHp = hp
    self.m_hp = hp
end

-------------------------------------
-- function checkAttributeCounter
-- @brief 속성 상성
-------------------------------------
function Character:checkAttributeCounter(attack_damage)
    -- 공격자 속성
    local attacker_attr = attributeNumToStr(attack_damage.m_attribute)

    -- 방어자 속성
    local defender_attr = self.m_charTable['attr']

    local t_attr_effect = getAttrSynastryEffect(attacker_attr, defender_attr)

    return t_attr_effect
end

-------------------------------------
-- function undergoAttack
-------------------------------------
function Character:undergoAttack(attacker, defender, i_x, i_y, is_protection)

    if (not attacker.m_activityCarrier) then
        --cclog('attacker.m_activityCarrier nil')
        return
    end

	-- SkillProtection defender check
    if (not is_protection) and self.m_lProtectionList and (table.count(self.m_lProtectionList) > 0) then
        for i,v in pairs(self.m_lProtectionList) do
            v:onHit()
            local defender = v.m_owner
            return defender:undergoAttack(attacker, defender, defender.pos.x, defender.pos.y, true)
        end
    end

    -- 속성 효과
    local t_attr_effect = self:checkAttributeCounter(attacker.m_activityCarrier)

    -- 데미지 타입
    local dmg_type = attacker.m_activityCarrier.m_damageType or DMG_TYPE_PHYSICAL

    -- 공격력 계산, 크리티컬 계산
    local atk_dmg, critical = 0, false
    local def_pwr = 0

    local damage = 0

    -- 데미지 계산
    do
		-- 공격력으로 사용할 스탯
		local atk_dmg_stat = attacker.m_activityCarrier:getAtkDmgStat()

        atk_dmg = attacker.m_activityCarrier:getStat(atk_dmg_stat)
        def_pwr = self.m_statusCalc:getFinalStat('def')

		-- 방어 무시 체크
		if (attacker.m_activityCarrier:isIgnoreDef()) then def_pwr = 0 end

        damage = math_floor(DamageCalc_P(atk_dmg, def_pwr))
    end

    do -- 크리티컬(치명타) 계산
        local critical_chance = attacker.m_activityCarrier:getStat('cri_chance')
        local critical_avoid = self.m_statusCalc:getFinalStat('cri_avoid')
        local final_critical_chance = (critical_chance - critical_avoid)

        -- 속성 상성 적용
        if t_attr_effect['cri_chance'] then
            final_critical_chance = (final_critical_chance + t_attr_effect['cri_chance'])
        end

        critical = (math_random(1, 1000) <= (final_critical_chance * 10))
    end

    local attr_bonus_dmg = 0 -- 속성에 의해 추가된 데미지
    do -- 데미지 관련
        local damage_multifly = 1

        -- 크리티컬
        if critical then
            damage_multifly = (attacker.m_activityCarrier:getStat('cri_dmg') / 100)
        end

        -- 속성
        if t_attr_effect['damage'] then
            local attr_dmg_multifly = (t_attr_effect['damage'] / 100)
            attr_bonus_dmg = (damage * attr_dmg_multifly)
            damage_multifly = damage_multifly + attr_dmg_multifly
        end

		-- 상태효과에 의한 증감
		damage_multifly = (damage_multifly + self.m_statusCalc.m_lPassive['dmg_adj_rate'] / 100)

        damage = (damage * damage_multifly)
    end

    -- 스킬계수 적용
    attr_bonus_dmg = math_floor(attr_bonus_dmg * attacker.m_activityCarrier.m_skillCoefficient)
    damage = math_floor(damage * attacker.m_activityCarrier.m_skillCoefficient)

    attr_bonus_dmg = math_min(attr_bonus_dmg, damage)
		
	if PRINT_ATTACK_INFO then
		cclog('######################################################')
		cclog('공격자 : ' .. attacker.m_activityCarrier.m_activityCarrierOwner:getName())
		cclog('방어자 : ' .. defender:getName())
		cclog('공격 타입 : ' .. attacker.m_activityCarrier:getAttackType())
		cclog(' 공격력 : ' .. atk_dmg)
		cclog(' 방어력 : ' .. def_pwr)
		cclog(' 데미지 : ' .. damage)
		cclog('------------------------------------------------------')
    end

    -- 회피 계산
    local hit_rate = attacker.m_activityCarrier:getStat('hit_rate')

    do -- 속성 상성 옵션 적용
        local hit_rates_multifly = 1

        -- 적중률
        if t_attr_effect['hit_rate'] then
            hit_rates_multifly = (hit_rates_multifly + (t_attr_effect['hit_rate']/100))
        end

        hit_rate = (hit_rate * hit_rates_multifly)
    end

    local avoid = self.m_statusCalc:getFinalStat('avoid')
    local avoid_rates = CalcAvoidChance(hit_rate, avoid)

    -- 회피율을 퍼밀 단위로 랜덤 연산
    if (math_random(1, 1000) <= (avoid_rates * 10)) then
        --cclog('MISS ' .. avoid_rates)
        self:makeMissFont(i_x, i_y)
        self:dispatch('avoid')
        return
    end

	-- 방어 이벤트 (에너지실드)
	local skipByShield, damage2 = self:dispatch('hit_shield', self, damage)
	if skipByShield then 
		self:makeShieldFont(i_x, i_y)
		return
	end
	if damage2 and damage2 > 0 then 
		damage = damage2
	end 

	-- 방어 이벤트 (횟수)
	local skipByBarrier = self:dispatch('hit_barrier')
	if skipByBarrier then 
		self:makeShieldFont(i_x, i_y)
		return 
	end

    -- 스킬 공격으로 피격되였다면 캐스팅 중이던 스킬을 취소시킴
    local attackType = attacker.m_activityCarrier:getAttackType()
    if (attackType ~= 'basic' and attackType ~= 'fever') then
        
        if self:cancelSkill() then
            -- 적 스킬 공격 캔슬 성공시
            local attackerCharacter = attacker.m_activityCarrier.m_activityCarrierOwner
            if attackerCharacter then
                local percentage = 0
                if self.m_castingMarkGauge then
                    percentage = self.m_castingMarkGauge:getPercentage()
                end

                self:dispatch('character_casting_cancel', attackerCharacter, percentage)
            end
        end

        -- 적 스킬 공격에 피격시
        self:dispatch('character_damaged_skill', self)

        -- 효과음
        if self.m_bLeftFormation then
            SoundMgr:playEffect('EFFECT', 'hit_damage_d')
        else
            SoundMgr:playEffect('EFFECT', 'hit_damage_m')
        end
    else
        -- 효과음
        if not self.m_bLeftFormation then
            SoundMgr:playEffect('EFFECT', 'hit_damage_n')
        end
    end
        	
	-- 공격 데미지 전달
    local t_info = {}
    t_info['attack_type'] = attackType
    t_info['attr'] = attacker.m_activityCarrier.m_attribute
    t_info['dmg_type'] = dmg_type
	t_info['critical'] = critical
    t_info['attr_bonus_dmg'] = attr_bonus_dmg
    self:setDamage(attacker, defender, i_x, i_y, damage, t_info)

	-- 공격받을 시점에서의 상태 정보 저장
	local t_damaged_info = {}
	t_damaged_info['isDead'] = self.m_bDead
    t_damaged_info['critical'] = critical
	attacker.m_activityCarrier:setDamagedInfo(t_damaged_info)

    -- 상태이상 체크
    StatusEffectHelper:statusEffectCheck_onHit(attacker.m_activityCarrier, self)

    -- 방어자 피격 이벤트 
    self:dispatch('undergo_attack', attacker.m_activityCarrier.m_activityCarrierOwner)

    -- 남은 체력이 20%이하일 경우 이벤트 발생
    if (damage > 0) then
        if ((self.m_hp / self.m_maxHp) <= 0.2) then
            self:dispatch('character_weak', self)
        end
    end
	
	-- 시전자 이벤트 
	if attacker.m_activityCarrier.m_activityCarrierOwner then
		attacker.m_activityCarrier.m_activityCarrierOwner:dispatch('hit', self)

		-- 적처치시 
		if self.m_bDead then 
			attacker.m_activityCarrier.m_activityCarrierOwner:dispatch('slain', self)
		
		-- 일반 공격시
		elseif (attacker.m_activityCarrier:getAttackType() == 'basic') then 
			attacker.m_activityCarrier.m_activityCarrierOwner:dispatch('hit_basic', self, attacker.m_activityCarrier)

		-- 액티브 공격시
		else
			attacker.m_activityCarrier.m_activityCarrierOwner:dispatch('hit_active', self)
		end
	end
end

-------------------------------------
-- function setDamage
-------------------------------------
function Character:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    if self.m_bDead then
        return
    end

    local t_info = t_info or EMPTY_TABLE
    --local dir = (attacker and attacker.movement_theta) or 0
    local dir = 0
    if attacker and isInstanceOf(attacker, PhysObject) then
        dir = attacker.movement_theta
    end

    -- 데미지 폰트 출력
    if t_info['attack_type'] == 'fever' then
        self:makeDamageEffectForFever(t_info['dmg_type'], t_info['attr'], i_x, i_y, dir, t_info['critical'])
    else
        self:makeDamageEffect(t_info['dmg_type'], t_info['attr'], i_x, i_y, dir, t_info['critical'])
    end
    self:makeDamageFont(damage, i_x, i_y, t_info['critical'], t_info['attr_bonus_dmg'])

    -- 데미지 적용
    local damage = math_min(damage, self.m_hp)
    self:setHp(self.m_hp - damage)

    -- 죽음 체크
    if (self.m_hp <= 0) and (self.m_bDead == false) then
        self:setDead()
        self:changeState('dying')
    end

    -- 피격시 타격감을 위한 연출
    self:animatorHit(attacker, dir)
            
    self:damagedEvent(self, damage)
end

-------------------------------------
-- function getSkillTable
-------------------------------------
function Character:getSkillTable(skill_id)
    if (not skill_id) or (skill_id == 'x') or (skill_id == 0) then
        return nil
    end

    local table_name = 'dragon_skill'

    -- 캐릭터 유형별 변수 정리(dragon or enemy)
    if (self.m_charType == 'dragon') then
        table_name = 'dragon_skill'
    else
        table_name = 'enemy_skill'
    end

    -- 테이블 정보 가져옴
    local table_skill = TABLE:get(table_name)
    local t_skill = table_skill[skill_id]

    return t_skill
end

-------------------------------------
-- function doAttack
-------------------------------------
function Character:doAttack(x, y)
    local skill_id = self.m_reservedSkillId
    if skill_id then
        local b_run_skill = self:doSkill(skill_id, nil, x, y)

        -- 지정된 스킬이 발동되지 않았을 경우 또는 basic_turn, rate 인 경우 기본 스킬 발동
        if self.m_isAddSkill or (not b_run_skill) then
            local basic_skill_id = self:getBasicAttackSkillID()
            self:doSkill(basic_skill_id, nil, x, y)
        end
    end

    -- 예약된 스킬 정보 초기화
    self.m_reservedSkillId = nil
    self.m_reservedSkillCastTime = 0
end

-------------------------------------
-- function makeDamageEffect
-------------------------------------
function Character:makeDamageEffect(dmg_type, attr, x, y, dir, critical)
    local dmg_type = dmg_type or DMG_TYPE_PHYSICAL
    local attr = attr or ATTR_LIGHT

    -- 일반 데미지
    local effect = MakeAnimator('res/effect/effect_hit_01/effect_hit_01.vrp')
    
    if critical then
        effect:changeAni('idle_3', false)
    else
        local aniName = 'idle_' .. math_random(1, 2)
        effect:changeAni(aniName, false)
    end
    
    effect:setPosition(x, y)

    local duration = effect:getDuration()
    effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
  
    self.m_world:addChild3(effect.m_node, DEPTH_DAMAGE_EFFECT)
end

-------------------------------------
-- function makeDamageEffectForFever
-------------------------------------
function Character:makeDamageEffectForFever(dmg_type, attr, x, y, dir, critical)
    -- 피버 데미지
    local effect = MakeAnimator('res/effect/effect_fever/effect_fever.vrp')
    effect:changeAni('damage', false)
    effect:setPosition(x, y)

    local duration = effect:getDuration()
    effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
  
    self.m_world.m_feverNode:addChild(effect.m_node, DEPTH_DAMAGE_EFFECT)
end

-------------------------------------
-- function makeDamageFont
-------------------------------------
function Character:makeDamageFont(damage, x, y, critical, attr_bonus_dmg)
    local y = y + 60

    if (damage == 0) then
        return
    end

    -- 소수점 제거
    damage = math_floor(damage)
    if attr_bonus_dmg then
        attr_bonus_dmg = math_floor(attr_bonus_dmg)
    end

    -- 속성 상성 보너스 데미지
    local attr_bonus_dmg_label = nil
    if (attr_bonus_dmg and (attr_bonus_dmg ~= 0)) then

        local color = nil
        local str = nil
        local scale = 0.8

        if (0 < attr_bonus_dmg) then
            color = cc.c3b(225, 229, 0)
            str = '(+' .. comma_value(attr_bonus_dmg) .. ')'
        elseif (attr_bonus_dmg < 0) then
            color = cc.c3b(158, 158, 158)
            str = '(' .. comma_value(attr_bonus_dmg) .. ')'
        end

        attr_bonus_dmg_label = cc.Label:createWithBMFont('res/font/normal.fnt', str)
        attr_bonus_dmg_label:setAnchorPoint(cc.p(0, 0.5)) -- 위치에서 오른쪽으로 숫자가 펼쳐지도록
        attr_bonus_dmg_label:setScale(scale)
        attr_bonus_dmg_label:setColor(color)
        --self:makeDmgFontFadeOut(attr_bonus_dmg_label)
    end

    -- 일반 데미지
    local scale = 1
    
    if critical then
        local node = nil
        local label = cc.Label:createWithBMFont('res/font/critical.fnt', comma_value(damage))
        --self:makeDmgFontFadeOut(label)
        
        --if attr_bonus_dmg_label then
        if false then
            node = cc.Node:create()
            node:addChild(label)
            node:addChild(attr_bonus_dmg_label)
            
            local string_width = label:getStringWidth()
            local offset_x = (string_width / 2)
            attr_bonus_dmg_label:setPositionX(offset_x)
        else
            node = label
        end

        node:setPosition(x, y)
        --node:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 3.5 * scale), cc.ScaleTo:create(0.3, 1 * scale), cc.DelayTime:create(0.4), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        node:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.4), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
        --node:runAction(self:makeDmgFontAction())
        self.m_world:addChild3(node, DEPTH_CRITICAL_FONT)
        
    else
        local node = nil
        local label = cc.Label:createWithBMFont('res/font/normal.fnt', comma_value(damage))
        --self:makeDmgFontFadeOut(label)
        
        if (self.m_charType == 'dragon') then
            label:setColor(cc.c3b(235, 71, 42))
        end

        --if attr_bonus_dmg_label then
        if false then
            node = cc.Node:create()
            node:addChild(label)
            node:addChild(attr_bonus_dmg_label)
            
            local string_width = label:getStringWidth()
            local offset_x = (string_width / 2)
            attr_bonus_dmg_label:setPositionX(offset_x)
        else
            node = label
        end

        node:setPosition(x, y)
        --node:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(0.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        node:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
        --node:runAction(self:makeDmgFontAction())
        self.m_world:addChild3(node, DEPTH_DAMAGE_FONT)
    end
end

-------------------------------------
-- function makeDmgFontAction
-------------------------------------
function Character:makeDmgFontAction()
    local scale = 1

    local sequence = cc.Sequence:create(
        cc.ScaleTo:create(0.05, 1.5 * scale),
        cc.ScaleTo:create(0.5, 0.5 * scale),
        --cc.DelayTime:create(0.2),
        --cc.FadeOut:create(0.3),
        cc.RemoveSelf:create())

    -- 이동
    local bezier1
    if self.m_bLeftFormation then
        bezier1 = {
            cc.p(0, 0),
            cc.p(-20, 80),
            cc.p(-40, 60),
        }
    else
        bezier1 = {
            cc.p(0, 0),
            cc.p(20, 80),
            cc.p(40, 60),
        }
    end
    local bazier_action = cc.BezierBy:create(0.5, bezier1)

    local sequence2 = cc.Sequence:create(
        cc.DelayTime:create(0.05),
        bazier_action)

    local spawn = cc.Spawn:create(sequence, sequence2)

    return spawn
end

-------------------------------------
-- function makeDmgFontFadeOut
-------------------------------------
function Character:makeDmgFontFadeOut(node)
    local sequence = cc.Sequence:create(
        cc.DelayTime:create(0.25),
        cc.FadeOut:create(0.3))

    node:runAction(sequence)
end

-------------------------------------
-- function makeHealFont
-------------------------------------
function Character:makeHealFont(heal)
    local heal = math_floor(heal)
    if (heal == 0) then
        return
    end

    local x = self.pos.x + math_random(-25, 25)
    local y = self.pos.y + math_random(-25, 25)

    -- 일반 데미지
    local label = nil
    local scale = 1
    
    label = cc.Label:createWithBMFont('res/font/heal.fnt', tostring(heal))
    --label:setColor(cc.c3b(0,255,0))
    label:setPosition(x, y)
    label:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(0.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
    --label:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 170)), 0.5))
    self.m_world:addChild3(label, DEPTH_HEAL_FONT)
end


-------------------------------------
-- function makeSkillChanceFont
-------------------------------------
function Character:makeSkillChanceFont(str, x, y)
    -- 일반 데미지
    local label = nil
    local scale = 1

    label = cc.Label:createWithBMFont('res/font/normal.fnt', str)
    label:setColor(cc.c3b(100,100,255))
    label:setPosition(x, y)
    label:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(0.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
    label:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 170)), 0.5))
    self.m_world:addChild3(label, DEPTH_MISS_FONT)
end


-------------------------------------
-- function makeMissFont
-------------------------------------
function Character:makeMissFont(x, y)

    -- 일반 데미지
    local sprite = cc.Sprite:create('res/font/miss.png')

    local scale = 1

    sprite:setPosition(x, y)
    sprite:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(0.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
    sprite:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 170)), 1))
    self.m_world:addChild3(sprite, DEPTH_MISS_FONT)
end

-------------------------------------
-- function makeShieldFont
-------------------------------------
function Character:makeShieldFont(x, y)

    local sprite = cc.Sprite:create('res/font/shield.png')

    local scale = 1

    sprite:setPosition(x, y)
    sprite:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(0.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
    sprite:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 170)), 1))
    self.m_world:addChild3(sprite, DEPTH_BLOCK_FONT)
end

-------------------------------------
-- function dealPercent
-------------------------------------
function Character:dealPercent(percent)
    local damage = self.m_maxHp * percent
	self:setDamage(nil, self, self.pos.x, self.pos.y, damage, t_info)
end

-------------------------------------
-- function healPercent
-------------------------------------
function Character:healPercent(percent, b_make_effect)
    local heal = self.m_maxHp * percent
    heal = math_min((self.m_maxHp - self.m_hp) , heal)

    self:healAbs(heal, b_make_effect)
end

-------------------------------------
-- function healAbs
-------------------------------------
function Character:healAbs(hp, b_make_effect)
    local hp = math_floor(hp)

    local heal = hp
    local heal_for_text = hp
    heal = math_min(heal, (self.m_maxHp-self.m_hp))

    self:makeHealFont(heal_for_text)
    self:setHp(self.m_hp + heal)

    if (b_make_effect == true) then
        local res = 'res/effect/skill_heal_monster/skill_heal_monster.vrp'
        local pos_x = self.pos['x']
        local pos_y = self.pos['y']
        local effect = self.m_world:addInstantEffect(res, 'idle', pos_x, pos_y)
    end
end

-------------------------------------
-- function setHp
-------------------------------------
function Character:setHp(hp)
    self.m_hp = hp

    if self.m_hpGauge then
        local percentage = self.m_hp / self.m_maxHp * 100
        self.m_hpGauge:setPercentage(self.m_hp / self.m_maxHp * 100)

        if self.m_hpGauge2 then
            local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ProgressTo:create(0.5, percentage))
            self.m_hpGauge2:runAction(cc.EaseIn:create(action, 2))
        end
    end

    if self.m_hpEventListener then
        for i, v in pairs(self.m_hpEventListener) do
            v:changeHpCB(self, self.m_hp, self.m_maxHp)
        end
    end
end

-------------------------------------
-- function addHpEventListener
-------------------------------------
function Character:addHpEventListener(listener)
    if (not self.m_hpEventListener) then
        self.m_hpEventListener = {}
    end

    -- 콜백 함수 등록
    table.insert(self.m_hpEventListener, listener)

    listener:changeHpCB(self, self.m_hp, self.m_maxHp)
end

-------------------------------------
-- function release
-------------------------------------
function Character:release()
    if self.m_hpNode then
        self.m_hpNode:removeFromParent(true)
    end

    if self.m_castingNode then
        self.m_castingNode:removeFromParent(true)
    end

    self.m_hpNode = nil
    self.m_hpGauge = nil

    self.m_castingNode = nil
    self.m_castingGauge = nil

    Entity.release(self)
end

-------------------------------------
-- function setOrgHomePos
-------------------------------------
function Character:setOrgHomePos(x, y)
    self.m_orgHomePosX = x
    self.m_orgHomePosY = y
end

-------------------------------------
-- function setHomePos
-------------------------------------
function Character:setHomePos(x, y)
    self.m_homePosX = x
    self.m_homePosY = y
end

-------------------------------------
-- function makeHPGauge
-------------------------------------
function Character:makeHPGauge(hp_ui_offset)
    self.m_hpUIOffset = hp_ui_offset
    
    local ui = UI_IngameUnitInfo(self)
    self.m_hpNode = ui.root
    self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_world.m_worldNode:addChild(self.m_hpNode, 5)
    
    -- casting
    do
        self.m_castingNode = cc.Node:create()
        self.m_castingNode:setDockPoint(cc.p(0.5, 0.5))
        self.m_castingNode:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_castingNode:setVisible(false)
        self.m_world.m_worldNode:addChild(self.m_castingNode, 6)


        local ui = UI()
        ui:load('enemy_skill_speech.ui')
        self.m_castingNode:addChild(ui.root)

        self.m_castingUI = ui.root
        self.m_castingMarkGauge = ui.vars['markGauge']
        self.m_castingSpeechVisual = ui.vars['speechVisual']

        --
        do
            self.m_castingMarkGauge:setVisible(true)
            self.m_castingSpeechVisual:setVisible(true)
        
            self.m_castingMarkGauge:setPosition(53, 107)
            self.m_castingSpeechVisual:setPosition(99, 144)
        end
        --

        --[[
        --local img = cc.Sprite:create('res/ui/gauge/ingame_enemy_gg_02.png')
        local img = cc.Sprite:create('res/ui/gauge/dragon_atk_gg.png')
        img:setDockPoint(cc.p(0.5, 0.5))
        img:setAnchorPoint(cc.p(0.5, 0.5))

        local progress = cc.ProgressTimer:create(img)
        progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        progress:setMidpoint(cc.p(0, 0))
        progress:setBarChangeRate(cc.p(1, 0))
        progress:setAnchorPoint(cc.p(0.5,0.5))
        progress:setDockPoint(cc.p(0.5,0.5))
        progress:setPercentage(0)
        progress:setPosition(0, -7)
        self.m_castingNode:addChild(progress)

        self.m_castingGauge = progress
        ]]--
    end
end

-------------------------------------
-- function setPosition
-------------------------------------
function Character:setPosition(x, y)
    Entity.setPosition(self, x, y)

    if self.m_hpNode then
        self.m_hpNode:setPosition(x + self.m_hpUIOffset[1], y + self.m_hpUIOffset[2])
    end

    if self.m_castingNode then
        self.m_castingNode:setPosition(x + self.m_hpUIOffset[1], y + self.m_hpUIOffset[2])
    end

    if self.m_cbChangePos then
        self.m_cbChangePos(self)
    end
end

-------------------------------------
-- function calcAttackPeriod
-- @brief 공격 주기 계산
-------------------------------------
function Character:calcAttackPeriod()
    local cast_time = self.m_reservedSkillCastTime

    -- 공격 주기 공식
    if self.m_bFirstAttack then
        self.m_bFirstAttack = false

        if self.m_charType == 'dragon' then
            self.m_attackPeriod = 0
        else
            self.m_attackPeriod = self.m_statusCalc.m_attackTick * math_random(1, 100) / 100
        end
    else
        self.m_attackPeriod = self.m_statusCalc.m_attackTick
    end

    -- 공격 주기에서 'attack'에니메이션의 길이는 제외
    if cast_time > 0 then
        self.m_attackPeriod = self.m_attackPeriod
    else
        self.m_attackPeriod = self.m_attackPeriod - self.m_attackAnimaDuration - self.m_chargeDuration
    end

    -- 음수가 나오지 않도록 보정
    self.m_attackPeriod = math_max(self.m_attackPeriod, 0)
end

-------------------------------------
-- function update
-------------------------------------
function Character:update(dt)
    -- 경직 중일 경우
    if self.m_isSpasticity then
        self.m_delaySpasticity = self.m_delaySpasticity - dt

        if self.m_delaySpasticity <= 0 or self.m_bEnableSpasticity == false then
            self:setSpasticity(false)
        else
            return
        end
    end

    self:updateMove(dt)
	self:updateStatusIcon(dt)

    return Entity.update(self, dt)
end

-------------------------------------
-- function updateMove
-------------------------------------
function Character:updateMove(dt)
    if (not self.m_isOnTheMove) then
        return
    end

    local body = self.body

    if self:isOverTargetPos() then
        self:setPosition(self.m_targetPosX, self.m_targetPosY)
        self:resetMove()
    end
end

-------------------------------------
-- function setMove
-------------------------------------
function Character:setMove(x, y, speed)
    self.m_isOnTheMove = true
    self:setTargetPos(x, y)
    self:setSpeed(speed)
end

-------------------------------------
-- function resetMove
-------------------------------------
function Character:resetMove()
    self.m_isOnTheMove = false
    self:setSpeed(0)
end

-------------------------------------
-- function syncAniAndPhys
-- @brief m_rootNode의 위치로 클래스의 위치 동기화
-------------------------------------
function Character:syncAniAndPhys()
	local x, y = self.m_rootNode:getPosition()
	self:setPosition(x, y)
end

-------------------------------------
-- function setTargetEffect
-------------------------------------
function Character:setTargetEffect(animator)
    self:removeTargetEffect()
    self.m_targetEffect = animator
    if animator then
        --self.m_rootNode:addChild(animator.m_node)
        animator:setPosition(-self.m_hpUIOffset[1], -self.m_hpUIOffset[2])

        if self.m_hpNode then
            self.m_hpNode:addChild(animator.m_node)
        end
    end
end

-------------------------------------
-- function removeTargetEffect
-------------------------------------
function Character:removeTargetEffect()
    if self.m_targetEffect then
        self.m_targetEffect:release()
        self.m_targetEffect = nil
    end
end

-------------------------------------
-- function addActivedSkill
-------------------------------------
function Character:addActivedSkill(skill, name, allow_duplicate)
    if (not self.m_lActivedSkill) then
        self.m_lActivedSkill = {}
    end

    -- 초기값 지정
    local allow_duplicate = allow_duplicate
    if (allow_duplicate == nil) then
        allow_duplicate = true
    else
        allow_duplicate = false
    end

    if (allow_duplicate == false) then
        local l_remove = {}
        for i,v in ipairs(self.m_lActivedSkill) do
            if v['name'] == name then
                table.insert(l_remove, v['skill'])
            end
        end

        for i,v in ipairs(l_remove) do
            self:removeActivedSkill(v)
        end
    end


    table.insert(self.m_lActivedSkill, {skill=skill, name=name})
end

-------------------------------------
-- function removeActivedSkill
-------------------------------------
function Character:removeActivedSkill(skill)
    for i,v in ipairs(self.m_lActivedSkill) do
        if (v['skill'] == skill) then
            skill:changeState('dying')
            table.remove(self.m_lActivedSkill, i)
            break
        end
    end
end

-------------------------------------
-- function updateStatusIcon
-------------------------------------
function Character:updateStatusIcon(dt)
	local count = 1
	for type, status_effect in pairs(self.m_lStatusEffect) do
		self:setStatusIcon(status_effect, count)
		count = count + 1
	end

	for i, v in pairs(self.m_lStatusIcon) do
		v:update(dt)
	end

end

-------------------------------------
-- function setStatusIcon
-------------------------------------
function Character:setStatusIcon(status_effect, idx)
	local status_effect_type = status_effect:getTypeName()
	local idx = idx 

	-- icon 생성 또는 있는것에 접근
	local icon = nil
	if (self.m_lStatusIcon[status_effect_type]) then 
		icon = self.m_lStatusIcon[status_effect_type]
	else
		icon = StatusEffectIcon(self, status_effect)
	end

	-- 4개를 넘어가면 y 값 조정
	local factor_y = 0
	if idx > 4 then 
		idx = idx - 4
		factor_y = -20
	end

	-- 위치 조정 
	if (self.m_charType == 'dragon') or (self.m_charType == 'tamer') then 
		icon.m_icon:setPosition(60 + 18 * (idx - 1), -8 + factor_y)
	else
		icon.m_icon:setPosition(-20 + 18 * (idx - 1), -23 + factor_y)
	end
end

-------------------------------------
-- function removeStatusIcon
-------------------------------------
function Character:removeStatusIcon(status_effect)
	local status_effect_type = status_effect:getTypeName()
	self.m_lStatusIcon[status_effect_type] = nil
end

-------------------------------------
-- function getFormationMgr
-------------------------------------
function Character:getFormationMgr(opposite)
	local isOpposite = (opposite == 'opposite')
    if self.m_bLeftFormation then
		if isOpposite then
			return self.m_world.m_rightFormationMgr
		else
			return self.m_world.m_leftFormationMgr
		end
    else
        if isOpposite then
			return self.m_world.m_leftFormationMgr
		else
			return self.m_world.m_rightFormationMgr
		end
    end
end

-------------------------------------
-- function getName
-------------------------------------
function Character:getName()
	if self.m_charTable then 
		return self.m_charTable['t_name']
	else
		return '까미'
	end
end

-------------------------------------
-- function getAttribute
-------------------------------------
function Character:getAttribute()
	return self.m_charTable['attr']
end

-------------------------------------
-- function getCharType
-- @return 공격 속성 physical or magical
-------------------------------------
function Character:getCharType()
	return self.m_charTable['char_type']
end

-------------------------------------
-- function insertStatusEffect
-------------------------------------
function Character:insertStatusEffect(status_effect)
	local effect_name = status_effect.m_statusEffectName
	
	if string.find(effect_name, 'buff_heal') then return end
	if string.find(effect_name, 'passive') then return end

	self.m_lStatusEffect[effect_name] = status_effect
end

-------------------------------------
-- function removeStatusEffect
-------------------------------------
function Character:removeStatusEffect(status_effect)
	local effect_name = status_effect.m_statusEffectName
	self.m_lStatusEffect[effect_name] = nil
end

-------------------------------------
-- function getStatusEffectList
-------------------------------------
function Character:getStatusEffectList()
	return self.m_lStatusEffect
end

-------------------------------------
-- function makeAttackDamageInstance
-- @brief
-------------------------------------
function Character:makeAttackDamageInstance(forced_skill_id)
    local activity_carrier = ActivityCarrier()

	-- 시전자를 지정
	activity_carrier.m_activityCarrierOwner = self

    -- 속성 지정
    activity_carrier.m_attribute = attributeStrToNum(self.m_charTable['attr'])

    -- 데미지 타입 지정
    activity_carrier.m_damageType = DMG_TYPE_STR[self.m_charTable['char_type']]

    local t_skill = TABLE:get(self.m_charType .. '_skill')[self.m_reservedSkillId]
    
	if (self.m_charTable['skill_basic'] == self.m_reservedSkillId) then
        activity_carrier:setAttackType('basic')
	elseif (forced_skill_id) then
		--@TODO 임시 처리 .. 일반적인 경우로 호출되지 않는 스킬은 어떻게 처리해야할까
		activity_carrier:setAttackType('active')
    else
        activity_carrier:setAttackType('active')
    end
    
    -- 세부 능력치 지정
	activity_carrier:setStatuses(self.m_statusCalc)

    return activity_carrier
end

-------------------------------------
-- function animatorShake
-- @brief 피격 시 캐릭터 진동 효과
-------------------------------------
function Character:animatorShake()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local x = -math_random(30, 40)
    local y = math_random(20, 30)
    --[[
    if (math_random(1, 2) == 1) then
        x = -x
    end

    if (math_random(1, 2) == 1) then
        y = -y
    end
    ]]--

    -- 실행중인 액션 stop
    do
        local action = target_node:getActionByTag(CHARACTER_ACTION_TAG__SHAKE);
        if action then
            target_node:stopAction(action)
            target_node:setPosition(0, 0)
        end
    end

    local start_action = cc.MoveTo:create(0.05, cc.p(x, 0))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.3, cc.p(0, 0)), 0.2)
    local action = cc.Sequence:create(start_action, end_action)
    action:setTag(CHARACTER_ACTION_TAG__SHAKE)

    target_node:runAction(action)
end

-------------------------------------
-- function animatorHit
-- @brief 피격 시 캐릭터 애니메이션
-------------------------------------
function Character:animatorHit(attacker, dir)
    local rarity = self.m_charTable['rarity']
       
    -- 경직
    if rarity ~= 'boss' and rarity ~= 'subboss' and rarity ~= 'elite' then
        self:animatorKnockback(dir)
        self:setSpasticity(true)

        if attacker then
            if isInstanceOf(attacker, Character) then
                attacker:setSpasticity(true)
            elseif isInstanceOf(attacker, Missile) and attacker.m_owner then
                attacker.m_owner:setSpasticity(true)
            end
        end
    end
    
    -- 점멸 처리
    local target_node = self.m_animator.m_node
    if target_node then
        local delay = 0.1

        if rarity ~= 'boss' and rarity ~= 'subboss' and rarity ~= 'elite' then
            delay = 0.06
        end

        -- 실행중인 액션 stop
        do
            local action = target_node:getActionByTag(CHARACTER_ACTION_TAG__SHADER);
            if action then
                target_node:stopAction(action)
            end
        end

        local action = cc.Sequence:create(
            cc.CallFunc:create(function(node)
                local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
                self.m_animator.m_node:setGLProgram(shader)
            end),
            cc.DelayTime:create(delay),
            cc.CallFunc:create(function(node)
                local shader = ShaderCache:getShader(cc.SHADER_POSITION_TEXTURE_COLOR)
                self.m_animator.m_node:setGLProgram(shader)
            end)
        )
        action:setTag(CHARACTER_ACTION_TAG__SHADER)
        
        target_node:runAction(action)
    end
end

-------------------------------------
-- function animatorKnockback
-- @brief 피격 시 캐릭터 밀림 효과
-------------------------------------
function Character:animatorKnockback(dir)
    local dir = dir

    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    -- 좌우 밀림만 사용
    if self.m_bLeftFormation then   dir = 180
    else                            dir = 0
    end

    local distance = 40
    local pos_x = math_cos(math_rad(dir)) * distance
    local pos_y = math_sin(math_rad(dir)) * distance

    -- 실행중인 액션 stop
    do
        local action = target_node:getActionByTag(CHARACTER_ACTION_TAG__KNOCKBACK);
        if action then
            target_node:stopAction(action)
        end
    end

    local start_action = cc.DelayTime:create(SpasticityTime)
    local end_action = cc.MoveTo:create(0.1, cc.p(0, 0))
    local action = cc.Sequence:create(start_action, end_action)
    action:setTag(CHARACTER_ACTION_TAG__KNOCKBACK)

    target_node:runAction(action)

    target_node:setPosition(pos_x, pos_y)
end

-------------------------------------
-- function animatorFloating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Character:animatorFloating()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    -- 실행중인 액션 stop
    do
        local action = target_node:getActionByTag(CHARACTER_ACTION_TAG__FLOATING);
        if action then
            target_node:stopAction(action)
            target_node:setPosition(0, 0)
        end
    end

    local function getTime()
        return math_random(5, 15) * 0.1 * CHARACTER_FLOATING_TIME / 2
    end

    local sequence = cc.Sequence:create(
        cc.MoveTo:create(getTime(), cc.p(math_random(-CHARACTER_FLOATING_MAX_X_SCOPE, -CHARACTER_FLOATING_MIN_X_SCOPE), math_random(-CHARACTER_FLOATING_MAX_Y_SCOPE, -CHARACTER_FLOATING_MIN_Y_SCOPE))),
        cc.MoveTo:create(getTime(), cc.p(math_random(CHARACTER_FLOATING_MIN_X_SCOPE, CHARACTER_FLOATING_MAX_X_SCOPE), math_random(CHARACTER_FLOATING_MIN_Y_SCOPE, CHARACTER_FLOATING_MAX_Y_SCOPE)))
    )

    local action = cc.RepeatForever:create(sequence)
    action:setTag(CHARACTER_ACTION_TAG__FLOATING)

    target_node:runAction(action)
end

-------------------------------------
-- function setStateDelegate
-- @brief 스킬들이 캐릭터의 상태를 대신 수행하는 클래스
-------------------------------------
function Character:setStateDelegate(state_delegate)
    if self.m_stateDelegate then
        self.m_stateDelegate:changeState('dying')
        self.m_stateDelegate:setOwnerCharacter(nil)
        self.m_stateDelegate = nil
    end

    self.m_stateDelegate = state_delegate

    if self.m_stateDelegate then
        self.m_stateDelegate:setOwnerCharacter(self)

        if (self.m_state ~= 'delegate') then
            self:changeState('delegate')
        end
    else
        if (self.m_state == 'delegate') then
            self:changeStateWithCheckHomePos('attackDelay')
        end
    end
end

-------------------------------------
-- function killStateDelegate
-- @brief StateDelegate를 중지
-------------------------------------
function Character:killStateDelegate()
    self:setStateDelegate(nil)
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Character:changeState(state, forced)
    local prev_state = self.m_state
    local ret = Entity.changeState(self, state, forced)

    if (ret == true) and (prev_state == 'delegate') then
        self:killStateDelegate()
    end

    return ret
end

-------------------------------------
-- function changeStateWithCheckHomePos
-- @brief homepos를 확인 후 state를 변경
--        homepos에 위치하지 않을 경우 comeback 후 state를 변경
-------------------------------------
function Character:changeStateWithCheckHomePos(state, forced)

    if (self.m_homePosX == self.pos['x'] and self.m_homePosY == self.pos['y']) then
        self:changeState(state, forced)
        return
    end

    self.m_comebackNextState = state
    self:changeState('comeback', forced)
end

-------------------------------------
-- function reserveSkill
-- @brief 사용될 스킬을 예약
-------------------------------------
function Character:reserveSkill(skill_id)
    if not skill_id then return end

    local t_skill = self:getSkillTable(skill_id)
    local cast_time = self:getCastTimeFromSkillID(skill_id)
    local event_time = 0

    local ani = self.m_tStateAni['attack']
    local eventList = self.m_animator:getEventList(ani, 'attack')
    
    if eventList[1] then
        event_time = eventList[1]['frames'] or 0
    end

    self.m_reservedSkillId = skill_id
    self.m_reservedSkillCastTime = cast_time
    self.m_reservedSkillAniEventTime = event_time
end

-------------------------------------
-- function setSpasticity
-- @brief 해당 영웅을 경직시킴
-------------------------------------
function Character:setSpasticity(b)
	if (not self.m_animator) then return end
    if b and self.m_bEnableSpasticity then
        --self.m_animator.m_node:pause()
        self.m_animator:setTimeScale(0)

        self.m_isSpasticity = true
        self.m_delaySpasticity = SpasticityTime
    else
        --self.m_animator.m_node:resume()
        self.m_animator:setTimeScale(1)

        self.m_isSpasticity = false
        self.m_delaySpasticity = 0
    end
end

-------------------------------------
-- function restore
-- @brief 원상복구한다
-------------------------------------
function Character:restore(restore_speed)
	local speed = restore_speed or 1000

    -- 제 위치로 
	if (self.pos.x ~= self.m_homePosX) then
		self:setMove(self.m_homePosX, self.m_homePosY, speed)
	end

	-- Visible On
	if (self.m_animator) and (not self.m_animator:isVisible()) then
		self.m_animator:setVisible(true)
	end
end