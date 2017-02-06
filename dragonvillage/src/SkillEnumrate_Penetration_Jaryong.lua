local PARENT = SkillEnumrate_Penetration

-------------------------------------
-- class SkillEnumrate_Penetration_Jaryong
-------------------------------------
SkillEnumrate_Penetration_Jaryong = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Penetration_Jaryong:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillEnumrate_Penetration_Jaryong
-------------------------------------
function SkillEnumrate_Penetration_Jaryong:init_skill(missile_res, motionstreak_res, line_num, line_size)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, line_size)
end

-------------------------------------
-- function doSpecailEffect
-------------------------------------
function SkillEnumrate_Penetration_Jaryong:doSpecailEffect()
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, {self.m_owner}, self.m_lStatusEffectStr)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate_Penetration_Jaryong:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
	local motionstreak_res = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner.m_charTable['attr'])

	local line_num = t_skill['hit']
	local line_size = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate_Penetration_Jaryong(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, line_size)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end