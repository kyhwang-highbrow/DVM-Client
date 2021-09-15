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
        m_charTable ='table',

		-- 캐릭터 기초 스탯
        m_lv = '',
        m_maxHp = '',
        m_hp = '',
        m_hpRatio = '',
        m_aspdRatio = '',
		m_attribute = '',
		m_attributeOrg = '',
        m_originScale = 'num',  -- 생성 시 스케일

		-- 기초 유틸
        m_statusCalc = '',
        m_stateDelegate = 'CharacterStateDelegate',
        m_charLogRecorder = 'LogRecorderChar',

		-- 캐릭터의 특정 상태
        m_bActive = 'boolean',
        m_bDead = 'boolean',
        m_bInvincibility = 'boolean',   -- 무적 상태 여부
        m_bMetamorphosis = 'boolean',   -- 변신 상태 여부
		        
        -- @ for FormationMgr
        m_bLeftFormation = 'boolean',   -- 왼쪽 진형일 경우 true, 오른쪽 진형일 경우 false

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

        -- 현재 프레임에서 사용된 스킬(이벤트들이 중첩되면서 연속으로 사용되는 스킬을 방지하기 위함. 매프레임마다 초기화시킴)
        m_mUsedSkillIdInFrame = 'map',

        -- @ 예약된 skill 정보
        m_reservedSkillId = 'number',
        m_reservedSkillCastTime = 'number',

        -- @ 예약된 activity carrier 정보
        m_reservedActivityCarrier = 'ActivityCarrier',  -- 예약된 skill 정보와는 별개로 사용
                
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
        m_lockOnNode = 'cc.Node',       -- 인디케이터 선택 대상 표시를 위한 노드
        m_enemySpeechNode = 'cc.Node',  -- 캐스팅 연출을 위한 노드로 사용됨

        m_passiveWindowNode = 'cc.Node',-- 겹쳐서 생성되는 걸 막기 위해 사용
        m_passiveTextLabel = 'cc.Node',

        -- @hp UI
		m_infoUI = '',
        m_hpNode = '',
        m_hpGauge = '',
        m_hpGauge2 = '',
        m_unitInfoOffset = 'UI_IngameDragonInfo/UI_IngameUnitInfo',
        m_bFixedPosHpNode = 'boolean',

        -- @status UI
        m_unitStatusIconNode = 'cc.Node',

        -- @charge
        m_chargeEffect = '',

        -- @casting UI
        m_castingNode = '',
        m_castingGauge = '',
        m_castingEffect = '',
        m_castingUI = '',
        m_castingMarkGauge = '',
        m_castingSpeechVisual = '',
        m_bUseCastingEffect = 'boolean',

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

		-- @TODO 수호 스킬 관련 .. 없애고 싶은데....
		m_guard = 'SkillGuard',	-- guard 되고 있는 상태(damage hijack)

        -- 부활 스킬 관련
        m_resurrect = 'SkillResurrect',     -- resurrect 되고 있는 상태

		-- @TODO 임시
        m_aiParam = '',
        m_aiParamNum = '',
        m_sortValue = '',				-- 타겟 찾기 등의 정렬에서 임의로 사용
        m_sortRandomIdx = '',			-- 타겟 찾기 등의 정렬에서 임의로 사용
        m_prevHp = 'number',            -- setHp() 내부에서 갱신전 hp를 임시 저장하기 위해 사용(체력 %이하 무적 효과 처리를 위함)

        -- 로밍 임시 처리
        m_bRoam = 'boolean',
        m_roamTimer = 'number',

		-- 몬스터가 아이템을 드랍하는지 여부
        m_hasItem = 'boolean',

        -- 보스인지 여부
        m_isBoss = 'boolean',

        -- 부활 가능한지 여부
        m_bPossibleRevive = 'boolean',

        -- ICharacterBinding 사용 여부
        m_bUseBinding = 'boolean',

        -- 리액션이 필요할 때 설정되는 정보
        m_reactingInfo  = 'table',

        m_characterSpeechNode = '',
        m_characterSpeech = '',
        m_characterSpeechLabel = '',
     })

local SpasticityTime = 0.2

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Character:init(file_name, body, ...)
    self.m_hpRatio = 1
    self.m_aspdRatio = 1

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
    self.m_bUseCastingEffect = true
	self.m_isUseAfterImage = false

	self.m_guard = false
    self.m_resurrect = false

    self.m_posIdx = 0
    self.m_orgHomePosX = 0
    self.m_orgHomePosY = 0
    self.m_homePosX = 0
    self.m_homePosY = 0
    self.m_attackOffsetX = 0
    self.m_attackOffsetY = 0

    self.m_movement = nil

    self.m_bRoam = false
    self.m_roamTimer = 0
    self.m_hasItem = false
    self.m_isBoss = false

    self.m_bPossibleRevive = false
    self.m_bUseBinding = false

    self.m_mUsedSkillIdInFrame = {}

    self.m_mTargetEffect = {}
    self.m_mNonTargetEffect = {}

    self.m_unitInfoOffset = { 0, 0 }

    self.m_originScale = 0.8

    self.m_reactingInfo = {}
end

-------------------------------------
-- function initWorld
-- @param game_world
-------------------------------------
function Character:initWorld(game_world)
    PARENT.initWorld(self, game_world)

    -- 월드 상의 레이어별 배치노드를 사용하기 위한 유닛별 노드 생성
    if (not self.m_unitStatusIconNode) then
        self.m_unitStatusIconNode = cc.Node:create()
        self.m_world.m_unitStatusNode:addChild(self.m_unitStatusIconNode, 1)
        
        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_unitStatusIconNode)
    end

    if (not self.m_unitInfoNode) then
        self.m_unitInfoNode = cc.Node:create()
        self.m_world.m_unitInfoNode:addChild(self.m_unitInfoNode)
        
        -- 하이라이트 노드 설정
        self:addHighlightNode(self.m_unitInfoNode)
    end

    if (not self.m_lockOnNode) then
        self.m_lockOnNode = cc.Node:create()
        self.m_world.m_lockOnNode:addChild(self.m_lockOnNode)
    end

    self:initSpeechUI()
end

-------------------------------------
-- function undergoMetamorphosis
-- @brief 애니메이션과 스킬셋을 변경
-------------------------------------
function Character:undergoMetamorphosis(b)
    if (self.m_bMetamorphosis == b) then return end

    -- 애니메이션 변경
    if (self.m_animator) then
        if (b) then
            self.m_animator:setAniAddName('_d')
        else
            self.m_animator:setAniAddName()
        end
    end

    -- 스킬 변경
    self:changeSkillSetByMetamorphosis(b)

    self:dispatch('character_metamorphosis', { metamorphosis = b }, self)
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
-- function getTargetListByTable
-- @brief skill table을 인자로 받는 경우..
-------------------------------------
function Character:getTargetListByTable(t_skill, t_data)
	local target_type = t_skill['target_type']
	local target_count = t_skill['target_count']
    local target_formation = t_skill['target_formation']
    local is_active_skill = t_skill['chance_type'] == 'active'
    
    if (target_type == '') then 
        local sid = tostring(t_skill['sid'])
        local name = tostring(t_skill['t_name'])
		error('타겟 타입이 없네요..ㅠ 테이블 수정해주세요 ' .. sid .. ' ' .. name)
	end

    return self:getTargetListByType(target_type, target_count, target_formation, t_data, is_active_skill)
end

-------------------------------------
-- function getTargetListByType
-- @param target_formation은 없어도 된다
-------------------------------------
function Character:getTargetListByType(target_type, target_count, target_formation, t_data, is_active_skill)
    local t_data = t_data or {}

	if (isNullOrEmpty(target_type) == true) then 
		error('타겟 타입이 없네요..ㅠ 테이블 수정해주세요')
	end
    
	local target_formation = target_formation or nil

    --> target_team = 'enemy'
    local target_team

    --> target_rule = 'low_hp'
    local target_rule

    --> target_count = 3
    local target_count = target_count

    -- self 시작이면 target_type 그대로 전달
    if (pl.stringx.startswith(target_type, 'self')) then
        target_team = target_type
        target_rule = ''
    else
	    target_team = string.gsub(target_type, '_.+', '')		
        target_rule = string.gsub(target_type, '%l+_', '', 1)
    end
    
	local t_ret = self.m_world:getTargetList(self, self.pos.x, self.pos.y, target_team, target_formation, target_rule, t_data, is_active_skill)

    -- 고대 유적 던전의 경우 아군의 일반 공격은 보스를 우선으로 공격하도록 처리
    if (self.m_world.m_gameMode == GAME_MODE_ANCIENT_RUIN and self.m_bLeftFormation) then
        if (t_data['skill_type'] and t_data['skill_type'] == 'basic') then
            for i, v in ipairs(t_ret) do
                v.m_sortValue = i
            end

            table.sort(t_ret, function(a, b)
                if (a:isBoss() and not b:isBoss()) then
                    return true
                elseif (not a:isBoss() and b:isBoss()) then
                    return false
                else
                    return (a.m_sortValue < b.m_sortValue)
                end
            end)
        end
    end
    	
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
    if (not t_skill) then return false end

	if (t_data and t_data['target']) then
		-- 인디케이터에서 받아온 정보가 있다면
		self.m_targetChar = t_data['target']
	else
		-- 없다면 탐색
		local t_ret = self:getTargetListByTable(t_skill, nil)
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
            statusCalc = MakeOwnDragonStatusCalculator(doid, nil, self.m_world.m_gameMode)
        else
            statusCalc = MakeDragonStatusCalculator(self.m_charTable['did'], level, grade, evolution, eclv)
        end
    elseif (self.m_charType == 'monster') then
        statusCalc = StatusCalculator(self.m_charType, self.m_charTable['mid'], level, grade, evolution, eclv)

    elseif (self.m_charType == 'summon_object') then
        statusCalc = StatusCalculator(self.m_charType, self.m_charTable['sobj_id'], level, grade, evolution, eclv)

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
    local hp_multi = self.m_statusCalc:getHiddenInfo('hp_multi') or 1

    self.m_maxHp = hp * hp_multi
    self.m_hp = self.m_maxHp
    self.m_hpRatio = 1
    self.m_prevHp = self.m_hp

    -- 공속 설정
    self:calcAttackPeriod(true)
