local PARENT = SkillLaser

-------------------------------------
-- class SkillLaser_Zet
-------------------------------------
SkillLaser_Zet = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_Zet:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser_Zet:init_skill(missile_res, hit, thickness)
    PARENT.init_skill(self, missile_res, hit, thickness)

    self.m_startPosX = self.m_owner.pos.x + self.m_attackPosOffsetX
    self.m_startPosY = self.m_owner.pos.y + self.m_attackPosOffsetY

    self.m_laserDir = getDegree(self.m_startPosX, self.m_startPosY, self.m_targetPos.x, self.m_targetPos.y)

    local pos = getPointFromAngleAndDistance(self.m_laserDir, 2560)
    self.m_laserEndPosX = self.m_startPosX + pos['x']
    self.m_laserEndPosY = self.m_startPosY + pos['y']

    -- 위치 및 각도 설정
	self:setPosition(self.m_startPosX, self.m_startPosY)
    self.m_animator:setRotation(getAdjustDegree(self.m_laserDir))
	
    -- 스킬 사용자 숨김
    self.m_owner.m_animator:setVisible(false)
end

-------------------------------------
-- function makeLaserLinkEffect
-------------------------------------
function SkillLaser_Zet:makeLaserLinkEffect(file_name)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser_Zet:initState()
    PARENT.initState(self)
    
    self:addState('start', SkillLaser_Zet.st_appear, 'appear', false)
    self:addState('idle', SkillLaser_Zet.st_idle, 'idle', false)
    self:addState('disappear', SkillLaser_Zet.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillLaser_Zet.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner:changeState('idle')
        end)
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLaser_Zet.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        local duration = owner.m_animator:getDuration()
        
        owner.m_multiHitTime = duration / owner.m_maxClearCount
        owner.m_multiHitTimer = 0
    end
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt

    if (owner.m_multiHitTimer >= owner.m_multiHitTime) then
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1

        owner:runAttack()
    end

    if (owner.m_clearCount >= owner.m_maxClearCount) then
        owner:changeState('disappear')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillLaser_Zet.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local unit = owner.m_owner

        unit.m_animator:setVisible(true)
        unit.m_animator:changeAni('skill_disappear', false)
        unit.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)

        owner.m_animator:setVisible(false)
    end
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser_Zet:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local hit = t_skill['hit']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser_Zet(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(nil, hit)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
