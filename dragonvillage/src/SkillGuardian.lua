local PARENT = Skill

-------------------------------------
-- class SkillGuardian
-------------------------------------
SkillGuardian = class(PARENT, {
		m_res = 'string',
        m_duration = 'num',

        m_shieldEffect = 'Animator',
        m_barEffect = 'Table',
        m_barrierEffect1 = 'Animator',
        m_barrierEffect2 = 'Table',

		m_bDirtyPos = 'boolean', -- 위치가 변경되어 이펙트 수정이 필요한 경우
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillGuardian:init(file_name, body, ...)
    self.m_barrierEffect2 = {}
    self.m_barEffect = {}
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillGuardian:init_skill(res, duration)
	PARENT.init_skill(self)

	-- 멤버 변수
    self.m_res = res
	self.m_duration = duration

    -- 타겟 리스트가 없을 경우(인디케이터로부터 받은 정보가 없을 경우)
    if (not self.m_lTargetChar) then
        self.m_lTargetChar = self.m_owner:getTargetListByType(self.m_targetType, nil, self.m_targetFormation)
    end

    -- 자기 자신은 제외시킴
    local idx = table.find(self.m_lTargetChar, self.m_owner)
    if (idx) then
        table.remove(self.m_lTargetChar, idx)
    end

    -- 타겟 수만큼만 가져옴
    self.m_lTargetChar = table.getPartList(self.m_lTargetChar, self.m_targetLimit)
end


-------------------------------------
-- function initState
-------------------------------------
function SkillGuardian:initState()
	self:setCommonState(self)
    self:addState('start', SkillGuardian.st_start, nil, true)
    self:addState('idle', SkillGuardian.st_idle, nil, true)
    self:addState('end', SkillGuardian.st_end, nil, false)
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
        
        for _, v in pairs(owner.m_lTargetChar) do
            
            --연결 이펙트
            owner.m_barEffect[v].m_effectNode:changeAni('bar_disappear', false, true)

            -- target 배리어 이펙트
            owner.m_barrierEffect2[v]:changeAni('barrier_disappear', false, true)
        end

        -- 베리어 이팩트
        owner.m_barrierEffect1:changeAni('barrier_disappear', false)

    elseif (owner.m_stateTimer >= 2) then
		-- 적당히 disappear animation이 끝난 후 동작
        owner:changeState('dying')
    end
end

-------------------------------------
-- function checkDurability
-------------------------------------
function SkillGuardian:checkDurability(dt)
	-- 시전자나 대상이 죽으면 중지
    
    local dead_target = 0
    for _, v in pairs(self.m_lTargetChar) do
        if (v:isDead()) then
            self:playDisappearEffect(v)
            dead_target = dead_target + 1
        end
    end
	if (self.m_owner:isDead()) or (dead_target == #self.m_lTargetChar) then
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

    for _, v in pairs(self.m_lTargetChar) do

        -- 연결 이펙트 -- 드래곤들 뒤쪽에 위치하기 위해 world의 groundNode에 붙임
        local bar_effect = EffectLink(res, 'bar_appear', '', '', 512, 256)
        bar_effect.m_startPointNode:setVisible(false)
        bar_effect.m_endPointNode:setVisible(false)
        bar_effect.m_effectNode:addAniHandler(function() bar_effect.m_effectNode:changeAni('bar_idle', true) end)
        self.m_world.m_groundNode:addChild(bar_effect.m_node)
        self.m_barEffect[v] = bar_effect

        -- 베리어 이펙트 (대상에게)
        local barrier_effect = MakeAnimator(res)
        barrier_effect:changeAni('barrier_appear', false)
        barrier_effect:addAniHandler(function() barrier_effect:changeAni('barrier_idle', true) end)
        self.m_rootNode:addChild(barrier_effect.m_node)
        self.m_barrierEffect2[v] = barrier_effect
    end
	-- 나머지는 드래곤 위에 있으면 되므로 스킬 자체에 addchild

    -- 방어 이펙트
    self.m_shieldEffect = MakeAnimator(res)
    self.m_shieldEffect:changeAni('shield_appear', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
    self.m_rootNode:addChild(self.m_shieldEffect.m_node, -1)

    if (self:isRightFormation()) then
		self.m_shieldEffect:setFlip(true)
	end

    -- 베리어 이펙트 (나자신에게)
    self.m_barrierEffect1 = MakeAnimator(res)
    self.m_barrierEffect1:changeAni('barrier_appear', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect1.m_node)


end

-------------------------------------
-- function onHit
-------------------------------------
function SkillGuardian:onHit(defender)



    -- 방패 이팩트
	if (self.m_shieldEffect) then 
		self.m_shieldEffect:changeAni('shield_hit', false)
		self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
	end
        
    -- 연결 이팩트
	if (self.m_barEffect[defender]) then
		self.m_barEffect[defender].m_effectNode:changeAni('bar_hit', false)
		self.m_barEffect[defender].m_effectNode:addAniHandler(function() self.m_barEffect[defender].m_effectNode:changeAni('bar_idle', true) end)
	end

    -- 베리어 이팩트 (주체)
	if (self.m_barrierEffect1) then
		self.m_barrierEffect1:changeAni('barrier_hit', false)
		self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)
	end
	
	-- 베리어 이팩트 (타겟)
	if (self.m_barrierEffect2[defender]) then
		self.m_barrierEffect2[defender]:changeAni('barrier_hit', false)
		self.m_barrierEffect2[defender]:addAniHandler(function() self.m_barrierEffect2[defender]:changeAni('barrier_idle', true) end)
	end
end

-------------------------------------
-- function onStart
-------------------------------------
function SkillGuardian:onStart()
    for _, v in pairs(self.m_lTargetChar) do

        if (v:getGuard()) then
            v:getGuard():changeState('end')
        end
    
        v:setGuard(self)

        v:addListener('guardian', self)
    end

    -- 상태효과
    do
	    local t_event = { l_target = self.m_lTargetChar }
	    self:dispatch(CON_SKILL_HIT, t_event)
    end
end

-------------------------------------
-- function onEnd
-------------------------------------
function SkillGuardian:onEnd()
    for _, v in pairs (self.m_lTargetChar) do
	    if (v:getGuard() == self) then
		    v:setGuard(nil)
		    v:removeListener('guardian', self)
	    end
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function SkillGuardian:onEvent(event_name, t_event, ...)
	PARENT.onEvent(self, event_name, t_event, ...)

	if (event_name == 'guardian') then
		local attacker = t_event['attacker']

	    -- 공격자 정보
	    local attack_activity_carrier = attacker.m_activityCarrier

        -- ignore 체크
        if (attack_activity_carrier) then
            if (attack_activity_carrier:isIgnoreGuardian()) then return end
        end

		self:onHit(t_event['defender'])
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
    
    for k, v in pairs(self.m_lTargetChar) do
    -- 베리어 대상자 변경 확인
        local x = self.m_lTargetChar[k].pos.x - self.pos.x
        local y = self.m_lTargetChar[k].pos.y - self.pos.y
        if (self.m_barrierEffect2[v].m_posX ~= x) or (self.m_barrierEffect2[v].m_posY ~= y) then
            self.m_bDirtyPos = true
            return
        end
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function SkillGuardian:updateBuffPos()
    -- 배리어 이펙트1과 실드 위치 조정
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    
    for k, v in pairs(self.m_lTargetChar) do
        local x = v.pos.x - self.pos.x
        local y = v.pos.y - self.pos.y
    

	    -- 배리어 이펙트2 대상의 위치로 조정
	    self.m_barrierEffect2[v]:setPosition(x, y)
    
	    -- 연결 이펙트 나와 대상의 월드 좌표로 계산하여 조정
	    EffectLink_refresh(self.m_barEffect[v], self.pos.x, self.pos.y, v.pos.x, v.pos.y)

    end
    self.m_bDirtyPos = false
end

-------------------------------------
-- function release
-------------------------------------
function SkillGuardian:release()
	self:onEnd()
    
    for k, v in pairs(self.m_barEffect) do
	    if (self.m_barEffect[k]) then
            self.m_barEffect[k]:release()
            self.m_barEffect[k] = nil
        end
    end

    if (self.m_shieldEffect) then
        self.m_shieldEffect:release()
        self.m_shieldEffect = nil
    end

    PARENT.release(self)
end

-------------------------------------
-- function playDisappearEffect
-- @brief   effect_owner에 붙어있는 배리어와 사슬의 disappear 이펙트를 실행한다.
-- @param   effect_owner    Character    :   key로써 사용되며, Character object이다.
-------------------------------------
function SkillGuardian:playDisappearEffect(effect_owner)
    self.m_barEffect[effect_owner].m_effectNode:changeAni('bar_disappear', false, true)
    self.m_barrierEffect2[effect_owner]:changeAni('barrier_disappear', false, true)
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function SkillGuardian:setTemporaryPause(pause)
    local setVisible = function(b)
        for k, v in pairs(self.m_barEffect) do
	        if (self.m_barEffect[k]) then
                self.m_barEffect[k]:setVisible(b)
            end
        end

        if (self.m_shieldEffect) then
            self.m_shieldEffect:setVisible(b)
        end

        if (self.m_barrierEffect1) then
            self.m_barrierEffect1:setVisible(b)
        end

        for k, v in pairs(self.m_barrierEffect2) do
            if (self.m_barrierEffect2[k]) then
                self.m_barrierEffect2[k]:setVisible(b)
            end
        end
    end

    local setOpacity = function(opacity)
        for k, v in pairs(self.m_barEffect) do
	        if (self.m_barEffect[k]) then
                self.m_barEffect[k]:setOpacity(opacity)
            end
        end

        if (self.m_shieldEffect) then
            self.m_shieldEffect:setOpacity(opacity)
        end

        if (self.m_barrierEffect1) then
            self.m_barrierEffect1:setOpacity(opacity)
        end

        for k, v in pairs(self.m_barrierEffect2) do
            if (self.m_barrierEffect2[k]) then
                self.m_barrierEffect2[k]:setOpacity(opacity)
            end
        end
    end

    if (PARENT.setTemporaryPause(self, pause)) then
        --setVisible(not pause)
        if (pause) then
            setOpacity(127)
        else
            setOpacity(255)
        end

        return true
    end

    return false
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillGuardian:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    
	local duration = t_skill['val_1']
    local is_wave_retail = t_skill['val_2']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillGuardian(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(res, duration)
	skill:initState()
    skill.m_bWaveRetainSkill = (is_wave_retail == 1)

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end