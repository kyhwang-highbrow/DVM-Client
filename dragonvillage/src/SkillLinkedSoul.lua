local PARENT = Skill

-------------------------------------
-- class SkillLinkedSoul
-------------------------------------
SkillLinkedSoul = class(PARENT, {
        m_duration = 'num',
        m_target = 'Character',
		m_res = 'string',

        m_shieldEffect = 'Animator',
        m_barEffect = 'EffectLink',
        m_barrierEffect1 = 'Animator',
        m_barrierEffect2 = 'Animator',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLinkedSoul:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLinkedSoul:init_skill(duration, def_up_rate, res)
	PARENT.init_skill(self)

	-- 멤버 변수
	self.m_duration = duration
	self.m_res = res

	self:initRes(res)
end


-------------------------------------
-- function initRes
-------------------------------------
function SkillLinkedSoul:initRes(res)

    -- 연결 이펙트 -- @TODO groundnode..? 여기서만 사용중
    self.m_barEffect = EffectLink(res, 'bar_appear', '', '', 512, 256)
    self.m_world.m_groundNode:addChild(self.m_barEffect.m_node)
    self.m_barEffect.m_startPointNode:setVisible(false)
    self.m_barEffect.m_endPointNode:setVisible(false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)

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

    -- 방패 이펙트
    self.m_shieldEffect = MakeAnimator(res)
    self.m_shieldEffect:changeAni('shield_appear', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
    self.m_rootNode:addChild(self.m_shieldEffect.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLinkedSoul:initState()
	self:setCommonState(self)
    self:addState('start', SkillLinkedSoul.st_start, 'buff_effect', true)
    self:addState('idle', SkillLinkedSoul.st_idle, 'idle', true)
    self:addState('end', SkillLinkedSoul.st_end, 'ready', false)
end

-------------------------------------
-- function st_start
-------------------------------------
function SkillLinkedSoul.st_start(owner, dt)
    if owner:checkDead() then
        return
    end

    if (owner.m_stateTimer == 0) then
        owner:onStart()

        local function func()
            owner:changeState('idle')
        end

        owner:addAniHandler(func)
    end

    SkillLinkedSoul.st_common(owner, dt)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLinkedSoul.st_idle(owner, dt)
    if owner:checkDead() then
        return
    end

    SkillLinkedSoul.st_common(owner, dt)
end


-------------------------------------
-- function st_end
-------------------------------------
function SkillLinkedSoul.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:onEnd()

        -- 방패 이팩트
        owner.m_shieldEffect:changeAni('shield_disappear', false)
        
        -- 연결 이팩트
        owner.m_barEffect.m_effectNode:changeAni('bar_disappear', false)

        -- 베리어 이팩트
        owner.m_barrierEffect1:changeAni('barrier_disappear', false)
        owner.m_barrierEffect2:changeAni('barrier_disappear', false)

    elseif (owner.m_stateTimer >= 3) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function st_common
-------------------------------------
function SkillLinkedSoul.st_common(owner, dt)    
    if (owner.m_duration == -1) then
        return
    end

    owner.m_duration = owner.m_duration - dt

    if (owner.m_duration <= 0) then
        owner.m_duration = 0
        owner:changeState('end')
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillLinkedSoul:update(dt)

    local ret = PARENT.update(self, dt)
    
    -- 위치 갱신이 필요한지 확인
    self:checkBuffPosDirty()

    -- 위치 변경 처리
    if self.m_bDirtyPos then
        self:updateBuffPos()
    end

    return ret
end

-------------------------------------
-- function onStart
-------------------------------------
function SkillLinkedSoul:onStart()
end

-------------------------------------
-- function onHit
-------------------------------------
function SkillLinkedSoul:onHit()
    -- 방패 이팩트
    self.m_shieldEffect:changeAni('shield_hit', false)
    self.m_shieldEffect:addAniHandler(function() self.m_shieldEffect:changeAni('shield_idle', true) end)
        
    -- 연결 이팩트
    self.m_barEffect.m_effectNode:changeAni('bar_hit', false)
    self.m_barEffect.m_effectNode:addAniHandler(function() self.m_barEffect.m_effectNode:changeAni('bar_idle', true) end)

    -- 베리어 이팩트
    self.m_barrierEffect1:changeAni('barrier_hit', false)
    self.m_barrierEffect1:addAniHandler(function() self.m_barrierEffect1:changeAni('barrier_idle', true) end)

    self.m_barrierEffect2:changeAni('barrier_hit', false)
    self.m_barrierEffect2:addAniHandler(function() self.m_barrierEffect2:changeAni('barrier_idle', true) end)
end

-------------------------------------
-- function onEnd
-------------------------------------
function SkillLinkedSoul:onEnd()
end

-------------------------------------
-- function checkBuffPosDirty
-------------------------------------
function SkillLinkedSoul:checkBuffPosDirty()
    -- 본체 변경 확인
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
        return
    end

    -- 베리어 대상자 변경 확인
    local x = self.m_target.pos.x - self.pos.x
    local y = self.m_target.pos.y - self.pos.y
    if (self.m_barrierEffect2.m_posX ~= x) or (self.m_barrierEffect2.m_posY ~= y) then
        self.m_bDirtyPos = true
        return
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function SkillLinkedSoul:updateBuffPos()
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

    local x = self.m_target.pos.x - self.pos.x
    local y = self.m_target.pos.y - self.pos.y
    self.m_barrierEffect2:setPosition(x, y)
    self.m_shieldEffect:setPosition(x, y)

    EffectLink_refresh(self.m_barEffect, self.pos.x, self.pos.y, self.m_target.pos.x, self.m_target.pos.y)

    self.m_bDirtyPos = false
end

-------------------------------------
-- function release
-------------------------------------
function SkillLinkedSoul:release()
    PARENT.release(self)

    if self.m_barEffect then
        self.m_barEffect:release()
        self.m_barEffect = nil
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillLinkedSoul:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local duration = t_skill['val_1']
    local def_up_rate = t_skill['val_2']
	local res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillLinkedSoul(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(duration, def_up_rate, res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end