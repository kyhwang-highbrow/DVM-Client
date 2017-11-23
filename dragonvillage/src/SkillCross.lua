local PARENT = Skill

local CROSS_ATK_STEP_1 = 1
local CROSS_ATK_STEP_FINAL = CROSS_ATK_STEP_1 + 1
local CROSS_ATK_STEP_END = CROSS_ATK_STEP_FINAL + 1

local repeat_count = 0

-------------------------------------
-- class SkillCross
-------------------------------------
SkillCross = class(PARENT, {
		m_lineSize = 'num',
        m_attackStep = 'num',
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
-- function initSkillSize
-------------------------------------
function SkillCross:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('cross', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_lineSize = t_data['size']
	else
        self.m_resScale = 1
        self.m_lineSize = g_constant:get('SKILL', 'CROSS_SIZE')
    end
end
-------------------------------------
-- function init_skill
-------------------------------------
function SkillCross:init_skill(hit_count, is_upgraded)
    PARENT.init_skill(self)

    -- 멤버변수 초기화
	
    self.m_attackStep = CROSS_ATK_STEP_1
    self.m_isUpgraded = is_upgraded

    -- 스킬 위치 타겟 위치로
	self:setPosition(self.m_targetPos.x, self.m_targetPos.y)

    -- activity carrier의 power_rate 변경
    if (self.m_isUpgraded) then
        local org_power_rate = self.m_activityCarrier:getPowerRate()
        --cclog('org_power_rate = ' .. org_power_rate)

        local power_rate_multi = self.m_tData['power_rate_multi'] or 1
        local new_power_rate = org_power_rate * power_rate_multi
        --cclog('new_power_rate = ' .. new_power_rate)
        
        self.m_activityCarrier:setPowerRate(new_power_rate)
    end
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillCross:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_tSkill = t_skill
    self.m_tData = t_data
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCross:initState()
	self:setCommonState(self)
	self:addState('start', SkillCross.st_idle, 'idle', false)
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
            owner.m_animator:addAniHandler(function()
                owner:changeState('dying')
		    end)

            owner.m_attackStep = CROSS_ATK_STEP_END

            -- 강화 되었을 시 추가 스킬 효과 처리
            if (owner.m_isUpgraded) then
                for _, v in ipairs(owner.m_lNextTarget) do
                    if (repeat_count > 0) then
                        SkillCross:makeNewInstance(owner, v)
                    else
                        break
                    end
                end
            end
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
    
	-- 하나의 리스트로 merge
    local l_ret = mergeCollisionLists({
        collisions1,
        collisions2
    })
    
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
function SkillCross:makeSkillInstance(owner, t_skill, t_data, _repeat_count)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)   
	local hit_count = t_skill['hit']
    local is_upgraded = (t_skill['val_1'] == 1)
    
    if (is_upgraded) then
        -- 반복 횟수
        repeat_count = _repeat_count or SkillHelper:getValid(t_skill['val_2'], 0)
    end

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCross(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(hit_count, is_upgraded)
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
    if (repeat_count <= 0) then return end
    repeat_count = repeat_count - 1

    local t_skill = owner.m_tSkill
    local org_repeat_count = SkillHelper:getValid(t_skill['val_2'], 0)
    local power_rate_multi = SkillHelper:getValid(t_skill['val_3'], 1)

    local t_data = {}

    t_data['target'] = target
    t_data['x'] = target.m_posX
    t_data['y'] = target.m_posY
    t_data['power_rate_multi'] = math_pow(power_rate_multi, org_repeat_count - repeat_count)

    SkillCross:makeSkillInstance(owner.m_owner, t_skill, t_data, repeat_count)
end