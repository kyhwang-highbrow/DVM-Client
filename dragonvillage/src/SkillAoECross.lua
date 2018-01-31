local PARENT = class(Skill, ISkillMultiAttack:getCloneTable())

-------------------------------------
-- class SkillAoECross
-------------------------------------
SkillAoECross = class(PARENT, {
		m_aoeRes = 'str', 
        m_aoeResDelay = 'num',
        m_multiAttackEffectFlag = 'bool',
        m_lTarget = 'table',
        m_lCollision = 'table',

        m_lineSize = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoECross:init(file_name, body, ...)    
    self.m_multiAttackEffectFlag = true
    self.m_lTarget = {}
    self.m_lCollision= {}
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoECross:init_skill(aoe_res, attack_count, aoe_res_predelay)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_maxAttackCount = attack_count 
	self.m_aoeRes = aoe_res
    self.m_aoeResDelay = aoe_res_predelay or 0
	--self.m_hitInterval -> attack state에서 지정
	
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoECross:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('cross', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_lineSize = t_data['size']
	else
        self.m_resScale = 1
        self.m_lineSize = g_constant:get('SKILL', 'CROSS_SIZE')
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoECross:initState()
	self:setCommonState(self)
    self:addState('start', PARENT.st_appear, 'appear', false)
    self:addState('attack', SkillAoECross.st_attack, 'idle', true)
	self:addState('disappear', PARENT.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillAoECross.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:enterAttack()
        owner.m_lTarget, owner.m_lCollision = owner:findTarget()
    end

    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt

    if (owner.m_multiAttackEffectFlag) then
        if (owner.m_attackCount < owner.m_maxAttackCount) then

            -- 타겟별 리소스
            for _, collision in ipairs(owner.m_lCollision) do
	            owner:makeEffect(owner.m_aoeRes, collision:getPosX(), collision:getPosY())
            end
            
            owner.m_multiAttackEffectFlag = false
        end
    end

	if (owner.m_multiAtkTimer >= owner.m_aoeResDelay and owner.m_multiAtkTimer >= owner.m_hitInterval) then
		-- 공격 횟수 초과시 탈출
		if (owner.m_attackCount >= owner.m_maxAttackCount) then
			owner:escapeAttack()
		else
			owner:runAttack(owner.m_lCollision)
            owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
			owner.m_attackCount = owner.m_attackCount + 1
            owner.m_multiAttackEffectFlag = true
		end
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoECross:runAttack(l_collision)

    for _, collision in ipairs(l_collision) do
        self:attack(collision)
    end

	self:doCommonAttackEffect()
end

-------------------------------------
-- function setAttackInterval
-- @brief 스킬에 따라 오버라이딩 해서 사용
-------------------------------------
function SkillAoECross:setAttackInterval()
	local duration = 0
    
    if (self.m_animator) then
        duration = self.m_animator:getDuration()
    end

	-- 이펙트 재생 단위 시간
    if (duration == 0) then
        self.m_hitInterval = 1 / self.m_maxAttackCount
    else
	    self.m_hitInterval = duration / self.m_maxAttackCount
    end
end

-------------------------------------
-- function enterAttack
-------------------------------------
function SkillAoECross:enterAttack()
	-- 이펙트 재생 단위 시간
	self:setAttackInterval()
	-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
	self.m_multiAtkTimer = self.m_hitInterval
	-- 공격 카운트 초기화
	self.m_attackCount = 0
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoECross:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillAoECross:findCollision()
    local target_x = self.m_targetPos.x
	local target_y = self.m_targetPos.y

	local l_target
    if (x == self.m_targetPos['x'] and y == self.m_targetPos['y']) then
        l_target = self:getProperTargetList()
    else
        l_target = self.m_owner:getTargetListByType(self.m_targetType, nil, self.m_targetFormation)    
    end
    	
    local std_width = CRITERIA_RESOLUTION_X
	local std_height = CRITERIA_RESOLUTION_Y
	
	local collisions1 = self:findCollisionEachLine(l_target, target_x, target_y, 0, std_height, 1)
    local collisions2 = self:findCollisionEachLine(l_target, target_x, target_y, std_width, 0, 2)
    
	-- 하나의 리스트로 merge
    local l_ret = mergeCollisionLists({
        collisions1,
        collisions2
    })
    
    -- 거리순으로 정렬(필요할 경우)
    table.sort(l_ret, function(a, b)
        return (a:getDistance() < b:getDistance())
    end)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)
	
	return l_ret
end

-------------------------------------
-- function findCollisionEachLine
-------------------------------------
function SkillAoECross:findCollisionEachLine(l_target, target_x, target_y, std_width, std_height, idx)
	local start_x = target_x - std_width
	local start_y = target_y - (std_height * (math_pow(-1, idx)))
		
	local end_x = target_x + std_width
	local end_y = target_y + (std_height * (math_pow(-1, idx)))

	return SkillTargetFinder:findCollision_Bar(l_target, start_x, start_y, end_x, end_y, self.m_lineSize/2)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoECross:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
	local aoe_res_predelay = tonumber(t_skill['val_1']) or 0

	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스
	local aoe_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)		-- 개별 타겟 이펙트 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoECross(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(aoe_res, attack_count, aoe_res_predelay)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end