end

-------------------------------------
-- function initLogRecorder
-------------------------------------
function Character:initLogRecorder(unique_id)
    if (unique_id) then
		self.m_charLogRecorder = LogRecorderChar(unique_id)
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

    local atk_attr_weak_adj_rate = attacker_char:getStat('attr_weak_adj_rate')
    local def_attr_weak_adj_rate = self:getStat('attr_weak_adj_rate')

    -- 방어자 속성
    local defender_attr = self:getAttribute()

    local t_attr_effect, attr_synastry = getAttrSynastryEffect(attacker_attr, defender_attr, atk_attr_adj_rate, def_attr_adj_rate, atk_attr_weak_adj_rate, def_attr_weak_adj_rate)

    return t_attr_effect, attr_synastry
end

-------------------------------------
-- function checkBash
-- @brief 강타 여부 검사
-------------------------------------
function Character:checkBash(attacker_char, rate)
    local rate = rate or 0
    
    if (math_random(1, 100) <= rate) then
        return true
	end

    return false
end

-------------------------------------
-- function checkMiss
-- @brief 빚맞힘 여부 검사
-------------------------------------
function Character:checkMiss(attacker_char, rate)
    local rate = rate or 0

    if (math_random(1, 100) <= rate) then
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

    -- 체력이 0일 경우 회피 할 수 없도록 처리
    if (self:isZeroHp()) then
        return false
    end

	-- 속성 상성 옵션 적용
	do 
		local hit_rates_multifly = 1

		-- 적중률
		if (t_attr_effect['hit_rate']) then
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
-- function checkGuard
-- @brief 피해 이전 여부 검사
-------------------------------------
function Character:checkGuard(attacker, defender)
    if (self.m_guard) then
        -- 수호 스킬 효과

		-- Event Carrier 세팅
		local t_event = clone(EVENT_HIT_CARRIER)
		t_event['attacker'] = attacker
        t_event['defender'] = defender
		-- @EVENT
		self:dispatch('guardian', t_event)
		return true
    else
        -- 룬 세트 효과(결의) : 자신보다 후방에 위치한 아군이 받는 피해를 스텟값(%)의 확률로 대신 받음
        local guard_list = {}
        local rate = 0
        local b = false
        local pos_x, pos_y = self:getPosForFormation()
        local v_x, v_y
        
        for _, v in pairs(self:getFellowList()) do
            rate = v:getStat('guard_rear')

            if (v ~= self and rate > 0) then
                b = false
                v_x, v_y = v:getPosForFormation()

                if (self.m_bLeftFormation and v_x > pos_x) then
                    b = true
                elseif (not self.m_bLeftFormation and v_x < pos_x) then
                    b = true
                end

                if (b and math_random(1, 100) <= rate) then
                    table.insert(guard_list, v)
                end
            end
        end

        if (#guard_list > 0) then
            guard_list = randomShuffle(guard_list)

            local guarder = guard_list[1]
            guarder:undergoAttack(attacker, guarder, guarder.pos.x, guarder.pos.y, 0, false, true)

            -- 이펙트
            MakeEffectGuard(self.m_world, self, guarder)
            
		    return true
        end
    end

    return false
end

-------------------------------------
-- function undergoAttack
-------------------------------------
function Character:undergoAttack(attacker, defender, i_x, i_y, body_key, no_event, is_guard)
    if (not self.m_world.m_gameState:isFight()) then return end
    if (not attacker.m_activityCarrier) then return end

    --------------------------------------------------------------------------
    -- variable
    --------------------------------------------------------------------------
    local use_debug_log = g_constant:get('DEBUG', 'PRINT_ATTACK_INFO')

	-- 공격자 정보
	local attack_activity_carrier = attacker.m_activityCarrier
    local attacker_char = attack_activity_carrier:getActivityOwner()
    local attack_type, real_attack_type = attack_activity_carrier:getAttackType()
    local is_active_skill = attack_type == 'active'
    local isAttackable = self:isAttackable(is_active_skill, attack_activity_carrier)

    -- 우선 공격 가능한지 체크한다
    if (not isAttackable or isAttackable == false) then return end

    local attack_add_cri_dmg = attack_activity_carrier:getAddCriPowerRate()
    local attack_hit_count = attack_activity_carrier:getSkillHitCount()
    local is_critical = nil
    local is_indicator_critical = attack_activity_carrier:getCritical()
    local is_cri_avoid = false

    -- 속성 효과
    local t_attr_effect, attr_synastry = self:checkAttributeCounter(attacker_char)
    local is_bash = (attr_synastry == 1) and self:checkBash(attacker_char, t_attr_effect['bash'])
    local is_miss = (attr_synastry == -1) and self:checkMiss(attacker_char, t_attr_effect['miss'])

    -- 모두 무시하는 경우나 공격자가 테이머인 경우 속성 효과를 적용하지 않음
    if (attack_activity_carrier:isIgnoreCalc() or attacker_char:getCharType() == 'tamer') then
        t_attr_effect = {}
        is_bash = false
        is_miss = false
    end
    
    -- 공격력 및 방어력 정보
    local org_atk_dmg = attack_activity_carrier:getAtkDmg(defender)
    local org_def_pwr = self:getStat('def')
    local damage = 0

    -- 반사 정보
    local reflex_damage = 0
    local reflex_rate = 0

    --------------------------------------------------------------------------
    -- variable end
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    -- ignore
    --------------------------------------------------------------------------

    -- 무적 상태 체크
    if (attack_activity_carrier:isIgnoreProtect()) then
        -- 무적 무시
    elseif (self.m_isProtected) then
        self:makeShieldFont(i_x, i_y)
        return
    end

    -- 수호(guard) 상태 체크
    if (attack_activity_carrier:isIgnoreGuardian()) then
        -- 수호 무시

    elseif (not is_guard and self:checkGuard(attacker, defender)) then
        return
    end

    -- 회피 계산
    if (attack_activity_carrier:isIgnoreAvoid()) then
        -- 회피 무시 체크

    elseif (self:checkAvoid(attack_activity_carrier, t_attr_effect)) then
        self:makeMissFont(i_x, i_y)
		-- @EVENT
		self:dispatch('avoid_rate')
        
		-- @LOG_CHAR : 방어자 회피 횟수
		self.m_charLogRecorder:recordLog('avoid', 1)
        return
    end

    --------------------------------------------------------------------------
    -- ignore end
    --------------------------------------------------------------------------

    
    --------------------------------------------------------------------------
    -- damage calc
    --------------------------------------------------------------------------

    -- 데미지 계산
    do
        --------------------------------------------------------------
		-- 공격력 계산(atk_dmg)
        --------------------------------------------------------------
		local atk_dmg = org_atk_dmg
        
        -- 스킬 계수
        local power_rate = attack_activity_carrier:getPowerRate() / 100

        -- 스킬 추가 공격력
        local power_add = attack_activity_carrier:getAbsAttack()

        -- 스킬 계수 및 추가 공격력 적용
		atk_dmg = atk_dmg * power_rate + power_add
        
        -- 스킬 타입별 추가 공격력 적용
        local basic_dmg = 0
        local drag_dmg = 0

        if (not attack_activity_carrier:isIgnoreCalc()) then
            if (real_attack_type == 'basic') then
                -- 일반 공격 추가 공격력 적용
                local basic_dmg_rate = attack_activity_carrier:getStat('basic_dmg') / 100
                basic_dmg = atk_dmg * basic_dmg_rate

                atk_dmg = atk_dmg + basic_dmg

            elseif (is_active_skill) then
                -- 드래그 스킬 추가 공격력 적용
                local drag_dmg_rate = attack_activity_carrier:getStat('drag_dmg') / 100
                drag_dmg = atk_dmg * drag_dmg_rate

                atk_dmg = atk_dmg + drag_dmg
            end
        end
        
        --------------------------------------------------------------
        -- 방어력 계산(def_pwr)
        --------------------------------------------------------------
        local def_pwr = org_def_pwr

        -- 방어 관통
        local def_pierce = 0
        if (attacker_char) then
            def_pierce = attacker_char:getStat('pierce') / 100
        end

        if (attack_activity_carrier:isIgnoreDef()) then
            -- 방어 무시
			def_pwr = 0 
        elseif (def_pierce > 0) then
            -- 방어 관통 적용
            def_pwr = def_pwr - (def_pwr * def_pierce)
        end

        def_pwr = math_max(def_pwr, 0)
		
        --------------------------------------------------------------
        -- 데미지 계산(damage)
        --------------------------------------------------------------
		local org_damage, str_debug

        if (attack_activity_carrier:isIgnoreCalc()) then
            -- 데미지 계산 무시
            org_damage = atk_dmg
        else
            org_damage, str_debug = DamageCalc_P(atk_dmg, def_pwr, use_debug_log)
        end
        damage = org_damage

        -- 게임 모드 및 진형에 따른 데미지 배율
        local damage_rate_game_mode
        local damage_rate_formation

        if (not attack_activity_carrier:isIgnoreCalc()) then
            -- 게임 모드에 따른 데미지 배율
            damage_rate_game_mode = CalcDamageRateDueToGameMode(self)

            -- 진형에 따른 데미지 배율
            damage_rate_formation = CalcDamageRateDueToFormation(self)

            -- 게임 모드에 따른 데미지 배율 적용
            damage = damage * damage_rate_game_mode

            -- 진형에 따른 데미지 배율 적용
            damage = damage * damage_rate_formation
        end

        -- @DEBUG
	    if (use_debug_log) then
            cclog('######################################################')
            if (attacker_char) then
	            cclog('공격자 : ' .. attacker_char:getName())
            end
	        cclog('방어자 : ' .. defender:getName())

            if (attack_type) then
	            if (attack_activity_carrier:getParam('add_dmg')) then
                    cclog('공격 타입 : ' .. attack_type .. '(add_dmg)')
                else
                    cclog('공격 타입 : ' .. attack_type)
                end
            end
            cclog('히트 수 : ' .. attack_hit_count)

            cclog('------------------------------------------------------')
            cclog('--공격력 : ' .. org_atk_dmg)
            cclog('--스킬 계수 : ' .. power_rate)
            cclog('--스킬 추가 공격력 : ' .. power_add)
            if (drag_dmg ~= 0) then
                cclog('--드래그 스킬 추가 공격력 : ' .. drag_dmg)
            end
            cclog('--최종 공격력 : ' .. atk_dmg)

            if (str_debug) then
                cclog(str_debug)
            end

            cclog('------------------------------------------------------')
	        cclog('--방어력 : ' .. org_def_pwr)
            if (def_pierce ~= 0) then
                cclog('--공격자 방어 관통 : ' .. def_pierce)
            end
            cclog('--최종 방어력 : ' .. def_pwr)

            cclog('------------------------------------------------------')
            cclog('--데미지 계산 결과값 : ' .. org_damage)
            if (damage_rate_game_mode and damage_rate_game_mode ~= 1) then
                cclog('--게임 모드에 따른 데미지 배율 : ' .. damage_rate_game_mode)
            end
            if (damage_rate_formation and damage_rate_formation ~= 1) then
                cclog('--진형에 따른 데미지 배율 : ' .. damage_rate_formation)
            end
            cclog('--배율 적용한 데미지 : ' .. damage)
        end
    end

    --------------------------------------------------------------------------
    -- damage calc end
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    -- critical damage calc
    --------------------------------------------------------------------------

    -- 크리티컬 계산
    if (not attack_activity_carrier:isIgnoreCalc()) then
        if (is_miss) then
            -- 빚맞힘일 경우 크리티컬 없도록 처리
            is_critical = false

        else
            local critical_chance = attack_activity_carrier:getStat('cri_chance') or 0
            local critical_avoid = self:getStat('cri_avoid')
            local final_critical_chance = CalcCriticalChance(critical_chance, critical_avoid)

            -- 속성 상성 적용
            if (t_attr_effect['cri_chance']) then
                final_critical_chance = (final_critical_chance + t_attr_effect['cri_chance'])
            end

            is_critical = (math_random(1, 1000) <= (final_critical_chance * 10))
        end

        -- 크리티컬 발생시 강타 해제
        if (is_critical) then
            is_bash = false
        end
    end

    --------------------------------------------------------------------------
    -- critical damage calc end
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    -- final damage calc
    --------------------------------------------------------------------------

    do -- 최종 데미지 계산
        local damage_multifly = 1

        if (is_active_skill) then 
            reflex_rate = math_max(self:getStat('reflex_skill'), 0) / 100
        else
            reflex_rate = math_max(self:getStat('reflex_normal'), 0) / 100
        end

        -- 크리티컬 데미지
        local cri_dmg_rate = 0
        if (is_critical) then
            local cri_dmg = attack_activity_carrier:getStat('cri_dmg') or 0
            cri_dmg_rate = cri_dmg / 100
        end

        local rate = math_max(cri_dmg_rate, -1)
        damage_multifly = damage_multifly * (1 + rate)

        -- 속성 데미지
        local attr_dmg_rate = 0
        if (t_attr_effect['damage']) then
            attr_dmg_rate = (t_attr_effect['damage'] / 100)
        end

        local rate = math_max(attr_dmg_rate, -1)
        damage_multifly = damage_multifly * (1 + rate)
        

        -- 피해량 비율
        local dmg_adj_rate = 0
        local atk_dmg_adj_rate = 0
        local cri_dmg_adj_rate = 0
        local se_dmg_adj_rate = 0
        local final_dmg_rate = 0

        -- 방어자 능력치
        do
            dmg_adj_rate = self:getStat('dmg_adj_rate') / 100

            local rate = math_max(dmg_adj_rate, -1)
            damage_multifly = damage_multifly * (1 + rate)
        end

        -- 공격자 능력치
        do
            atk_dmg_adj_rate = (attack_activity_carrier:getStat('atk_dmg_adj_rate') or 0) / 100

            local rate = math_max(atk_dmg_adj_rate, -1)
            damage_multifly = damage_multifly * (1 + rate)
        end

        -- 치명타시 피해량 증감
        if (is_critical) then
            cri_dmg_adj_rate = (attack_activity_carrier:getStat('cri_dmg_adj_rate') or 0) / 100

            local rate = math_max(cri_dmg_adj_rate, -1)
            damage_multifly = damage_multifly * (1 + rate)

            -- 치명타시 추가 피해량 증가
            if (attack_add_cri_dmg > 0) then
                local rate = attack_add_cri_dmg / 100
                
                damage_multifly = damage_multifly * (1 + rate)
            end
        end

        -- 특정 조건에 따른 피해량 증감
        do
            -- (피격/공격)시 상대가 (특정 상태효과)를 가진 적이면 피해량 증가
            for k, v in pairs(attacker_char:getStatusEffectList()) do
                if (v.m_type == 'modify_dmg' and v.m_branch == 0) then
                    if(defender:isExistStatusEffectName(v.m_targetStatusEffectName, nil, true)) then
                        se_dmg_adj_rate = se_dmg_adj_rate + v.m_totalValue
                    end
                end
            end

            for k, v in pairs(defender:getStatusEffectList()) do
                if (v.m_type == 'modify_dmg' and v.m_branch == 1) then
                    if(attacker_char:isExistStatusEffectName(v.m_targetStatusEffectName, nil, true)) then
                        se_dmg_adj_rate = se_dmg_adj_rate - v.m_totalValue
                    end
                end
            end

            local rate = math_max(se_dmg_adj_rate, -1)
            damage_multifly = damage_multifly * (1 + rate)
        end

        -- 최종 피해량 증가
        do
            final_dmg_rate = attack_activity_carrier:getStat('final_dmg_rate') or 1

            damage_multifly = damage_multifly * final_dmg_rate
        end

        -- 피해 반사에 따른 받는 피해 감소
        -- 상태효과에 따른 반사뎀 적용
        if (reflex_rate > 0) then
            damage_multifly = damage_multifly * (1 - reflex_rate)

            -- 반사 데미지 계산
            reflex_damage = damage * reflex_rate
        end

        -- 강타일 경우 피해 증가
        if (is_bash) then
            damage_multifly = damage_multifly * 1.3
        end

        -- 빚맞힘일 경우 피해 감소
        if (is_miss) then
            damage_multifly = damage_multifly * 0.7
        end
        
        -- 데미지 계산 무시일 경우
        if (attack_activity_carrier:isIgnoreCalc()) then
            damage_multifly = 1
        end

        -- 피해량 배율 적용
        damage = (damage * damage_multifly)
        
        -- nan 체크
        if (damage ~= damage) then
            damage = 0
        end

        -- 최소 데미지 1로 처리
        damage = math_max(damage, 1)

        -- 데미지 계산 무시이고 대상이 보스일 경우 최대 피해량 제한 처리...
        if (self:isBoss() and attack_activity_carrier:isIgnoreCalc() and not attack_activity_carrier:isIgnoreAll()) then
            damage = math_min(damage, 30000)
        end
        
        -- @DEBUG
	    if (use_debug_log) then
            cclog('------------------------------------------------------')
            if (not attack_activity_carrier:isIgnoreCalc()) then
                if (cri_dmg_rate ~= 0) then
                    cclog('--치명타로 인한 피해량 비율 : ' .. cri_dmg_rate)
                end
                cclog('--속성으로 인한 피해량 비율 : ' .. attr_dmg_rate)
                cclog('--방어자의 피해량 증감 비율 : ' .. dmg_adj_rate)
                cclog('--특정 상태효과로 인한 피해량 비율 : ' .. se_dmg_adj_rate)
            end
            cclog('--피해량 비율 총합 : ' .. (damage_multifly - 1))
            cclog('--최종 데미지 : ' .. damage)
            cclog('######################################################')
        end
    end

    --------------------------------------------------------------------------
    -- final damage calc end
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    -- apply Damage
    --------------------------------------------------------------------------

    -- Event Carrier 세팅
	local t_event = clone(EVENT_HIT_CARRIER)
    t_event['skill_id'] = attack_activity_carrier:getSkillId()
	t_event['damage'] = damage
	t_event['attacker'] = attacker_char
	t_event['defender'] = self
	t_event['is_critical'] = is_critical
    t_event['i_x'] = i_x
    t_event['i_y'] = i_y
    t_event['left_formation'] = self.m_bLeftFormation
    t_event['body_key'] = body_key
	
	-- 방어와 관련된 이벤트 처리후 데미지 계산
	if (not attack_activity_carrier:isIgnoreBarrier()) then
		-- @EVENT 방어 이벤트
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
	
    -- 효과음
    local str_sound_name = is_critical and 'efx_damage_critical' or 'efx_damage_normal'
    SoundMgr:playEffect('EFX', str_sound_name)
    
	-- 공격 데미지 전달
	do
		local t_info = {}
        t_info['skill_id'] = attack_activity_carrier:getSkillId()
		t_info['attack_type'] = attack_type
		t_info['attr'] = attack_activity_carrier.m_attribute
		t_info['is_critical'] = is_critical
        t_info['is_indicator_critical'] = is_indicator_critical

		t_info['is_add_dmg'] = attack_activity_carrier:getParam('add_dmg')
        t_info['is_definite_death'] = attack_activity_carrier:isDefiniteDeath()

        t_info['is_bash'] = is_bash
        t_info['is_miss'] = is_miss
		t_info['body_key'] = body_key
	
		self:setDamage(attacker, defender, i_x, i_y, damage, t_info)
	end

    if (not no_event and attacker_char) then
        -- isAttackable 은 액티브, 평타, 무적 status_effect 로 제어된다. 
        -- 반사뎀지 면역이면 데미지 0으로 설정
        local is_reflectable = attacker_char:isAttackable(false)
        reflex_damage = is_reflectable and reflex_damage or 0

        -- 만약에 보스에 반 데미지 받을 수 있다면?
        local is_boss = attacker_char:isBoss()
        if (is_boss and is_reflectable) then
            -- 반사 상태효과를 받고 있는 드래곤의 최대 체력의 20%를 넘을 수 없다.
            local max_damage = self.m_maxHp * 0.2

            -- 데미지 상한천 초과하면 상한선 값으로 데미지 고정
            reflex_damage = math.min(reflex_damage, max_damage)
        end

        -- 공격자 반사 데미지 처리
        if (reflex_damage > 0) then
            -- 진형에 따른 데미지 배율 적용
            reflex_damage = reflex_damage * CalcDamageRateDueToFormation(attacker_char)

            -- 최소 데미지 1로 처리
            reflex_damage = math_max(reflex_damage, 1)
                
            attacker_char:setDamage(nil, attacker_char, attacker_char.pos.x, attacker_char.pos.y, reflex_damage)

            -- @LOG_CHAR : 공격자 데미지
            self.m_charLogRecorder:recordLog('damage', reflex_damage)
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

    --------------------------------------------------------------------------
    -- apply Damage end
    --------------------------------------------------------------------------


    --------------------------------------------------------------------------
    -- after damage event
    --------------------------------------------------------------------------

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

            for _, v in pairs(self:getFellowList()) do
                v:dispatch('ally_under_atk_cri', t_event)
                if (v ~= self) then
                    v:dispatch('teammate_under_atk_cri', t_event)
                end
            end
		end

		-- 일반 피격
		if (attack_type == 'basic') then 
			attacker_char:dispatch('under_atk_basic', t_event, self, attack_activity_carrier)

		-- 액티브 피격
		elseif (is_active_skill) then
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

            attacker_char:dispatch('hit_cri', t_event)

            if (real_attack_type == 'basic') then
			    attacker_char:dispatch('basic_cri', t_event)
            elseif (is_active_skill) then
                attacker_char:dispatch('skill_cri', t_event)
            end
		end
			
		-- 적 처치시
        if (not no_event) then
            local b = false

            if (is_active_skill) then
                b = self:isZeroHp()
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
                attacker_char:dispatch('hit_basic', t_event, self, attack_activity_carrier)
			    attacker_char:dispatch('enemy_last_attack', t_event, self, attack_activity_carrier) -- 삭제 예정
                self.m_world.m_logRecorder:recordLog('basic_attack_cnt', 1)

		    -- 액티브 공격시
		    elseif (is_active_skill) then
			    attacker_char:dispatch('hit_active', t_event, self, attack_activity_carrier)
		    end
        end
    end

    if (not no_event) then
        if (real_attack_type == 'active') then 
            self:runAction_Shake()
        end
    end

    --------------------------------------------------------------------------
    -- after damage event end
    --------------------------------------------------------------------------

end

-------------------------------------
-- function setDamage
-------------------------------------
function Character:setDamage(attacker, defender, i_x, i_y, damage, t_info)
    if (self.m_bDead) then return false end
    
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
    local bApplyDamage = false

    if (g_benchmarkMgr and g_benchmarkMgr:isActive()) then
        -- NOTHING TO DO

    elseif (t_info['is_definite_death']) then
        damage = self.m_hp
        bApplyDamage = true
	elseif (self.m_bLeftFormation and g_constant:get('DEBUG', 'PLAYER_INVINCIBLE')) then
		-- NOTHING TO DO
	elseif (not self.m_bLeftFormation and g_constant:get('DEBUG', 'ENEMY_INVINCIBLE')) then
		-- NOTHING TO DO
	elseif (self.m_bInvincibility) then
        -- NOTHING TO DO
    else
        bApplyDamage = true
    end

    if (bApplyDamage) then
        local prev_hp = self.m_hp
		        
		self:setHp(self.m_hp - damage, t_info['is_definite_death'])

        -- 체력을 0으로 만들었을 시
        if (prev_hp > 0 and self:isZeroHp()) then
            local damage = math_min(damage, self.m_hp)
            local attack_type = t_info['attack_type']

            -- 좀비 스킬 발동 이벤트
            self:dispatch('zombie')

            -- 공격이 부활 불가 효과가 있는 경우
            if (attacker) then
                if (attacker.m_activityCarrier:isIgnoreRevive()) then
                    self.m_bPossibleRevive = false

                    if (PLAYER_VERSUS_MODE[self.m_world.m_gameMode] == 'pvp' and self:isDragon()) then
                        -- 부활 불가 설명 표시
                        local str_map = {}
                        str_map[Str('부활 불가')] = 'bad'

                        self.m_world:makePassiveStartEffect(self, str_map)
                    end
                end
            end

            -- @LOG : 보스 막타 타입
		    if (self:isBoss()) then
			    self.m_world.m_logRecorder:recordLog('finish_atk', attack_type)
		    end

            -- @LOG : 드래그 스킬로 적 처치
            if (attack_type == 'active') then
                self.m_world.m_logRecorder:recordLog('active_kill_cnt', 1)
            end
        end
	end

    -- @LOG_CHAR : 공격자 데미지
    if (attacker) then
		attacker.m_activityCarrier:getActivityOwner().m_charLogRecorder:recordLog('damage', damage)
    end
	-- @LOG_CHAR : 방어지 피해량
	self.m_charLogRecorder:recordLog('be_damaged', damage)

    -- @LOG : 유저 드래곤이 총 받은 피해
    if (self.m_bLeftFormation) then
        self.m_world.m_logRecorder:recordLog('total_damage_to_hero', damage)

    -- @LOG : 적군이 총 받은 피해
    else
        --self.m_world.m_logRecorder:recordLog('total_damage_to_enemy', damage)

    end

    -----------------------------------------------------------------
    -- 죽음 체크
    -----------------------------------------------------------------
    local checkDie = function()
        -- 죽음이 확정된 경우
        if (t_info['is_definite_death']) then return true end

        return (not self:isDead() and self:isZeroHp() and not self.m_isZombie)
    end

    if (checkDie()) then
        -- 죽기 직전 이벤트(딱 한번만 호출됨)
        self:dispatch('dead_ago', {}, self)
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

    return bApplyDamage
end

-------------------------------------
-- function getSkillTable
-------------------------------------
function Character:getSkillTable(skill_id)
    if (not skill_id) or (skill_id == '') or (skill_id == 0) then
        return nil
    end

    local t_skill

    local skill_indivisual_info = self:findSkillInfoByID(skill_id)
    if (skill_indivisual_info) then
	    t_skill = skill_indivisual_info:getSkillTable()

        --[[
        if (not t_skill and self.m_charType == 'monster') then
            t_skill = TableMonsterSkill():get(skill_id)
            --error('skill_id = ' .. skill_id)
        end]]
    end

    -- 그래도 없으면?
    if (not t_skill) then
        if (self.m_charType == 'monster' and TableMonsterSkill():exists(skill_id)) then
            t_skill = TableMonsterSkill():get(skill_id)
        elseif (self.m_charType == 'dragon' and TableDragonSkill():exists(skill_id)) then
            t_skill = TableDragonSkill():get(skill_id)
        end
    end

    return t_skill
end

-------------------------------------
-- function doAttack
-------------------------------------
function Character:doAttack(skill_id, x, y)
    local t_skill = self:getSkillTable(skill_id)
    local b_run_skill = self:doSkill(skill_id, x, y)

    -- 지정된 스킬이 발동되지 않았을 경우 또는 basic_turn, rate 인 경우 기본 스킬 발동
    if self.m_isAddSkill or (not b_run_skill) then
        local basic_skill_id = self:getSkillID('basic')
        if (basic_skill_id and basic_skill_id ~= 0) then
            self:doSkill(basic_skill_id, x, y)
        end
    end

	self:dispatch('char_do_atk')
		
	-- 기본 공격 + 드래곤 일때 사운드 재생
	if (t_skill['chance_type'] == 'basic') and (self.m_charType == 'dragon') then
		SoundMgr:playEffect('EFX', 'efx_attack')
	end
    
    -- 예약된 스킬 정보 초기화
    self.m_reservedSkillId = nil
    self.m_reservedSkillCastTime = 0
end

-------------------------------------
-- function doDie
-- @brief 죽임(좀비나 자폭 등의 죽기전 발동되는 스킬을 발동시킴)
-------------------------------------
function Character:doDie()
    self:setDamage(nil, self, self.pos.x, self.pos.y, self.m_hp, { is_definite_death = true })
end

-------------------------------------
-- function doRevive
-- @brief 부할
-------------------------------------
function Character:doRevive(heal, caster, is_abs)
    if (not self.m_bDead or not self.m_bPossibleRevive) then return false end
    self.m_bDead = false
    self.m_resurrect = false

    -- 유닛 리스트에 재등록
    if (self.m_bLeftFormation) then
        self.m_world:addHero(self)
    else
        self.m_world:addEnemy(self)
    end

    -- 체력 회복
    if (is_abs) then
        self:healAbs(caster, heal, true, true)
    else
        self:healPercent(caster, heal, true, true)
    end

    -- 이미지 표시
    if (self.m_animator and self.m_animator.m_node) then
        self.m_animator.m_node:stopActionByTag(CHARACTER_ACTION_TAG__DYING)
        self.m_animator:setRotation(90)
        self.m_animator:runAction(cc.FadeTo:create(0.5, 255))
    end
    self.m_hpNode:setVisible(true)

    -- 홈 위치로 즉시 이동시킴
    self:setPosition(self.m_homePosX, self.m_homePosY)

    -- 공격 상태로 전환
    self:changeState('attackDelay', true)

    self:dispatch('character_revive', {}, self)

    return true
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
  
    self.m_world:addChild2(effect.m_node, DEPTH_DAMAGE_EFFECT)
end

-------------------------------------
-- function makeDamageFont
-------------------------------------
function Character:makeDamageFont(damage, x, y, tParam)
    

    local y = y + 60
    local x_offset = 0
    local tParam = tParam or {}
    local r, g, b = nil, nil, nil

    local is_critical = tParam['is_critical'] or false
    local is_indicator_critical = tParam['is_indicator_critical'] or false
    local is_add_dmg = tParam['is_add_dmg'] or false
    local is_bash = tParam['is_bash'] or false
    local is_miss = tParam['is_miss'] or false

    -- 소수점 제거
    local damage = math_floor(damage)

	-- 0 데미지는 출력하지 않는다.
    if (damage <= 0) then
        return
    end
    
    -- 색상 설정
    if (is_add_dmg) then
		    r, g, b = 225, 229, 0 -- 노랑

        elseif (is_critical) then
            -- 치명타
            r, g, b = 233, 84, 255
        
        elseif (is_miss) then
            -- 빚맞힘
            r, g, b = 198, 198, 198	-- 회색
	    
	    elseif (is_bash) then
            -- 강타
            r, g, b = 235, 71, 42	-- 빨강
        else
            r, g, b = 255, 255, 255
        end

    local node = cc.Node:create()
    node:setPosition(x, y)
    node:setCascadeOpacityEnabled(true)

    -- 애니메이션 적용
    if (is_critical) then
        node:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 3.5), cc.ScaleTo:create(0.3, 1), cc.DelayTime:create(0.4), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
    else
        node:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
        node:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
    end

    self.m_world:addChild3(node, DEPTH_DAMAGE_FONT)

    node:addChild(self:makeDamageNumber(damage, r, g, b))

    -- 숫자 위에 뜰 문자열 (치명타, 강타, 빚맟힘, 치명회피)
    local option_sprite = nil
    if (is_critical) then
        option_sprite = self:createWithSpriteFrameName('ingame_damage_critical.png')
    elseif (is_bash) then
        option_sprite = self:createWithSpriteFrameName('ingame_damage_bash.png')
    elseif (is_miss) then
        option_sprite = self:createWithSpriteFrameName('ingame_damage_miss.png')
    end

    if (option_sprite) then
        option_sprite:setAnchorPoint(cc.p(0.5, 0.5))
        option_sprite:setDockPoint(cc.p(0.5, 0.5))
        option_sprite:setPosition(0, 27.5)
        node:addChild(option_sprite)
    end

