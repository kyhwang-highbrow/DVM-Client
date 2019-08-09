local PARENT = Skill

---------------------------------------------------------------------
-- 이 스킬에서 target은 hit될 수 있는 후보들을 의미합니다. 
-- 그러므로 target_count를  아군+적군인 경우 10(최대값)으로,
--                         아군이나 적군만인 경우 5(최대값)으로 값을 부여해야합니다. 
-- 실제 퐁당퐁당 스킬로 타격할 개체 수는 hit 컬럼을 통해 조절해야 합니다.
---------------------------------------------------------------------

-------------------------------------
-- class SkillSpatter
-------------------------------------
SkillSpatter = class(PARENT, {
        m_owner = 'Character',
        m_spatterCount = 'number',
        m_spatterMaxCount = 'number',
        
        m_stdPosX = 'number',
        m_stdPosY = 'number',

        m_prevPosX = 'number',
        m_prevPosY = 'number',

        m_targetIdx = 'number',
        m_onlyAlly = 'bool',

        m_lTargetCollisions = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSpatter:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillSpatter:init_skill(motionstreak_res, count, target_range)
    PARENT.init_skill(self)

	-- 멤버 변수
    self.m_spatterCount = 0
    self.m_spatterMaxCount = count
    
    self.m_stdPosX = self.m_owner.pos.x
    self.m_stdPosY = self.m_owner.pos.y

    self.m_prevPosX = self.m_stdPosX
    self.m_prevPosY = self.m_stdPosY


    if (not self.m_lTargetChar) then
	    self.m_lTargetChar = self:findTarget()
    end
    if (tonumber(target_range) == 2) then
        self.m_onlyAlly = false
    else
        self.m_onlyAlly = true
    end
    self.m_lTargetChar = self:makeSpatterTargetList()


    local pos_x, pos_y = self:getAttackPositionAtWorld()

    self.m_lTargetCollisions = SkillTargetFinder:getCollisionFromTargetList(self.m_lTargetChar, pos_x, pos_y, true)
    self.m_targetIdx = 1
	-- 위치 지정 및 모션스트릭	
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    self:setMotionStreak(self.m_world:getMissileNode(), motionstreak_res)

	-- 스킬 효과 시작
    self:heal(self.m_owner) -- 시전자는 회복을 하고 시작
    self:trySpatter()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSpatter:initState()
    self:setCommonState(self)
    
    self:addState('start', SkillSpatter.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillSpatter.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		local target_char, target_collision = owner:getNextTarget()

        -- JumpTo액션 실행
		if (target_char) then
            local tar_x, tar_y = target_char:getCenterPos()
			local target_pos = cc.p(tar_x, tar_y)
			local action = cc.JumpTo:create(0.5, target_pos, 100, 1)

			-- 액션 종료 후 타겟을 회복, 튀기기 시도
			local function end_func()
                --아군 적군 여부에 따라
                if (owner.m_owner.m_bLeftFormation == target_char.m_bLeftFormation) then
				    owner:heal(target_char)
                else
                    owner:attack(target_collision)
                end

				if (owner:trySpatter()) then
                    owner:changeState('start')
                end
			end

			local sequence = cc.Sequence:create(action, cc.CallFunc:create(end_func))
			owner.m_rootNode:runAction(sequence)
		else
			owner:changeState('dying')
		end
    end

    -- m_rootNode의 위치로 클래스위 위치 동기화, 각도 지정
    local x, y = owner.m_rootNode:getPosition()
    local degree = getDegree(owner.m_prevPosX, owner.m_prevPosY, x, y)
    owner:setRotation(degree)
    owner:setPosition(x, y)
    owner.m_prevPosX, owner.m_prevPosY = x, y
end

-------------------------------------
-- function trySpatter
-------------------------------------
function SkillSpatter:trySpatter()
	if (self.m_spatterCount >= self.m_spatterMaxCount) then
        self:changeState('dying')
        return false
    end

    self.m_spatterCount = self.m_spatterCount + 1
    return true
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillSpatter:findTarget()
    return self:getProperTargetList()
end

-------------------------------------
-- function getNextTarget
-------------------------------------
function SkillSpatter:getNextTarget()
	local target_char
    local target_collision
	local target_char = self.m_lTargetChar[self.m_targetIdx]
	local target_collision = self.m_lTargetCollisions[self.m_targetIdx]
	-- 타겟이 없거나 죽었을 시 다음 적절한 타겟을 찾기 위해 타겟리스트를 순서대로 한번 순회
	local idx = 0
	while (not target_char or target_char:isDead()) do
		idx = idx + 1
		self.m_targetIdx = self.m_targetIdx + 1
		target_char = self.m_lTargetChar[self.m_targetIdx]
        target_collision = self.m_lTargetCollisions[self.m_targetIdx]
		if (self.m_targetIdx > #self.m_lTargetChar) then
			self.m_targetIdx = 0
		end

		if (idx > #self.m_lTargetChar) then
			break
		end
	end

	self.m_targetIdx = self.m_targetIdx + 1
	return target_char, target_collision
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSpatter:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
    local count = t_skill['hit']
    local target_range = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillSpatter(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(motionstreak_res, count, target_range)
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
-- function makeSpatterTargetList
-------------------------------------
function SkillSpatter:makeSpatterTargetList()

	local ally_target_idx = 1
    local enemy_target_idx = 1

    local l_ally_target = {}
    local l_enemy_target = {}

    
    for i, v in ipairs(self.m_lTargetChar) do
        if (self.m_owner.m_bLeftFormation == v.m_bLeftFormation) then
            table.insert(l_ally_target, v)
        else
            table.insert(l_enemy_target, v)
        end
    end

    -- 힐을 해줄 아군이 좀비일 경우 우선순위를 뒤로 둔다
    local sort_zombie = function(a, b)
        if (a.m_isZombie) then
            return false
        end

        if (b.m_isZombie) then
            return true
        end

        return false
    end

    table.sort(l_ally_target, sort_zombie)

    local b_next_formation
    if (self.m_onlyAlly) then
        b_next_formation = self.m_owner.m_bLeftFormation
    else
        b_next_formation = not self.m_owner.m_bLeftFormation
    end
    local t_temp_target = {}

    for _ = 1, self.m_spatterMaxCount do
        if (b_next_formation == self.m_owner.m_bLeftFormation) then
            if (ally_target_idx > #l_ally_target) then
                ally_target_idx = 1
            end
            table.insert(t_temp_target, l_ally_target[ally_target_idx])
            ally_target_idx = ally_target_idx + 1
        else 
            if (enemy_target_idx > #l_enemy_target) then
                enemy_target_idx = 1
            end
            table.insert(t_temp_target, l_enemy_target[enemy_target_idx])
            enemy_target_idx = enemy_target_idx + 1
        end
        if (not self.m_onlyAlly) then
            b_next_formation = not b_next_formation
        end
    end
    return t_temp_target
end
