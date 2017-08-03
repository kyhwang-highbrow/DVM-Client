local PARENT = Skill

local CROSS_ATK_STEP_1 = 1
local CROSS_ATK_STEP_FINAL = CROSS_ATK_STEP_1 + 1

-------------------------------------
-- class SkillCross
-------------------------------------
SkillCross = class(PARENT, {
		m_lineSize = 'num',
        m_attackStep = 'num',
		m_skillAniName = 'str',

     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCross:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillCross:init_skill(attack_count)
    PARENT.init_skill(self)

	-- 멤버변수 초기화
	self.m_lineSize = g_constant:get('SKILL', 'VOLTES_LINE_SIZE')
    self.m_attackStep = CROSS_ATK_STEP_1

	self.m_skillAniName = 'idle'

	-- 스킬 위치 타겟 위치로 
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCross:initState()
	self:setCommonState(self)
	self:addState('start', SkillCross.st_idle, self.m_skillAniName, false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillCross.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then

    elseif (owner.m_stateTimer > 0.8) then
        if (owner.m_attackStep == CROSS_ATK_STEP_1) then
            owner:runAttack()
            owner.m_attackStep = CROSS_ATK_STEP_FINAL
        end
        
		-- 일반 스킬이라면 ATK STEP FINAL 일떄 탈출
	    if (owner.m_attackStep == CROSS_ATK_STEP_FINAL) then 
		    owner.m_animator:addAniHandler(function()
                    owner:changeState('dying')
		    end)
	    end	
    end
end

-------------------------------------
-- function doStatusEffect
-- @brief l_start_con 조건에 해당하는 statusEffect를 적용
-------------------------------------
function SkillCross:doStatusEffect(l_start_con, t_target)
    if (not t_target) then return end
    
    Skill.doStatusEffect(self, l_start_con, t_target)
end

-------------------------------------
-- function runAttack
-- @brief findCollision으로 찾은 body별로 공격
-------------------------------------
function SkillCross:runAttack()

    local collisions = self:findCollision()
    for _, collision in ipairs(collisions) do
        self:attack(collision)
    end
    
	self:doCommonAttackEffect()
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillCross:findCollision()
	local l_target = self:getProperTargetList()
	
    local std_width = CRITERIA_RESOLUTION_X
	local std_height = CRITERIA_RESOLUTION_Y
	
	local target_x, target_y = self.m_targetPos.x, self.m_targetPos.y
	local collisions1 = self:findCollisionEachLine(l_target, target_x, target_y, 0, std_height, 1)
    local collisions2 = self:findCollisionEachLine(l_target, target_x, target_y, std_width, 0, 2)
    
	-- 맵형태로 임시 저장(중복 제거를 위함)
    local m_temp = {}
    local l_temp = {
        collisions1,
        collisions2
    }

    for _, collisions in ipairs(l_temp) do
        for _, collision in ipairs(collisions) do
            local target = collision:getTarget()
            local body_key = collision:getBodyKey()

            if (not m_temp[target]) then
                m_temp[target] = {}
            end

            m_temp[target][body_key] = collision
        end
    end
    
    -- 인덱스 테이블로 다시 담는다
    local l_ret = {}
    
    for _, map in pairs(m_temp) do
        for _, collision in pairs(map) do
            table.insert(l_ret, collision)
        end
    end

    -- 거리순으로 정렬(필요할 경우)
    table.sort(l_ret, function(a, b)
        return (a:getDistance() < b:getDistance())
    end)

    -- 타겟 수 만큼만 얻어옴
    l_ret = table.getPartList(l_ret, self.m_targetLimit)
	
	return l_ret
end

-------------------------------------
-- function findCollisionEachLine
-------------------------------------
function SkillCross:findCollisionEachLine(l_target, target_x, target_y, std_width, std_height, idx)
	local start_x = target_x - std_width
	local start_y = target_y - (std_height * (math_pow(-1, idx)))
		
	local end_x = target_x + std_width
	local end_y = target_y + (std_height * (math_pow(-1, idx)))

	return SkillTargetFinder:findCollision_Bar(l_target, start_x, start_y, end_x, end_y, self.m_lineSize/2)
end

-------------------------------------
-- function findTarget
-- @brief 모든 대상 찾음(Character 기준)
-------------------------------------
function SkillCross:findTarget(idx)
    local l_collision = self:findCollision(idx)
    local m_temp = {}

    -- 맵형태로 임시 저장(중복된 대상 처리를 위함)
    for _, collision in ipairs(l_collision) do
        local target = collision:getTarget()
        m_temp[target] = collision
    end

    -- 리스트 형태로 변환
    local l_target = {}

    for _, collision in pairs(m_temp) do
        table.insert(l_target, collision)
    end

	return l_target, l_collision
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillCross:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local attack_count = t_skill['hit']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCross(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
