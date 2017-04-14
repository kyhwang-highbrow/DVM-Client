local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillLaser
-------------------------------------
SkillLaser = class(PARENT, {
        m_linkEffect = '',  -- 레이저의 그래픽 리소스
        m_laserDir = '',

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
-- function initc
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

    self.m_physGroup = self.m_owner:getAttackPhysGroup()

    local duration = (self.m_owner.m_statusCalc.m_attackTick / 2)
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

		--self.m_resScale = t_data['scale']
		self.m_laserThickness = t_data['size']
	end
end

-------------------------------------
-- function makeLaserLinkEffect
-------------------------------------
function SkillLaser:makeLaserLinkEffect(file_name)
    local link_effect = EffectLink(file_name)

    link_effect.m_bRotateEndEffect = false

    -- 저사양모드 ignore
    link_effect:setIgnoreLowEndMode(true)

    -- 'appear' -> 'idle' 에니메이션으로 자동 변경
    link_effect:registCommonAppearAniHandler()

    do -- 이펙트 스케일 지정
        local scale = self.m_resScale
        link_effect.m_startPointNode:setScale(scale)
        link_effect.m_effectNode:setScale(scale, 1)
        link_effect.m_endPointNode:setScale(scale)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    self.m_linkEffect = link_effect
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser:initState()
	self:setCommonState(self)
    self:addState('start', SkillLaser.st_idle, 'idle', true)
    self:addState('disappear', SkillLaser.st_disappear, 'idle', true)
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

        local l_target, l_bodys = owner:findTarget()
		owner:runAttack(l_target, l_bodys)
    end

    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner.m_bDead) or (owner.m_stateTimer >= owner.m_limitTime) then
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
-- function findTarget
-------------------------------------
function SkillLaser:findTarget()
	local l_target = self:getProperTargetList()
	return SkillTargetFinder:findTarget_Bar(l_target, self.m_startPosX, self.m_startPosY, self.m_laserEndPosX, self.m_laserEndPosY, self.m_laserThickness/2)
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillLaser:runAttack(t_collision_obj, t_collision_bodys)
	if (not self.t_collision) then
		return
	end
	
    for i, target in ipairs(t_collision_obj) do
        local body_keys = t_collision_bodys[i]

        for i, body_key in ipairs(body_keys) do
		    -- 이미 충돌된 객체라면 리턴
		    if (not self.t_collision[target.phys_idx]) then
			    self.t_collision[target.phys_idx] = {}
		    end

            if (not self.t_collision[target.phys_idx][body_key]) then
		        -- 충돌, 공격 처리
		        self.t_collision[target.phys_idx][body_key] = true

		        self:attack(target, {body_key})
            end
        end
	end

	self:doCommonAttackEffect(t_collision_obj)
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local hit = t_skill['hit']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser(nil)

	-- 2. 초기화 관련 함수
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

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        --world.m_gameHighlight:addMissile(skill)
    end

    skill:refresh(true)
end
