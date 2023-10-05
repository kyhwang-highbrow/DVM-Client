local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillLaser
-------------------------------------
SkillLaser = class(PARENT, {
        m_linkEffect = '',  -- 레이저의 그래픽 리소스
        m_laserDir = '',
        m_fireDistance = '', -- 드래곤과 발사 지점 사이의 거리 설정

        m_limitTime = '',

        m_multiHitTime = '',
        m_multiHitTimer = '',

        m_clearCount = '',
        m_maxClearCount = '',

        m_startPosX = '',
        m_startPosY = '',

        m_laserEndPosX = '',
        m_laserEndPosY = '',

        m_physGroup = '',

        m_laserThickness = 'number', -- 레이저 굵기
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser:init_skill(missile_res, hit, thickness)
	PARENT.init_skill(self)

    self.m_physGroup = self.m_owner:getMissilePhysGroup()

    local duration = (3 / 2)
    local hit = math_max(hit, 1)

	    -- 쿨타임 지정
    self.m_limitTime = duration
    self.m_multiHitTime = self.m_limitTime / hit
    self.m_multiHitTimer = 0
	
    self.m_clearCount = 0
	self.m_maxClearCount = hit
	
    self.m_laserDir = 180

    self.m_startPosX = 0
    self.m_startPosY = 0
	
    -- 레이저 링크 이펙트 생성
    self:makeLaserLinkEffect(missile_res)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillLaser:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('bar', self.m_skillSize)  

		self.m_resScale = 1 --t_data['scale']
		self.m_laserThickness = t_data['size']
	end
end

-------------------------------------
-- function makeLaserLinkEffect
-------------------------------------
function SkillLaser:makeLaserLinkEffect(file_name)
    local link_effect = EffectLink(file_name, nil, nil, nil, nil, nil, nil, self.m_owner:getAttribute(), self.m_fireDistance) 

    link_effect.m_bRotateEndEffect = false

    -- 저사양모드 ignore
    link_effect:setIgnoreLowEndMode(true)
    -- 'appear' -> 'idle' 에니메이션으로 자동 변경
    link_effect:registCommonAppearAniHandler()
	-- 이펙트 스케일 지정
	link_effect:setScale(self.m_resScale)

    self.m_rootNode:addChild(link_effect.m_node)
    self.m_linkEffect = link_effect
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser:initState()
	self:setCommonState(self)
    self:addState('start', SkillLaser.st_idle, 'idle', true)
    self:addState('disappear', SkillLaser.st_disappear, nil, true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLaser.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_owner.m_animator:changeAni('skill_disappear', false)
    end
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt
    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount) then
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1

        owner:runAttack()
    end

    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner:isDead() or (owner.m_clearCount >= owner.m_maxClearCount)) then
        owner:changeState('disappear')
        return
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillLaser.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:changeState('dying')
        end
		--owner.m_linkEffect:setVisible(false)
        owner.m_linkEffect:changeCommonAni('disappear', false, ani_handler)
    end
end


-------------------------------------
-- function refresh
-------------------------------------
function SkillLaser:refresh(force)
    local change_start = false
	
    if (self.m_owner) then
        if (self.m_owner.pos.x ~= self.m_startPosX) or (self.m_owner.pos.y ~= self.m_startPosY) then
            change_start = true
            self.m_startPosX = self.m_owner.pos.x + self.m_attackPosOffsetX
            self.m_startPosY = self.m_owner.pos.y + self.m_attackPosOffsetY
            self:setPosition(self.m_startPosX, self.m_startPosY)
        end
    end

    if (force or change_start) then
        local dir = getDegree(self.m_startPosX, self.m_startPosY, self.m_targetPos.x, self.m_targetPos.y)

        if (force or self.m_laserDir ~= dir) then
            self.m_laserDir = dir
            local pos = getPointFromAngleAndDistance(dir, 2560)    
            EffectLink_refresh(self.m_linkEffect, 0, 0, pos['x'], pos['y'])

            self.m_laserEndPosX = self.m_startPosX + pos['x']
            self.m_laserEndPosY = self.m_startPosY + pos['y']
        end
    end
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillLaser:findCollision()
    if (self.m_lTargetCollision) then
        return self.m_lTargetCollision
    end

    local l_target = self:getProperTargetList()
	local l_ret = SkillTargetFinder:findCollision_Bar(l_target, self.m_startPosX, self.m_startPosY, self.m_laserEndPosX, self.m_laserEndPosY, self.m_laserThickness/2)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)

    return l_ret
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillLaser:runAttack(t_collision_obj, t_collision_bodys)
	if (not self.t_collision) then
		return
	end

    local collisions = self:getProperCollisionList()

    for _, collision in ipairs(collisions) do
        local target = collision:getTarget()
        local body_key = collision:getBodyKey()

        if (not self.t_collision[target.phys_idx]) then
			self.t_collision[target.phys_idx] = {}
		end

        if (not self.t_collision[target.phys_idx][body_key]) then
		    -- 충돌, 공격 처리
		    self.t_collision[target.phys_idx][body_key] = true
            
            self:attack(collision)
        end
    end
    
	self:doCommonAttackEffect()
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    local fire_distance = nil

    if tonumber(t_skill['res_2']) ~= nil then
        fire_distance = tonumber(t_skill['res_2'])
    end

	local hit = t_skill['hit']

	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser(nil)

	-- 2. 초기화 관련 함수
    skill.m_fireDistance = fire_distance
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    skill:refresh(true)
end
