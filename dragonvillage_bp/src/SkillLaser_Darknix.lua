local PARENT = SkillLaser

-------------------------------------
-- class SkillLaser_Darknix
-------------------------------------
SkillLaser_Darknix = class(PARENT, {})

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_Darknix:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser_Darknix:init_skill(missile_res, hit, thickness)
    PARENT.init_skill(self, missile_res, hit, thickness)

    self.m_clearCount = 1
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLaser_Darknix:initState()
    PARENT.initState(self)
    
    self:addState('disappear', SkillLaser_Darknix.st_disappear, nil, true)
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillLaser_Darknix.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
        local function ani_handler()
            owner:changeState('dying')
        end

        owner.m_clearCount = owner.m_clearCount - 1

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
