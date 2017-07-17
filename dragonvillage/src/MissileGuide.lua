-------------------------------------
-- class MissileGuide
-------------------------------------
MissileGuide = class(Missile, {
        m_target = 'Enemy',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileGuide:init(file_name, body)
    self.m_target = nil
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
	if (owner.m_stateTimer >= 0) then
        -- 타겟이 없거나, 타겟이 죽었을 경우 다음 타겟을 찾는다.
        if (owner.m_target == nil or owner.m_target:isDead()) then
			local l_target = owner.m_owner:getTargetListByType('enemy_distance_line', nil, nil)
            owner.m_target = l_target[1]
        end

        if owner.m_target then
            owner.m_targetPosX, owner.m_targetPosY = owner.m_target:getCenterPos()

            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
            
			if (curr_degree ~= dest_degree) then
				owner:setDir(dest_degree)
				if not (owner.m_bNoRotate) then
					owner:setRotation(dest_degree)
				end
			end
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