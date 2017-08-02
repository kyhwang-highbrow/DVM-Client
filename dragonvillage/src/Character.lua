local PARENT = class(Entity,
    IEventListener:getCloneTable(),
    IEventDispatcher:getCloneTable(),
    IHighlight:getCloneTable(),
    ICharacterStatusEffect:getCloneTable(),
    IDragonSkillManager:getCloneTable()
)

local SPEED_COMEBACK = 1500

-------------------------------------
-- class Character
-------------------------------------
Character = class(PARENT, {
		-- 캐릭터 기초 스탯
        m_lv = '',
        m_maxHp = '',
        m_hp = '',
		m_attribute = '',
		m_attributeOrg = '',

		-- 기초 유틸
        m_statusCalc = '',
        m_stateDelegate = 'CharacterStateDelegate',
        m_activityCarrier = 'ActivityCarrier',
        m_charLogRecorder = 'LogRecorderChar',

		-- 캐릭터의 특정 상태
        m_bActive = 'boolean',
        m_bDead = 'boolean',
        m_bInvincibility = 'boolean',   -- 무적 상태 여부
		m_isSilence = 'boolean',		-- 침묵 (스킬 사용 불가 상태)
		m_isImmuneSE = 'boolean',		-- 면역 (해로운 상태 효과 면역)
        m_isImmortal = 'boolean',       -- 불사 (체력이 1이하로 내려가지 않는 상태)
        m_isZombie = 'boolean',         -- 좀비 (죽지 않는 상태)

        -- @ for FormationMgr
        m_bLeftFormation = 'boolean',   -- 왼쪽 진형일 경우 true, 오른쪽 진형일 경우 false
        m_currFormation = '',
        m_cbChangePos = 'function',

        -- @ 공격 속도
        m_chargeDuration = 'number',
        m_attackAnimaDuration = 'number',
        m_attackPeriod = 'number',
        m_prevAttackPeriod = 'number',

        -- @ attack상태 관리하는 변수들
        m_bLuanchMissile = 'boolean',       -- MissileLauncher생성 여부
        m_bFinishAttack = 'boolean',        -- MissileLauncher가 공격을 완료했는지 여부
        m_bFinishAnimation = 'boolean',     -- 'attack'에니메이션 재생 완료 여부
        m_bFirstAttack = 'boolean',         -- 최초의 공격일 경우

        -- @ 예약된 skill 정보
        m_reservedSkillId = 'number',
        m_reservedSkillCastTime = 'number',
                
        m_isAddSkill = 'bool', -- 드래곤이 에약한 스킬이 basic_rate나 basic_turn 인 경우
        m_bActivePassive = 'bool',  -- 패시브 스킬 적용 여부

        m_prevReservedSkillId = 'number',
        m_prevIsAddSkill = 'bool',
        m_prevAttackDelayTimer = 'number',

        m_comebackNextState = 'state',

        -- @ target
        m_targetChar = 'Character',
        m_mTargetEffect = '',
        m_mNonTargetEffect = '',

        -- @node UI
        m_unitInfoNode = 'cc.Node',
        m_enemySpeechNode = 'cc.Node',
        m_dragonSpeechNode = 'cc.Node',

        -- @hp UI
		m_infoUI = '',
        m_hpNode = '',
        m_hpGauge = '',
        m_hpGauge2 = '',
        m_unitInfoOffset = 'UI_IngameDragonInfo/UI_IngameUnitInfo',
        m_bFixedPosHpNode = 'boolean',

        -- @status UI
        m_statusNode = '',

        -- @casting UI
        m_castingNode = '',
        m_castingGauge = '',
        m_castingEffect = '',
        m_castingUI = '',
        m_castingMarkGauge = '',
        m_castingSpeechVisual = '',

        -- @이동 관련
        m_isOnTheMove = 'boolean',
        m_orderOnTheMove = 'number',    -- 현재 이동의 우선순위(높을 수록 우선순위 높음)
        m_movement = 'EnemyMovement',
        
        -- @ 위치 관련
        m_posIdx = 'number',  -- 덱진형에서의 위치 인덱스
        m_orgHomePosX = 'number',
        m_orgHomePosY = 'number',
        m_homePosX = 'number',
        m_homePosY = 'number',
        m_attackOffsetX = 'number',
        m_attackOffsetY = 'number',

		-- 피격시 경직 관련
        m_bEnableSpasticity = 'boolean',-- 경직 가능 활성화 여부
        m_isSpasticity = 'boolean',     -- 경직 중 여부
        m_delaySpasticity = 'number',   -- 경직 남은 시간

		-- 잔상(afterImage) 관련
		m_afterimageTimer = 'number',
		m_isUseAfterImage = 'boolean',

		---------------------------------------------------------------------------------------

		-- @TODO 임시 추가 충돌박스
		m_isSlaveCharacter = 'boolean', -- 이 물리객체가 다른 객체에 추가된 것인지 여부
		m_masterCharacter = 'Character', -- 이 물리객체를 가진 Character

		-- @TODO 수호 스킬 관련 .. 없애고 싶은데....
		m_guard = 'SkillGuard',	-- guard 되고 있는 상태(damage hijack)

		-- @TODO 임시
        m_aiParam = '',
        m_aiParamNum = '',
        m_sortValue = '',				-- 타겟 찾기 등의 정렬에서 임의로 사용
        m_sortRandomIdx = '',			-- 타겟 찾기 등의 정렬에서 임의로 사용

        -- 로밍 임시 처리
        m_bRoam = 'boolean',
        m_roamTimer = 'number',

		-- 몬스터가 아이템을 드랍하는지 여부
        m_hasItem = 'boolean',

        -- 부활 가능한지 여부
        m_bPossibleRevive = 'boolean',
     })

local SpasticityTime = 0.2

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Character:init(file_name, body, ...)
    self.m_bActive = false
    self.m_bDead = false
	self.m_attribute = nil
	self.m_attributeOrg = nil

    self.m_chargeDuration = 0
    self.m_attackAnimaDuration = 0

    self.m_bActivePassive = false
    self.m_isOnTheMove = false
    self.m_orderOnTheMove = -1
    self.m_bFixedPosHpNode = false

    self.m_bEnableSpasticity = true
    self.m_isSpasticity = false
    self.m_delaySpasticity = 0

    self.m_bInvincibility = false
	self.m_isSilence = false
	self.m_isImmuneSE = false
    self.m_isImmortal = false
    self.m_isZombie = false
    
	self.m_isUseAfterImage = false

	self.m_isSlaveCharacter = false
	self.m_masterCharacter = nil
	
	self.m_guard = false

    self.m_posIdx = 0
    self.m_orgHomePosX = 0
    self.m_orgHomePosY = 0
    self.m_homePosX = 0
    self.m_homePosY = 0

    self.m_movement = nil

    self.m_bRoam = false
    self.m_roamTimer = 0
    self.m_hasItem = false
    self.m_bPossibleRevive = false

    self.m_mTargetEffect = {}
    self.m_mNonTargetEffect = {}
end

-------------------------------------
-- function initWorld
-- @param game_world
-------------------------------------
function Character:initWorld(game_world)
    PARENT.initWorld(self, game_world)

    if (not self.m_unitInfoNode) then
        self.m_unitInfoNode = cc.Node:create()
        self.m_world.m_unitInfoNode:addChild(self.m_unitInfoNode)
        
        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_unitInfoNode)
    end
end

-------------------------------------
-- function getPosIdx
-------------------------------------
function Character:getPosIdx()
    return self.m_posIdx
end

-------------------------------------
-- function setPosIdx
-- @brief 덱진형에서의 위치 인덱스 값을 저장
-------------------------------------
function Character:setPosIdx(posIdx)
    self.m_posIdx = posIdx
end

-------------------------------------
-- function setDead
-------------------------------------
function Character:setDead()
    if (self.m_bDead) then return false end
    self.m_bDead = true

    self:setEnableBody(false)
    self:removeTargetEffect()

    self:dispatch('character_dead', {}, self)

    return true
end

-------------------------------------
-- function getTargetList
-- @brief skill table을 인자로 받는 경우..
-------------------------------------
function Character:getTargetListByTable(t_skill, t_data)
	local target_type = t_skill['target_type']
	local target_count = t_skill['target_count']
    local target_formation = t_skill['target_formation']

    if (target_type == '') then 
        local sid = tostring(t_skill['sid'])
        local name = tostring(t_skill['t_name'])
		error('타겟 타입이 없네요..ㅠ 테이블 수정해주세요 ' .. sid .. ' ' .. name)
	end

    return self:getTargetListByType(target_type, target_count, target_formation, t_data)
