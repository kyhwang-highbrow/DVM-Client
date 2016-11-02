local PARENT = class(Entity, ISkill:getCloneTable())

-------------------------------------
-- class SkillAddAttack
-------------------------------------
SkillAddAttack = class(PARENT, {
        m_rangeX = 'number', 
		m_rangeY = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAddAttack:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillAddAttack:init_skill(range_x, range_y)
	PARENT.init_skill(self)

	-- 멤버 변수
	self.m_rangeX = range_x
	self.m_rangeY = range_y

	self:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAddAttack:initState()
    self:addState('idle', SkillAddAttack.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)  
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAddAttack.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:runAttack()
		owner.m_animator:addAniHandler(function() owner:changeState('dying') end)
    end
end

-------------------------------------
-- function findTarget
-- @brief 위아래(동일한 x축선상에서) 특정px 이내 적군
-------------------------------------
function SkillAddAttack:findTarget()
	local x, y = self.m_targetPos.x, self.m_targetPos.y
	
    local world = self.m_world
	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'distance_line')
    
	local l_ret = {}
    local distance = 0

    for _, target in pairs(l_target) do
		if isCollision_Rect(x, y, target, self.m_rangeX, self.m_rangeY) then 
			table.insert(l_ret, target)
		end
    end
    
    return l_ret
end

-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillAddAttack:makeSkillInstnce(missile_res, range_x, range_y, ...)
	-- 1. 스킬 생성
    local skill = SkillAddAttack(missile_res)

	-- 2. 초기화 관련 함수
	skill:setParams(...)
    skill:init_skill(range_x, range_y)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('idle')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillAddAttack:makeSkillInstnceFromSkill(owner, t_skill, target)
    local owner = owner

	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local pre_delay = t_skill['pre_delay']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_value = t_skill['status_effect_value']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = target.pos.x
	local tar_y = target.pos.y
	local target = target

	-- 2. 특수 변수
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local range_x = t_skill['val_1']
	local range_y = t_skill['val_2']

    SkillAddAttack:makeSkillInstnce(missile_res, range_x, range_y, owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
end