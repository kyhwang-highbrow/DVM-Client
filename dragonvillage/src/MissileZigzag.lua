-------------------------------------
-- class MissileZigzag
-------------------------------------
MissileZigzag = class(Missile, {
        m_baseDir = 'number',
        m_zigzagDir = 'number',
        m_targetDir = 'number',
        m_zigzagRotation = 'number',
        m_leftOrRight = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileZigzag:init(file_name, body)
    self.m_baseDir = 270
    self.m_zigzagDir = 90
    self.m_targetDir = 270
    self.m_zigzagRotation = 0
    self.m_leftOrRight = true
end

-------------------------------------
-- function initState
-------------------------------------
function MissileZigzag:initState()
    Missile.initState(self)

    self:addState('move', MissileZigzag.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileZigzag.st_move(owner, dt)

    -- 가속 여부(가속도가 양수이고, 가속 딜레이가 없거나, 가속 딜레이의 시간이 지났을 경우
    local can_accel = (owner.m_acceleration ~= 0) and ((not owner.m_accelDelay) or (owner.m_stateTimer >= owner.m_accelDelay))

    -- 가속도 지정
    if can_accel then    
        local speed = owner.speed + (owner.m_acceleration * dt)
        speed = owner:getAdjustSpeed(speed)
        owner:setSpeed(speed)

        -- 속도에 비례하게 회전량 지정
        owner.m_zigzagRotation = 720 * (owner.speed / 1000)
    end

    if owner.m_stateTimer == 0 then
        owner.m_baseDir = owner.movement_theta
        
        -- left
        if owner.m_leftOrRight then
            owner.m_zigzagDir = 90
            owner.m_targetDir = 270
        -- right
        else
            owner.m_zigzagDir = 270
            owner.m_targetDir = 90
        end

        owner:setDir(owner.m_baseDir)
        owner:setRotation(owner.m_baseDir)

        -- 속도에 비례하게 회전량 지정
        owner.m_zigzagRotation = 720 * (owner.speed / 1000)
    else
        if owner.m_zigzagDir >= owner.m_targetDir then
            owner.m_targetDir = math_max(90, owner.m_zigzagDir - 45)
            owner.m_zigzagDir = getRotationDegree(owner.m_zigzagDir, owner.m_targetDir, dt * owner.m_zigzagRotation)

            if owner.m_zigzagDir == owner.m_targetDir then
                owner.m_targetDir = owner.m_zigzagDir + 45
            end
        else
            owner.m_targetDir = math_min(270, owner.m_zigzagDir + 45)
            owner.m_zigzagDir = getRotationDegree(owner.m_zigzagDir, owner.m_targetDir, dt * owner.m_zigzagRotation)

            if owner.m_zigzagDir == owner.m_targetDir then
                owner.m_targetDir = owner.m_zigzagDir - 45
            end
        end
        
        owner:setDir(owner.m_baseDir + (owner.m_zigzagDir - 180))
        owner:setRotation(owner.m_baseDir + (owner.m_zigzagDir - 180))
    end

    -- 옵션 체크
    owner:updateMissileOption(dt)
end