local PARENT = SkillLaser

-------------------------------------
-- class SkillLaser_Darknix
-------------------------------------
SkillLaser_Darknix = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_Darknix:init(file_name, body, ...)    
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser_Darknix:initState()
    PARENT.initState(self)
    
    self:addState('start', SkillLaser_Darknix.st_idle, 'idle', true)
    self:addState('disappear', SkillLaser_Darknix.st_disappear, nil, true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLaser_Darknix.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_owner.m_animator:changeAni('skill_disappear', false)
    end
    
    owner.m_multiHitTimer = owner.m_multiHitTimer + dt

    if (owner.m_multiHitTimer >= owner.m_multiHitTime) and
        (owner.m_clearCount < owner.m_maxClearCount - 1) then
		owner:clearCollisionObjectList()
        owner.m_multiHitTimer = owner.m_multiHitTimer - owner.m_multiHitTime
        owner.m_clearCount = owner.m_clearCount + 1

        owner:runAttack()
    end

    owner:refresh()

    if ((not owner.m_owner) or owner.m_owner:isDead() or (owner.m_clearCount >= owner.m_maxClearCount - 1)) then
        owner:changeState('disappear')
        return
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillLaser_Darknix.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            if (owner.m_clearCount < owner.m_maxClearCount) then
                owner:clearCollisionObjectList()
                owner.m_clearCount = owner.m_clearCount + 1

                owner:runAttack()
            end

            owner:changeState('dying')
        end

        owner.m_linkEffect:changeCommonAni('disappear', false, ani_handler)
    end

    if (owner.m_stateTimer >= 0.5 and owner.m_clearCount < owner.m_maxClearCount) then
        owner:clearCollisionObjectList()
        owner.m_clearCount = owner.m_clearCount + 1

        owner:runAttack()
    end
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser_Darknix:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local hit = t_skill['hit']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser_Darknix(nil)

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

    skill:refresh(true)
end