end

-------------------------------------
-- function makeHealFont
-------------------------------------
function Character:makeHealFont(heal, is_critical)
    local heal = math_floor(heal)
    if (heal <= 0) then return end

    local x = self.pos.x + math_random(-25, 25)
    local y = self.pos.y + math_random(-25, 25)
    local scale = 1

    -- root node 생성
    local node = cc.Node:create()
    node:setPosition(x, y)
    
    node:runAction( cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(0.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))

    self.m_world:addChild3(node, DEPTH_HEAL_FONT)


    node:addChild(self:makeDamageNumber(heal, 102, 255, 0))


    -- 판정 표시
    do
        local sprite

        if (is_critical) then
            sprite = self:createWithSpriteFrameName('ingame_damage_maximization.png')
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
-- function makeDamageNumber
-------------------------------------
function Character:makeDamageNumber(damage, r, g, b)
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_btn/ingame_btn.plist')
    local x_offset = 0
    local str = comma_value(damage)
    local length = #str
    local damage_node = cc.Node:create()
    for i = 1, #str do
        local v = str:sub(i, i)
        local sprite = nil
        if (v == ',') then  -- comma
            sprite = self:createWithSpriteFrameName('ingame_damage_comma.png')
        else                -- number
            sprite = self:createWithSpriteFrameName('ingame_damage_'.. v.. '.png')
        end

        sprite:setPosition(x_offset, 0)
        sprite:setColor(cc.c3b(r, g, b))
        sprite:setScale(0.75)
        damage_node:addChild(sprite)
        x_offset = x_offset + (sprite:getContentSize()['width'] / 2)
    end
    
    damage_node:setPosition(-(x_offset/2), 0)
    damage_node:setCascadeOpacityEnabled(true)
    return damage_node
