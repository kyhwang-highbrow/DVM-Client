-------------------------------------
-- class MissileTarget
-------------------------------------
MissileTarget = class(Missile, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileTarget:init(file_name, body)
end

-------------------------------------
-- function initState
-------------------------------------
function MissileTarget:initState()
    Missile.initState(self)

    self:addState('move', MissileTarget.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileTarget.st_move(owner, dt)

    if owner.m_stateTimer == 0 then
        local dir = 0
        local target = owner.m_world:findTarget(owner.m_owner, owner.pos.x + owner.body.x, owner.pos.y + owner.body.y)
        
        if target then
            dir = getDegree(owner.pos.x + owner.body.x, owner.pos.y + owner.body.y, target.pos.x + target.body.x, target.pos.y + target.body.y)
        end

        owner:setDir(dir)
        owner:setRotation(dir)
    end


    -- 가속 여부(가속도가 양수이고, 가속 딜레이가 없거나, 가속 딜레이의 시간이 지났을 경우
    local can_accel = (owner.m_acceleration ~= 0) and ((not owner.m_accelDelay) or (owner.m_stateTimer >= owner.m_accelDelay))

    if can_accel then
        local speed = owner.speed + (owner.m_acceleration * dt)
        speed = owner:getAdjustSpeed(speed)
        owner:setSpeed(speed)
    end

    -- 옵션 체크
    owner:updateMissileOption(dt)
end