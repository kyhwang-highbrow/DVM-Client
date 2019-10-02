local PARENT = Skill

-------------------------------------
-- class SkillBind
-------------------------------------
SkillBind = class(PARENT, {
		m_statusDuration = 'num',
		m_statusName = 'str', 
        m_scale = 'number',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillBind:init(file_name, body, ...)
    self.m_scale = 1
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillBind:init_skill()
	PARENT.init_skill(self)

	local struct_status_effect = self.m_lStatusEffect[1]
	self.m_statusDuration = struct_status_effect.m_duration
	self.m_statusName = struct_status_effect.m_type

    local x, y = self.m_targetChar:getCenterPos()
    self:setPosition(x, y)

    local scale, type = self.m_targetChar:getSizeType()
    self.m_scale = self:calcScale(type, scale)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillBind:initState()
	self:setCommonState(self)
    self:addState('start', SkillBind.st_appear, 'appear', false)
	self:addState('idle', SkillBind.st_idle, 'idle', true)
	self:addState('end', SkillBind.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillBind.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
        owner.m_animator:setScale(owner.m_scale)
		owner.m_animator:addAniHandler(function()
			owner:changeState('idle')
		end)
	end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillBind.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
        owner:runAttack()

	elseif (owner.m_stateTimer > owner.m_statusDuration) then
		owner:changeState('end')

	else
		-- 해당 상태효과가 제거되었는지 체크
		local isExist = false
		for _, v  in pairs(owner.m_targetChar:getStatusEffectList()) do
			if (owner.m_statusName == v:getTypeName()) then 
				isExist = true
			end 
		end

		if (not isExist) then
			owner:changeState('end')
		end
	end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillBind.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_animator:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillBind:update(dt)
	if (self.m_state ~= 'dying') then
		-- 타겟 사망 체크
		if (self.m_targetChar:isDead()) then
			self:changeState('dying')
		end
	end

	-- 드래곤의 애니와 객체, 스킬 위치 동기화
    do
	    self.m_targetChar:syncAniAndPhys()

        local x, y = self.m_targetChar:getCenterPos()
        self:setPosition(x, y)
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function runAttack
-- @brief findCollision으로 찾은 body별로 공격
-------------------------------------
function SkillBind:runAttack()
    local pos_x, pos_y = self:getAttackPositionAtWorld()
    local l_collision = SkillTargetFinder:getCollisionFromTargetList({self.m_targetChar}, pos_x, pos_y)

    if (l_collision[1]) then
        self:attack(l_collision[1])
    end

	self:doCommonAttackEffect()
end

-------------------------------------
-- function calcScale
-------------------------------------
function SkillBind:calcScale(type, scale)
    if (type == 'monster') then
        if (scale == 'm') then
            return 1.5
        elseif (scale == 'l') then
            return 2
        elseif (scale == 'xl') then
            return 2.5
        else
            return 1  
        end
    else
        if (scale == 2) then
            return 1.25
        elseif (scale == 3) then
            return 1.5
        else
            return 1
        end
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillBind:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	  -- 광역 스킬 리소스
	local l_enemy = owner.m_world:getEnemyList() or {}
	-- 적이 없을 경우 스킬 발동 x
	if (#l_enemy == 0) then
		return
	end

	-- 남은 적이 타겟수보다 적을 경우, 스킬 생성 갯수 = min(타겟 갯수, 남은 적 갯수)
	local target_count = t_skill['target_count']
	local count = math.min(target_count, #l_enemy)

	local l_target = nil
	for idx = 1, count do -- 정해진 갯수 만큼 각 SkillBind 생성
		-- 인스턴스 생성부
		------------------------------------------------------
		-- 1. 스킬 생성
		local skill = SkillBind(missile_res)

		-- 2. 초기화 관련 함수
		skill:setSkillParams(owner, t_skill, t_data)
		
		do
            -- 타겟 리스트는 한 번만 생성
            if (not l_target) then
            	l_target = skill:getDefaultTargetList()
            end
            
            -- idx 순서대로 타겟 지정해줌
            local target = l_target[idx]
            skill:setTargetChar(target)
            
            -- 타겟 위치 지정
            local x, y
            if target then
            	skill.m_targetChar = target
            	x, y = target.pos.x, target.pos.y
            else
            	x, y = skill.m_owner.pos.x, skill.m_owner.pos.y
            end
            skill:setTargetPos(x, y)
		end

		skill:init_skill()
		skill:initState()

		-- 3. state 시작 
		skill:changeState('delay')

		-- 4. Physics, Node, GameMgr에 등록
		local world = skill.m_owner.m_world
		local missileNode = world:getMissileNode()
		missileNode:addChild(skill.m_rootNode, 0)
		world:addToSkillList(skill)
	end
end