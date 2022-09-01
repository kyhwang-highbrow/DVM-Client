-------------------------------------
-- class MissileGuidTarget
-------------------------------------
MissileGuidTarget = class(Missile, {
        m_tergatTimer = 'number',
        m_angularVelocityGuid = 'number',
        m_straightWaitTime = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileGuidTarget:init(file_name, body, target)
    self.m_target = target
    self.m_tergatTimer = 0
    self.m_angularVelocityGuid = 360
    self.m_straightWaitTime = 0.3

    self:addAtkCallback(MissileGuidTarget.hitCB)
end

-------------------------------------
-- function hitCB
-- @brief 타겟에 맞았을 경우만 삭제
-------------------------------------
function MissileGuidTarget.hitCB(attacker, defender, i_x, i_y)
    if (attacker.m_target == defender) then
        attacker:changeState('dying')
    end
end

-------------------------------------
-- function initState
-------------------------------------
function MissileGuidTarget:initState()
    Missile.initState(self)
    self:addState('move', MissileGuidTarget.st_move_hero, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move_hero
-------------------------------------
function MissileGuidTarget.st_move_hero(owner, dt)

    -- 0.3초동안 직선 운동
    if owner.m_stateTimer == 0 then
        owner.m_aiParam = owner.m_angularVelocityGuid
        if (owner.m_target and not owner.m_target:isDead()) then
            if (owner.m_targetBody) then
                owner.m_targetPosX = owner.m_target.pos.x + owner.m_targetBody['x']
                owner.m_targetPosY = owner.m_target.pos.y + owner.m_targetBody['y']
            else
                
        end
    end

    elseif (owner.m_stateTimer >= owner.m_straightWaitTime) and (owner.m_aiParam > 0) then
        owner.m_tergatTimer = owner.m_tergatTimer + dt
        owner.m_targetPosX, owner.m_targetPosY = owner.m_target:getCenterPos()
        if owner.m_targetPosX and owner.m_targetPosY then
            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
            local new_degree, gap = getRotationDegree(curr_degree, dest_degree, dt * owner.m_aiParam)

            owner:setDir(new_degree)
            owner:setRotation(new_degree)

            owner.m_aiParam = owner.m_aiParam + (dt * dt * 900)
       
        end

    -- 5초 이상 지속 시 미사일 삭제
    elseif owner.m_stateTimer >= 5 then
        owner:changeState('dying')
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