end

-------------------------------------
-- function getTargetListByType
-- @param target_formation은 없어도 된다
-------------------------------------
function Character:getTargetListByType(target_type, target_count, target_formation, t_data)
	if (target_type == '') then 
		error('타겟 타입이 없네요..ㅠ 테이블 수정해주세요')
	end
    
	local target_formation = target_formation or nil
	
	-- parsing : target_type = 'enemy_low_hp'

	--> target_team = 'enemy'
	local target_team = string.gsub(target_type, '_.+', '')		

	--> target_rule = 'low_hp'
    local target_rule = string.gsub(target_type, '%l+_', '', 1)

	--> target_count = 3
	local target_count = target_count

	local t_ret = self.m_world:getTargetList(self, self.pos.x, self.pos.y, target_team, target_formation, target_rule, t_data)
    	
	if (target_count) and (type(target_count) == 'number') then
		return table.getPartList(t_ret, target_count)
	else
		return t_ret
	end
end

-------------------------------------
-- function checkTarget
-------------------------------------
function Character:checkTarget(t_skill, t_data)
	if (t_data and t_data['target']) then
		-- 인디케이터에서 받아온 정보가 있다면
		self.m_targetChar = t_data['target']
	else
		-- 없다면 탐색
		local t_ret = self:getTargetListByTable(t_skill)
		self.m_targetChar = t_ret[1]
	end

    return (self.m_targetChar ~= nil)
end


-------------------------------------
-- function initStatus
-------------------------------------
function Character:initStatus(t_char, level, grade, evolution, doid, eclv)
    local level = level or 1
    self.m_charTable = t_char
	self.m_attribute = t_char['attr']
	self.m_attributeOrg = t_char['attr']
    self.m_lv = level

    -- 능력치 계산기
    local grade = (grade or 1)
    local evolution = (evolution or 1)
    local statusCalc

    if (self.m_charType == 'dragon') then
        if doid then
            statusCalc = MakeOwnDragonStatusCalculator(doid)
        else
            statusCalc = MakeDragonStatusCalculator(self.m_charTable['did'], level, grade, evolution, eclv)
        end
    elseif (self.m_charType == 'monster') then
        statusCalc = StatusCalculator(self.m_charType, self.m_charTable['mid'], level, grade, evolution, eclv)
    else
        error('self.m_charType : ' .. self.m_charType)
    end

    self:setStatusCalc(statusCalc)
end

-------------------------------------
-- function setStatusCalc
-------------------------------------
function Character:setStatusCalc(status_calc)
    self.m_statusCalc = status_calc

    if (not self.m_statusCalc) then
        return
    end

    -- hp 설정
    local hp = self:getStat('hp')
    self.m_maxHp = hp
    self.m_hp = hp
end

-------------------------------------
-- function initLogRecorder
-------------------------------------
function Character:initLogRecorder(unique_id)
    if (unique_id) then
		self.m_charLogRecorder = self.m_world.m_logRecorder:getLogRecorderChar(unique_id)
	else
		cclog('다음 id의 캐릭터가 LogRecorder를 생성하지 못했습니다. ')
	end
end

-------------------------------------
-- function checkAttributeCounter
-- @brief 속성 상성
-------------------------------------
function Character:checkAttributeCounter(attacker_char)
    -- 공격자 속성
	local tar_attr = attacker_char:getAttribute()
    local attacker_attr = attributeNumToStr(tar_attr)

	local atk_attr_adj_rate = attacker_char:getStat('attr_adj_rate')
	local def_attr_adj_rate = self:getStat('attr_adj_rate')

    -- 방어자 속성
    local defender_attr = self:getAttribute()

    local t_attr_effect, attr_synastry = getAttrSynastryEffect(attacker_attr, defender_attr, atk_attr_adj_rate, def_attr_adj_rate)

    return t_attr_effect, attr_synastry
end

-------------------------------------
-- function checkMiss
-- @brief 빚맞힘 여부 검사
-------------------------------------
function Character:checkMiss(attacker_char)
    local miss_rate =  g_constant:get('INGAME', 'MISS_RATE') or 100

    if (math_random(1, 100) <= miss_rate) then
        return true
	end

    return false
end

-------------------------------------
-- function checkAvoid
-- @brief 회피 여부 검사
-------------------------------------
function Character:checkAvoid(activity_carrier, t_attr_effect)
    local hit_rate = activity_carrier:getStat('hit_rate') or 100

	-- 속성 상성 옵션 적용
	do 
		local hit_rates_multifly = 1

		-- 적중률
		if t_attr_effect['hit_rate'] then
			hit_rates_multifly = (hit_rates_multifly + (t_attr_effect['hit_rate']/100))
		end

		hit_rate = (hit_rate * hit_rates_multifly)
	end

	local avoid = self:getStat('avoid')
	local avoid_rates = CalcAvoidChance(hit_rate, avoid)

	-- 회피율을 퍼밀 단위로 랜덤 연산
	if (math_random(1, 1000) <= (avoid_rates * 10)) then
		--cclog('MISS ' .. avoid_rates)
        return true
	end

    return false
end

