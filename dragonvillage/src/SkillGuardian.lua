local PARENT = Skill

-------------------------------------
-- class SkillGuardian
-------------------------------------
SkillGuardian = class(PARENT, {
		m_res = 'string',
        m_duration = 'num',

        m_shieldEffect = 'Animator',
        m_barEffect = 'EffectLink',
        m_barrierEffect1 = 'Animator',
        m_barrierEffect2 = 'Animator',

		m_bDirtyPos = 'boolean', -- 위치가 변경되어 이펙트 수정이 필요한 경우
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillGuardian:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillGuardian:init_skill(res, duration)
	PARENT.init_skill(self)

	-- 멤버 변수
	self.m_res = res
	self.m_duration = duration
end


-------------------------------------
-- function initState
-------------------------------------
function SkillGuardian:initState()
	self:setCommonState(self)
    self:addState('start', SkillGuardian.st_start, nil, true)
    self:addState('idle', SkillGuardian.st_idle, nil, true)
    self:addState('end', SkillGuardian.st_end, nil, false)
    self:addState('dying', SkillGuardian.st_dying, nil, false)
end

-------------------------------------
-- function st_start
-------------------------------------
function SkillGuardian.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:makeEffectLink()
        owner:onStart()

        local function func()
            owner:changeState('idle')
        end

        owner:addAniHandler(func)
    end

	-- 리소스 생성후 애니메이션 끝날때까지 체크
    owner:checkDurability(dt)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillGuardian.st_idle(owner, dt)
	owner:checkDurability(dt)
end

-------------------------------------
-- function st_end
-------------------------------------
function SkillGuardian.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:onEnd()

        -- 방패 이팩트
        owner.m_shieldEffect:changeAni('shield_disappear', false)
        
        -- 연결 이팩트
        owner.m_barEffect.m_effectNode:changeAni('bar_disappear', false)

        -- 베리어 이팩트
        owner.m_barrierEffect1:changeAni('barrier_disappear', false)
        owner.m_barrierEffect2:changeAni('barrier_disappear', false)

    elseif (owner.m_stateTimer >= 2) then
		-- 적당히 disappear animation이 끝난 후 동작
        owner:changeState('dying')
    end
end

-------------------------------------
-- function checkDurablity
-------------------------------------
function SkillGuardian:checkDurability(dt)
	-- 시전자나 대상이 죽으면 중지
	if (self.m_owner.m_bDead) or (self.m_targetChar.m_bDead) then
		self:changeState('end')
	end

    self.m_duration = self.m_duration - dt
    if (self.m_duration <= 0) then
        self:changeState('end')
	else
		-- 위치 갱신이 필요한지 확인
		self:checkBuffPosDirty()

		-- 위치 변경 처리
		if self.m_bDirtyPos then
			self:updateBuffPos()
		end
    end
end

-------------------------------------
-- function makeEffectLink
-------------------------------------
function SkillGuardian:makeEffectLink()
	local res = self.m_res

    -- 방어 이펙트 -- 백판에 박기 위해 goundNode에 붙임
    self.m_shieldEffect = MakeAnimator(res)
    self.m_shieldEffect:changeAni('shield_appear', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
    self.m_world.m_groundNode:addChild(self.m_shieldEffect.m_node)

    -- 연결 이펙트
    self.m_barEffect = EffectLink(res, 'bar_appear', '', '', 512, 256)
    self.m_barEffect.m_startPointNode:setVisible(false)
    self.m_barEffect.m_endPointNode:setVisible(false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)
    self.m_world.m_groundNode:addChild(self.m_barEffect.m_node)

    -- 베리어 이펙트
    self.m_barrierEffect1 = MakeAnimator(res)
    self.m_barrierEffect1:changeAni('barrier_appear', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect1.m_node)

    -- 베리어 이펙트
    self.m_barrierEffect2 = MakeAnimator(res)
    self.m_barrierEffect2:changeAni('barrier_appear', false)
    self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect2.m_node)
end

-------------------------------------
-- function onHit
-------------------------------------
function SkillGuardian:onHit()
    -- 방패 이팩트
	if (self.m_shieldEffect) then 
		self.m_shieldEffect:changeAni('shield_hit', false)
		self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
	end
        
    -- 연결 이팩트
	if (self.m_barEffect) then
		self.m_barEffect.m_effectNode:changeAni('bar_hit', false)
		self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)
	end

    -- 베리어 이팩트
	if (self.m_barrierEffect1) and (self.m_barrierEffect2) then
		self.m_barrierEffect1:changeAni('barrier_hit', false)
		self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)
		self.m_barrierEffect2:changeAni('barrier_hit', false)
		self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
	end
end

-------------------------------------
-- function onStart
-------------------------------------
function SkillGuardian:onStart()
	local target_char = self.m_targetChar

    if (target_char:getGuard()) then
        target_char:getGuard():changeState('end')
    end
    
    target_char:setGuard(self)

	target_char:addListener('guardian', self)
end

-------------------------------------
-- function onEnd
-------------------------------------
function SkillGuardian:onEnd()
	local target_char = self.m_targetChar
	if (target_char:getGuard() == self) then
		target_char:setGuard(nil)
		target_char:removeListener('guardian', self)
	end
end

-------------------------------------
-- function onEvent
-------------------------------------
function SkillGuardian:onEvent(event_name, t_event, ...)
	if (event_name == 'guardian') then
		self:onHit()
		local attacker = t_event['attacker']
		local defender = self.m_owner
		defender:undergoAttack(attacker, defender, defender.pos.x, defender.pos.y, 0, false, true)
	end
end

-------------------------------------
-- function checkBuffPosDirty
-------------------------------------
function SkillGuardian:checkBuffPosDirty()
    -- 본체 변경 확인
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
        return
    end

    -- 베리어 대상자 변경 확인
    local x = self.m_targetChar.pos.x - self.pos.x
    local y = self.m_targetChar.pos.y - self.pos.y
    if (self.m_barrierEffect2.m_posX ~= x) or (self.m_barrierEffect2.m_posY ~= y) then
        self.m_bDirtyPos = true
        return
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function SkillGuardian:updateBuffPos()
    local x = self.m_targetChar.pos.x - self.pos.x
    local y = self.m_targetChar.pos.y - self.pos.y
    self.m_barrierEffect2:setPosition(x, y)
    self.m_shieldEffect:setPosition(self.m_targetChar.pos.x, self.m_targetChar.pos.y)
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    EffectLink_refresh(self.m_barEffect, self.pos.x, self.pos.y, self.m_targetChar.pos.x, self.m_targetChar.pos.y)

    self.m_bDirtyPos = false
end

-------------------------------------
-- function release
-------------------------------------
function SkillGuardian:release()
	self:onEnd()
    
	if (self.m_barEffect) then
        self.m_barEffect:release()
        self.m_barEffect = nil
    end

    if (self.m_shieldEffect) then
        self.m_shieldEffect:release()
        self.m_shieldEffect = nil
    end

    PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillGuardian:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    
	local duration = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillGuardian(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(res, duration)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end