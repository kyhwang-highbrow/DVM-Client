local PARENT = SkillLaser

-------------------------------------
-- class SkillLaser_Lightning
-------------------------------------
SkillLaser_Lightning = class(PARENT, {
        m_lightingDMG
     })

-------------------------------------
-- function initc
-- @param file_name
-- @param body
-------------------------------------
function SkillLaser_Lightning:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLaser_Lightning:init_skill(missile_res, hit, thickness, lighting_dmg)
	PARENT.init_skill(self, missile_res, hit, thickness)
	self.m_lightingDMG = lighting_dmg
end

-------------------------------------
-- function makeSkillInstance
-- @param missile_res 
-------------------------------------
function SkillLaser_Lightning:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local hit = t_skill['hit']
	local thickness = t_skill['val_1']
	local lighting_dmg = t_skill['val_2']
	
	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillLaser_Lightning(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit, thickness, lighting_dmg)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    skill:refresh(true)
end