-------------------------------------
-- function undergoAttack
-------------------------------------
function Character:undergoAttack(attacker, defender, i_x, i_y, body_key, no_event, is_guard)
    if (not attacker.m_activityCarrier) then
        return
    end

    -- guard 상태 체크
    if (self.m_guard) and (not is_guard) then
		-- Event Carrier 세팅
		local t_event = clone(EVENT_HIT_CARRIER)
		t_event['attacker'] = attacker
        t_event['defender'] = defender
		-- @EVENT
		self:dispatch('guardian', t_event)
		return
    end

	-- 공격자 정보
	local attack_activity_carrier = attacker.m_activityCarrier
    local attacker_char = attack_activity_carrier:getActivityOwner()
    local attack_type, real_attack_type = attack_activity_carrier:getAttackType()
    local is_critical = attack_activity_carrier:getCritical() 


    -- 속성 효과
    local t_attr_effect, attr_synastry = self:checkAttributeCounter(attacker_char)
    local is_bash = (attr_synastry == 1)
    local is_miss = (attr_synastry == -1) and self:checkMiss(attacker_char)

    -- 회피 계산(드래그 스킬의 경우는 회피 불가)
    if (attack_type ~= 'active') then
        if (self:checkAvoid(attack_activity_carrier, t_attr_effect)) then
            self:makeMissFont(i_x, i_y)
		    -- @EVENT
		    self:dispatch('avoid_rate')
        
		    -- @LOG_CHAR : 방어자 회피 횟수
		    self.m_charLogRecorder:recordLog('avoid', 1)
            return
        end
    end
    
    -- 공격력 계산, 크리티컬 계산
    local atk_dmg = 0
    local def_pwr = 0
    local damage = 0
	local reduced_damage = 0

    -- 데미지 계산
    do
		-- 공격력, 방어력 스탯
		atk_dmg = attack_activity_carrier:getAtkDmg(defender)
        def_pwr = self:getStat('def')

        -- 방어 관통 적용
        if(attacker) then
            def_pwr = def_pwr - (def_pwr * attacker_char:getStat('pierce') / 100)
            def_pwr = math_max(def_pwr, 0)
        end
		-- 스킬 계수 적용
		atk_dmg = atk_dmg * attack_activity_carrier:getPowerRate()
        
		-- 스킬 추가 공격력 적용
        atk_dmg = atk_dmg + attack_activity_carrier:getAbsAttack()

        -- 드래그 스킬 추가 공격력 적용
        if (attack_type == 'active') then
            local drag_dmg_rate = attack_activity_carrier:getStat('drag_dmg') / 100
            local drag_dmg = atk_dmg * drag_dmg_rate
            atk_dmg = atk_dmg + drag_dmg
        end
		
		-- 방어 무시 체크
		if (attack_activity_carrier:isIgnoreDef()) then 
			def_pwr = 0 
		end
        
		damage = DamageCalc_P(atk_dmg, def_pwr)

		-- 방어에 의해 감소된 피해량 계산
		reduced_damage = atk_dmg - damage
    end

    -- 크리티컬 계산(ActivityCarrier에서 판정되지 않은 경우만)
    do
        if (is_miss) then
            -- 빚맞힘일 경우 크리티컬 없도록 처리
            is_critical = false

        elseif (is_critical == nil) then
            local critical_chance = attack_activity_carrier:getStat('cri_chance') or 0
            local critical_avoid = self:getStat('cri_avoid')
            local final_critical_chance = CalcCriticalChance(critical_chance, critical_avoid)

            -- 속성 상성 적용
            if t_attr_effect['cri_chance'] then
                final_critical_chance = (final_critical_chance + t_attr_effect['cri_chance'])
            end

            is_critical = (math_random(1, 1000) <= (final_critical_chance * 10))
        end
    end

    do -- 최종 데미지 계산
        local damage_multifly = 1

        -- 크리티컬
        if is_critical then
            local cri_dmg = attack_activity_carrier:getStat('cri_dmg') or 0
            damage_multifly = (cri_dmg / 100)
        end

        -- 속성
        if t_attr_effect['damage'] then
            local attr_dmg_multifly = (t_attr_effect['damage'] / 100)
            attr_bonus_dmg = (damage * attr_dmg_multifly)
            damage_multifly = damage_multifly + attr_dmg_multifly
        end
        -- (피격/공격)시 상대가 (특정 상태효과)를 가진 적이면 피해량 증가
        local additional_dmg_adj_rate = 0
        for k, v in pairs(attacker_char:getStatusEffectList()) do

            if (v.m_type == 'modify_dmg' and v.m_branch == 0) then
                if(defender:isExistStatusEffectName(v.m_targetStatusEffectName)) then
                    additional_dmg_adj_rate = additional_dmg_adj_rate + v.m_totalValue
                end
            end
        end

        for k, v in pairs(defender:getStatusEffectList()) do

            if (v.m_type == 'modify_dmg' and v.m_branch == 1) then
                if(attacker_char:isExistStatusEffectName(v.m_targetStatusEffectName)) then
                    additional_dmg_adj_rate = additional_dmg_adj_rate - v.m_totalValue
                end
            end
        end

		-- 상태효과에 의한 증감
		damage_multifly = (damage_multifly + (self:getStat('dmg_adj_rate') + additional_dmg_adj_rate) / 100)

        damage = (damage * damage_multifly)

        -- 음수일 경우 0으로 변경
        damage = math_max(damage, 0)
    end

    -- Event Carrier 세팅
	local t_event = clone(EVENT_HIT_CARRIER)
    t_event['skill_id'] = attack_activity_carrier:getSkillId()
	t_event['damage'] = damage
	t_event['reduced_damage'] = reduced_damage
	t_event['attacker'] = attacker_char
	t_event['defender'] = self
	t_event['is_critical'] = is_critical
    t_event['i_x'] = i_x
    t_event['i_y'] = i_y
    t_event['left_formation'] = self.m_bLeftFormation
	
	-- 방어와 관련된 이벤트 처리후 데미지 계산
	do	
		-- @EVENT 방어 이벤트 (에너지실드)
		self:dispatch('hit_shield', t_event)

		-- @EVENT 방어 이벤트 (횟수)
		self:dispatch('hit_barrier', t_event)
	
		damage = t_event['damage']
		
		-- 방어 처리 후 데미지 0이라면 방어 성공 처리
		if (t_event['is_handled']) and (damage == 0) then 
			self:makeShieldFont(i_x, i_y)
            
			-- @LOG_CHAR
			self.m_charLogRecorder:recordLog('shield', 1)

			return
		end
	end
	
    -- 스킬 공격으로 피격되였다면 캐스팅 중이던 스킬을 취소시킴
    if (attack_type == 'active') then
        -- 효과음
        if (is_critical) then
            SoundMgr:playEffect('EFX', 'efx_damage_critical')
        else
            SoundMgr:playEffect('EFX', 'efx_damage_normal')
        end
    else
        -- 효과음
        if (is_critical) then
            SoundMgr:playEffect('EFX', 'efx_damage_critical')
        else
            SoundMgr:playEffect('EFX', 'efx_damage_normal')
        end
    end
        	
	-- 공격 데미지 전달
	do
		local t_info = {}
		t_info['attack_type'] = attack_type
		t_info['attr'] = attack_activity_carrier.m_attribute
		t_info['is_critical'] = is_critical
		t_info['is_add_dmg'] = attack_activity_carrier:getParam('add_dmg')
        t_info['is_bash'] = is_bash
        t_info['is_miss'] = is_miss
		t_info['body_key'] = body_key
	
		self:setDamage(attacker, defender, i_x, i_y, damage, t_info)
	end

    if (not no_event and attacker_char) then
        -- 공격자 반사 데미지 처리
        if (attack_type == 'active') then 
            local reflex_skill = self:getStat('reflex_skill')
            if (reflex_skill > 0) then
                local reflex_damage = damage * (reflex_skill / 100)
			    attacker_char:setDamage(nil, attacker_char, attacker_char.pos.x, attacker_char.pos.y, reflex_damage)
            end
        else
            local reflex_normal = self:getStat('reflex_normal')
            if (reflex_normal > 0) then
                local reflex_damage = damage * (reflex_normal / 100)
			    attacker_char:setDamage(nil, attacker_char, attacker_char.pos.x, attacker_char.pos.y, reflex_damage)
            end
        end

        -- 공격자 HP 흡수 처리
        local hp_drain = attacker_char:getStat('hp_drain')
        if (hp_drain > 0) then
            local heal_abs = damage * (hp_drain / 100)
			attacker_char:healAbs(attacker_char, heal_abs, true)
        end
    end

    -- 상태이상 체크(attack_activity_carrier가 가진 상태효과)
    if (not no_event and not is_miss) then
        StatusEffectHelper:statusEffectCheck_onHit(attack_activity_carrier, self)
    end

	-- @LOG_CHAR : 방어자 피격 횟수
	self.m_charLogRecorder:recordLog('under_atk', 1)
	
	-- @EVENT 방어자 이벤트 처리
	if (not no_event) then
		-- 피격
		self:dispatch('under_atk', t_event)
		
		-- 피격 스킬용 이벤트
		self:dispatch('under_atk_turn', t_event)
		self:dispatch('under_atk_rate', t_event)
	
		-- 크리로 피격
		if (is_critical) then
			self:dispatch('under_atk_cri', t_event)
		end

		-- 일반 피격
		if (attack_type == 'basic') then 
			attacker_char:dispatch('under_atk_basic', t_event, self, attack_activity_carrier)

		-- 액티브 피격
		elseif (attack_type == 'active') then
			attacker_char:dispatch('under_atk_active', t_event, self, attack_activity_carrier)
		end
	end

	-- @EVENT 시전자 이벤트 처리
	if (attacker_char and not is_miss) then
        -- 일반
        if (not no_event) then
		    self:dispatch(CON_SKILL_HIT, t_event)
        end

		-- 크리티컬 
		if (is_critical) then
            self:dispatch(CON_SKILL_HIT_CRI, t_event)

            if (real_attack_type == 'basic') then
			    attacker_char:dispatch('basic_cri', t_event)
            elseif (attack_type == 'active') then
                attacker_char:dispatch('skill_cri', t_event)
            end
		end
			
		-- 적 처치시
        if (not no_event) then
            local b = false

            if (attack_type == 'active') then
                b = (self.m_hp <= 0)
            else
                b = self:isDead()
		    end

            if (b) then
                self:dispatch(CON_SKILL_HIT_KILL, t_event, self)
            end
        end
		
		-- 일반 공격시
        if (not no_event) then
		    if (attack_type == 'basic') then 
			    attacker_char:dispatch('enemy_last_attack', t_event, self, attack_activity_carrier)
                self.m_world.m_logRecorder:recordLog('basic_attack_cnt', 1)

		    -- 액티브 공격시
		    elseif (attack_type == 'active') then
			    attacker_char:dispatch('hit_active', t_event, self, attack_activity_carrier)
		    end
        end
    end

    if (not no_event) then
        if (real_attack_type == 'active') then 
            self:runAction_Shake()
        end
    end

	-- @DEBUG
	if g_constant:get('DEBUG', 'PRINT_ATTACK_INFO') then
		SkillHelper:printAttackInfo(attacker, defender, attack_type, atk_dmg, def_pwr, damage)
    end
end

