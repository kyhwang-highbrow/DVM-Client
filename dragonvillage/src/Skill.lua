local PARENT = Entity

-------------------------------------
-- class Skill
-------------------------------------
Skill = class(PARENT, {
        m_owner = 'Character',
        m_activityCarrier = 'ActivityCarrier',
		m_range = 'num',
		m_powerRate = 'num',
		m_powerAbs = 'num',
		m_powerSource = 'str',
		m_preDelay = 'num',
		m_resScale = 'str',

		m_rangeEffect = 'a2d',

		-- 타겟 관련 .. 
		m_targetChar = 'Character', 
		m_targetType = 'str', -- 타겟 선택하는 룰
		m_targetPos = 'pos', -- 타겟 위치 정보 빠르게 접근하기 위해..~
		
		-- 상태 효과 관련 변수들
		m_lStatusEffectStr = '',

		-- 스킬 타입 명 ex) skill_expolosion 
		m_skillName = 'str',
		m_skillType = 'str', 

		-- 캐릭터의 중심을 기준으로 실제 공격이 시작되는 offset
        m_attackPosOffsetX = 'number',
        m_attackPosOffsetY = 'number',

		-- 스킬 연출 관리자 - 디렉터
		m_skillHitEffctDirector = 'SkillHitEffectDirector',
		m_bSkillHitEffect = 'bool', -- 사용 여부
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Skill:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-- @brief actvityCarrier, AttackOffset, defualt target, default target pos를 설정한다. 
-------------------------------------
function Skill:init_skill()
	self:initActvityCarrier(self.m_powerRate, self.m_powerAbs)
	self:initAttackPosOffset()
	self:adjustAnimator()

	self.m_skillHitEffctDirector = SkillHitEffectDirector(self.m_owner)
	
	if (not self.m_targetChar) then
		self.m_targetChar = self:getDefaultTarget()
	end
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
    self.m_activityCarrier.m_skillCoefficient = (self.m_powerRate / 100)
    self.m_activityCarrier.m_skillAddAtk = power_abs or 0
end

-------------------------------------
-- function adjustAnimator
-- @breif animator 조정하는 부분
-------------------------------------
function Skill:adjustAnimator()    
	if (not self.m_animator) then return end

	-- res_scale 의 경우 ;가 있으면 x,y 각각 개별로 들어간다...
	if string.find(self.m_resScale, ';') then
		local l_scale = stringSplit(self.m_resScale, ';')
		self.m_animator.m_node:setScaleX(l_scale[1])
		self.m_animator.m_node:setScaleY(l_scale[2])
	else
 		self.m_animator:setScale(self.m_resScale)
	end
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
	self.m_powerRate = t_skill['power_rate']
    self.m_powerAbs = t_skill['power_add'] or 0
	self.m_powerSource  = t_skill['power_source'] or 'atk'
	self.m_targetType = t_skill['target_type']
	self.m_preDelay = t_skill['pre_delay'] or 0
	self.m_resScale = t_skill['res_scale'] or 1
	self.m_lStatusEffectStr = {t_skill['status_effect_1'], t_skill['status_effect_2']}
	self.m_skillType = t_skill['chance_type']
	self.m_skillName = t_skill['type']
	self.m_targetPos = {x = t_data.x, y = t_data.y}
	self.m_targetChar = t_data.target or self.m_targetChar
	self.m_bSkillHitEffect = true
end

-------------------------------------
-- function st_delay
-------------------------------------
function Skill.st_delay(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:setVisible(false) 
		if (not owner.m_targetChar) then 
			owner:printTargetIsNotExist()
			owner:changeState('dying') 
		end
	elseif (owner.m_stateTimer > owner.m_preDelay) then
		owner.m_animator:setVisible(true) 
		owner:changeState('start')
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Skill.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_owner:restore()
		return true
    end
end

-------------------------------------
-- function runAttack
-- @brief findtarget으로 찾은 적에게 공격을 실행한다. 
-------------------------------------
function Skill:runAttack(bNoStatusEffect)
	local t_target = self:findTarget()
    for i,target_char in ipairs(t_target) do
		self:attack(target_char)
    end
	
	-- 스킬이 제거할 수 있는 미사일 제거
	self:removeDestructibleMissile()

	-- 상태효과
	if not bNoStatusEffect then
		StatusEffectHelper:doStatusEffectByStr(self.m_owner, t_target, self.m_lStatusEffectStr)
	end
end

-------------------------------------
-- function attack
-- @brief 공격 콜백을 실행시키고 hit 연출을 조작한다. 되도록 재정의 하지 않는다. 공격의 최소단위
-------------------------------------
function Skill:attack(target_char)
    -- 공격
    self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
    target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)

	-- 연출
	if (self.m_bSkillHitEffect) then 
		self.m_skillHitEffctDirector:doWork()
	end
end

-------------------------------------
-- function findTarget
-- @brief 모든 공격 대상 찾음
-- @default 직선거리에서 범위를 기준으로 충돌여부 판단
-------------------------------------
function Skill:findTarget(x, y, range)
	local x = x or self.m_targetPos.x
	local y = y or self.m_targetPos.y
	local range = range or self.m_range

    local world = self.m_world
	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'distance_line')
    
	local l_ret = {}
    local distance = 0

    for _, target in pairs(l_target) do
		-- 바디사이즈를 감안한 충돌 체크
		if isCollision(x, y, target, range) then 
			table.insert(l_ret, target)
		end
    end
    
    return l_ret
end

-------------------------------------
-- function getDefaultTarget
-- @brief 디폴트 타겟을 반환한다.
-- @brief 인디케이터 없이 시전 된 경우 사용된다.
-- @default 타겟 룰에 따른 타겟 리스트 중 첫번째를 선택
-------------------------------------
function Skill:getDefaultTarget()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
	local target = nil

	for i, v in pairs(l_target) do
		-- @TODO 추가된 캐릭터 일단 제외 
		if (not v.m_isSlaveCharacter) then 
			target = v
			break
		end
	end

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
    
    local l_event_data = animator:getEventList('attack', 'attack')

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
-- function removeDestructibleMissile
-- @brief 월드의 처리 가능한 미사일을 없앤다
-------------------------------------
function Skill:removeDestructibleMissile()
	if (self.m_skillType == 'active') and (self.m_owner:getCharType() == 'dragon') then 
		local x = self.m_targetPos.x
		local y = self.m_targetPos.y
		local range = 300
		for i, v in pairs(self.m_world.m_lSpecailMissileList) do
			if isCollision(x, y, v, range) then 
				v:release()
			end
		end
	end
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
-- function release
-- @brief
-------------------------------------
function Skill:release()
    if self.m_skillHitEffctDirector then
        self.m_skillHitEffctDirector:onEnd()
    end

	if self.m_world then
		self.m_world.m_lSkillList[self] = nil
	end

	PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-- @brief 사용할 변수 정리 및 실제 스킬 인스턴스를 생성하고 월드에 등록하는 부분
-------------------------------------
function Skill:makeSkillInstance()
end






-------------------------------------
-- function printTargetIsNotExist
-- @brief
-------------------------------------
function Skill:printTargetIsNotExist()
	cclog('###########################################')
	cclog('-- 타겟을 못 찾았습니다')
	cclog('STATE NAME : ' .. self.m_state)
	cclog('SKILL CASTER : ' ..  self.m_owner:getName())
	cclog('SKILL TYPE : ' ..  self.m_skillName)
	cclog('-------------------------------------------')
end