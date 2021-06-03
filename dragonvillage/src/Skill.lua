local PARENT = class(Entity,
    IEventListener:getCloneTable(),
    IEventDispatcher:getCloneTable(),
    ISkillSound:getCloneTable()
)

-------------------------------------
-- class Skill
-------------------------------------
Skill = class(PARENT, {
        m_owner = 'Character',
        m_activityCarrier = 'ActivityCarrier',

        m_skillId = 'number', -- 스킬 아이디
        m_skillHitCount = 'number',
		m_skillName = 'str',  -- 스킬 타입 명 ex) skill_expolosion 
		m_chanceType = 'str',  -- 스킬 종류.. active or basic etc.

		m_powerRate = 'num',
        m_addCriPowerRate = 'num',
		m_powerAbs = 'num',
		m_powerSource = 'str',
		m_powerIgnore = 'str',  -- 피격대상 특정 스탯 무시(맵형태)
        m_critical = 'num',     -- 크리티컬 판정(1:발동 , 0:미발동, nil:피격시 판정)
		m_preDelay = 'num',

		m_skillSize = 'str',
		m_resScale = 'str',
		m_range = 'num',

		-- 타겟 관련 .. 
		m_targetFormation = 'str',
		m_targetType = 'str', -- 타겟 선택하는 룰
		m_targetLimit = 'num', -- 선택할 타겟의 최대 수
		m_targetChar = 'Character', 
        m_lTargetChar = 'table', -- 인디케이터에서 보낸 타겟 리스트 
        m_lTargetCollision = 'table', -- 인디케이터에서 보낸 충돌정보 리스트
		m_targetPos = 'pos', -- 인디케이터에서 보낸 x, y 좌표
		
		-- 상태 효과 관련 변수들
		m_lStatusEffect = 'List<StructStatusEffect>',
        
        -- 이벤트
        m_mSpecialEvent = '', -- 스킬 종료시 적용될 특수한 조건의 이벤트를 저장하기 위한 맵(조건 달성 시점이 아닌 종료시 적용을 위함)

		-- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',

        -- 스킬 진행 정보
        m_totalHit = 'number',
        m_totalDamage = 'number',
        m_totalHeal = 'number',

		-- 스킬 연출 관리자 - 디렉터
		m_skillHitEffctDirector = 'SkillHitEffectDirector',
		m_bSkillHitEffect = 'bool', -- 사용 여부
        
        -- 스킬 종료시 피드백(보너스) 관련
        m_hitTargetList = 'table',
        m_hitCollisionList = 'table',
        
        -- 하이라이트시 숨김 처리
        m_dataForTemporaryPause = '',

        -- 미사일 사용 여부(미사일 사용시는 일정시간 동안 스킬을 살림)
        m_bUseMissile = 'boolean'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Skill:init(file_name, body, ...)
    self.m_totalHit = 0
    self.m_totalDamage = 0
    self.m_totalHeal = 0

    self.m_dataForTemporaryPause = nil
    self.m_bUseMissile = false
end

-------------------------------------
-- function init_skill
-- @brief actvityCarrier, AttackOffset, defualt target, default target pos를 설정한다. 
-------------------------------------
function Skill:init_skill()
	-- 멤버 변수 
	self.m_range = 0
    self.m_mSpecialEvent = {}
    self.m_hitTargetList = {}
    self.m_hitCollisionList = {}

	-- 세부 초기화 함수 실행
	self:initActvityCarrier()
    self:initAttackPosOffset()
	self:initSkillSize()
	self:initEventListener()
	self:adjustAnimator()
    self:adjustFlip()

    -- 타겟이 없다면 기본 타겟 찾음
	if (not self.m_targetChar) then
		self.m_targetChar = self:getDefaultTarget()
	end
	-- 타겟 좌표가 없다면 기본 타겟 좌표를 찾음
    if (not self.m_targetPos.x) or (not self.m_targetPos.y) then
        local x, y = self:getDefaultTargetPos()
		self.m_targetPos = {x = x, y = y}
    end
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function Skill:initActvityCarrier()
    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
	self.m_activityCarrier:setAtkDmgStat(self.m_powerSource)
	self.m_activityCarrier:setAttackType(self.m_chanceType)
    self.m_activityCarrier:setSkillId(self.m_skillId)
    self.m_activityCarrier:setSkillHitCount(self.m_skillHitCount)
    self.m_activityCarrier:setPowerRate(self.m_powerRate)
    self.m_activityCarrier:setAddCriPowerRate(self.m_addCriPowerRate)
    self.m_activityCarrier:setAbsAttack(self.m_powerAbs)
    self.m_activityCarrier:setCritical(self.m_critical)

    -- 스킬 발동 타입 별도로 저장(상태효과 등에 전송하기 위함)
    self.m_activityCarrier:setParam('chance_type', self.m_chanceType)

    -- 수식에서 사용하기 위한 값을 세팅
    EquationHelper:setEquationParamOnMapForSkill(self.m_activityCarrier.m_tParam, self)
	
    self.m_activityCarrier:setIgnoreByTable(self.m_powerIgnore)
end

-------------------------------------
-- function initSkillSize
-- @breif table의 skill_size를 통하여 필요한 값과 scale 추출 / 각 스킬 대분류 마다 작성
-------------------------------------
function Skill:initSkillSize()
end

-------------------------------------
-- function initEventListener
-- @breif 이벤트 처리..
-------------------------------------
function Skill:initEventListener()
   
    -- 기본 이벤트
	self:addListener(CON_SKILL_START, self)
    self:addListener(CON_SKILL_HIT_FIRST, self)
	self:addListener(CON_SKILL_HIT, self)
	self:addListener(CON_SKILL_END, self)

    local is_active_skill = self.m_chanceType == 'active'

    -- 특정 이벤트 추가
    local l_target = self.m_owner:getTargetListByType(self.m_targetType, nil, nil, nil, is_active_skill)
    local target

    for _, unit in pairs(l_target) do
        if (unit.m_bUseBinding and unit.m_parentChar) then
            target = unit.m_parentChar
        else
            target = unit
        end

        if (target.m_bLeftFormation ~= self.m_owner.m_bLeftFormation) then
            target:addListener(CON_SKILL_HIT_CRI, self)
            target:addListener(CON_SKILL_HIT_KILL, self)

            -- 총 데미지를 계산하기 위함
            target:addListener('under_atk', self)
        else
            -- 총 힐량을 계산하기 위함
            target:addListener('character_recovery', self)
        end
    end
    
	-- 스킬 내부의 특정 이벤트
    for _,  v in pairs(self.m_lStatusEffect) do
        local trigger = v.m_trigger or ''
        if (string.find(trigger, CON_SKILL_HIT_TARGET)) then
            self:addListener(trigger, self)
        end
    end
end

-------------------------------------
-- function adjustAnimator
-- @breif animator 조정하는 부분
-------------------------------------
function Skill:adjustAnimator()    
	if (not self.m_animator) then return end
	
	-- delay state 종료시 켜준다.
	self.m_animator:setVisible(false) 

	-- skill_size 가 있다면 skill_size에 의해 계산된 스케일 적용
	-- 없다면 res_scale 칼럼 값 사용
	if (self.m_resScale and self.m_resScale ~= '') then
		-- res_scale 의 경우 ;가 있으면 x,y 각각 개별로 들어간다...
		if string.find(self.m_resScale, ';') then
			local l_scale = plSplit(self.m_resScale, ';')
			self.m_animator.m_node:setScaleX(tonumber(l_scale[1]))
			self.m_animator.m_node:setScaleY(tonumber(l_scale[2]))
		else
 			self.m_animator:setScale(self.m_resScale)
		end
	end

	-- 스킬 애니 속성 세팅
	self.m_animator:setAniAttr(self.m_owner:getAttribute())
end

-------------------------------------
-- function adjustFlip
-- @breif 우측에서 사용한 스킬일 경우 이미지 반전
-------------------------------------
function Skill:adjustFlip()
    -- 반전 시키지 않아야하는 스킬 리스트(이런 경우가 늘어날 경우 별도 정리가 필요할듯...)
    local temp = { 
        -- 뇌신
        208011, 208013, 208014, 208041, 208043, 208044,

        -- 태엽
        207311, 207312, 207313, 207314, 207341, 207342, 207343, 207344
    }

    -- 반전 시키지 않아야하는 스킬인지 체크
    for _, sid in ipairs(temp) do
        if (sid == self.m_skillId) then
            return
        end
    end

    if (self:isRightFormation()) then
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function update
-------------------------------------
function Skill:update(dt)
    -- 사운드 업데이트
    self:updateSkillSound(dt)

    return PARENT.update(self, dt)
end

-------------------------------------
-- function setCommonState
-- @breif state 정의
-- @breif 모든 스킬은 delay로 시작하고 start로 본래의 스킬 state를 진행한다.
-------------------------------------
function Skill:setCommonState(skill)
	skill:addState('delay', Skill.st_delay, nil, false)
    skill:addState('dying_wait', Skill.st_dying_wait, nil, nil, 10)
    skill:addState('dying', Skill.st_dying, nil, nil, 10)
end

-------------------------------------
-- function changeState
-------------------------------------
function Skill:changeState(state, forced)
    if (self.m_bUseMissile or self.m_chanceType == 'active') then
        if (state == 'dying' and not forced) then
            state = 'dying_wait'
        end
    end

    local ret = PARENT.changeState(self, state, forced)
    return ret
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function Skill:setSkillParams(owner, t_skill, t_data)
	self.m_owner = owner
    self.m_world = owner.m_world
	
	self.m_powerRate = SkillHelper:getValid(t_skill['power_rate'], 0)
    self.m_addCriPowerRate = SkillHelper:getValid(t_skill['critical_damage_add'])
    self.m_powerAbs = SkillHelper:getValid(t_skill['power_add'], 0)
	self.m_powerSource  = SkillHelper:getValid(t_skill['power_source'], 'atk')
    self.m_powerIgnore = t_data['ignore'] or {}
    self.m_critical = t_data['critical']
	self.m_lStatusEffect = SkillHelper:makeStructStatusEffectList(t_skill)
	
	self.m_preDelay = SkillHelper:getValid(t_skill['pre_delay'], 0)
	self.m_resScale = SkillHelper:getValid(t_skill['res_scale'])

    -- 스킬 스케일을 시전자와 맞추기
    if (not isNullOrEmpty(self.m_resScale) and owner and owner.m_originScale and owner.m_originScale ~= owner.m_animator:getScale()) then
        local scale_rate = owner.m_animator:getScale() / owner.m_originScale

        self.m_resScale = self.m_resScale * scale_rate
    end

	self.m_skillSize = SkillHelper:getValid(t_skill['skill_size'])

    self.m_skillId = t_skill['sid']
    self.m_skillHitCount = t_skill['hit']
	self.m_skillName = t_skill['skill_type']
	self.m_chanceType = t_skill['chance_type']
	
	self.m_targetPos = {x = t_data['x'], y = t_data['y']}
	self.m_targetChar = t_data['target'] or self.m_targetChar
    self.m_lTargetChar = t_data['target_list']
    self.m_lTargetCollision = t_data['collision_list']
    
	self.m_targetType = SkillHelper:getValid(t_skill['target_type'])
	self.m_targetLimit = SkillHelper:getValid(t_skill['target_count'])
	self.m_targetFormation = SkillHelper:getValid(t_skill['target_formation'])

	self.m_bSkillHitEffect = (g_gameScene.m_bDevelopStage) or (owner.m_bLeftFormation and (t_skill['chance_type'] == 'active')) 
        
    -- 콤보 이펙트 생성
    if (self.m_bSkillHitEffect) then
        self.m_skillHitEffctDirector = SkillHitEffectDirector(self.m_owner)
    end

    -- 사운드 설정
    if (t_skill) then
        self:initSkillSound(t_skill['sid'])
    end
end

-------------------------------------
-- function st_delay
-------------------------------------
function Skill.st_delay(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:onDelay(owner.m_owner)
		-- 타겟이 없다면 바로 종료
		if (not owner.m_targetChar) then 
			SkillHelper:printTargetNotExist(owner)
			owner:changeState('dying') 
		end
	elseif (owner.m_stateTimer > owner.m_preDelay) then
        owner.m_animator:runAction(cc.CallFunc:create(function(node)
            node:setVisible(true)
        end))
		owner:changeState('start')

        -- 스킬 사용시 발동되는 status effect를 적용
		owner:dispatch(CON_SKILL_START, {l_target = {owner.m_targetChar}})
    end
end

-------------------------------------
-- function st_dying_wait
-------------------------------------
function Skill.st_dying_wait(owner, dt)
    if (owner.m_totalTimer >= 2) then
        owner:changeState('dying', true)
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Skill.st_dying(owner, dt)
    owner:onDying()

    owner.m_owner:restore()

    local l_target = {}
    for target, _ in pairs(owner.m_hitTargetList) do
        table.insert(l_target, target)
    end

    -- 스킬 종료시 발동되는 status effect를 적용
    do
		owner:dispatch(CON_SKILL_END, {l_target = l_target})
    end

    -- 조건 달성 시점이 아닌 종료시 수행되어야할 이벤트의 상태효과를 적용
    do
        for event_name, _  in pairs(owner.m_mSpecialEvent) do
            owner:doStatusEffect(event_name, l_target) 
        end
    end

    return true
end

-------------------------------------
-- function onDelay
-------------------------------------
function Skill:onDelay(char)                                       
end

-------------------------------------
-- function onDying
-------------------------------------
function Skill:onDying()                                       
end

-------------------------------------
-- function onEvent
-------------------------------------
function Skill:onEvent(event_name, t_event, ...)
	local t_event = t_event or {}

    if (string.find(event_name, CON_SKILL_HIT_TARGET)) then
        self.m_mSpecialEvent[event_name] = true

    elseif (isExistValue(event_name, CON_SKILL_HIT_KILL)) then
        local skill_id = t_event['skill_id']
        if (skill_id and self.m_skillId == skill_id) then
            self.m_mSpecialEvent[event_name] = true
        end

    elseif (isExistValue(event_name, CON_SKILL_HIT_CRI)) then
        local skill_id = t_event['skill_id']
        if (skill_id and self.m_skillId == skill_id) then
            local target = t_event['defender']
            self:doStatusEffect(event_name, { target })
        end

    elseif (event_name == 'under_atk') then
        if (t_event['skill_id']) then
            if (self.m_skillId == t_event['skill_id']) then
                if (((not g_gameScene.m_bDevelopStage) and self.m_owner == t_event['attacker']) or
                    (g_gameScene.m_bDevelopStage and self.m_chanceType ~= 'basic')) then
                    self.m_totalHit = self.m_totalHit + 1
                    self.m_totalDamage = self.m_totalDamage + t_event['damage']

                    -- 연출
                    self:doWorkHitDirector(self.m_totalHit, self.m_totalDamage)

                    -- 피격자의 이벤트 dispatch에서 타격 카운트를 추가하기 위해 activityCarrier에 저장
                    local hit_count = self.m_activityCarrier:getParam('hit_count') or 0
                    hit_count = hit_count + 1
                    self.m_activityCarrier:setParam('hit_count', hit_count)
                end
            end
        end
    elseif (event_name == 'character_recovery') then
        if (t_event['skill_id']) then
            if (self.m_skillId == t_event['skill_id'] and self.m_owner == t_event['attacker']) then

                self.m_totalHit = self.m_totalHit + 1
                self.m_totalHeal = self.m_totalHeal + t_event['heal']

                -- 연출
                self:doWorkHitDirector(self.m_totalHit, self.m_totalHeal, true)

                
                -- 피격자의 이벤트 dispatch에서 타격 카운트를 추가하기 위해 activityCarrier에 저장
                local hit_count = self.m_activityCarrier:getParam('hit_count') or 0
                hit_count = hit_count + 1
                self.m_activityCarrier:setParam('hit_count', hit_count)
            end
        end
    else
        self:doStatusEffect(event_name, t_event['l_target'])

    end
end

-------------------------------------
-- function doStatusEffect
-- @brief l_start_con 조건에 해당하는 statusEffect를 적용
-------------------------------------
function Skill:doStatusEffect(start_con, l_target)
    local lStatusEffect = self:getStatusEffectList(start_con)
    
    if (#lStatusEffect > 0) then
        local l_target = l_target
		local add_param = self.m_activityCarrier.m_tParam

        -- 드래그 스킬의 경우엔 충돌 정보를 파라미터에 추가시킴
        if (self.m_chanceType == 'active') then
            if (start_con == CON_SKILL_START) then
                l_target = self.m_lTargetChar
                add_param['skill_collision_list'] = self.m_lTargetCollision
            else
                l_target = l_target or self:findTarget()
                add_param['skill_collision_list'] = convertToListFrom2DArray(self.m_hitCollisionList)
            end
        else
            l_target = l_target or self:findTarget()
        end

        -- 시전자 사망 여부에 상관없이 적용시키도록 한다
        add_param['ignore_caster_dead'] = true

        StatusEffectHelper:doStatusEffectByStruct(self.m_owner, l_target, lStatusEffect, nil, self.m_skillId, add_param)
    end
end

-------------------------------------
-- function runAttack
-- @brief findCollision으로 찾은 body별로 공격
-------------------------------------
function Skill:runAttack()
    local collisions = self:getProperCollisionList()

    for _, collision in ipairs(collisions) do
        self:attack(collision)
    end
    
	self:doCommonAttackEffect()
end

-------------------------------------
-- function runHeal
-------------------------------------
function Skill:runHeal()
    local l_collision = self:getProperCollisionList()

    for _, collision in ipairs(l_collision) do
        local target_char = collision:getTarget()
        self:heal(target_char)
    end

	self:doCommonAttackEffect()
end

-------------------------------------
-- function attack
-- @brief 공격 콜백을 실행시키고 hit 연출을 조작한다. 되도록 재정의 하지 않는다. 공격의 최소단위
-------------------------------------
function Skill:attack(collision)
    local target_char = collision:getTarget()
    local body_key = collision:getBodyKey()
    local body = target_char:getBody(body_key)
    local x = target_char.pos.x + body.x
    local y = target_char.pos.y + body.y

    -- 공격
    self:runAtkCallback(target_char, x, y, body_key)

    target_char:runDefCallback(self, x, y, body_key)

	self:onAttack(target_char, collision)
end

-------------------------------------
-- function heal
-------------------------------------
function Skill:heal(target_char, b_make_effect)
    local make_effect = true
    if (b_make_effect ~= nil) then make_effect = b_make_effect end

    local atk_dmg = self.m_activityCarrier:getAtkDmg(target_char)
    local heal = HealCalc_M(atk_dmg) * self.m_activityCarrier:getPowerRate() / 100
    local is_critical = self.m_activityCarrier:getCritical() 

    target_char:healAbs(self.m_owner, heal, make_effect, false, self.m_skillId)

    self:onHeal(target_char)
end


-------------------------------------
-- function onAttack
-- @brief 공격(attack) 직후 호출됨, 스킬에서 미사일 날릴 때 콜백으로도 사용
-------------------------------------
function Skill:onAttack(target_char, target_collision)
    local bUpdateHitTargetCount = false

    -- 피격된 대상 저장
    if (not self.m_hitTargetList[target_char]) then
        self.m_hitTargetList[target_char] = true
        bUpdateHitTargetCount = true
    end

    -- 피격된 충돌정보 저장
    if (target_collision) then
        local body_key = target_collision:getBodyKey()
        if (not self.m_hitCollisionList[target_char]) then
            self.m_hitCollisionList[target_char] = {}
        end
        self.m_hitCollisionList[target_char][body_key] = target_collision
    end

    local hit_target_count = table.count(self.m_hitTargetList)

    -- 화면 쉐이킹
    if (self.m_chanceType == 'active') then
        self.m_world.m_shakeMgr:doShakeRandomAngle(40, 1) -- distance, duration
        --self.m_world.m_shakeMgr:doShake(50, 50, 1)
    elseif (self.m_owner:getCharType() ~= 'tamer') then
        self.m_world.m_shakeMgr:doShakeRandomAngle(35, 0.5) -- distance, duration
        --self.m_world.m_shakeMgr:doShake(25, 25, 0.5)
    end

    -- 상태효과
    do
	    local t_event = { l_target = { target_char } }
	    self:dispatch(CON_SKILL_HIT, t_event)

        -- 피격된 대상수가 갱신된 경우 해당 이벤트 발동
        if (bUpdateHitTargetCount) then
            self:dispatch(CON_SKILL_HIT_TARGET .. hit_target_count, t_event)

            -- 대상을 처음 피격한 경우
            self:dispatch(CON_SKILL_HIT_FIRST, t_event)
        end
    end
end

-------------------------------------
-- function onHeal
-- @brief 힐(heal) 직후 호출됨
-------------------------------------
function Skill:onHeal(target_char)
    local bUpdateHitTargetCount = false

    -- 피격된 대상 저장
    if (not self.m_hitTargetList[target_char]) then
        self.m_hitTargetList[target_char] = true
        bUpdateHitTargetCount = true
    end

    local hit_target_count = table.count(self.m_hitTargetList)

    -- 힐 사운드
	if (self.m_owner:isDragon()) then
		SoundMgr:playEffect('SFX', 'sfx_heal')
	end

    -- 상태효과
    do
	    local t_event = {l_target = {target_char}}
	    self:dispatch(CON_SKILL_HIT, t_event)

        -- 피격된 대상수가 갱신된 경우 해당 이벤트 발동
        if (bUpdateHitTargetCount) then
            self:dispatch(CON_SKILL_HIT_TARGET .. hit_target_count, t_event)
        end
    end
end

-------------------------------------
-- function doWorkHitDirector
-------------------------------------
function Skill:doWorkHitDirector(total_hit, total_damage, is_heal)
	if (self.m_skillHitEffctDirector) then 
		self.m_skillHitEffctDirector:doWork(total_hit, total_damage, is_heal)
	end
end

-------------------------------------
-- function doCommonAttackEffect
-- @breif 어택 이벤트와 관련된 처리
-------------------------------------
function Skill:doCommonAttackEffect()
	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()
end

-------------------------------------
-- function findCollision
-- @brief 모든 충돌 대상 찾음(Body 기준)
-- @default 직선거리에서 범위를 기준으로 충돌여부 판단
-------------------------------------
function Skill:findCollision()
    local l_target = self:getProperTargetList()
	local x = self.m_targetPos.x
	local y = self.m_targetPos.y
	local range = self.m_range

    local l_ret = SkillTargetFinder:findCollision_AoERound(l_target, x, y, range)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

	return l_ret
end

-------------------------------------
-- function findTarget
-- @brief 모든 대상 찾음(Character 기준)
-- @default 직선거리에서 범위를 기준으로 충돌여부 판단
-------------------------------------
function Skill:findTarget()
    local l_collision = self:getProperCollisionList()
    local m_temp = {}

    -- 맵형태로 임시 저장(중복된 대상 처리를 위함)
    for _, collision in ipairs(l_collision) do
        local target = collision:getTarget()
        m_temp[target] = collision
    end

    -- 리스트 형태로 변환
    local l_target = {}

    for target, _ in pairs(m_temp) do
        table.insert(l_target, target)
    end

	return l_target, l_collision
end

-------------------------------------
-- function getProperCollisionList
-- @brief 적절한 충돌리스트 가져옴
-------------------------------------
function Skill:getProperCollisionList()
    if (self.m_lTargetCollision) then
        return self.m_lTargetCollision
    end

    return self:findCollision()
end

-------------------------------------
-- function getProperTargetList
-- @brief 타겟룰에 의해 적절한 타겟리스트 가져옴
-------------------------------------
function Skill:getProperTargetList()
    local target_count
    local is_active_skill = self.m_chanceType == 'active'

    if (is_active_skill) then
        if (self.m_lTargetChar) then
            return self.m_lTargetChar
        end

        target_count = nil
    else
        target_count = self.m_targetLimit
    end

	return self.m_owner:getTargetListByType(self.m_targetType, target_count, self.m_targetFormation, nil, is_active_skill)
end

-------------------------------------
-- function getDefaultTarget
-- @brief 디폴트 타겟을 반환한다.
-- @brief 인디케이터 없이 시전 된 경우 사용된다.
-- @default 타겟 룰에 따른 타겟 리스트 중 첫번째를 선택
-------------------------------------
function Skill:getDefaultTarget()
    if (self.m_targetChar) then return self.m_targetChar end
    local is_active_skill = self.m_chanceType == 'active'

    local l_target = self.m_owner:getTargetListByType(self.m_targetType, nil, self.m_targetFormation, nil, is_active_skill)
	local target = l_target[1]

	if (not target) then
	    cclog('Skill : Can not find target')
    end

	return target
end

-------------------------------------
-- function getDefaultTargetList
-------------------------------------
function Skill:getDefaultTargetList(idx)
    if (self.m_targetChar) then return self.m_targetChar end
    local is_active_skill = self.m_chanceType == 'active'

    local l_target = self.m_owner:getTargetListByType(self.m_targetType, nil, self.m_targetFormation, nil, is_active_skill)
	
	return l_target or {}
end

-------------------------------------
-- function getDefaultTargetPos
-- @brief 디폴트 타겟의 좌표를 반환한다.
-------------------------------------
function Skill:getDefaultTargetPos()
    local target = self:getDefaultTarget()
    if target then
		self.m_targetChar = target
		return target.pos.x, target.pos.y
    else
        return self.m_owner.pos.x, self.m_owner.pos.y
    end
end

-------------------------------------
-- function initAttackPosOffset
-- @brief 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset 지정
-------------------------------------
function Skill:initAttackPosOffset()
    self.m_attackPosOffsetX = 0
    self.m_attackPosOffsetY = 0

    local animator = self.m_owner.m_animator
    
    local l_event_data

    if (self.m_chanceType == 'active') then
        l_event_data = animator:getEventList('skill_disappear', 'attack')
    else
        l_event_data = animator:getEventList('attack', 'attack')
    end

    if (not l_event_data[1]) then
        return
    end

    local string_value = l_event_data[1]['stringValue']

    if (not string_value) or (string_value == '') then
        return
    end

    local l_str = seperate(string_value, ',')

    local scale = animator:getScale()
    self.m_attackPosOffsetX = (l_str[1] * scale)
    self.m_attackPosOffsetY = (l_str[2] * scale)

    if (self:isRightFormation()) then
        self.m_attackPosOffsetX = -self.m_attackPosOffsetX
    end
end

-------------------------------------
-- function getAttackPosition
-- @brief 캐릭터의 애니메이션상 공격 시작 위치의 offset을 가져온다.
-------------------------------------
function Skill:getAttackPosition()
    return self.m_attackPosOffsetX, self.m_attackPosOffsetY
end

-------------------------------------
-- function getAttackPositionAtWorld
-- @brief 캐릭터의 애니메이션상 공격 시작 위치의 월드좌표를 가져온다.
-------------------------------------
function Skill:getAttackPositionAtWorld()
	local pos_x = self.m_owner.pos.x + self.m_attackPosOffsetX
	local pos_y = self.m_owner.pos.y + self.m_attackPosOffsetY
    return pos_x, pos_y
end

-------------------------------------
-- function getStatusEffectListByStartCondition
-- @brief 시작 조건에 해당하는 status effect 리스트를 얻음
-- @param l_start_con : 시작 조건을 지칭하는 스트링값 리스트 ex) { 'skill_action', 'hit' }
-------------------------------------
function Skill:getStatusEffectListByStartCondition(l_start_con)
    local l_status_effect = {}
    
	for _, start_con in ipairs(l_start_con) do
		local l_ret = self:getStatusEffectList(start_con)
		table.merge(l_status_effect, l_ret)
    end

    return l_status_effect
end

-------------------------------------
-- function getStatusEffectList
-------------------------------------
function Skill:getStatusEffectList(start_con)
	local l_status_effect = {}
	for i, struct_status_effect in ipairs(self.m_lStatusEffect) do
		if (struct_status_effect.m_trigger == start_con) then
			table.insert(l_status_effect, struct_status_effect)
		end
	end

	return l_status_effect
end

-------------------------------------
-- function removeDestructibleMissile
-- @brief 월드의 처리 가능한 미사일을 없앤다
-------------------------------------
function Skill:removeDestructibleMissile()
	if (self.m_chanceType == 'active') and (self.m_owner:getCharType() == 'dragon') then 
		local x = self.m_targetPos.x
		local y = self.m_targetPos.y
		local range = 300
		for i, v in pairs(self.m_world.m_lSpecailMissileList) do
			if isCollision(v, x, y, range) then 
				v:release()
			end
		end
	end
end

-------------------------------------
-- function makeEffect
-- @breif 대상에게 생성되는 추가 이펙트 생성
-------------------------------------
function Skill:makeEffect(res, x, y, ani_name, cb_function, attr)
    local effect
    if (attr) then
        effect = SkillHelper:makeEffect_withAttrAni(self.m_world, res, x, y, ani_name, cb_function, attr)
    else
        effect = SkillHelper:makeEffect(self.m_world, res, x, y, ani_name, cb_function)
    end
	return effect
end

-------------------------------------
-- function release
-- @brief
-------------------------------------
function Skill:release()
    if self.m_skillHitEffctDirector then
        self.m_skillHitEffctDirector:onEnd()
        self.m_skillHitEffctDirector = nil
    end

	if self.m_world then
		self.m_world.m_lSkillList[self] = nil
	end

	-- 이벤트 해제
	self:release_EventDispatcher()
    self:release_EventListener()

	PARENT.release(self)
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function Skill:setTemporaryPause(pause)
    if (PARENT.setTemporaryPause(self, pause)) then
        if (pause) then
            if (self.m_animator) then
                self.m_dataForTemporaryPause = self.m_animator:isVisible()
                self.m_animator:setVisible(false)
            end
        else
            if (self.m_animator) then
                if (self.m_dataForTemporaryPause ~= nil) then
                    self.m_animator:setVisible(self.m_dataForTemporaryPause)
                    self.m_dataForTemporaryPause = nil
                else
                    self.m_animator:setVisible(true)
                end
            end
        end
        
        return true
    end

    return false
end

-------------------------------------
-- function makeMissile
-------------------------------------
function Skill:makeMissile(t_option)
    self.m_bUseMissile = true

    -- t_option 테이블을 반복적으로 사용하는 경우 참조로 인한 문제 해결을 위한 처리
    local prev_body_size

    -- 인디케이터로부터 충돌 정보를 받은 경우
    if (self.m_lTargetCollision and not t_option['bFixedAttack']) then
        t_option['bFixedAttack'] = true

        if (not t_option['collision_list']) then
            t_option['collision_list'] = self.m_lTargetCollision
        end

        -- body 크기를 일괄적으로 키운다
        if (t_option['physics_body']) then
            local body_size = t_option['physics_body'][3]
            prev_body_size = body_size

            t_option['physics_body'][3] = body_size * 1.25
        end
    end

    -- 발사
    local missile = self.m_world.m_missileFactory:makeMissile(t_option)

    if (prev_body_size) then
        t_option['physics_body'][3] = prev_body_size
    end

	return missile
end

-------------------------------------
-- function isRightFormation
-------------------------------------
function Skill:isRightFormation()
    if (not self.m_owner) then return end

    return (self.m_owner.m_bLeftFormation == false)
end

-------------------------------------
-- function makeSkillInstance
-- @brief 사용할 변수 정리 및 실제 스킬 인스턴스를 생성하고 월드에 등록하는 부분
-------------------------------------
function Skill:makeSkillInstance()
end

-------------------------------------
-- function setTargetChar
-------------------------------------
function Skill:setTargetChar(char)
	self.m_targetChar = char
end

-------------------------------------
-- function setTargetPos
-------------------------------------
function Skill:setTargetPos(_x, _y)
    self.m_targetPos = {x = _x, y = _y}
end

-------------------------------------
-- function hasSkillScaleEffect
-------------------------------------
function Skill:hasSkillScaleEffect(l_StatusEffect)
    if (not l_StatusEffect) then return false end

    for i, v in pairs(l_StatusEffect) do
        if (v.m_type == 'res_scale_up') then
            return true
        end
    end

    return false
end