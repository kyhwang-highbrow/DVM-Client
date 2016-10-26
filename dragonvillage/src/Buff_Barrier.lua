-------------------------------------
-- class Buff_Barrier
-- @brief 방어 횟수가 있는 보호막
-------------------------------------
Buff_Barrier = class(Buff, clone(IEventListener), {
		m_defCount = 'num',
        m_barrierEffect = 'Animator',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Buff_Barrier:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_buff
-------------------------------------
function Buff_Barrier:init_buff(owner, t_skill)
	self.m_owner = owner
    
    local duration = t_skill['val_1'] -- 지속 시간 (단위 : 초)
    local def_count = t_skill['val_2'] -- 방어 횟수
	
	self.m_defCount = def_count

    Buff.init_buff(self, owner, duration)

    -- 베리어 이펙트
	local res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
    self.m_barrierEffect = MakeAnimator(res)
    self.m_barrierEffect:changeAni('appear', false)
    self.m_barrierEffect:addAniHandler(function() self.m_barrierEffect:changeAni('idle', true) end)
    self.m_rootNode:addChild(self.m_barrierEffect.m_node)

	-- 이벤트리스너 등록
	self.m_owner:addListener('hit_barrier', self)
end

-------------------------------------
-- function initState
-----------------/--------------------
function Buff_Barrier:initState()
    Buff.initState(self)

    self:addState('end', Buff_Barrier.st_end, nil, false)
end

-------------------------------------
-- function st_end
-------------------------------------
function Buff_Barrier.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:endBuff()
		owner:release_listener()

        -- 베리어 이팩트
        owner.m_barrierEffect:changeAni('disappear', false)

    elseif (owner.m_stateTimer >= 3) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function checkDead
-------------------------------------
function Buff_Barrier:checkDead()
    if (self.m_owner.m_bDead or self.m_defCount == 0) then
        self:changeState('end')
        return true
    end

    return false
end

-------------------------------------
-- function onStart
-------------------------------------
function Buff_Barrier:onStart()
    if (self.m_owner.m_buffProtection) then
        self.m_owner.m_buffProtection:changeState('dying')
    end
    
    self.m_owner.m_buffProtection = self

end


-------------------------------------
-- function onHit
-------------------------------------
function Buff_Barrier:onHit()
    -- 베리어 이팩트
    self.m_barrierEffect:changeAni('hit', false)
    self.m_barrierEffect:addAniHandler(function() self.m_barrierEffect:changeAni('idle', true) end)
end

-------------------------------------
-- function onEnd
-------------------------------------
function Buff_Barrier:onEnd()
    -- 이벤트리스너 등록
	self.m_owner:removeListener('hit_barrier', self)

    if (self.m_owner.m_buffProtection == self) then
        self.m_owner.m_buffProtection = nil
    end
end

-------------------------------------
-- function checkBuffPosDirty
-------------------------------------
function Buff_Barrier:checkBuffPosDirty()
    -- 본체 변경 확인
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
        return
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function Buff_Barrier:updateBuffPos()
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

    self.m_bDirtyPos = false
end

-------------------------------------
-- function onEvent
-------------------------------------
function Buff_Barrier:onEvent(event_name, ...)
    if (self.m_defCount <= 0) then
        self:changeState('dying')
        return false
    end

    self.m_defCount = self.m_defCount - 1
	-- 맞는 연출
	self:onHit()
    
	return true
end