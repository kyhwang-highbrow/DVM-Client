local PARENT = class(Entity, ISkill:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class SkillCounterAttack
-- @breif 스킬 시전 중.. 공격을 받으면 대상에게 반격
-------------------------------------
SkillCounterAttack = class(PARENT, {
		m_invokeSkillId = 'num',
		m_duration = 'num',
		m_triggerName = 'str',

		m_attackCount = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCounterAttack:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillCounterAttack:init_skill(invoke_skill_id, duration)
    PARENT.init_skill(self)
	self.m_invokeSkillId = invoke_skill_id
	self.m_duration = duration
	
	self.m_triggerName = 'undergo_attack'
	self.m_attackCount = 0

	self.m_owner:addListener(self.m_triggerName, self)
	
	self.m_owner:changeState('delegate')
end

-------------------------------------
-- function initState
-- @breif state 정의
-------------------------------------
function SkillCounterAttack:initState()
	PARENT.initState(self)
    self:addState('start', SkillCounterAttack.st_appear, nil, true)
    self:addState('idle', SkillCounterAttack.st_idle, nil, true)
	self:addState('disappear', SkillCounterAttack.st_disappear, nil, true)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillCounterAttack.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- attack -> idle -> skill_1_appear로 진행
		owner.m_owner.m_animator:changeAni('idle', false) 
		local cbFunc = function () 
			owner.m_owner.m_animator:changeAni('skill_1_appear', false) 
			local cbFunc2 = function () 
				owner:changeState('idle')
			end
			owner.m_owner:addAniHandler(cbFunc2)	
		end
		owner.m_owner:addAniHandler(cbFunc)
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillCounterAttack.st_idle(owner, dt)
    -- 종료
    if (not owner.m_owner) or owner.m_owner.m_bDead then
        owner:changeState('dying')
        return
    end

    if (owner.m_stateTimer == 0) then
		owner.m_owner.m_animator:changeAni('skill_1_idle', true) 
	elseif (owner.m_stateTimer > owner.m_duration) then
		owner:changeState('disappear')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillCounterAttack.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		if owner.m_owner.m_animator then 
			owner.m_owner.m_animator:changeAni('skill_1_disappear', false) 
		end
		local cbFunc = function () 
			owner.m_owner:changeState('attackDelay')
			owner:changeState('dying')
		end
		owner.m_owner:addAniHandler(cbFunc)
    end
end


-------------------------------------
-- function onEvent
-------------------------------------
function SkillCounterAttack:onEvent(event_name, ...)
	local args = {...}
	local attacker = args[1]
	local defender = self.m_owner
    if (event_name == self.m_triggerName) and (self.m_stateTimer > self.m_attackCount) then
		-- 1초에 한번씩만 실행된다.
		defender:doSkill(self.m_invokeSkillId, nil, 0, 0, {})
		self.m_attackCount = self.m_attackCount + 1
    end
end

-------------------------------------
-- function release
-------------------------------------
function SkillCounterAttack:release()
    self.m_owner:removeListener(self.m_triggerName, self)
	PARENT.release(self)
end



-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillCounterAttack:makeSkillInstnce(invoke_skill_id, duration, ...)
	-- 1. 스킬 생성
    local skill = SkillCounterAttack(nil)

	-- 2. 초기화 관련 함수
	skill:setParams(...)
    skill:init_skill(invoke_skill_id, duration)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillCounterAttack:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner
	
	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local pre_delay = t_skill['pre_delay']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_value = t_skill['status_effect_value']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target

	-- 2. 특수 변수
    local invoke_skill_id = t_skill['val_1']
	local duration = t_skill['val_2']

    SkillCounterAttack:makeSkillInstnce(invoke_skill_id, duration, owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
end