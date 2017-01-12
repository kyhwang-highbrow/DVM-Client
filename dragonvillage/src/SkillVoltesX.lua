local PARENT = Skill

-------------------------------------
-- class SkillVoltesX
-------------------------------------
SkillVoltesX = class(PARENT, {
		m_physGroup = 'str',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillVoltesX:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillVoltesX:init_skill(attack_count, range, angle)
    PARENT.init_skill(self)
	self.m_physGroup = self.m_owner:getAttackPhysGroup()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillVoltesX:initState()
	self:setCommonState(self)
	self:addState('start', SkillVoltesX.st_idle, 'idle_01', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillVoltesX.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:setPosition(owner.m_targetPos.x, owner.m_targetPos.y)
		owner.m_animator:addAniHandler(function() 
			owner:runAttack()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillVoltesX:findTarget()
	local t_collision_obj = nil
	local t_ret = {}
	
    local radius = 20
	local std_width = (1280 / 2)
	local std_height = (720 / 2)
	
	local target_x, target_y = self.m_targetPos.x, self.m_targetPos.y
	local start_x, start_y = nil, nil
	local end_x, end_y = nil, nil

	-- 레이저에 충돌된 모든 객체 리턴
	for i = 1, 2 do 
		
		start_x = target_x - std_width
		start_y = target_y - (std_height * (math_pow(-1, i)))
		
		end_x = target_x + std_width
		end_y = target_y + (std_height * (math_pow(-1, i)))
		
		t_collision_obj = self.m_world.m_physWorld:getLaserCollision(
			start_x, start_y,
			end_x, end_y, radius, self.m_physGroup)
		
		for i, obj in pairs(t_collision_obj) do 
			table.insert(t_ret, obj['obj'])
		end
    end
	
	return t_ret
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillVoltesX:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = 'res/effect/skill_optatio_x/skill_optatio_x_water.vrp' --string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local attack_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillVoltesX(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, range, angle)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
