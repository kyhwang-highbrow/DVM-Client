local PARENT = SkillLeap

-------------------------------------
-- class SkillTamerArena
-------------------------------------
SkillTamerArena = class(PARENT, {
    m_effect = '',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillTamerArena:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillTamerArena:init_skill(res)
	PARENT.init_skill(self)

    -- 이펙트 생성
    if (not self.m_effect) then
        local animator = MakeAnimator(res)
        animator:changeAni('appear', false)
        animator:addAniHandler(function()
            animator:changeAni('idle', true)
        end)
        animator.m_node:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

        if (self:isRightFormation()) then
            animator:setFlip(true)
        end

        local missileNode = self.m_world:getMissileNode('bottom')
        missileNode:addChild(animator.m_node)

        self.m_effect = animator
    end
	
    -- 목표 좌표 설정
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    if (self:isRightFormation()) then
        self.m_targetPos = { x = 720 + cameraHomePosX, y = cameraHomePosY }
    else
        self.m_targetPos = { x = 560 + cameraHomePosX, y = cameraHomePosY }
    end

    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillTamerArena:initSkillSize()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillTamerArena:initState()
	self:setCommonState(self)
    self:addState('start', SkillTamerArena.st_move, nil, true)
    self:addState('attack', SkillTamerArena.st_attack, nil, false)
    self:addState('dying', SkillTamerArena.st_dying, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function SkillTamerArena:update(dt)
    -- 드래곤의 애니와 객체 위치 동기화
	if (self.m_state ~= 'dying') then 
		self.m_owner:syncAniAndPhys()
	end

    if (self.m_effect) then
        self.m_effect:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    end
	
    return Skill.update(self, dt)
end


-------------------------------------
-- function st_move
-------------------------------------
function SkillTamerArena.st_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 사용자 이동
        owner.m_owner:stopAllActions()
        owner.m_owner:resetMove()
        owner.m_owner.m_animator:changeAni('i_idle', true)

        local target_pos = cc.p(owner.m_targetPos.x, owner.m_targetPos.y)
        local action = cc.MoveTo:create(0.5, target_pos)
        local finich_cb = cc.CallFunc:create(function()
            owner:changeState('attack')
        end)

        owner.m_owner:runAction(cc.Sequence:create(action, finich_cb))
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillTamerArena.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 사용자 애니메이션
        owner.m_owner.m_animator:changeAni('i_summon', false)
        owner.m_owner.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)

		-- 공격
		owner:runAttack()

        -- 화면 쉐이킹
        owner.m_world.m_shakeMgr:doShake(50, 50, 1)
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function SkillTamerArena.st_dying(owner, dt)
    owner:onDying()

    if (owner.m_effect) then
        owner.m_effect:changeAni('disappear', false)
        
        local duration = owner.m_effect:getDuration()
        owner.m_effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

        owner.m_effect = nil
    end

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
-- function attack
-- @brief 공격 콜백을 실행시키고 hit 연출을 조작한다. 되도록 재정의 하지 않는다. 공격의 최소단위
-------------------------------------
function SkillTamerArena:attack(collision)
    local target_char = collision:getTarget()
    local body_key = collision:getBodyKey()
    local body = target_char:getBody(body_key)
    local x = target_char.pos.x + body.x
    local y = target_char.pos.y + body.y

    -- 공격
    --self:runAtkCallback(target_char, x, y, body_key)

    --target_char:runDefCallback(self, x, y, body_key)

	self:onAttack(target_char, collision)
end

-------------------------------------
-- function findCollision
-- @brief 모든 충돌 대상 찾음(Body 기준)
-------------------------------------
function SkillTamerArena:findCollision()
    local l_target = self:getProperTargetList()
    --cclog('SkillTamerArena:findCollision #l_target : ' .. #l_target)
	local x = self.m_targetPos.x
	local y = self.m_targetPos.y
	
    local l_ret = SkillTargetFinder:getCollisionFromTargetList(l_target, x, y, true)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

	return l_ret
end

-------------------------------------
-- function release
-------------------------------------
function SkillTamerArena:release()
    if (self.m_effect) then
        self.m_effect:changeAni('disappear', false)
        
        local duration = self.m_effect:getDuration()
        self.m_effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))

        self.m_effect = nil
    end

    PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillTamerArena:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillTamerArena(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(t_skill['res_1'])
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
