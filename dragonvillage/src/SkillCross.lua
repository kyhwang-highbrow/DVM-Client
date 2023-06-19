local PARENT = class(Skill, ISkillMultiAttack:getCloneTable())

-------------------------------------
-- class SkillCross
-------------------------------------
SkillCross = class(PARENT, {
        m_missileRes = 'string',
        m_repeatCount = 'number',
        
		m_lineSize = 'number',
        
        m_lNextTarget = 'list',
        
        m_lTargetPos = 'list',
        m_lPowerRate = 'list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCross:init(file_name, body, ...)    
    self.m_repeatCount = 0
    self.m_lNextTarget = {}
    
    self.m_lTargetPos = {}
    self.m_lPowerRate = {}
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
function SkillCross:init_skill(missile_res, hit)
    PARENT.init_skill(self)

    -- 멤버변수 초기화
    self.m_maxAttackCount = hit 
    self.m_missileRes = missile_res
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillCross:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_lPowerRate = { self.m_powerRate }

    if (t_skill['val_1'] == 1) then
        -- 반복 횟수
        self.m_repeatCount = SkillHelper:getValid(t_skill['val_2'], 0)

        local org_power_rate = self.m_powerRate
        local power_rate_multi = SkillHelper:getValid(t_skill['val_3'], 1)
        
        for i = 1, self.m_repeatCount do
            local power_rate = org_power_rate * math_pow(power_rate_multi, i)
            table.insert(self.m_lPowerRate, power_rate)
        end
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCross:initState()
	self:setCommonState(self)
    self:addState('start', SkillCross.st_appear, nil, false)
    self:addState('attack', SkillCross.st_attack, nil, true)
	self:addState('disappear', SkillCross.st_disappear, nil, false)
end



-------------------------------------
-- function getIdleAniName
-------------------------------------
function SkillCross:getIdleAniName()
    local ani_name = 'idle'

    if self.m_animator ~= nil then
        local visual_list = self.m_animator:getVisualList()
        for _ , name in ipairs(visual_list) do
            if name == ani_name then
                return ani_name
            end
        end
    end

    return self.m_owner:getAttributeForRes() .. '_idle'
end


-------------------------------------
-- function enterAttack
-- @brief 공격이 시작되는 시점에 실행
-------------------------------------
function SkillCross:enterAttack()
    self.m_lTargetPos = {}

    local effect
    local idle_ani_name = self:getIdleAniName()

    -- 이펙트
    if (#self.m_lNextTarget > 0) then   
        local m_unit = {}
         
        for _, collision in pairs(self.m_lNextTarget) do
            local target_char = collision:getTarget()
            local body_key = collision:getBodyKey()
            local body = target_char:getBody(body_key)
            local x = target_char.pos.x + body.x
            local y = target_char.pos.y + body.y

            effect = self:makeEffect(self.m_missileRes, x, y, idle_ani_name)

            table.insert(self.m_lTargetPos, { x = x, y = y })

            m_unit[target_char] = true
        end

        self.m_lNextTarget = {}
    else
        effect = self:makeEffect(self.m_missileRes, self.m_targetPos['x'], self.m_targetPos['y'], idle_ani_name)

        table.insert(self.m_lTargetPos, { x = self.m_targetPos['x'], y = self.m_targetPos['y'] })
    end

    -- 이펙트 재생 단위 시간
    local duration = effect:getDuration() / 2
	self.m_hitInterval = (duration / self.m_maxAttackCount)

	-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
	self.m_multiAtkTimer = self.m_hitInterval
    
    -- 공격 카운트 초기화
	self.m_attackCount = 0
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillCross:escapeAttack()
    if (#self.m_lNextTarget > 0) then
        self:changeState('attack')
    else
        self:changeState('disappear')
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
    for i, pos in ipairs(self.m_lTargetPos) do
        local list = self:findCollision(pos['x'], pos['y'])
        local new_power_rate = table.remove(self.m_lPowerRate, 1)

        if (new_power_rate) then
            self.m_activityCarrier:setPowerRate(new_power_rate)

            for i, collision in ipairs(list) do
                self:attack(collision)

                -- 남은 반복 횟수만큼 피격된 대상을 임시 저장
                if (self.m_repeatCount > 0) then
                    -- 해당 충돌 정보가 이미 있는지 체크
                    local b = true

                    for _, v in ipairs(self.m_lNextTarget) do
                        if (v:getTarget() == collision:getTarget() and v:getBodyKey() == collision:getBodyKey()) then
                            b = false
                            break
                        end
                    end

                    if (b) then
                        self.m_repeatCount = self.m_repeatCount - 1

                        table.insert(self.m_lNextTarget, collision)
                    end
                end
            end
        end
    end
    
	self:doCommonAttackEffect() 
end

-------------------------------------
-- function findCollision
-------------------------------------
function SkillCross:findCollision(x, y)
    local target_x = x
    local target_y = y

	local l_target
    if (x == self.m_targetPos['x'] and y == self.m_targetPos['y']) then
        l_target = self:getProperTargetList()
    else
        l_target = self.m_owner:getTargetListByType(self.m_targetType, nil, self.m_targetFormation)    
    end
    	
    local std_width = CRITERIA_RESOLUTION_X
	local std_height = CRITERIA_RESOLUTION_Y
	
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
function SkillCross:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)   
	local hit_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCross(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, hit_count, is_upgraded)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end