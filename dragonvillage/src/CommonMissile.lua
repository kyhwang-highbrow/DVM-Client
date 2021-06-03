local PARENT = class(Entity, ISkillSound:getCloneTable())

-------------------------------------
-- class CommonMissile
-- @brief 공용탄을 쏘기 위한 클래스, 일종의 간이 미사일런처 
-------------------------------------
CommonMissile = class(PARENT, {
		m_owner = 'Character',
		m_target = 'Charater',
        m_lTarget = 'table',

		m_missileRes = 'str',
		m_motionStreakRes = 'str',
		m_resScale = 'num',

		m_activityCarrier = 'AttackDamage',
        m_skillId = 'num',
		m_powerRate = 'num',
        m_addCriPowerRate = 'num',
        m_powerSource = '',
        m_powerIgnore = '', -- 피격대상 특정 스탯 무시(맵형태)
		m_chanceType = 'str',
		m_lStatusEffect = 'List<StructStatusEffect>',

		m_targetType = '', -- target_type 필드, 상대 선택 규칙
        m_attackPos = 'number', -- 캐릭터의 중심을 기준으로 실제 공격이 시작 지점

		m_missileOption = 'table',
		m_missileTimer = 'time',
		m_missileFireTerm = 'time',
		m_fireLimitTime = 'time',
		m_fireCnt = 'num',
		m_maxFireCnt = 'num',
		m_missileSpeed = 'num',

        m_ownerAnimation = 'string',    -- 해당 스킬 사용시 지정된 애니메이션
     })

-------------------------------------
-- function init
-------------------------------------
function CommonMissile:init(file_name, body)
end

-------------------------------------
-- function initCommonMissile
-------------------------------------
function CommonMissile:initCommonMissile(owner, t_skill, t_data)
    -- 변수 초기화
	self.m_owner = owner
    self.m_world = owner.m_world
	
	self.m_missileRes = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	self.m_motionStreakRes = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	self.m_lStatusEffect = SkillHelper:makeStructStatusEffectList(t_skill)
	self.m_resScale = SkillHelper:getValid(t_skill['res_scale'])


    -- 스킬 스케일을 시전자와 맞추기
    if (not isNullOrEmpty(self.m_resScale) and owner and owner.m_originScale and owner.m_originScale ~= owner.m_animator:getScale()) then
        local scale_rate = owner.m_animator:getScale() / owner.m_originScale
        self.m_resScale = self.m_resScale * scale_rate

    elseif (self.m_owner.m_reactingInfo['skill_scale']) then
        self.m_resScale = self.m_owner.m_reactingInfo['skill_scale']

    end


	self.m_missileSpeed = SkillHelper:getValid(t_skill['val_3'], 1000)

    self.m_skillId = t_skill['sid']
	self.m_powerRate = t_skill['power_rate']
    self.m_addCriPowerRate = t_skill['critical_damage_add']
    self.m_powerSource = t_skill['power_source']
    self.m_powerIgnore = t_data['ignore'] or {}

	self.m_chanceType = t_skill['chance_type']
	self.m_targetType = t_skill['target_type']
	self.m_maxFireCnt = t_skill['hit']
	self.m_fireCnt = 0
	self.m_fireLimitTime = g_constant:get('INGAME', 'FIRE_LIMIT_TIME')

	self.m_target, self.m_lTarget = self:getRandomTargetByRule()
	self.m_missileTimer = 0

    if (self.m_owner:getCharType() == 'dragon') then
        -- 드래곤의 경우 기본탄을 제외하고 attack 이벤트 위치값을 사용하지 않도록 함
        if (self.m_owner:getSkillID('basic') == self.m_skillId) then
            self.m_ownerAnimation = SkillHelper:getValid(t_skill['animation'], 'attack')
        else
            self.m_ownerAnimation = 'idle'
        end
    else
        self.m_ownerAnimation = SkillHelper:getValid(t_skill['animation'], 'attack')
    end

	self:initActvityCarrier()
	self:initState()
	self:initAttackPos()

	-- resource 체크 
	if (not self.m_missileRes) or (self.m_missileRes == '') then
		error('공통탄 .. ' ..  t_skill['skill_type'] .. ' .. 리소스 없음')
	end
	if (self.m_motionStreakRes == '') then 
		self.m_motionStreakRes = nil 
	end

    -- 사운드 설정
    if (t_skill) then
        self:initSkillSound(t_skill['sid'])
    end
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function CommonMissile:initActvityCarrier()    
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()

    self.m_activityCarrier:setSkillId(self.m_skillId)
    self.m_activityCarrier:setSkillHitCount(self.m_maxFireCnt)
    self.m_activityCarrier:setPowerRate(self.m_powerRate)
    self.m_activityCarrier:setAddCriPowerRate(self.m_addCriPowerRate)
    self.m_activityCarrier:setAtkDmgStat(self.m_powerSource)
	self.m_activityCarrier:setAttackType(self.m_chanceType)
    self.m_activityCarrier:insertStatusEffectRate(self.m_lStatusEffect)

    -- 스킬 발동 타입 별도로 저장(상태효과 등에 전송하기 위함)
    self.m_activityCarrier:setParam('chance_type', self.m_chanceType)

    -- 수식에서 사용하기 위한 값을 세팅
    EquationHelper:setEquationParamOnMapForSkill(self.m_activityCarrier.m_tParam, self)
    
    self.m_activityCarrier:setIgnoreByTable(self.m_powerIgnore)
end

-------------------------------------
-- function initState
-------------------------------------
function CommonMissile:initState()    
    self:addState('attack', CommonMissile.st_attack, nil, nil)
    self:addState('dying_wait', CommonMissile.st_dying_wait, nil, nil, 3)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 3)
