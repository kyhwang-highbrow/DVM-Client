local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillRay
-------------------------------------
SkillRay = class(PARENT, {

        m_linkEffect = '',  -- 레이저의 그래픽 리소스
        m_laserLength = '',
        m_laserDir = '',

        m_laserTimer = '',
        m_limitTime = '',

        m_multiHitTime = '',
        m_multiHitTimer = '',

        m_clearCount = '',
        m_maxClearCount = '',

        m_startPosX = '',
        m_startPosY = '',
        m_endPosX = '',
        m_endPosY = '',

        m_physGroup = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillRay:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillRay:init_skill(missile_res, hit)
	PARENT.init_skill(self)

    local file_name = missile_res
    local start_ani = 'start_appear'
    local link_ani = 'bar_appear'
    local end_ani = 'end_appear'
    self.m_linkEffect = EffectLink(file_name, link_ani, start_ani, end_ani, 200, 200)
    self.m_linkEffect.m_bRotateEndEffect = false

    self.m_laserLength = 800
    self.m_laserDir = 180

    self.m_limitTime = 3

    self.m_multiHitTime = 1
    self.m_multiHitTimer = 0

    self.m_clearCount = 0
    self.m_maxClearCount = 0

    self.m_startPosX = 0
    self.m_startPosY = 0
    self.m_endPosX = 0
    self.m_endPosY = 0

	self.m_physGroup = self.m_owner:getAttackPhysGroup()

    -- 저사양모드 ignore
    self.m_linkEffect:setIgnoreLowEndMode(true)

    -- 에니메이션 변경
    self.m_linkEffect:registCommonAppearAniHandler()
    
	self.m_rootNode:addChild(self.m_linkEffect.m_node)

	-- 쿨타임 지정
    self.m_limitTime = self.m_owner.m_statusCalc.m_attackTick

    local hit = math_max(hit, 1)
    self.m_multiHitTime = self.m_limitTime / hit

    self.m_maxClearCount = hit - 1

    if is_hero then
        self.m_endPosX = self.m_startPosX + 2560
    else
        self.m_endPosX = self.m_startPosX - 2560
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillRay:initState()
	self:setCommonState(self)
    self:addState('start', SkillRay.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillRay.st_idle(owner, dt)
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount ) then

        owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime

        owner.m_clearCount = owner.m_clearCount + 1
    end

    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
        owner:changeState('dying')
        return
    end


    if ((not owner.m_targetChar) or owner.m_targetChar.m_bDead) then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function SkillRay:refresh()
    local change_start = false
    if self.m_owner then
        if (self.m_owner.pos.x ~= self.m_startPosX) or (self.m_owner.pos.y ~= self.m_startPosY) then
            change_start = true
            self.m_startPosX = self.m_owner.pos.x + self.m_attackPosOffsetX
            self.m_startPosY = self.m_owner.pos.y + self.m_attackPosOffsetY
            self:setPosition(self.m_startPosX, self.m_startPosY)
        end
    end

    local change_end = false
    if self.m_targetChar then
        if (self.m_targetChar.pos.x ~= self.m_endPosX) or (self.m_targetChar.pos.y ~= self.m_endPosY) then
            change_end = true
            self.m_endPosX = self.m_targetChar.pos.x
            self.m_endPosY = self.m_targetChar.pos.y
        end
    end

    if change_start or change_end then
        local dir = getDegree(self.m_startPosX, self.m_startPosY, self.m_endPosX, self.m_endPosY)
        local dist = getDistance(self.m_startPosX, self.m_startPosY, self.m_endPosX, self.m_endPosY)
        local pos = getPointFromAngleAndDistance(dir, dist)


        -- 레이저에 충돌된 모든 객체 리턴
        local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(self.m_startPosX, self.m_startPosY,
            self.m_endPosX, self.m_endPosY, 25, self.m_physGroup)

        -- 가장 가까이 위치한 충돌체의 거리까지만 레이저 출력
        if (not self:checkCollision()) then
            EffectLink_refresh(self.m_linkEffect, 0, 0, pos['x'], pos['y'])
        end
    else
        self:checkCollision()
    end
end

-------------------------------------
-- function checkCollision
-------------------------------------
function SkillRay:checkCollision()
    -- 레이저에 충돌된 모든 객체 리턴
    local t_collision_obj = self.m_world.m_physWorld:getLaserCollision(self.m_startPosX, self.m_startPosY,
        self.m_endPosX, self.m_endPosY, 10, self.m_physGroup)

    -- 가장 가까이 위치한 충돌체의 거리까지만 레이저 출력
    if t_collision_obj[1] then
        local first_obj = t_collision_obj[1]
        local x = math_clamp2(first_obj['x'], self.m_startPosX, self.m_endPosX)
        local y = math_clamp2(first_obj['y'], self.m_startPosY, self.m_endPosY)

        x = x - self.pos.x
        y = y - self.pos.y

        EffectLink_refresh(self.m_linkEffect, 0, 0, x, y)

        self:collisionAttack(first_obj['obj'])

        return true
    end
    return false
end

-------------------------------------
-- function collisionAttack
-------------------------------------
function SkillRay:collisionAttack(target_char)
    if (not self.t_collision) then
        return
    end

    if (not self.t_collision[target_char.phys_idx]) then
        self.t_collision[target_char.phys_idx] = true

        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
    end
    
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillRay:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local hit = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillRay(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end