local PARENT = Skill

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
-- function makeSkillInstance
-------------------------------------
function SkillAddAttack:makeSkillInstance(owner, t_skill, target)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local range_x = t_skill['val_1']
	local range_y = t_skill['val_2']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAddAttack(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(range_x, range_y)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('idle')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        world.m_gameHighlight:addMissile(skill)
    end
end