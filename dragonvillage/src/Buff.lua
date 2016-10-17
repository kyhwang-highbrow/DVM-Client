-------------------------------------
-- class Buff
-------------------------------------
Buff = class(Entity, {
        m_owner = 'Character',
        m_duration = 'number',
        m_bStartBuff = 'boolean',
        m_bFinish = 'boolean',
        m_bDirtyPos = 'boolean', -- 위치가 변경되어 이펙트 수정이 필요한 경우
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Buff:init(file_name, body, ...)
    self:initState()

    self.m_duration = -1
    self.m_bStartBuff = false
    self.m_bFinish = false
    self.m_bDirtyPos = true
end


-------------------------------------
-- function init_buff
-------------------------------------
function Buff:init_buff(owner, duration)
    self.m_owner = owner
    self.m_duration = duration
end

-------------------------------------
-- function initState
-------------------------------------
function Buff:initState()
    self:addState('start', Buff.st_start, 'buff_effect', false)
    self:addState('idle', Buff.st_idle, 'idle', true)
    self:addState('end', Buff.st_end, 'ready', false)
    self:addState('dying', function(owner, dt) owner:endBuff() return true end, nil, nil, 10)
    self:changeState('start')
end


-------------------------------------
-- function update
-------------------------------------
function Buff:update(dt)

    local ret = Entity.update(self, dt)
    
    -- 위치 갱신이 필요한지 확인
    self:checkBuffPosDirty()

    -- 위치 변경 처리
    if self.m_bDirtyPos then
        self:updateBuffPos()
    end

    return ret
end

-------------------------------------
-- function checkBuffPosDirty
-------------------------------------
function Buff:checkBuffPosDirty()
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
    end
end

-------------------------------------
-- function updateBuffPos
-------------------------------------
function Buff:updateBuffPos()
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    self.m_bDirtyPos = false
end



-------------------------------------
-- function st_start
-------------------------------------
function Buff.st_start(owner, dt)
    if owner:checkDead() then
        return
    end

    if (owner.m_stateTimer == 0) then
        owner:startBuff()

        local function func()
            owner:changeState('idle')
        end

        owner:addAniHandler(func)
    end

    Buff.st_commont(owner, dt)
end

-------------------------------------
-- function st_idle
-------------------------------------
function Buff.st_idle(owner, dt)
    if owner:checkDead() then
        return
    end

    Buff.st_commont(owner, dt)
end

-------------------------------------
-- function st_end
-------------------------------------
function Buff.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:endBuff()

        local function func()
            owner:changeState('dying')
        end

        owner:addAniHandler(func)
    end
end

-------------------------------------
-- function st_commont
-------------------------------------
function Buff.st_commont(owner, dt)    
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
-- function checkDead
-------------------------------------
function Buff:checkDead()
    if self.m_owner.m_bDead then
        self:changeState('end')
        return true
    end

    return false
end

-------------------------------------
-- function startBuff
-------------------------------------
function Buff:startBuff()
    if self.m_bStartBuff then
        return
    end

    self.m_bStartBuff = true
    self.m_bFinish = false

    self:onStart()
end

-------------------------------------
-- function endBuff
-------------------------------------
function Buff:endBuff()
    if self.m_bFinish then
        return
    end

    self.m_bFinish = true

    self:onEnd()
end

-------------------------------------
-- function release
-------------------------------------
function Buff:release()
    self:endBuff()
    Entity.release(self)
end