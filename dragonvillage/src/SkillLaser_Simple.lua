local PARENT = SkillLaser_Zet

-------------------------------------
-- class SkillLaser_Simple
-------------------------------------
SkillLaser_Simple = class(PARENT, {
     })

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_Simple:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser_Simple:init_skill(missile_res, hit, thickness)
    PARENT.init_skill(self, missile_res, hit, thickness)

    -- 스킬 사용자 보임
    self.m_owner.m_animator:setVisible(true)
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser_Simple:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local hit = t_skill['hit']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser_Simple(missile_res)

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