end

-------------------------------------
-- function makeMissFont
-------------------------------------
function Character:makeMissFont(x, y)
    local y = y + 60

    -- 일반 데미지
    local sprite = self:createWithSpriteFrameName('ingame_damage_dodge.png')

    local scale = 1

    sprite:setPosition(x, y)
    sprite:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
    sprite:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
    --self.m_world:addChild3(sprite, DEPTH_MISS_FONT)
    self.m_world:addChild3(sprite, DEPTH_DAMAGE_FONT)
end

-------------------------------------
-- function makeShieldFont
-------------------------------------
function Character:makeShieldFont(x, y)
    local y = y + 60

    local sprite = self:createWithSpriteFrameName('ingame_damage_shield.png')

    local scale = 1

    sprite:setPosition(x, y)
    sprite:runAction( cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.2), cc.FadeOut:create(0.5), cc.RemoveSelf:create()))
    sprite:runAction(cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 80)), 1))
    --self.m_world:addChild3(sprite, DEPTH_BLOCK_FONT)
    self.m_world:addChild3(sprite, DEPTH_DAMAGE_FONT)
end

-------------------------------------
-- function makeImmuneFont
-------------------------------------
function Character:makeImmuneFont(x, y, scale)

    local sprite = self:createWithSpriteFrameName('ingame_damage_immunity.png')

    scale = scale or 1

    sprite:setPosition(x, y)
    sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(1.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
    sprite:runAction(cc.Sequence:create(cc.DelayTime:create(.5), cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 170)), 1)))
    self.m_world:addChild3(sprite, DEPTH_IMMUNE_FONT)
