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
	
	-- 1. 멤버 변수
	self.m_skillInterval = 0
	self.m_enumTargetType = 'target'
	self.m_enumPosType = 'linear'
	
	self.m_skillStartPosList = self:getStartPosList()
	self.m_skillTargetList = self:getSkillTargetList()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillEnumrate_Penetration_Jaryong:initState()
	self:setCommonState(self)
    self:addState('start', SkillEnumrate_Penetration_Jaryong.st_appear, nil, false)
	self:addState('idle', SkillEnumrate_Penetration_Jaryong.st_idle, nil, true)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillEnumrate_Penetration_Jaryong.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
		local pos = {
			x = owner.m_skillStartPosList[1].x + owner.m_owner.pos.x,
			y = owner.m_skillStartPosList[1].y + owner.m_owner.pos.y
		}
		local cb_function = function() 
			owner:changeState('idle')
		end
		local effect = owner:makeEffect(owner.m_missileRes, pos.x, pos.y, 'appear', cb_function)
		effect:setRotation(owner:getAttackDir(1))
	end
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
    local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local motionstreak_res = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner:getAttribute())

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