-------------------------------------
-- function setDamage
-------------------------------------
function Character:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    if (self.m_bDead) then return end

    local t_info = t_info or EMPTY_TABLE
    local dir = 0
    
    if (attacker) then
        if (isInstanceOf(attacker, PhysObject)) then
            dir = attacker.movement_theta
        end
    end

    -- 데미지 폰트 출력
    self:makeDamageEffect(i_x, i_y, dir, t_info['is_critical'])
    self:makeDamageFont(damage, i_x, i_y, t_info)

    -- 무적 체크 후 데미지 적용
	if (self.m_bLeftFormation and g_constant:get('DEBUG', 'PLAYER_INVINCIBLE')) then
		-- NOTHING TO DO
	elseif (not self.m_bLeftFormation and g_constant:get('DEBUG', 'ENEMY_INVINCIBLE')) then
		-- NOTHING TO DO
	elseif (self.m_bInvincibility) then
        -- NOTHING TO DO
    else
		local damage = math_min(damage, self.m_hp)
		self:setHp(self.m_hp - damage)

		-- @LOG_CHAR : 공격자 데미지
        if (attacker) then
		    attacker.m_activityCarrier:getActivityOwner().m_charLogRecorder:recordLog('damage', damage)
        end
		-- @LOG_CHAR : 방어지 피해량
		self.m_charLogRecorder:recordLog('be_damaged', damage)
	end

    -----------------------------------------------------------------
    -- 죽음 체크
    -----------------------------------------------------------------
    local checkDie = function() return (not self:isDead() and self.m_hp <= 0 and not self.m_isZombie) end

    if (checkDie()) then
        -- 죽기 직전 이벤트(딱 한번만 호출됨)
        self:dispatch('dead_ago', {}, self)

        local attack_type = t_info['attack_type']
                
        -- @LOG : 보스 막타 타입
		if (self:isBoss()) then
			self.m_world.m_logRecorder:recordLog('finish_atk', attack_type)
		end

        -- @LOG : 드래그 스킬로 적 처치
        if (attack_type == 'active') then
            self.m_world.m_logRecorder:recordLog('active_kill_cnt', 1)
        end
    end

    -- 드래그 스킬시 일시동안 무적처리 및 골드 드래곤 금화 드랍을 위해 사용되는 이벤트
    do
        self:dispatch('damaged', { ['damage']=damage, ['i_x']=i_x, ['i_y']=i_y, ['will_die']=checkDie() }, self)
    end

    -- damaged 이벤트로 좀비 상태가 될 수 있음
    if (checkDie()) then
        self:changeState('dying')
    else
        -- 피격시 타격감을 위한 연출
        if (attacker) then
            self:runAction_Hit(attacker, dir)
        end
    end
end

-------------------------------------
-- function getSkillTable
-------------------------------------
function Character:getSkillTable(skill_id)
    if (not skill_id) or (skill_id == '') or (skill_id == 0) then
        return nil
    end

	local t_skill = nil

    -- 캐릭터 유형별(dragon or enemy)로 스킬 테이블 호출하고 가져온다.
    if (self.m_charType == 'monster') then
        t_skill = TableMonsterSkill():get(skill_id)
	else
        t_skill = self:getLevelingSkillById(skill_id)
    end

    return t_skill
end

-------------------------------------
-- function doAttack
-------------------------------------
function Character:doAttack(skill_id, x, y)
    if skill_id then
        local indicatorData

        local t_skill = self:getSkillTable(skill_id)

        if (t_skill['chance_type'] == 'indie_time') then
            indicatorData = {}
        end

        local b_run_skill = self:doSkill(skill_id, x, y, indicatorData)

        -- 지정된 스킬이 발동되지 않았을 경우 또는 basic_turn, rate 인 경우 기본 스킬 발동
        if self.m_isAddSkill or (not b_run_skill) then
            local basic_skill_id = self:getSkillID('basic')
            self:doSkill(basic_skill_id, x, y)
        end

		self:dispatch('char_do_atk')
		
		-- 기본 공격 + 드래곤 일때 사운드 재생
		if (t_skill['chance_type'] == 'basic') and (self.m_charType == 'dragon') then
			SoundMgr:playEffect('EFX', 'efx_attack')
		end
    end

    -- 예약된 스킬 정보 초기화
    self.m_reservedSkillId = nil
    self.m_reservedSkillCastTime = 0
end

-------------------------------------
-- function checkDie
-- @brief 죽임(좀비나 자폭 등의 죽기전 발동되는 스킬을 발동시킴)
-------------------------------------
function Character:doDie()
    self:setDamage(nil, self, self.pos.x, self.pos.y, self.m_hp, nil)
end

-------------------------------------
-- function doRevive
-- @brief 부할
-------------------------------------
function Character:doRevive(hp_rate)
    if (not self.m_bDead or not self.m_bPossibleRevive) then return end
    self.m_bDead = false

    local hp = math_floor(self.m_maxHp * hp_rate)
    self:setHp(hp, true)
    self.m_hpNode:setVisible(true)

    self:changeState('revive', true)

    self.m_world:addHero(self)

    self:dispatch('character_revive', {}, self)
end

-------------------------------------
-- function makeDamageEffect
-------------------------------------
function Character:makeDamageEffect(x, y, dir, is_critical)
    -- 일반 데미지
    local effect = MakeAnimator('res/effect/effect_hit_01/effect_hit_01.vrp')
    
    if is_critical then
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
-- function makeDamageFont
-------------------------------------
function Character:makeDamageFont(damage, x, y, tParam)
    local y = y + 60
    local tParam = tParam or {}

    local is_critical = tParam['is_critical'] or false
    local is_add_dmg = tParam['is_add_dmg'] or false
    local is_bash = tParam['is_bash'] or false
    local is_miss = tParam['is_miss'] or false

    -- 소수점 제거
    local damage = math_floor(damage)

	-- 0 데미지는 출력하지 않는다.
    if (damage <= 0) then
        return
    end

    if (type(damage) ~= 'number') then
        error('invalid damage value = ' .. damage)
    end

    -- root node 생성
    local node = cc.Node:create()
    node:setPosition(x, y)
    
    if (is_critical) then
        node:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 3.5), cc.ScaleTo:create(0.3, 1), cc.DelayTime:create(0.4), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        --node:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.4), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
    else
        node:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
    end

    self.m_world:addChild3(node, DEPTH_DAMAGE_FONT)
    
	-- label 생성
    do
        local font_res = 'res/font/normal.fnt'
	    if (is_critical) then
		    font_res = 'res/font/critical.fnt'	-- 보라계열
	    end
     
        local label = cc.Label:createWithBMFont(font_res, comma_value(damage))

        
	    -- 추가 데미지
        if (g_constant:get('DEBUG', 'ADD_DMG_YELLOW_FONT') and is_add_dmg) then
		    label:setColor(cc.c3b(225, 229, 0))	-- 노랑
        
        elseif (is_miss) then
            -- 빚맞힘
            label:setColor(cc.c3b(198, 198, 198))	-- 회색
	    
	    else
            -- 일반 데미지
            if (self.m_bLeftFormation) then
                label:setColor(cc.c3b(235, 71, 42))	-- 빨강
            end
        end
               
	    node:addChild(label)
    end

    -- 판정 표시
    do
        local sprite

        if (is_critical) then
            sprite = cc.Sprite:create('res/font/ingame_critical.png')
        elseif (is_bash) then
            sprite = cc.Sprite:create('res/font/bash.png')
        elseif (is_miss) then
            sprite = cc.Sprite:create('res/font/miss.png')
        end

        if (sprite) then
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            sprite:setDockPoint(cc.p(0.5, 0.5))
            sprite:setPosition(0, 25)
            node:addChild(sprite)
        end
    end
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
    local sprite = cc.Sprite:create('res/font/dodge.png')

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
-- function healPercent
-------------------------------------
function Character:healPercent(caster, percent, b_make_effect)
    local heal = self.m_maxHp * percent
    heal = math_min((self.m_maxHp - self.m_hp) , heal)

    self:healAbs(caster, heal, b_make_effect)
end