end

-------------------------------------
-- function makeResistanceFont
-------------------------------------
function Character:makeResistanceFont(x, y, scale)

    local sprite = self:createWithSpriteFrameName('ingame_resist.png')

    scale = scale or 1

    sprite:setPosition(x, y)
    sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.5 * scale), cc.ScaleTo:create(0.1, 1 * scale), cc.DelayTime:create(1.2), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
    sprite:runAction(cc.Sequence:create(cc.DelayTime:create(.5), cc.EaseIn:create(cc.MoveTo:create(1, cc.p(x, y + 170)), 1)))
    self.m_world:addChild3(sprite, DEPTH_IMMUNE_FONT)
end

-------------------------------------
-- function createWithSpriteFrameName
-------------------------------------
function Character:createWithSpriteFrameName(res_name)
    Translate:a2dTranslate('ui/a2d/ingame_damage/ingame_damage.plist')
    local sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    if (not sprite) then
        -- @E.T.
		g_errorTracker:appendFailedRes(res_name)

        --cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/ingame_damage/ingame_damage.plist')
        Translate:a2dTranslate('ui/a2d/ingame_damage/ingame_damage.plist')
        sprite = cc.Sprite:createWithSpriteFrameName(res_name)
    end

	sprite:setDockPoint(CENTER_POINT)
	sprite:setAnchorPoint(CENTER_POINT)
	return sprite
