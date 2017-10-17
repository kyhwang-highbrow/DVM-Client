-------------------------------------
-- class MissileDropZigzag
-------------------------------------
MissileDropZigzag = class(Missile, {
        m_baseSpeed = '',

        m_baseDir = 'number',
        m_zigzagDir = 'number',
        m_targetDir = 'number',
        m_zigzagRotation = 'number',
        m_leftOrRight = 'boolean',
        m_bHero = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileDropZigzag:init(file_name, body, is_hero)
    self.m_baseSpeed = 0

    self.m_baseDir = 270
    self.m_zigzagDir = 90
    self.m_targetDir = 270
    self.m_zigzagRotation = 0
    self.m_leftOrRight = true
    self.m_bHero = is_hero
end

-------------------------------------
-- function initState
-------------------------------------
function MissileDropZigzag:initState()
    Missile.initState(self)

    self:addState('move', MissileDropZigzag.st_move, 'move', true)
    self:addState('wait', MissileDropZigzag.st_wait, 'move', true)
    self:addState('move_drop', MissileDropZigzag.st_move_drop, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileDropZigzag.st_move(owner, dt)

    if owner.m_stateTimer == 0 then
        owner.m_baseSpeed = owner.speed

        -- 200픽셀을 이동하는데 소요되는 시간
        owner.m_aiParam = 200 / owner.speed * 2

        local angle = owner.movement_theta
        local distance = 200
        local dest_point = getPointFromAngleAndDistance(angle, distance)
        owner:setTargetPos(owner.pos.x + dest_point.x, owner.pos.y + dest_point.y)

    elseif owner:isOverTargetPos() then
        owner:setPosition(owner.m_targetPosX, owner.m_targetPosY)
        owner:setSpeed(0)
        owner:changeState('wait')
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
function MissileDropZigzag.st_wait(owner, dt)
    if owner.m_stateTimer >= (owner.m_aiParam/10) then
        owner:changeState('move_drop')
    end
end

-------------------------------------
-- function st_move_drop
-------------------------------------
function MissileDropZigzag.st_move_drop(owner, dt)

    if owner.m_stateTimer == 0 then
        if owner.m_acceleration == 0 then
            owner.speed = owner.m_baseSpeed
        end

        -- 영웅의 경우 위로, 적군은 아래로 공격
        if owner.m_bHero then
            owner:setDir(90)
        else
            owner:setDir(270)
        end
    end

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

    -- 속도에 비례하게 회전량 지정
    owner.m_zigzagRotation = 720 * (owner.speed / 1000)

    if owner.m_stateTimer == 0 then
        owner.m_baseDir = owner.movement_theta
        
        -- 영웅의 경우 반대 방향
        if owner.m_bHero then
            -- left
            if owner.m_leftOrRight then
                owner.m_zigzagDir = 270
                owner.m_targetDir = 90
            -- right
            else
                owner.m_zigzagDir = 90
                owner.m_targetDir = 270
            end
        else
            -- left
            if owner.m_leftOrRight then
                owner.m_zigzagDir = 90
                owner.m_targetDir = 270
            -- right
            else
                owner.m_zigzagDir = 270
                owner.m_targetDir = 90
            end
        end


        owner:setDir(owner.m_baseDir)

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
    end

    -- 옵션 체크
    owner:updateMissileOption(dt)
end