-------------------------------------
-- function healAbs
-------------------------------------
function Character:healAbs(caster, heal, b_make_effect)
    local heal = math_floor(heal)

    -- 시전자 회복 스킬 효과 증가 처리
    if (caster) then
         local heal_power = caster:getStat('heal_power')
         if (heal_power ~= 0) then
            heal_power = math_max(heal_power, -100)
            heal = heal + math_floor(heal * (heal_power / 100))
         end
    end

    -- 대상자 받는 치유 효과 증가 처리
    do
        local recovery_power = self:getStat('recovery_power')
        if (recovery_power ~= 0) then
            recovery_power = math_max(recovery_power, -100)
            heal = heal + math_floor(heal * (recovery_power / 100))
        end
    end

    -- 회복량이 0일 경우 표시하지 않음
    --if (heal <= 0) then return end

    local heal_for_text = heal
    heal = math_min(heal, (self.m_maxHp-self.m_hp))

    self:makeHealFont(heal_for_text)
    self:setHp(self.m_hp + heal)

    if (b_make_effect) then
        local res = 'res/effect/skill_heal_monster/skill_heal_monster.vrp'
        local pos_x = self.pos['x']
        local pos_y = self.pos['y']
        local effect = self.m_world:addInstantEffect(res, 'idle', pos_x, pos_y)
    end

    if (caster) then
        -- 회복 되었을 시 이벤트
        self:dispatch('character_recovery', {}, self)
    end

	-- @LOG_CHAR : 피회복자 피회복량
	self.m_charLogRecorder:recordLog('be_healed', heal)
	-- @LOG_CHAR : 회복시전자 회복량
	if (caster) then
		caster.m_charLogRecorder:recordLog('heal', heal)
	end
end

-------------------------------------
-- function setHp
-------------------------------------
function Character:setHp(hp, bFixed)
	-- 죽었을시 탈출
	if (self:isDead()) then return end
    if (not bFixed and self.m_hp == 0) then return end

    self.m_hp = math_min(hp, self.m_maxHp)

    if (self.m_isImmortal) then
        self.m_hp = math_max(self.m_hp, 1)
    end

    -- 리스너에 전달
	local t_event = clone(EVENT_CHANGE_HP_CARRIER)
	t_event['owner'] = self
	t_event['hp'] = self.m_hp
	t_event['max_hp'] = self.m_maxHp

    self:dispatch('character_set_hp', t_event, self)

    self.m_hp = t_event['hp']

    local percentage = self.m_hp / self.m_maxHp

	-- 체력바 가감 연출
    if self.m_hpGauge then
        self.m_hpGauge:setScaleX(percentage)
    end
	if self.m_hpGauge2 then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, percentage, 1))
        self.m_hpGauge2:runAction(cc.EaseIn:create(action, 2))
    end
end

-------------------------------------
-- function release
-------------------------------------
function Character:release()
    if (self.m_world) then
        if (self.m_bLeftFormation) then
            self.m_world:removeHero(self)
        else
            self.m_world:removeEnemy(self)
        end
    end

    if (self.m_unitInfoNode) then
        self.m_unitInfoNode:removeFromParent(true)
    end

    if (self.m_enemySpeechNode) then
        self.m_enemySpeechNode:removeFromParent(true)
        self.m_enemySpeechNode = nil
    end

    if (self.m_dragonSpeechNode) then
        self.m_dragonSpeechNode:removeFromParent(true)
        self.m_dragonSpeechNode = nil
    end

    self.m_unitInfoNode = nil

    self.m_hpNode = nil
    self.m_hpGauge = nil

    self.m_statusNode = nil

    self.m_castingNode = nil
    self.m_castingGauge = nil

    -- formationMgr
    self.m_cbChangePos = nil

	-- 이벤트 해제
	self:release_EventDispatcher()
    self:release_EventListener()

    PARENT.release(self)
end

-------------------------------------
-- function setActive
-------------------------------------
function Character:setActive(active)
    self.m_bActive = active

    if self.m_bActive then
        self.enable_body = true
        if self.m_rootNode then
            self.m_rootNode:setVisible(true)
        end
    else
        self.enable_body = false
        if self.m_rootNode then
            self.m_rootNode:setVisible(false)
        end

        -- 이동 중지
        self:resetMove()
    end
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
    self.m_unitInfoOffset = hp_ui_offset

    if (self.m_hpNode) then
        self.m_hpNode:removeFromParent()
        self.m_hpNode = nil
        self.m_hpGauge = nil
        self.m_hpGauge2 = nil
        self.m_statusNode = nil
        self.m_infoUI = nil
    end
    
    local ui = UI_IngameUnitInfo(self)
    self.m_hpNode = ui.root
    self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setVisible(false)

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_statusNode = self.m_hpNode

    self.m_unitInfoNode:addChild(self.m_hpNode)

	self.m_infoUI = ui
end

-------------------------------------
-- function makeCastingNode
-------------------------------------
function Character:makeCastingNode()
    self.m_castingNode = cc.Node:create()
    self.m_castingNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_castingNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_castingNode:setVisible(false)
    self:getEnemySpeechNode():addChild(self.m_castingNode, 5)

    local ui = UI()
    ui:load('enemy_skill_speech.ui')
    self.m_castingNode:addChild(ui.root)

    self.m_castingUI = ui.root
    self.m_castingMarkGauge = ui.vars['markGauge']
    self.m_castingSpeechVisual = ui.vars['speechVisual']

    do
        self.m_castingMarkGauge:setVisible(true)
        self.m_castingSpeechVisual:setVisible(true)
        
        self.m_castingMarkGauge:setPosition(53, 107)
        self.m_castingSpeechVisual:setPosition(99, 144)
    end
end

