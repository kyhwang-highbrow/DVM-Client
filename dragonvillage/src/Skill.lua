local PARENT = class(Entity, IEventListener:getCloneTable(), IEventDispatcher:getCloneTable())

-------------------------------------
-- class Skill
-------------------------------------
Skill = class(PARENT, {
        m_owner = 'Character',
        m_activityCarrier = 'ActivityCarrier',

		m_skillName = 'str',  -- 스킬 타입 명 ex) skill_expolosion 
		m_chanceType = 'str',  -- 스킬 종류.. active or basic etc.

		m_powerRate = 'num',
		m_powerAbs = 'num',
		m_powerSource = 'str',
		m_powerIgnore = 'str',		-- 피격대상 특정 스탯 무시 
		m_preDelay = 'num',

		m_skillSize = 'str',
		m_resScale = 'str',
		m_rangeEffect = 'a2d',
		m_range = 'num',

		-- 타겟 관련 .. 
		m_targetFormation = 'str',
		m_targetType = 'str', -- 타겟 선택하는 룰
		m_targetLimit = 'num', -- 선택할 타겟의 최대 수
		m_targetChar = 'Character', 
		m_targetPos = 'pos', -- 인디케이터에서 보낸 x, y 좌표
		
		-- 상태 효과 관련 변수들
		m_lStatusEffect = 'List<StructStatusEffect>',
		m_tSpecialTarget = '', -- 임시 처리

		-- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',

		-- 스킬 연출 관리자 - 디렉터
		m_skillHitEffctDirector = 'SkillHitEffectDirector',
		m_bSkillHitEffect = 'bool', -- 사용 여부
        m_bHighlight = 'bool',  -- 하이라이트 여부

        -- 스킬 종료시 피드백(보너스) 관련
        m_bonusLevel = 'number',

        -- 하이라이트시 숨김 처리
        m_dataForTemporaryPause = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Skill:init(file_name, body, ...)
    self.m_dataForTemporaryPause = nil
end

-------------------------------------
-- function init_skill
-- @brief actvityCarrier, AttackOffset, defualt target, default target pos를 설정한다. 
-------------------------------------
function Skill:init_skill()
	-- 멤버 변수 
	self.m_range = 0    
	self.m_tSpecialTarget = {}

	-- 세부 초기화 함수 실행
	self:initActvityCarrier(self.m_powerRate, self.m_powerAbs)
    self:initAttackPosOffset()
	self:initSkillSize()
	self:initEventListener()
	self:adjustAnimator()
	
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
function Skill:initActvityCarrier(power_rate, power_abs)
    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
	self.m_activityCarrier:setAtkDmgStat(self.m_powerSource)
	self.m_activityCarrier:setAttackType(self.m_chanceType)
    self.m_activityCarrier:setPowerRate(self.m_powerRate)
    self.m_activityCarrier:setAbsAttack(power_abs)
	
	-- 방어 무시 -> 차후에 좀더 구조화 해서 늘려나감
	if (self.m_powerIgnore == 'def') then 
		self.m_activityCarrier:setIgnoreDef(true)
	end

    -- 피격시 하일라이트 여부
    self.m_activityCarrier:setHighlight(self.m_bHighlight)
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
	-- 스킬 생명 주기 내의 이벤트
	self:addListener(CON_SKILL_START, self)
	self:addListener(CON_SKILL_HIT, self)
	self:addListener(CON_SKILL_END, self)

	-- 스킬 외부에서의 이벤트
	--self.m_owner:addListener('hit', self)
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
	if (self.m_resScale) and (not (self.m_resScale == '')) then
		-- res_scale 의 경우 ;가 있으면 x,y 각각 개별로 들어간다...
		if string.find(self.m_resScale, ';') then
			local l_scale = stringSplit(self.m_resScale, ';')
			self.m_animator.m_node:setScaleX(tonumber(l_scale[1]))
			self.m_animator.m_node:setScaleY(tonumber(l_scale[2]))
		else
 			self.m_animator:setScale(self.m_resScale)
		end
	end
end

-------------------------------------
-- function update
-------------------------------------
function Skill:update(dt)
    -- 스킬 멈춤 여부 체크
    if (isInstanceOf(self, IStateDelegate)) then
        if (self.m_state ~= 'dying') then
	        if (self.m_owner:checkToStopSkill()) then
                self:changeState('dying')
            end
        end
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function setCommonState
-- @breif state 정의
-- @breif 모든 스킬은 delay로 시작하고 start로 본래의 스킬 state를 진행한다.
-------------------------------------
function Skill:setCommonState(skill)
	skill:addState('delay', Skill.st_delay, nil, false)
    skill:addState('dying', Skill.st_dying, nil, nil, 10)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function Skill:setSkillParams(owner, t_skill, t_data)
	self.m_owner = owner
    self.m_world = owner.m_world
	
	self.m_powerRate = SkillHelper:getValid(t_skill['power_rate'], 0)
    self.m_powerAbs = SkillHelper:getValid(t_skill['power_add'], 0)
	self.m_powerSource  = SkillHelper:getValid(t_skill['power_source'], 'atk')
	self.m_powerIgnore = SkillHelper:getValid(t_skill['ignore'])
	self.m_lStatusEffect = SkillHelper:makeStructStatusEffectList(t_skill)
	
	self.m_preDelay = SkillHelper:getValid(t_skill['pre_delay'], 0)
	self.m_resScale = SkillHelper:getValid(t_skill['res_scale'])
	self.m_skillSize = SkillHelper:getValid(t_skill['skill_size'])

	self.m_skillName = t_skill['skill_type']
	self.m_chanceType = t_skill['chance_type']
	
	self.m_targetPos = {x = t_data.x, y = t_data.y}
	self.m_targetChar = t_data.target or self.m_targetChar
	self.m_targetType = SkillHelper:getValid(t_skill['target_type'])
	self.m_targetLimit = SkillHelper:getValid(t_skill['target_count'])
	self.m_targetFormation = SkillHelper:getValid(t_skill['target_formation'])

	self.m_bSkillHitEffect = owner.m_bLeftFormation and (t_skill['chance_type'] == 'active')
    self.m_bHighlight = t_data['highlight'] or false
    self.m_bonusLevel = 0
    
    if (t_data['score']) then
        self.m_bonusLevel = SkillHelper:getDragonActiveSkillBonusLevel(t_skill, t_data['score'])
    end


    -- 생성
    if self.m_bSkillHitEffect then
        local bonus_desc = nil
        if (self.m_bonusLevel > 0) then
            bonus_desc = SkillHelper:getDragonActiveSkillBonusDesc(self.m_owner)
        end

        self.m_skillHitEffctDirector = SkillHitEffectDirector(self.m_owner, bonus_desc)
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
		owner.m_animator:setVisible(true) 
		owner:changeState('start')

        -- 스킬 사용시 발동되는 status effect를 적용
		owner:dispatch(CON_SKILL_START)
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Skill.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:onDying()

        owner.m_owner:restore()
		
		if (owner.m_rangeEffect) then
			owner.m_rangeEffect:changeAni('disapper', false)
		end

        -- 스킬 종료시 발동되는 status effect를 적용
		owner:dispatch(CON_SKILL_END)

        -- 보너스 버프 효과 부여
        if (owner.m_bonusLevel > 0) then
            -- 효과 적용
            SkillHelper:invokeDragonActiveSkillBonus(owner.m_owner, owner.m_bonusLevel)
        end
        
		return true
    end
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
	self:doStatusEffect(event_name, t_event['l_target'])
end

-------------------------------------
-- function doStatusEffect
-- @brief l_start_con 조건에 해당하는 statusEffect를 적용
-------------------------------------
function Skill:doStatusEffect(start_con, t_target)
    local lStatusEffect = self:getStatusEffectList(start_con)

    if (#lStatusEffect > 0) then
        local l_ret = nil
		if (#self.m_tSpecialTarget > 0) then 
			-- type이 target이고 해당 테이블에 대상이 담겨있을때 적용하게됨
			l_ret = self.m_tSpecialTarget
		else
			l_ret = t_target or self:findTarget()
		end
        StatusEffectHelper:doStatusEffectByStruct(self.m_owner, l_ret, lStatusEffect)
    end
end

-------------------------------------
-- function runAttack
-- @brief findtarget으로 찾은 적에게 공격을 실행한다. 
-------------------------------------
function Skill:runAttack()
	local l_target, l_bodys = self:findTarget()
    for i, target_char in ipairs(l_target) do
		self:attack(target_char, l_bodys[i])
    end

	self:doCommonAttackEffect(l_target)
end

-------------------------------------
-- function doCommonAttackEffect
-- @breif 어택 이벤트와 관련된 처리
-------------------------------------
function Skill:doCommonAttackEffect(l_target)
	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()
end

-------------------------------------
-- function attack
-- @brief 공격 콜백을 실행시키고 hit 연출을 조작한다. 되도록 재정의 하지 않는다. 공격의 최소단위
-------------------------------------
function Skill:attack(target_char, bodys)
    -- 공격
    self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)

    if (bodys) then
        for i, k in ipairs(bodys) do
            -- 데미지 함수 내부에서 body위치를 계산해야할까...
            local body = target_char:getBody(k)
            local x = target_char.pos.x + body.x
            local y = target_char.pos.y + body.y

            if (i == 1) then
                target_char:runDefCallback(self, x, y, k)
            else
                target_char:runDefCallback(self, x, y, k, true)
            end
        end
    else
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
    end

	self:onAttack(target_char)
end

-------------------------------------
-- function onAttack
-- @brief 공격(attack) 직후 호출됨, 스킬에서 미사일 날릴 때 콜백으로도 사용
-------------------------------------
function Skill:onAttack(target_char)
    -- 연출
	if (self.m_skillHitEffctDirector) then 
		self.m_skillHitEffctDirector:doWork(target_char)
	end

    -- 타격 카운트 갱신
    self:addHitCount()
	
	-- 상태효과
	local t_event = {l_target = {target_char}}
	self:dispatch(CON_SKILL_HIT, t_event)

    -- 화면 쉐이킹
    if (self.m_bHighlight) then
        if (self.m_chanceType == 'active') then
            self.m_world.m_shakeMgr:doShake(50, 50, 1)
        else
            self.m_world.m_shakeMgr:doShake(25, 25, 0.5)
        end
    end
end

-------------------------------------
-- function doSpecialEffect
-- @brief 로직화 할 수 없는 특수 효과들은 이함수를 통해서 실행 시키고 특정 상위 수준에서 실행한다
-------------------------------------
function Skill:doSpecialEffect()
end

-------------------------------------
-- function findTarget
-- @brief 모든 공격 대상 찾음
-- @default 직선거리에서 범위를 기준으로 충돌여부 판단
-------------------------------------
function Skill:findTarget()
    local l_target = self:getProperTargetList()
	local x = self.m_targetPos.x
	local y = self.m_targetPos.y
	local range = self.m_range

	return SkillTargetFinder:findTarget_AoERound(l_target, x, y, range)
end

-------------------------------------
-- function findTarget
-- @brief 타겟룰에 의해 적절한 타겟리스트 가져옴
-------------------------------------
function Skill:getProperTargetList()
	return self.m_owner:getTargetListByType(self.m_targetType, self.m_targetLimit, self.m_targetFormation)
end

-------------------------------------
-- function getDefaultTarget
-- @brief 디폴트 타겟을 반환한다.
-- @brief 인디케이터 없이 시전 된 경우 사용된다.
-- @default 타겟 룰에 따른 타겟 리스트 중 첫번째를 선택
-------------------------------------
function Skill:getDefaultTarget()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
	local target = l_target[1]

	if (not target) then
	    cclog('Skill : Can not find target')
    end

	return target
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

    if (animator.m_bFlip) then
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
-- @brief 캐릭터의 애니메이션상 공격 시작 위치의 offset을 가져온다.
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
function Skill:makeEffect(res, x, y, ani_name, cb_function)
	local effect = SkillHelper:makeEffect(self.m_world, res, x, y, ani_name, cb_function)
	return effect
end

-------------------------------------
-- function makeRangeEffect
-- @brief range effect를 생성한다.
-------------------------------------
function Skill:makeRangeEffect(res_path, range)
	-- 1. 생성
	local effect = MakeAnimator(res_path)
	effect:setScale(range/200)
	self.m_rootNode:addChild(effect.m_node)
	self.m_rangeEffect = effect

	-- 2. appear 후 idle 반복 재생
	effect:changeAni('appear', false)
	effect:addAniHandler(function()
		effect:changeAni('idle', true)
	end)
end

-------------------------------------
-- function addHitCount
-- @brief 타격 카운트를 증감
-------------------------------------
function Skill:addHitCount()
    -- 피격자의 이벤트 dispatch에서 타격 카운트를 추가하기 위해 activityCarrier에 저장
    local hit_count = self.m_activityCarrier:getFlag('hit_count') or 0
    hit_count = hit_count + 1
    self.m_activityCarrier:setFlag('hit_count', hit_count)
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
-- function makeSkillInstance
-- @brief 사용할 변수 정리 및 실제 스킬 인스턴스를 생성하고 월드에 등록하는 부분
-------------------------------------
function Skill:makeSkillInstance()
end