end
-------------------------------------
-- function healPercent
-------------------------------------
function Character:healPercent(caster, percent, b_make_effect, forced)
    local max_hp = self:getStat('hp')
    local heal = max_hp * percent
    heal = math_min(max_hp - self.m_hp, heal)

    self:healAbs(caster, heal, b_make_effect, forced)
end

-------------------------------------
-- function healAbs
-------------------------------------
function Character:healAbs(caster, heal, b_make_effect, forced, skill_id)
    local heal = math_floor(heal)
    local is_critical = false

    if (caster) then
        -- 크리 여부 검사
        local critical_chance = caster:getStat('cri_chance') or 0
        local critical_avoid = 0
        local final_critical_chance = CalcCriticalChance(critical_chance, critical_avoid)

        is_critical = (math_random(1, 1000) <= (final_critical_chance * 10))

        if (is_critical) then
            local cri_dmg = caster:getStat('cri_dmg') or 0
            local multifly = 1 + (cri_dmg / 100)

            local cri_dmg_adj_rate = caster:getStat('cri_dmg_adj_rate') / 100

            local rate = math_max(cri_dmg_adj_rate, -1)
            multifly = multifly * (1 + rate)


            heal = heal * multifly 
        end
        
        -- 시전자 회복 스킬 효과 증가 처리
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

    -- 최종 치유량 증가
    do
        local final_heal_rate = self:getStat('final_heal_rate') or 1
        heal = heal * final_heal_rate
    end

    -- 최소 힐량 1로 표시
    heal = math_max(heal, 1)



    local heal_for_log = math_min(heal, (self.m_maxHp - self.m_hp))

    self:makeHealFont(heal, is_critical)
    self:setHp(self.m_hp + heal, forced)

    if (b_make_effect) then
        local res = 'res/effect/skill_heal_monster/skill_heal_monster.vrp'
        local pos_x = self.pos['x']
        local pos_y = self.pos['y']
        local effect = self.m_world:addInstantEffect(res, 'idle', pos_x, pos_y)
    end

    -- 회복 되었을 시 이벤트
    do
        -- Event Carrier 세팅
	    local t_event = clone(EVENT_HEAL_CARRIER)
        t_event['skill_id'] = skill_id
	    t_event['heal'] = heal
	    t_event['attacker'] = caster
	    t_event['defender'] = self
	    t_event['is_critical'] = is_critical
        t_event['i_x'] = i_x
        t_event['i_y'] = i_y
        t_event['left_formation'] = self.m_bLeftFormation

        self:dispatch('character_recovery', t_event, self)
    end

	-- @LOG_CHAR : 피회복자 피회복량
	self.m_charLogRecorder:recordLog('be_healed', heal_for_log)
	-- @LOG_CHAR : 회복시전자 회복량
	if (caster) then
		caster.m_charLogRecorder:recordLog('heal', heal_for_log)
	end
end

-------------------------------------
-- function setHp
-------------------------------------
function Character:setHp(hp, forced)
	-- 죽었을시 탈출
    if (not forced) then
	    if (self:isDead()) then return end
        if (self:isZeroHp()) then return end
    end

    self.m_prevHp = self.m_hp
    self.m_hp = math_min(hp, self.m_maxHp)

    if (not forced and self.m_isImmortal) then
        self.m_hp = math_max(self.m_hp, 1)
    else
        self.m_hp = math_max(self.m_hp, 0)
    end
        
    self.m_hpRatio = self.m_hp / self.m_maxHp

    -- 리스너에 전달
	local t_event = clone(EVENT_CHANGE_HP_CARRIER)
	t_event['owner'] = self
    t_event['prev_hp'] = self.m_prevHp
	t_event['hp'] = self.m_hp
	t_event['max_hp'] = self.m_maxHp
    t_event['hp_rate'] = self.m_hpRatio

    self:dispatch('character_set_hp', t_event, self)

    self.m_prevHp = self.m_hp

    -- 체력바 가감 연출
    if (self.m_hpGauge) then
        self.m_hpGauge:setScaleX(self.m_hpRatio)
    end
	if (self.m_hpGauge2) then
        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.ScaleTo:create(0.5, self.m_hpRatio, 1))
        self.m_hpGauge2:runAction(cc.EaseIn:create(action, 2))
    end
end

-------------------------------------
-- function release
-------------------------------------
function Character:release()
    if (self.m_world) then
        if (self.m_charType == 'tamer') then

        elseif (self.m_bLeftFormation) then
            self.m_world:removeHero(self)
        else
            self.m_world:removeEnemy(self)
        end
    end

    -- 상태효과 아이콘 해제(m_unitStatusIconNode보다 먼저 되어야함!!)
    self:removeStatusIconAll()

    if (self.m_unitStatusIconNode) then
        self.m_unitStatusIconNode:removeFromParent(true)
        self.m_unitStatusIconNode = nil    
    end
    if (self.m_unitInfoNode) then
        self.m_unitInfoNode:removeFromParent(true)
        self.m_unitInfoNode = nil    
    end
    if (self.m_lockOnNode) then
        self.m_lockOnNode:removeFromParent(true)
        self.m_lockOnNode = nil
    end
    if (self.m_enemySpeechNode) then
        self.m_enemySpeechNode:removeFromParent(true)
        self.m_enemySpeechNode = nil
    end

    self.m_hpNode = nil
    self.m_hpGauge = nil
    self.m_hpGauge2 = nil
    self.m_castingNode = nil
    self.m_castingGauge = nil

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

    self:setEnableBody(self.m_bActive)

    if (self.m_rootNode) then
        self.m_rootNode:setVisible(self.m_bActive)
    end

    if (not self.m_bActive) then
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
    end
    
    local ui = UI_IngameUnitInfo(self)
    self.m_hpNode = ui.root
    self.m_hpNode:setDockPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_hpNode:setVisible(false)

    self.m_hpGauge = ui.vars['hpGauge']
    self.m_hpGauge2 = ui.vars['hpGauge2']

    self.m_unitInfoNode:addChild(self.m_hpNode)

	self.m_infoUI = ui

    self:makeStatusIconNode(self.m_unitStatusIconNode)
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

    if (self.m_unitStatusIconNode) then
        self.m_unitStatusIconNode:setPosition(x, y)
    end

    if (self.m_unitInfoNode) then
        self.m_unitInfoNode:setPosition(x, y)
    end

    if (self.m_lockOnNode) then
        self.m_lockOnNode:setPosition(x, y)
    end

    if (not self.m_bFixedPosHpNode) then
        if (self.m_hpNode) then
            self.m_hpNode:setPosition(self.m_unitInfoOffset[1], self.m_unitInfoOffset[2])
        end

        self:setPositionStatusIcons(self.m_unitInfoOffset[1], self.m_unitInfoOffset[2])
    end

    if (self.m_castingNode) then
        self.m_castingNode:setPosition(self.m_unitInfoOffset[1], self.m_unitInfoOffset[2])
    end

    if (self.m_enemySpeechNode) then
        self.m_enemySpeechNode:setPosition(x, y)
    end
end

-------------------------------------
-- function calcAttackPeriod
-- @brief 공격 주기 계산
-------------------------------------
function Character:calcAttackPeriod(calc_attack_tick)
    local calc_attack_tick = calc_attack_tick or false
    local cast_time = self.m_reservedSkillCastTime or 0
    local attack_duration = self.m_attackAnimaDuration
    local charge_duration = self.m_chargeDuration
    
    -- attack tick 재계산
    if (calc_attack_tick) then
        self.m_statusCalc.m_attackTick = self.m_statusCalc:getAttackTick()

        -- 애니메이션 속도 조절(드래곤만 처리)
        if (self.m_charType == 'dragon') then
            -- 공속 버프 비율
            local aspd_ratio = self:getStat('aspd') / 100

            self.m_aspdRatio = aspd_ratio
            
            attack_duration = attack_duration / self.m_aspdRatio
            charge_duration = charge_duration / self.m_aspdRatio
        end

        -- 공속 버프 비율만큼 애니메이션 속도를 보정
        if (not self.m_temporaryPause) then
            self:setTimeScale()
        end
    end

    -- 공격 주기 공식
    if (self.m_bFirstAttack) then
        self.m_bFirstAttack = false

        -- 전투 시작 후 첫 공격까지 시간 설정
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
    if (cast_time > 0) then
        self.m_attackPeriod = self.m_attackPeriod
    else
        self.m_attackPeriod = self.m_attackPeriod - attack_duration - charge_duration
    end

    -- 음수가 나오지 않도록 보정
    self.m_attackPeriod = math_max(self.m_attackPeriod, 0)
