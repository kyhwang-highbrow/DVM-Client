-------------------------------------
-- class MissileGuide
-- @breif 각속도를 사용하지 않고 목표 대상의 방향으로 이동
-------------------------------------
MissileGuide = class(Missile, {
        m_target = 'Enemy',
        m_angularVelocityGuid = 'number',
        m_accelAngularVelocityGuid = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileGuide:init(file_name, body)
    self.m_target = nil
    self.m_angularVelocityGuid = 240
    self.m_accelAngularVelocityGuid = 90
end

-------------------------------------
-- function initState
-------------------------------------
function MissileGuide:initState()
    Missile.initState(self)
    self:addState('move', MissileGuide.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileGuide.st_move(owner, dt)
	if (owner.m_stateTimer == 0) then
        owner.m_aiParam = owner.m_angularVelocityGuid

    -- 5초 이상 지속 시 미사일 삭제
    elseif (owner.m_stateTimer >= 5) then
        owner:changeState('dying')

    else
        -- 타겟이 없거나, 타겟이 죽었을 경우 다음 타겟을 찾는다.
        if (owner.m_target == nil or owner.m_target:isDead()) then
			local l_target = owner.m_owner:getTargetListByType('enemy_distance_line', nil, nil)
            owner.m_target = l_target[1]
            owner.m_targetBody = nil
        end

        if (owner.m_target) then
            if (owner.m_targetBody) then
                owner.m_targetPosX = owner.m_target.pos.x + owner.m_targetBody['x']
                owner.m_targetPosY = owner.m_target.pos.y + owner.m_targetBody['y']
            else
                owner.m_targetPosX, owner.m_targetPosY = owner.m_target:getCenterPos()
            end

            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
            local new_degree, gap = getRotationDegree(curr_degree, dest_degree, dt * owner.m_aiParam)
            
			owner:setDir(dest_degree)
			owner:setRotation(dest_degree)
			
            owner.m_aiParam = owner.m_aiParam + (dt * owner.m_accelAngularVelocityGuid)
        end
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