-------------------------------------
-- function setPosition
-------------------------------------
function Character:setPosition(x, y)
	PARENT.setPosition(self, x, y)

    if (self.m_unitInfoNode) then
        self.m_unitInfoNode:setPosition(x, y)
    end

    if (self.m_hpNode and not self.m_bFixedPosHpNode) then
        self.m_hpNode:setPosition(self.m_unitInfoOffset[1], self.m_unitInfoOffset[2])
    end

    if (self.m_castingNode) then
        self.m_castingNode:setPosition(self.m_unitInfoOffset[1], self.m_unitInfoOffset[2])
    end

    if (self.m_cbChangePos) then
        self.m_cbChangePos(self)
    end

    if (self.m_dragonSpeechNode) then
        self.m_dragonSpeechNode:setPosition(x, y)
    end

    if (self.m_enemySpeechNode) then
        self.m_enemySpeechNode:setPosition(x, y)
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

        if (self.m_bLeftFormation) then
            self.m_attackPeriod = 0
        else
            if (self.m_charType == 'dragon') then
                self.m_attackPeriod = 0
            else
                self.m_attackPeriod = self.m_statusCalc.m_attackTick * math_random(1, 100) / 100
            end
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
    if (self.m_isSpasticity) then
        self.m_delaySpasticity = self.m_delaySpasticity - dt

        if (self.m_delaySpasticity <= 0 or not self.m_bEnableSpasticity) then
            self:setSpasticity(false)
        else
            return
        end
    end

    if (not self:isDead() and self.m_world.m_gameState:isFight()) then
        -- 로밍
        if (self.m_bRoam) then
			self:updateRoaming(dt)
            self:syncAniAndPhys()
        end
        
		-- 쿨타임 스킬 타이머
        self:updateBasicSkillTimer(dt)
    end

	-- 이동 시 업데이트
	if (self.m_isOnTheMove) then
		self:updateMove(dt)
	end
		
	-- 잔상 효과 업데이트
	if (self.m_isUseAfterImage) then
		self:updateAfterImage(dt)
	end

	-- 상태효과 업데이트
	self:updateStatusEffect(dt)
    
	-- @TEST 디버깅용 디스플레이
    if (self.m_infoUI) then
		self:updateDebugingInfo()
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function updateMove
-------------------------------------
function Character:updateMove()
    local body = self.body

    if self:isOverTargetPos(true) then
        self:setPosition(self.m_targetPosX, self.m_targetPosY)
        self:resetMove()
    end
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function Character:updateAfterImage(dt)
    self.m_afterimageTimer = self.m_afterimageTimer + (self.speed * dt)
    local interval = 50

    if (self.m_afterimageTimer >= interval) then
        self.m_afterimageTimer = self.m_afterimageTimer - interval

        local duration = (interval / self.speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = self.m_animator.m_resName
		local scale = self.m_animator:getScale()

       -- GL calls를 줄이기 위해 월드를 통해 sprite를 얻어옴
        local sprite = self.m_world:getDragonBatchNodeSprite(res, scale)
        sprite:setFlippedX(self.m_animator.m_bFlip)
        sprite:setOpacity(255 * 0.3)
        sprite:setPosition(self.pos.x, self.pos.y)

        sprite:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function updateBasicSkillTimer
-------------------------------------
function Character:updateBasicSkillTimer(dt)
    if (self:isDead()) then
		return
	end

    if (self.m_isSilence) then
		return
	end

    -- 스킬 사용 불가 상태
    if (isExistValue(self.m_state, 'delegate', 'stun')) then
        return
    end

    -- 이미 스킬을 사용하기 위한 상태일 경우
    if (isExistValue(self.m_state, 'skillPrepare', 'skillAppear', 'skillIdle')) then
        return
    end

    -- cool_actu 스텟 적용(쿨타임 감소)
    do
        -- @ RUNE
        local cool_actu = self:getStat('cool_actu') or 0
        local rate = 1 + (cool_actu / 100)
        rate = math_max(rate , 0)

        dt = dt * rate
    end
    
    PARENT.updateBasicSkillTimer(self, dt)
end

-------------------------------------
-- function isPossibleMove
-------------------------------------
function Character:isPossibleMove(order)
    local order = order or 0

    if (self:isDead()) then
        return false
    end

    if (isExistValue(self.m_state, 'delegate', 'stun')) then
        return false
    end

    if (self.m_isOnTheMove and order < self.m_orderOnTheMove) then
        return false
    end
        
    return true
end

-------------------------------------
-- function setMove
-------------------------------------
function Character:setMove(x, y, speed, order)
    self.m_isOnTheMove = true
    self.m_orderOnTheMove = order or 0

    self:setTargetPos(x, y)
    self:setSpeed(speed)
end

-------------------------------------
-- function setMoveHomePos
-------------------------------------
function Character:setMoveHomePos(speed)
    local speed = speed or SPEED_COMEBACK

    self:setMove(self.m_homePosX, self.m_homePosY, speed)
end

-------------------------------------
-- function resetMove
-------------------------------------
function Character:resetMove()
    self.m_isOnTheMove = false
    self.m_orderOnTheMove = -1

    self:setSpeed(0)

    if (self.m_movement) then
        self.m_movement:doMove(self)
    end
end

-------------------------------------
-- function changeHomePos
-------------------------------------
function Character:changeHomePos(x, y, speed, order)
    local order = order or 0

    self:setHomePos(x, y)

    if (not self:isPossibleMove(order)) then return end

    local speed = speed or 500
    self:setMove(x, y, speed, order)
end

-------------------------------------
-- function changeHomePos
-------------------------------------
function Character:changeHomePosByTime(x, y, time, order)
    local order = order or 0

    self:setHomePos(x, y)

    if (not self:isPossibleMove(order)) then return end

    -- 거리를 계산하여 속도를 구함
    local cur_x, cur_y = self.pos.x, self.pos.y
    local distance = getDistance(cur_x, cur_y, x, y)
    if (distance == 0) then return end

    local speed

    local time = time or 0.5
    if (time <= 0) then
        speed = 9999
    else
        speed = distance / time 
    end
    
    self:setMove(x, y, speed, order)
end

-------------------------------------
-- function setAfterImage
-------------------------------------
function Character:setAfterImage(b)
    self.m_afterimageTimer = 0
    self.m_isUseAfterImage = b
end

-------------------------------------
-- function syncAniAndPhys
-- @brief m_rootNode의 위치로 클래스의 위치 동기화
-------------------------------------
function Character:syncAniAndPhys()
    if (not self.m_rootNode) then return end

	local x, y = self.m_rootNode:getPosition()
	self:setPosition(x, y)
end

-------------------------------------
-- function getTargetChar
-------------------------------------
function Character:getTargetChar()
    return self.m_targetChar
end

-------------------------------------
-- function isExistTargetEffect
-------------------------------------
function Character:isExistTargetEffect(k)
    if (self.m_mTargetEffect[k]) then
        return true
    end

    return false
end

-------------------------------------
-- function setTargetEffect
-------------------------------------
function Character:setTargetEffect(animator, k)
    if (self.m_bDead) then return end

    self:removeNonTargetEffect(k)
    self.m_mTargetEffect[k] = animator

    if (animator) then
        local body = self:getBody(k)
        local root_node = self:getRootNode()
        
		if (self.m_isSlaveCharacter) then 
			animator:setPosition(self.m_unitInfoOffset[1] + body['x'], self.m_unitInfoOffset[2] + body['y'])
			root_node:addChild(animator.m_node)
		else
			animator:setPosition(body['x'], body['y'])
			root_node:addChild(animator.m_node)
		end

		-- 사운드
		SoundMgr:playEffect('UI', 'ui_target')
    end
end

-------------------------------------
-- function removeTargetEffect
-------------------------------------
function Character:removeTargetEffect(k)
    local f_remove = function(k)
        if (self.m_mTargetEffect[k]) then
            self.m_mTargetEffect[k]:release()
            self.m_mTargetEffect[k] = nil
        end 
    end

    if (k) then
        f_remove(k)
    else
        local body_list = self:getBodyList() 
        for i, body in ipairs(body_list) do
            f_remove(body['key'])
        end
    end
end

-------------------------------------
-- function isExistTargetEffect
-------------------------------------
function Character:isExistNonTargetEffect(k)
    if (self.m_mNonTargetEffect[k]) then
        return true
    end

    return false
end

-------------------------------------
-- function setNonTargetEffect
-------------------------------------
function Character:setNonTargetEffect(animator, k)
    if (self.m_bDead) then return end

    self:removeTargetEffect(k)
    self.m_mNonTargetEffect[k] = animator

    if (animator) then
        local body = self:getBody(k)
        local root_node = self:getRootNode()
        
		if (self.m_isSlaveCharacter) then 
			animator:setPosition(self.m_unitInfoOffset[1] + body['x'], self.m_unitInfoOffset[2] + body['y'])
			root_node:addChild(animator.m_node)
		else
			animator:setPosition(body['x'], body['y'])
			root_node:addChild(animator.m_node)
		end
    end
end

-------------------------------------
-- function removeNonTargetEffect
-------------------------------------
function Character:removeNonTargetEffect(k)
    if (k) then
        if (self.m_mNonTargetEffect[k]) then
            self.m_mNonTargetEffect[k]:release()
            self.m_mNonTargetEffect[k] = nil
        end 
    else
        for _, effect in pairs(self.m_mNonTargetEffect) do
            effect:release()
        end

        self.m_mNonTargetEffect = {}
    end
end

-------------------------------------
-- function updateRoaming
-- @brief roaming을 한다
-------------------------------------
function Character:updateRoaming(dt)
    if (not self:isPossibleMove(-1)) then
        self:stopRoaming()
        return
    end

    if (self.m_roamTimer <= 0) then
        local time_range =  g_constant:get('INGAME', 'ENEMY_ROAM_TIME_RANGE')
        local time = math_random(time_range[1] * 10, time_range[2] * 10) / 10

        -- 랜덤한 위치를 뽑는다
        local tar = getRandomWorldEnemyPos(self)

        local bezier_range =  g_constant:get('INGAME', 'ENEMY_ROAM_BEZIER_RANGE')
        local distance = math_random(bezier_range[1], bezier_range[2])
        local bezier = getRandomBezier(tar.x, tar.y, self.pos.x, self.pos.y, distance)
        local move_action = cc.BezierBy:create(time, bezier)

        self:setHomePos(tar.x, tar.y)
        cca.stopAction(self.m_rootNode, CHARACTER_ACTION_TAG__ROAM)
        cca.runAction(self.m_rootNode, move_action, CHARACTER_ACTION_TAG__ROAM)
        
        self.m_roamTimer = time
    else
        self.m_roamTimer = self.m_roamTimer - dt
    end
end

-------------------------------------
-- function updateDebugingInfo
-- @brief 인게임 정보 출력용 업데이트
-------------------------------------
function Character:updateDebugingInfo()
	-- 화면에 체력 표시
	if g_constant:get('DEBUG', 'DISPLAY_UNIT_HP') then 
		self.m_infoUI.m_label:setString(string.format('%d/%d\n(%d%%)',self.m_hp, self.m_maxHp, self.m_hp/self.m_maxHp*100))

	-- 화면에 좌표 표시
	elseif g_constant:get('DEBUG', 'DISPLAY_UNIT_POS') then 
		self.m_infoUI.m_label:setString(string.format('%d, %d, %d, %d',self.pos.x, self.pos.y, self.m_homePosX, self.m_homePosY))

	-- 화면에 특정 로그 표시
	elseif (g_constant:get('DEBUG', 'DISPLAY_UNIT_LOG')) then
		local key = g_constant:get('DEBUG', 'DISPLAY_UNIT_LOG')
		local log = self.m_charLogRecorder:getLog(key)
		self.m_infoUI.m_label:setString(string.format('%s : %d', key, log))
	end
end

-------------------------------------
-- function setStatusIcon
-------------------------------------
function Character:setStatusIcon(status_effect, idx)
    --PARENT.setStatusIcon(self, status_effect, idx)
	local status_effect_type = status_effect:getTypeName()
	local idx = idx 

	-- icon 생성 또는 있는것에 접근
	local icon = nil
	if (self.m_lStatusIcon[status_effect_type]) then 
		icon = self.m_lStatusIcon[status_effect_type]
	else
		icon = StatusEffectIcon(self, status_effect)

        self.m_lStatusIcon[status_effect_type] = icon
	end

    if self.m_infoUI then
        local x, y = self.m_infoUI:getPositionForStatusIcon(self.m_bLeftFormation, idx)
        local scale = self.m_infoUI:getScaleForStatusIcon()

        icon.m_icon:setPosition(x, y)
        icon.m_icon:setScale(scale)
    end
end

-------------------------------------
-- function getFormationMgr
-- @param is_opposite : true 일때 상대 진형을 선택
-------------------------------------
function Character:getFormationMgr(is_opposite)
	if is_opposite then 
		-- 상대 진형 선택
		if self.m_bLeftFormation then
			return self.m_world.m_rightFormationMgr
		else
			return self.m_world.m_leftFormationMgr
		end
	else
		-- 아군 진형 선택
		if self.m_bLeftFormation then
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
	if (self.m_charTable) 
	and (self.m_charTable['t_name']) then 
		return self.m_charTable['t_name']
	else
		return '까미'
	end
end

-------------------------------------
-- function getCharId
-------------------------------------
function Character:getCharId()
    local char_id
    if (self.m_charType == 'dragon') then
        char_id = self.m_charTable['did']
    elseif (self.m_charType == 'monster') then
        char_id = self.m_charTable['mid']
    elseif (self.m_charType == 'tamer') then
        char_id = self.m_charTable['tid']
    else
        error('Character:getCharId error')
    end
        
	return char_id
end

-------------------------------------
-- function getCharType
-- @return 'dragon' or 'enemy'
-------------------------------------
function Character:getCharType()
	return self.m_charType
end

-------------------------------------
-- function getRarity
-- @return 희귀도(보스 판정으로 사용)
-------------------------------------
function Character:getRarity()
    return 0
end

-------------------------------------
-- function getRole
-------------------------------------
function Character:getRole()
	return self.m_charTable['role']
end

-------------------------------------
-- function getAttribute
-------------------------------------
function Character:getAttribute()
	return self.m_attribute
end

-------------------------------------
-- function getAttributeOrg
-------------------------------------
function Character:getAttributeOrg()
	return self.m_attributeOrg
end

-------------------------------------
-- function getAttributeForRes
-- @brief 원리소스가 우선인 경우 사용 
-------------------------------------
function Character:getAttributeForRes()
	return self:getAttributeOrg() or self:getAttribute() or ''
end

-------------------------------------
-- function changeAttribute
-------------------------------------
function Character:changeAttribute(tar_attr)
	-- 대상 속성을 지정하면 그 속성으로 변경한다.
	if (tar_attr) then
		self.m_attribute = tar_attr

	-- 대상 속성을 지정하지 않는다면 원 속성으로 바꾼다.
	else
		if (self.m_attributeOrg) then 
			self.m_attribute = self.m_attributeOrg
		end
	end
end

-------------------------------------
-- function makeAttackDamageInstance
-- @brief
-------------------------------------
function Character:makeAttackDamageInstance()
    local activity_carrier = ActivityCarrier()

	-- 시전자를 지정
	activity_carrier:setActivityOwner(self)

    -- 속성 지정
    activity_carrier.m_attribute = attributeStrToNum(self:getAttribute())

    -- 세부 능력치 지정
	activity_carrier:setStatuses(self.m_statusCalc)

    return activity_carrier
end

-------------------------------------
-- function runAction_Shake
-- @brief 피격 시 캐릭터 진동 효과
-------------------------------------
function Character:runAction_Shake()
    if (not self.m_animator) then return end
    
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local x = -math_random(20, 25)
    local y = math_random(20, 30)
    
    target_node:setPosition(0, 0)
    local start_action = cc.MoveTo:create(0.05, cc.p(x, 0))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.15, cc.p(0, 0)), 0.2)
    local action = cc.Sequence:create(start_action, end_action)
    cca.runAction(target_node, action, CHARACTER_ACTION_TAG__SHAKE)