end

-------------------------------------
-- function getRandomTargetByRule
-- @brief 테이블 target_type 에 따른 랜덤한 타겟 선택 
-------------------------------------
function CommonMissile:getRandomTargetByRule()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType, nil , nil, { skill_type = self.m_chanceType })
    local target = l_target[1]

	if (not target) then
	    cclog('Common Missile : Can not find target')
    end

    return target, l_target
end

-------------------------------------
-- function getDir
-------------------------------------
function CommonMissile:getDir(target)
	if (not self.m_target) then 
		return self:getDefaultDir() 
	end
	local target = target or self.m_target 
    local x, y = target:getCenterPos()
	return getDegree(self.m_attackPos.x, self.m_attackPos.y, x, y) or self:getDefaultDir()
end

-------------------------------------
-- function getDefaultDir
-- @brief 타겟을 못가져왔을 때 
-------------------------------------
function CommonMissile:getDefaultDir()
	cclog('-- 공용탄 타겟을 못찾아 기본 발사각 0 or 180 으로 발사합니다.')
    if self.m_owner.m_bLeftFormation then   
		return 0
    else                            
		return 180
    end
end

-------------------------------------
-- function initAttackPos
-- @brief 캐릭터의 중심을 기준으로 실제 공격이 시작 지점 설정
-------------------------------------
function CommonMissile:initAttackPos()
    -- 1. 초기화
	local pos_x = self.m_owner.pos.x
	local pos_y = self.m_owner.pos.y
	self.m_attackPos = {x = pos_x, y = pos_y}

	-- 2. attack event 가져옴
    local animator = self.m_owner.m_animator
    local l_event_data = animator:getEventList(self.m_ownerAnimation, 'attack')

	-- 2-1. attack event 못가져오면 탈출
    if (not l_event_data[1]) then
        return
    end

	-- 3. 부여된 값 가져옴
    local string_value = l_event_data[1]['stringValue']

	-- 3-1. 못가져오면 탈출
    if (not string_value) or (string_value == '') then
        return
    end

	-- 4. 정리
    local l_str = seperate(string_value, ',') or {0, 0}
    local scale = animator:getScale()
    local offset_x = (l_str[1] * scale)
    local offset_y = (l_str[2] * scale)

	-- 5. offset 진영에 따라 가감
	if self.m_owner.m_bLeftFormation then   
		pos_x = pos_x + offset_x
		pos_y = pos_y + offset_y
    else                            
		pos_x = pos_x - offset_x
		pos_y = pos_y + offset_y
    end

	-- 6. 조정된 값 저장
	self.m_attackPos = {x = pos_x, y = pos_y}
end
-------------------------------------
-- function setMissile
-------------------------------------
function CommonMissile:setMissile()
	error('KMS - 공용탄은 자식클래스에서 탄을 정의합니다.')
end

-------------------------------------
-- function fireMissile
-------------------------------------
function CommonMissile:fireMissile()
	if (not self.m_target) then return end

    local world = self.m_world
	local t_option = self.m_missileOption
	
	-- 같은 시점에서의 반복 공격
	for i = 1, t_option['count'] do
		world.m_missileFactory:makeMissile(t_option)
		t_option['dir'] = t_option['dir'] + t_option['dir_add']
	end
end

-------------------------------------
-- function update
-------------------------------------
function CommonMissile:update(dt)
    PARENT.update(self, dt)

    -- 사운드 업데이트
    self:updateSkillSound(dt)
end

-------------------------------------
-- function st_attack
-------------------------------------
function CommonMissile.st_attack(owner, dt)
	-- 1. missile timer 따로 계산
	owner.m_missileTimer = owner.m_missileTimer + dt
    
	-- 2. state 시작시 처리 작업
	if (owner.m_stateTimer == 0) then
		-- 1일 경우 바로 발사후 종료
		if (owner.m_maxFireCnt == 1) then
			owner:fireMissile()

		-- 값이 있을 경우 기준 시간을 나눠서 간격을 구한다.
		elseif (owner.m_maxFireCnt) then 
			owner.m_missileFireTerm = owner.m_fireLimitTime / owner.m_maxFireCnt
			owner.m_missileTimer = owner.m_missileFireTerm
		end
	end

	-- 3. 발사 
	if (owner.m_missileFireTerm) then 
		if (owner.m_missileTimer >= owner.m_missileFireTerm) and (owner.m_maxFireCnt > owner.m_fireCnt) then
			owner:fireMissile()
			owner.m_missileTimer = owner.m_missileTimer - owner.m_missileFireTerm
			owner.m_fireCnt = owner.m_fireCnt + 1
		end
	end
	
	-- 4. 탈출 조건 : 기준 시간 경과 또는 발사수가 1
	if (owner.m_stateTimer >= owner.m_fireLimitTime) or (owner.m_maxFireCnt == 1) then 
		owner:changeState('dying_wait')
        return true
    end

    return false
end

-------------------------------------
-- function st_dying_wait
-------------------------------------
function CommonMissile.st_dying_wait(owner, dt)
    if (owner:isEndSkillSound()) then
        owner:changeState('dying', true)
    end
end

-------------------------------------
-- function makeMissileInstance
-------------------------------------
function CommonMissile:makeMissileInstance(owner, t_skill, t_data)
	local common_missile = CommonMissile()
	common_missile:initCommonMissile(owner, t_skill, t_data)
	common_missile:setMissile()

	owner.m_world:addToUnitList(common_missile)
    owner.m_world.m_worldNode:addChild(common_missile.m_rootNode)
end