end

-------------------------------------
-- function updatePhys
-------------------------------------
function Character:updatePhys(dt)
    PARENT.updatePhys(self, dt)

    -- 이동 목표 지점을 지나친 경우 목표 지점으로 세팅
	if (self.m_isOnTheMove) then
        if self:isOverTargetPos(true) then
            self:setPosition(self.m_targetPosX, self.m_targetPosY)
            self:resetMove()
        end
	end
end

-------------------------------------
-- function update
-------------------------------------
function Character:update(dt)
    self.m_mUsedSkillIdInFrame = {}

    -- 경직 중일 경우
    if (self.m_isSpasticity) then
        self.m_delaySpasticity = self.m_delaySpasticity - dt

        if (self.m_delaySpasticity <= 0 or not self.m_bEnableSpasticity) then
            self:setSpasticity(false)
        else
            return
        end
    end

    -- 로밍
    self:updateRoaming(dt)
        
    -- 쿨타임 스킬 타이머(액티브 제외)
    self:updateBasicSkillTimer(dt)
        		
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

    if (not self.m_world.m_gameState:isFight()) then
        return
    end

    -- 이미 스킬을 사용하기 위한 상태나 사용 중인 경우
    if (isExistValue(self.m_state, 'skillPrepare', 'skillAppear', 'skillIdle', 'delegate')) then
        -- 게임이 멈춰있는지도 체크해야 한다
        if (not self:isDragon()) then
            return
        elseif (self:isDragon() and self.m_world:isPause()) then
            return
        end
    end

    -- 쿨타임 감소를 적용하여 스킬별 쿨타임 갱신
    local cool_actu = self:getStat('cool_actu') or 0
    local has_cc = self:hasStatusEffectToDisableSkill()
    PARENT.updateBasicSkillTimer(self, dt, cool_actu, has_cc)
    
    -- 특정 발동 조건을 가진 스킬들은 실시간으로 체크
    do
        -- indie_time_short 타입 스킬
        do
            local list = self:getSkillIndivisualInfo('indie_time_short') or {}

            for i, v in pairs(list) do
                if (v:isEndCoolTime()) then
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end

        -- indie_time_fix 타입 스킬
        -- 랜덤값이 아닌 확정 값으로 사용하기 위해 사용
        do
            local list = self:getSkillIndivisualInfo('indie_time_fix') or {}

            for i, v in pairs(list) do
                if (v:isEndCoolTime()) then
                    self:doSkill(v.m_skillID, 0, 0)
                end
            end
        end

        -- hp_rate_short 타입 스킬
        do
            local list = self:getSkillIndivisualInfo('hp_rate_short') or {}
        
            for i, v in pairs(list) do
                if (v:isEndCoolTime()) then
                    local hp_rate = self.m_hpRatio * 100
                    if (hp_rate <= v:getChanceValue()) then
                        self:doSkill(v.m_skillID, 0, 0)
                    end
                end
            end
        end
    end
end

-------------------------------------
-- function isAttackable
-------------------------------------
function Character:isAttackable(is_active_skill, attack_activity_carrier)
    local is_attackable = true

    local has_active_only_passive = self:isExistStatusEffectName('target_active_skill_only')
    local has_without_skill_passive = self:isExistStatusEffectName('target_without_skill')
    local has_disabled_passive = self:isExistStatusEffectName('target_disabled')

    -- 아예 못떄림
    if (has_disabled_passive) then
        is_attackable = false

    -- 액티브만 먹을 때
    elseif (has_active_only_passive) then
        is_attackable = is_active_skill

    -- 액티브 뺴고 다먹어야 할 때
    elseif (has_without_skill_passive) then
        is_attackable = not is_active_skill

    end

    -- 액티비티 캐리어가 없으면 그냥 결과 반환
    if (not attack_activity_carrier) then return is_attackable end

    -- 일부 특별한 공격은 무조건 적중.
    local skill_id = attack_activity_carrier:getSkillId()
    local t_skill = self:getSkillTable(skill_id)
    local is_definite_target = false

    if (t_skill and t_skill['target_type']) then 
        local target_type = t_skill['target_type']
        local is_teammate = string.find(target_type, 'teammate')
        local is_self = string.find(target_type, 'self')
        local is_ally = string.find(target_type, 'ally')
        local is_boss = string.find(target_type, 'boss')

        -- 이 중에 하나라도 해다된다면 타겟 지정 가능
        if (is_teammate or is_self or is_ally or is_boss) then 
            is_definite_target = true 
        end
    end

    if (is_definite_target) then 
        is_attackable = true
    end

    return is_attackable
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
-- function changeHomePosByTime
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
    if (self:isDead()) then return end

    self:removeNonTargetEffect(k)
    self.m_mTargetEffect[k] = animator

    if (animator) then
        local body = self:getBody(k)
                
		animator:setPosition(body['x'], body['y'])
		self.m_lockOnNode:addChild(animator.m_node)
		
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
-- function isExistNonTargetEffect
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
    if (self:isDead()) then return end

    self:removeTargetEffect(k)
    self.m_mNonTargetEffect[k] = animator

    if (animator) then
        local body = self:getBody(k)
                
		animator:setPosition(body['x'], body['y'])
		self.m_lockOnNode:addChild(animator.m_node)
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
    if (not self.m_bRoam) then return end
    if (not self:isPossibleMove(-1) or self.m_world.m_gameState:isFight() == false) then
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

    self:syncAniAndPhys()
end

-------------------------------------
-- function updateDebugingInfo
-- @brief 인게임 정보 출력용 업데이트
-------------------------------------
function Character:updateDebugingInfo()
	-- 화면에 체력 표시
	if g_constant:get('DEBUG', 'DISPLAY_UNIT_HP') then 
		self.m_infoUI.m_label:setString(string.format('%d/%d\n(%d%%)',self.m_hp, self.m_maxHp, self:getHpRate()*100))

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
-- function onEnabledBehavior
-- @brief 행동 가능 상태가 되었을 때 호출
-------------------------------------
function Character:onEnabledBehavior()
    if (not self.m_temporaryPause) then
        self:runAction_Floating()
    end
end

-------------------------------------
-- function onDisabledBehavior
-- @brief 행동 불가능 상태가 되었을 때 호출
-------------------------------------
function Character:onDisabledBehavior()
    if (self.m_animator and self.m_animator.m_node) then
        cca.stopAction(self.m_animator.m_node, CHARACTER_ACTION_TAG__FLOATING)
    end
end

-------------------------------------
-- function getName
-------------------------------------
function Character:getName()
	if (self.m_charTable and self.m_charTable['t_name']) then 
		return Str(self.m_charTable['t_name'])
	end
end

-------------------------------------
-- function getCharTable
-------------------------------------
function Character:getCharTable()
	return self.m_charTable
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
-- function getGrade
-------------------------------------
function Character:getGrade()
	return 1
end

-------------------------------------
-- function getTotalLevel
-------------------------------------
function Character:getTotalLevel()
	return self.m_lv
end

-------------------------------------
-- function getRole
-------------------------------------
function Character:getRole()
	return self.m_charTable['role']
end

-------------------------------------
-- function getActiveSkillTargetCount
-- @return 액티브 스킬 타겟 숫자
-------------------------------------
function Character:getActiveSkillTargetCount()
    local t_skill_indivisual

    -- 변신 전 or 후 액티브 스킬 정보
    if (self:isMetamorphosis()) then
        t_skill_indivisual = self:getActiveSkillIndivisualInfoAfterMetamorphosis()
    else
        t_skill_indivisual = self:getActiveSkillIndivisualInfoBeforeMetamorphosis()
    end

    if (not t_skill_indivisual) then
        return 0
    end

    
    local t_skill = t_skill_indivisual.m_tSkill
    if (not t_skill) then
        return 0
    end

    local active_skill_target_count = t_skill['target_count']
    return active_skill_target_count or 0
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
    local activity_carrier = self.m_reservedActivityCarrier or ActivityCarrier()

    self.m_reservedActivityCarrier = nil

	-- 시전자를 지정
	activity_carrier:setActivityOwner(self)

    -- 속성 지정
    activity_carrier.m_attribute = attributeStrToNum(self:getAttribute())

    -- 세부 능력치 지정
	activity_carrier:setStatuses(self.m_statusCalc)

    return activity_carrier
end

-------------------------------------
-- function reserveAttackDamage
-- @brief 다음 makeAttackDamageInstance 호출시 가져올 activity carrier를 설정
-------------------------------------
function Character:reserveAttackDamage(activity_carrier)
    self.m_reservedActivityCarrier = activity_carrier
end