end

-------------------------------------
-- function runAction_Hit
-- @brief 피격 시 캐릭터 애니메이션
-------------------------------------
function Character:runAction_Hit(attacker, dir)
    -- 경직
    if self:isBoss() then
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

        if self:isBoss() then
            delay = 0.06
        end

        local action = cc.Sequence:create(
            cc.CallFunc:create(function(node)
                local shader = ShaderCache:getShader(SHADER_CHARACTER_DAMAGED)
                self.m_animator.m_node:setGLProgram(shader)
            end),
            cc.DelayTime:create(delay),
            cc.CallFunc:create(function(node)
                local baseShaderKey = self.m_animator.m_baseShaderKey
                local shader = ShaderCache:getShader(baseShaderKey)
                self.m_animator.m_node:setGLProgram(shader)
            end)
        )        
        cca.runAction(target_node, action, CHARACTER_ACTION_TAG__SHADER)
    end
end

-------------------------------------
-- function runAction_Knockback
-- @brief 피격 시 캐릭터 밀림 효과
-------------------------------------
function Character:runAction_Knockback(dir)
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

    local start_action = cc.DelayTime:create(SpasticityTime)
    local end_action = cc.MoveTo:create(0.1, cc.p(0, 0))
    local action = cc.Sequence:create(start_action, end_action)
    cca.runAction(target_node, action, CHARACTER_ACTION_TAG__KNOCKBACK)

    target_node:setPosition(pos_x, pos_y)
end

-------------------------------------
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Character:runAction_Floating()
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    target_node:setPosition(0, 0)

	local floating_x_max = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MAX_X_SCOPE')
	local floating_y_max = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MAX_Y_SCOPE')
	local floating_x_min = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MIN_X_SCOPE')
	local floating_y_min = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_MIN_Y_SCOPE')
	local floating_time = g_constant:get('MODE_DIRECTING', 'CHARACTER_FLOATING_TIME')

    local function getTime()
        return math_random(5, 15) * 0.1 * floating_time / 2
    end

    local sequence = cc.Sequence:create(
        cc.MoveTo:create(getTime(), cc.p(math_random(-floating_x_max, -floating_x_min), math_random(-floating_y_max, -floating_y_min))),
        cc.MoveTo:create(getTime(), cc.p(math_random(floating_x_min, floating_x_max), math_random(floating_y_min, floating_y_max)))
    )

    local action = cc.RepeatForever:create(sequence)
    cca.runAction(target_node, action, CHARACTER_ACTION_TAG__FLOATING)
end

-------------------------------------
-- function setStateDelegate
-- @brief 스킬들이 캐릭터의 상태를 대신 수행하는 클래스
-------------------------------------
function Character:setStateDelegate(state_delegate)
	-- 있던 것은 없애버린다.
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
    local ret = PARENT.changeState(self, state, forced)

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
    if not skill_id then return false end

    local t_skill = self:getSkillTable(skill_id)
    local cast_time = self:getCastTimeFromSkillID(skill_id)
    
    self.m_reservedSkillId = skill_id
    self.m_reservedSkillCastTime = cast_time
    
    return true
end

-------------------------------------
-- function setInvincibility
-- @brief 해당 캐릭 무적 여부 설정
-------------------------------------
function Character:setInvincibility(b)
    self.m_bInvincibility = b
end

-------------------------------------
-- function setSpasticity
-- @brief 해당 캐릭 경직 여부 설정
-------------------------------------
function Character:setSpasticity(b)
	if (not self.m_animator) then return end
    
    if (b and self.m_bEnableSpasticity) then
        
        self.m_animator:setTimeScale(0)

        self.m_isSpasticity = true
        self.m_delaySpasticity = SpasticityTime
    else
        if (not self.m_temporaryPause) then
            self.m_animator:setTimeScale(1)
        end

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
		self:setMoveHomePos(speed)
	end

    -- 경직 가능 상태 설정
    self.m_bEnableSpasticity = true
