local PARENT = Skill

-------------------------------------
-- class SkillCounterAttack
-- @breif 스킬 시전 중.. 공격을 받으면 대상에게 반격
-------------------------------------
SkillCounterAttack = class(PARENT, {
		m_invokeSkillId = 'num',
		m_duration = 'num',
		m_triggerName = 'str',
		m_animationName = 'str', 
		m_effect = 'Animator',
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
function SkillCounterAttack:init_skill(invoke_skill_id, duration, animation_name, trigger_name, effect_res)
    PARENT.init_skill(self)

	-- 멤버 변수
	self.m_invokeSkillId = invoke_skill_id
	self.m_duration = duration
	self.m_animationName = animation_name
	self.m_triggerName = trigger_name
	self.m_attackCount = 0

	-- 추가 리소스 있다면 effect 생성
	if (effect_res) then
		--self.m_effect = self:makeEffect(effect_res, self.m_owner.pos.x, self.m_owner.pos.x)
		--self.m_effect:setVisible(false)
	end

	-- 스킬 캐스터 이벤트 처리
	self.m_owner:addListener(self.m_triggerName, self)
	self.m_owner:changeState('delegate')
end

-------------------------------------
-- function initState
-- @breif state 정의
-------------------------------------
function SkillCounterAttack:initState()
	self:setCommonState(self)
    self:addState('start', SkillCounterAttack.st_appear, 'appear', false)
    self:addState('idle', SkillCounterAttack.st_idle, 'idle', true)
	self:addState('disappear', SkillCounterAttack.st_disappear, 'disappear', false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillCounterAttack.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 캐릭터
		owner.m_owner.m_animator:changeAni(owner.m_animationName .. '_appear', false) 
		owner.m_owner.m_animator:addAniHandler(function () 
			owner:changeState('idle')
		end)	  

	end  
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillCounterAttack.st_idle(owner, dt)
    -- 종료
    if (not owner.m_owner or owner.m_owner:isDead()) then
        owner:changeState('dying')
		if (owner.m_effect) then 
			owner.m_effect:release()
            owner.m_effect = nil
		end
        return
    end
    
	if (owner.m_stateTimer == 0) then
		-- 이펙트
		if (owner.m_effect) then 
			owner.m_effect:setVisible(true)
			owner.m_effect:changeAni('appear', false)
			owner.m_effect:addAniHandler(function () 
				owner.m_effect:changeAni('idle', true)
			end)	  
		end

		-- 캐릭터
		owner.m_owner.m_animator:changeAni(owner.m_animationName .. '_idle', true) 

	elseif (owner.m_stateTimer > owner.m_duration) then
		owner:changeState('disappear')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillCounterAttack.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트
		if (owner.m_effect) then
			owner.m_effect:changeAni('disappear', false)
		end
		
		-- 캐릭터
		owner.m_owner.m_animator:changeAni(owner.m_animationName .. '_disappear', false) 
		owner.m_owner.m_animator:addAniHandler(function () 
			owner.m_owner:changeState('attackDelay')
			owner:changeState('dying')
		end)
    end
end


-------------------------------------
-- function onEvent
-------------------------------------
function SkillCounterAttack:onEvent(event_name, t_event, ...)
	PARENT.onEvent(self, event_name, t_event, ...)

	if (not event_name == self.m_triggerName) then return end
	
	local args = {...}
	local attacker = args[1]
	local defender = self.m_owner
    if (self.m_stateTimer > self.m_attackCount) then
		-- 1초에 한번씩만 실행된다.
		defender:doSkill(self.m_invokeSkillId, 0, 0, {})
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
-- function makeSkillInstance
-------------------------------------
function SkillCounterAttack:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local invoke_skill_id = t_skill['val_1']
	local duration = t_skill['val_2']
	local trigger_name = t_skill['val_3']
	local animation_name = t_skill['animation']
	local effect_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCounterAttack(effect_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(invoke_skill_id, duration, animation_name, trigger_name, effect_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end