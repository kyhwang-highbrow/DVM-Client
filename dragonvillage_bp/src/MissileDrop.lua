-------------------------------------
-- class MissileDrop
-------------------------------------
MissileDrop = class(Missile, {
        m_baseSpeed = '',
        m_bHero = 'boolean',

        m_dropDir = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileDrop:init(file_name, body, is_hero)
    self.m_baseSpeed = 0
    self.m_bHero = is_hero
    self.m_dropDir = 180
end

-------------------------------------
-- function initState
-------------------------------------
function MissileDrop:initState()
    Missile.initState(self)

    self:addState('move', MissileDrop.st_move, 'move', true)
    self:addState('wait', MissileDrop.st_wait, 'move', true)
    self:addState('move_drop', MissileDrop.st_move_drop, 'move', true)
    self:addState('move_accel', MissileDrop.st_move_accel, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileDrop.st_move(owner, dt)

    if owner.m_stateTimer == 0 then
        owner.m_baseSpeed = owner.speed

        -- 200픽셀을 이동하는데 소요되는 시간
        owner.m_aiParam = 50 / owner.speed * 2

        local angle = owner.movement_theta
        local distance = 50
        local dest_point = getPointFromAngleAndDistance(angle, distance)
        owner:setTargetPos(owner.pos.x + dest_point.x, owner.pos.y + dest_point.y)

    elseif owner:isOverTargetPos() then
        owner:setPosition(owner.m_targetPosX, owner.m_targetPosY)
        owner:setSpeed(0)
        if owner.m_acceleration ~= 0 then
            owner:changeState('move_accel')
        else
            owner:changeState('wait')
        end
        return
    end

    local rate = (owner.m_aiParam - owner.m_stateTimer) / owner.m_aiParam
    rate = math_max(rate, 0)
    rate = math_min(rate, 1)
    owner:setSpeed(owner.m_baseSpeed * 2 * rate)
end

-------------------------------------
-- function st_wait
-------------------------------------
function MissileDrop.st_wait(owner, dt)
    if owner.m_stateTimer == 0 then
        owner:setSpeed(0)
    end

    if owner.m_stateTimer >= (owner.m_aiParam/10) then
        owner:changeState('move_drop')
    end
end

-------------------------------------
-- function st_move_drop
-------------------------------------
function MissileDrop.st_move_drop(owner, dt)

    if owner.m_stateTimer == 0 then
        owner:setDir(owner.m_dropDir)
    else
        local rate = owner.m_stateTimer / 0.5
        rate = math_max(rate, 0)
        rate = math_min(rate, 1)
        owner:setSpeed(owner.m_baseSpeed * rate)
    end

    -- 옵션 체크
    owner:updateMissileOption(dt)
end

-------------------------------------
-- function st_move_free
-------------------------------------
function MissileDrop.st_move_accel(owner, dt)
    if owner.m_stateTimer == 0 then
        owner:setDir(owner.m_dropDir)
    else
        -- 가속 여부(가속도가 양수이고, 가속 딜레이가 없거나, 가속 딜레이의 시간이 지났을 경우
        local can_accel = (owner.m_acceleration ~= 0) and ((not owner.m_accelDelay) or (owner.m_stateTimer >= owner.m_accelDelay))

        -- 가속 상태에 따른 속도 지정
        if (not can_accel) then        
            local rate = owner.m_stateTimer / 0.25
            rate = math_max(rate, 0)
            rate = math_min(rate, 1)
            owner:setSpeed(owner.m_baseSpeed * rate)
        else
            local speed = owner.speed + (owner.m_acceleration * dt)
            speed = owner:getAdjustSpeed(speed)
            owner:setSpeed(speed)
        end
    end

    -- 옵션 체크
    owner:updateMissileOption(dt)
end