end

-------------------------------------
-- function getStat
-- @brief 최종 계산된 스탯을 가져온다
-------------------------------------
function Character:getStat(stat_type)
	-- @TODO
	if (self.m_charType == 'tamer') then
		return 0
	end
	return self.m_statusCalc:getFinalStat(stat_type)
end

-------------------------------------
-- function getHp
-- @brief 현재 HP 정보를 가져온다
-------------------------------------
function Character:getHp()
    return self.m_hp
end

-------------------------------------
-- function getBuffStat
-- @brief 현재 적용된 버프수치를 가져온다
-------------------------------------
function Character:getBuffStat(stat_type)
	-- @TODO
	if (self.m_charType == 'tamer') then
		return 0
	end
	return self.m_statusCalc:getAdjustRate(stat_type)
end

-------------------------------------
-- function setSilence
-------------------------------------
function Character:setSilence(b)
	self.m_isSilence = b
end

-------------------------------------
-- function setImmuneSE
-------------------------------------
function Character:setImmuneSE(b)
	self.m_isImmuneSE = b
end

-------------------------------------
-- function isImmuneSE
-------------------------------------
function Character:isImmuneSE()
	if (self.m_isImmuneSE) then
        return true
    end

    if (self:getStat('debuff_time') <= -100) then
        return true
    end

    return false
end

-------------------------------------
-- function setImmortal
-------------------------------------
function Character:setImmortal(b)
	self.m_isImmortal = b
end

-------------------------------------
-- function setZombie
-------------------------------------
function Character:setZombie(b)
	self.m_isZombie = b
end

-------------------------------------
-- function addGroggy
-------------------------------------
function Character:addGroggy(statusEffectName)
    PARENT.addGroggy(self, statusEffectName)
    
    if (self.m_state ~= 'stun') then
        self:changeState('stun')
    end
end

-------------------------------------
-- function removeGroggy
-------------------------------------
function Character:removeGroggy(statusEffectName)
    PARENT.removeGroggy(self, statusEffectName)
    
    if (not self:hasGroggyStatusEffect()) then
        if (self.m_state == 'stun') then
            self:changeState('stun_esc')
        end
    end
end

-------------------------------------
-- function setGuard
-------------------------------------
function Character:setGuard(skill)
	self.m_guard = skill
end

-------------------------------------
-- function getGuardSkill
-------------------------------------
function Character:getGuard()
	return self.m_guard
end

-------------------------------------
-- function isCasting
-------------------------------------
function Character:isCasting()
    return (self.m_state == 'casting')
end

-------------------------------------
-- function isDragon
-------------------------------------
function Character:isDragon()
    return (self.m_charType == 'dragon')
end

-------------------------------------
-- function isBoss
-- @brief boss, sub_boss, elite 체크
-------------------------------------
function Character:isBoss()
	local rarity = self.m_charTable['rarity']
    return isExistValue(rarity, 'elite', 'subboss', 'boss') 
end

-------------------------------------
-- function isDead
-------------------------------------
function Character:isDead()
    return (self.m_bDead or self.m_state == 'dying')
end

-------------------------------------
-- function getAttackPhysGroup
-- @brief 해당 캐릭터가 쏠 미사일의 PhysGruop 가져온다.
-------------------------------------
function Character:getAttackPhysGroup()
    if (self.phys_key == PHYS.HERO) then
        return PHYS.MISSILE.HERO
    else
        return PHYS.MISSILE.ENEMY
    end
end

-------------------------------------
-- function getRootNode
-------------------------------------
function Character:getRootNode()
	if (self.m_isSlaveCharacter) then 
		return self.m_masterCharacter.m_rootNode
	else
		return self.m_rootNode
	end
end

-------------------------------------
-- function getFellowList
-- @brief 어떤 진형이든 항상 아군을 가져온다.
-------------------------------------
function Character:getFellowList()
	if (self.m_bLeftFormation) then 
		return self.m_world:getDragonList()
	else
		return self.m_world:getEnemyList()
	end
end

-------------------------------------
-- function getOpponentList
-- @brief 어떤 진형이든 항상 적군을 가져온다.
-------------------------------------
function Character:getOpponentList()
	if (self.m_bLeftFormation) then 
		return self.m_world:getEnemyList()
	else
		return self.m_world:getDragonList()
	end
end

-------------------------------------
-- function referenceForSlaveCharacter
-------------------------------------
function Character:referenceForSlaveCharacter(t_body, adj_x, adj_y)
	local char = Character(nil, t_body)

	char.m_hp = self.m_hp
	char.m_maxHp = self.m_maxHp
	
	char.m_infoUI = nil
	char.m_hpNode = nil
	char.m_castingUI = nil
	char.m_castingNode = nil
	char.m_unitInfoOffset = {0, 0}
	char.m_charTable = {attr = self:getAttribute(), rarity = self.m_charTable['rarity']}
	
	char.m_bLeftFormation = self.m_bLeftFormation
	char.m_cbChangePos = self.m_cbChangePos
	char.m_world = self.m_world

	char.m_isSlaveCharacter = true
	char.m_masterCharacter = self
	char.m_unitInfoOffset = {adj_x, adj_y}

    char:addState('dying', Character.st_dying, 'idle', false, PRIORITY.DYING)
    char:addState('dead', Character.st_dead, nil, nil, PRIORITY.DEAD)

	return char
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function Character:setTemporaryPause(pause)
    if (PARENT.setTemporaryPause(self, pause)) then
        -- 액션 정지
        local target_node = self.m_animator.m_node

        if (pause) then
            -- 위치 좌표값 동기화
            self:syncAniAndPhys()

            cca.stopAction(target_node, CHARACTER_ACTION_TAG__FLOATING)

            if (self.m_bRoam) then
                self:stopRoaming()
            end
        else
            self:runAction_Floating()
        end

        return true
    end

    return false
end

-------------------------------------
-- function stopRoaming
-------------------------------------
function Character:stopRoaming()
    cca.stopAction(self.m_rootNode, CHARACTER_ACTION_TAG__ROAM)
    self.m_roamTimer = 1
end

-------------------------------------
-- function printAllInfomation
-- @DEBUG
-------------------------------------
function Character:printAllInfomation()
    local str = self:getAllInfomationString()
    cclog(str)
end

-------------------------------------
-- function getAllInfomationString
-- @DEBUG
-------------------------------------
function Character:getAllInfomationString()
    local str = '\n'

    local printLine = function(_str)
        str = str .. _str .. '\n'
    end

    printLine('-------------------------------------------------------')
	printLine('NAME : ' .. self.m_charTable['t_name'])
    printLine('CURR_STATE = ' .. self.m_state)
    printLine('## STATUS EFFECT LIST ##')
    for type, se in pairs(self:getStatusEffectList()) do
		printLine(string.format('- %s : overlap:%d time:%d', type, se.m_overlabCnt, se:getLatestTimer()))
	end
    printLine('## HIDDEN STATUS EFFECT LIST ##')
    for type, se in pairs(self:getHiddenStatusEffectList()) do
		printLine(string.format('- %s : overlap:%d time:%d', type, se.m_overlabCnt, se:getLatestTimer()))
	end
	printLine('## STAT LIST ##')
	printLine(self.m_statusCalc:getAllStatString())

	printLine('=======================================================')

    return str
end

-------------------------------------
-- function getDragonSpeechNode
-------------------------------------
function Character:getDragonSpeechNode()
    if (not self.m_dragonSpeechNode) then
        self.m_dragonSpeechNode = cc.Node:create()
        self.m_world.m_dragonSpeechNode:addChild(self.m_dragonSpeechNode)
        self.m_dragonSpeechNode:setPosition(self.pos.x, self.pos.y)

        self:addHighlightNode(self.m_dragonSpeechNode)
    end

    return self.m_dragonSpeechNode
end

-------------------------------------
-- function getEnemySpeechNode
-------------------------------------
function Character:getEnemySpeechNode()
    if (not self.m_enemySpeechNode) then
        self.m_enemySpeechNode = cc.Node:create()
        self.m_world.m_enemySpeechNode:addChild(self.m_enemySpeechNode)
        self.m_enemySpeechNode:setPosition(self.pos.x, self.pos.y)

        self:addHighlightNode(self.m_enemySpeechNode)
    end

    return self.m_enemySpeechNode
end