-------------------------------------
-- function runAction_Shake
-- @brief 피격 시 캐릭터 진동 효과
-------------------------------------
function Character:runAction_Shake()
    if (not self.m_animator) then return end
    
    local target_node = self.m_animator.m_node
    if (not target_node) then return end

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
    if (not self.m_animator) then return end
    
    local target_node = self.m_animator.m_node
    if (not target_node) then return end

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
    if (not self.m_animator) then return end
    
    local target_node = self.m_animator.m_node
    if (not target_node) then return end
    
    -- 행동 불가 상태일 경우
    if (self:hasStatusEffectToDisableBehavior()) then
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
        -- delegate 상태에서의 애니메이션 정보를 초기화(외부에서 변경될 수 있기 때문)
        self.m_tStateAni['delegate'] = 'idle'
        self.m_tStateAniLoop['delegate'] = true

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

    if (ret) then
        if (prev_state == 'stun') then
            

        elseif (prev_state == 'delegate') then
            self:killStateDelegate()
        end
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
     if (skill_id and skill_id ~= 0) then
        local cast_time = self:getCastTimeFromSkillID(skill_id)
    
        self.m_reservedSkillId = skill_id
        self.m_reservedSkillCastTime = cast_time
    else
        -- 예약된 스킬 정보 초기화
        self.m_reservedSkillId = nil
        self.m_reservedSkillCastTime = 0
    end
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
        
        self:setTimeScale(0)

        self.m_isSpasticity = true
        self.m_delaySpasticity = SpasticityTime
    else
        if (not self.m_temporaryPause) then
            self:setTimeScale()
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
-- function getBasicStat
-- @brief 기본 스탯을 가져온다
-------------------------------------
function Character:getBasicStat(stat_type)
	-- @TODO
	if (self.m_charType == 'tamer') then
		return 0
	end

    return self.m_statusCalc:getBasicStat(stat_type)
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

    if (not self.m_statusCalc) then
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
-- function getMaxHp
-- @brief 현재 최대 HP 정보를 가져온다
-------------------------------------
function Character:getMaxHp()
    return self.m_maxHp
end

-------------------------------------
-- function getHpRate
-- @brief 현재 HP 정보를 가져온다
-------------------------------------
function Character:getHpRate()
    return self.m_hpRatio
end

-------------------------------------
-- function isZeroHp
-------------------------------------
function Character:isZeroHp()
    return (self.m_hp <= 0)
end

-------------------------------------
-- function isMaxHp
-------------------------------------
function Character:isMaxHp()
    return (self.m_hp >= self.m_maxHp)
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
-- function addGroggy
-------------------------------------
function Character:addGroggy(statusEffectName)
    PARENT.addGroggy(self, statusEffectName)
    
    if (self.m_isGroggy) then
        self:changeState('stun')
    end
end

-------------------------------------
-- function setStatusIconPosition
-------------------------------------
function Character:setStatusIconPosition(status_icon, idx)
    if (not self.m_infoUI) then return end

    local x, y = self.m_infoUI:getPositionForStatusIcon(self.m_bLeftFormation, idx)
    local scale = self.m_infoUI:getScaleForStatusIcon()

    status_icon:setPosition(x, y)
    status_icon:setScale(scale)
end

-------------------------------------
-- function setGuard
-------------------------------------
function Character:setGuard(skill)
	self.m_guard = skill
end

-------------------------------------
-- function getGuard
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
    return self.m_isBoss
end

-------------------------------------
-- function isDead
-------------------------------------
function Character:isDead(no_dying)
    if (self.m_resurrect) then
        return false
    end

    if (not no_dying) then
        if (self.m_state == 'dying' or self.m_state == 'dead') then return true end
    end
        
    return (self.m_bDead)
end

-------------------------------------
-- function getMissilePhysGroup
-- @brief 해당 캐릭터가 쏠 미사일의 PhysGruop 가져온다.
-------------------------------------
function Character:getMissilePhysGroup()
    if (self.phys_key == PHYS.HERO) then
        return PHYS.MISSILE.HERO

    elseif (self.phys_key == PHYS.HERO_TOP) then
        return PHYS.MISSILE.HERO_TOP

    elseif (self.phys_key == PHYS.HERO_BOTTOM) then
        return PHYS.MISSILE.HERO_BOTTOM

    elseif (self.phys_key == PHYS.ENEMY_TOP) then
        return PHYS.MISSILE.ENEMY_TOP

    elseif (self.phys_key == PHYS.ENEMY_BOTTOM) then
        return PHYS.MISSILE.ENEMY_BOTTOM

    else
        return PHYS.MISSILE.ENEMY
    end
end

-------------------------------------
-- function getFellowList
-- @brief 어떤 진형이든 항상 아군을 가져온다.
-------------------------------------
function Character:getFellowList()
	if (self.m_bLeftFormation) then 
		return self.m_world:getDragonList(self)
	else
		return self.m_world:getEnemyList(self)
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
-- function setTemporaryPause
-------------------------------------
function Character:setTemporaryPause(pause)
    if (PARENT.setTemporaryPause(self, pause)) then
        if (pause) then
            -- 위치 좌표값 동기화
            self:syncAniAndPhys()

            if (self.m_animator) then
                local target_node = self.m_animator.m_node
                
                -- 액션 정지
                cca.stopAction(target_node, CHARACTER_ACTION_TAG__FLOATING)
            end
        else
            self:runAction_Floating()
        end

        return true
    end

    return false
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function Character:setTimeScale(time_scale)
    local time_scale = time_scale or self.m_aspdRatio

    if (self.m_animator) then
        self.m_animator:setTimeScale(time_scale)
    end
    if (self.m_chargeEffect) then
        self.m_chargeEffect:setTimeScale(time_scale)
    end
end

-------------------------------------
-- function stopRoaming
-------------------------------------
function Character:stopRoaming()
    if (self.m_rootNode) then
        cca.stopAction(self.m_rootNode, CHARACTER_ACTION_TAG__ROAM)
    end
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
	printLine('NAME : ' .. self:getName())
    printLine('LEVEL : ' .. self.m_lv)
    printLine('CURR_STATE = ' .. (self.m_state or ''))
    printLine('## STATUS EFFECT LIST ##')
    for type, se in pairs(self:getStatusEffectList()) do
		printLine(string.format('- %s : overlap:%d time:%d', type, se:getOverlabCount(), se:getLatestTimer()))
	end
    printLine('## HIDDEN STATUS EFFECT LIST ##')
    for type, se in pairs(self:getHiddenStatusEffectList()) do
		printLine(string.format('- %s : overlap:%d time:%d', type, se:getOverlabCount(), se:getLatestTimer()))
	end
	printLine('## STAT LIST ##')
	printLine(self.m_statusCalc:getAllStatString())

	printLine('=======================================================')

    return str
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

-------------------------------------
-- function getSizeType
-- 하위 클래스에서 재정의 필요
-------------------------------------
function Character:getSizeType()
end

-------------------------------------
-- function getPosForFormation
-------------------------------------
function Character:getPosForFormation()
    return self:getPosition()
end

-------------------------------------
-- function checkSpecialImmune
-- @brief 특정 상태효과 면역 체크
-------------------------------------
function Character:checkSpecialImmune(t_status_effect)
    -- 보스의 경우 cc타입의 상태효과는 면역 처리
    if (self:isBoss()) then
        if (t_status_effect['type'] == 'cc') then
            return true
        end
    end

    return false
end

-------------------------------------
-- function getZOrder
-------------------------------------
function Character:getZOrder()
    if (self.m_bLeftFormation) then 
        return WORLD_Z_ORDER.HERO
    elseif (self:isBoss()) then
        return WORLD_Z_ORDER.BOSS
    else
        return WORLD_Z_ORDER.ENEMY
    end
end

-------------------------------------
-- function isMetamorphosis
-------------------------------------
function Character:isMetamorphosis()
    return self.m_bMetamorphosis
end


-------------------------------------
-- function initSpeechUI
-------------------------------------
function Character:initSpeechUI()
    -- 말풍선
    self.m_characterSpeech = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_characterSpeech:setScale(1)
    self.m_characterSpeech:setVisual('skill_gauge', 'bubble_2')
    self.m_characterSpeech:setRepeat(false)
    self.m_characterSpeech:setVisible(false)
    self:getEnemySpeechNode():addChild(self.m_characterSpeech.m_node, 5)
    
    local speechNode = self.m_characterSpeech.m_node:getSocketNode('skill_bubble')
    local font_scale_x, font_scale_y = Translate:getFontScaleRate()

    self.m_characterSpeechLabel = cc.Label:createWithTTF('', Translate:getFontPath(), 24, 0, cc.size(340, 100), 1, 1)
    self.m_characterSpeechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_characterSpeechLabel:setDockPoint(cc.p(0, 0))
	self.m_characterSpeechLabel:setColor(cc.c3b(0,0,0))
    self.m_characterSpeechLabel:setScale(font_scale_x * 1.3, font_scale_y * 1.3)
    speechNode:addChild(self.m_characterSpeechLabel)
end


-------------------------------------
-- function setTemporaryPause
-------------------------------------
function Character:showSpeech(strSpeech)
    if (not self.m_characterSpeech) then return end

    self.m_characterSpeechLabel:setString(strSpeech)
    
    UIHelper:autoPositioning(self:getEnemySpeechNode(), self.m_characterSpeech, self.m_characterSpeechLabel)

    self.m_characterSpeech:setFrame(30)
    self.m_characterSpeech:setAnimationPause(true)

    self.m_characterSpeech:setVisible(true)

    local function hide_func()
    self.m_characterSpeech:setVisible(false)
    end

    self.m_characterSpeech.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(4.5), cc.CallFunc:create(hide_func)))
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function Character:hideSpeech()
    self.m_characterSpeech:setAnimationPause(false)

    self.m_characterSpeech:addAniHandler(function()
        self.m_characterSpeech:setVisible(false)
    end)
end