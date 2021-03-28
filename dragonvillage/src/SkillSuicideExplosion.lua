local PARENT = SkillLeap

-------------------------------------
-- class SkillSuicideExplosion
-------------------------------------
SkillSuicideExplosion = class(PARENT, {
		m_explosionRes = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSuicideExplosion:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillSuicideExplosion:init_skill(explosion_res, jump_res)
	PARENT.init_skill(self, jump_res)
	
	self.m_explosionRes = explosion_res

    local is_boss = string.find(self.m_targetType, 'boss')

    if (is_boss) then
        local l_target = self.m_owner:getTargetListByType('boss')

        local target
        if (l_target and #l_target > 0) then
            target = l_target[1]
            local pos_x, pos_y = target:getPosForFormation()
            self.m_targetPos =  { x = pos_x, y = pos_y }
        else
            self:setDefaultTargetPosition()
        end
    else
        self:setDefaultTargetPosition()
    end

    -- 사용자 무적 처리
    self.m_owner:setZombie(true)
end

-------------------------------------
-- function setDefaultTargetPosition
-------------------------------------
function SkillSuicideExplosion:setDefaultTargetPosition()
    -- 목표 좌표 설정
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    local is_atk_teammate = string.find(self.m_targetType, 'teammate')
    local left_target_pos = { x = 320 + cameraHomePosX, y = cameraHomePosY }
    local right_target_pos = { x = 960 + cameraHomePosX, y = cameraHomePosY }

    if (self:isRightFormation()) then
        self.m_targetPos = is_atk_teammate and right_target_pos or left_target_pos

    else
        self.m_targetPos = is_atk_teammate and left_target_pos or right_target_pos

    end
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillSuicideExplosion:initSkillSize()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSuicideExplosion:initState()
	self:setCommonState(self)
    self:addState('start', SkillSuicideExplosion.st_move, nil, true)
    self:addState('attack', SkillSuicideExplosion.st_attack, nil, false)
    self:addState('dying', SkillSuicideExplosion.st_dying, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function SkillSuicideExplosion:update(dt)
    -- 드래곤의 애니와 객체 위치 동기화
	if (self.m_state ~= 'dying') then 
		self.m_owner:syncAniAndPhys()
	end
	
    return Skill.update(self, dt)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillSuicideExplosion.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 공격
		owner:makeEffect(owner.m_explosionRes, owner.m_targetPos.x, owner.m_targetPos.y)
		owner:runAttack()
		owner.m_world.m_shakeMgr:shakeBySpeed(owner.movement_theta, 1500)
		owner:changeState('dying')
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function SkillSuicideExplosion.st_dying(owner, dt)
    owner:onDying()

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

    -- 사용자 죽임
    do
        owner.m_owner:setZombie(false)
        owner.m_owner:changeState('dying')
    end

    return true
end

-------------------------------------
-- function findCollision
-- @brief 모든 충돌 대상 찾음(Body 기준)
-------------------------------------
function SkillSuicideExplosion:findCollision()
    local l_target = self:getProperTargetList()
	local x = self.m_targetPos.x
	local y = self.m_targetPos.y
	
    local l_ret = SkillTargetFinder:getCollisionFromTargetList(l_target, x, y, true)

    -- 타겟 수 만큼만 얻어옴
    --l_ret = table.getPartList(l_ret, self.m_targetLimit)

	return l_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSuicideExplosion:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local explosion_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local jump_res = t_skill['res_2']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillSuicideExplosion(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(explosion_res, jump_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
