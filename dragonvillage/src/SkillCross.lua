local PARENT = Skill

local CROSS_ATK_STEP_1 = 1
local CROSS_ATK_STEP_FINAL = CROSS_ATK_STEP_1 + 1
local CROSS_ATK_STEP_END = CROSS_ATK_STEP_FINAL + 1
-------------------------------------
-- class SkillCross
-------------------------------------
SkillCross = class(PARENT, {
		m_lineSize = 'num',
        m_attackStep = 'num',
		m_skillAniName = 'str',
        m_isUpgraded = 'bool',
        m_tSkill = 'table',
        m_tData = 'table',
        m_lNextTarget = 'list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCross:init(file_name, body, ...)    
    self.m_lNextTarget = {}
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillCross:init_skill(attack_count, is_upgraded, t_skill, t_data)
    PARENT.init_skill(self)

	-- 멤버변수 초기화
	self.m_lineSize = g_constant:get('SKILL', 'VOLTES_LINE_SIZE')
    self.m_attackStep = CROSS_ATK_STEP_1
    self.m_isUpgraded = is_upgraded
    self.m_tSkill= t_skill
    self.m_tData= t_data
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

    elseif (owner.m_stateTimer > 0.4) then
        if (owner.m_attackStep == CROSS_ATK_STEP_1) then
            owner:runAttack()
            owner.m_attackStep = CROSS_ATK_STEP_FINAL
        end
        
		-- 일반 스킬이라면 ATK STEP FINAL 일떄 탈출
	    if (owner.m_attackStep == CROSS_ATK_STEP_FINAL) then
            if (owner.m_tData['val_2'] - 1 > 0) then
                for _, v in ipairs(owner.m_lNextTarget) do  
                    SkillCross:makeNewInstance(owner, v)
                end
            end
            owner.m_animator:addAniHandler(function()
                    owner:changeState('dying')
		    end)

            owner.m_attackStep = CROSS_ATK_STEP_END
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

    local l_collision = self:findCollision()
    for i, collision in ipairs(l_collision) do
        local target_hp_before = collision:getTarget().m_hp
   
        self:attack(collision)
        
        if (collision:getTarget().m_hp <= 0 and target_hp_before > 0) then
            table.insert(self.m_lNextTarget, collision)
        end
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
-- function makeSkillInstance
-------------------------------------
function SkillCross:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)   
	local attack_count = t_skill['hit']
    local is_upgraded = (t_skill['val_1'] == 1)
    local cnt = nil
    if (is_upgraded) then
        cnt = tonumber(t_data['val_2']) or tonumber(t_skill['val_2'])
        if (cnt > 3) then 
            cnt = 3
        elseif (cnt < 1) then
            cnt = 1
        end
    end
    t_data['val_2'] = cnt or 0
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCross(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count, is_upgraded, t_skill, t_data)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end



-------------------------------------
-- function makeNewInstance
-------------------------------------
function SkillCross:makeNewInstance(owner, target)
    if (owner.m_isUpgraded) then
        local t_data = {}
        t_data['bonus'] = owner.m_tData['bonus']
        t_data['target'] = owner.m_tData['target']
        t_data['target_list'] = owner.m_tData['target_list']
        t_data['x'] = target.m_posX
        t_data['y'] = target.m_posY

        local critical_chance = owner.m_owner:getStat('cri_chance')
        local critical_avoid = 0
        local final_critical_chance = CalcCriticalChance(critical_chance, critical_avoid)

        local is_critical = (math_random(1, 1000) <= (final_critical_chance * 10))
        if (is_critical) then
            t_data['critical'] = 1
        else
            t_data['critical'] = 0
        end

        t_data['val_2'] = owner.m_tData['val_2'] - 1
        SkillCross:makeSkillInstance(owner.m_owner, owner.m_tSkill, t_data)
    end
end