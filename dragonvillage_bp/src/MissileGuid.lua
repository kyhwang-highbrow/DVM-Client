-------------------------------------
-- class MissileGuid
-------------------------------------
MissileGuid = class(Missile, {
        m_bHero = 'boolean',
        m_target = 'Enemy',
        m_tergatTimer = 'number',
        m_angularVelocityGuid = 'number',
        m_straightWaitTime = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileGuid:init(file_name, body, is_hero)
    self.m_bHero = is_hero
    self.m_target = nil
    self.m_tergatTimer = 0
    self.m_straightWaitTime = 0.3

    if self.m_bHero then
        self.m_angularVelocityGuid = 240
    else
        self.m_angularVelocityGuid = 500
    end
end

-------------------------------------
-- function initState
-------------------------------------
function MissileGuid:initState()
    Missile.initState(self)

    if self.m_bHero then
        self:addState('move', MissileGuid.st_move_hero, 'move', true)
    else
        self:addState('move', MissileGuid.st_move, 'move', true)
    end
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileGuid.st_move(owner, dt)
    -- 0.3초동안 직선 운동
    if (owner.m_stateTimer == 0) then
        owner.m_aiParam = owner.m_angularVelocityGuid

    elseif (owner.m_stateTimer >= 0.3) and (owner.m_aiParam > 0) then
        owner.m_tergatTimer = owner.m_tergatTimer + dt

        -- 타겟이 없거나, 타겟이 죽었을 경우 .. 0.3 초 이후 매 프레임 타겟을 찾던 것은 제외
        if (owner.m_target == nil or owner.m_target:isDead()) then 
            owner.m_target = owner.m_world:findTarget('hero', owner.pos.x + owner.body.x, owner.pos.y + owner.body.y)
        end

        if owner.m_target then
            owner.m_targetPosX, owner.m_targetPosY = owner.m_target:getCenterPos()

            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
            local new_degree, gap = getRotationDegree(curr_degree, dest_degree, dt * owner.m_aiParam)

            owner:setDir(new_degree)
            owner:setRotation(new_degree)

            owner.m_aiParam = owner.m_aiParam - (dt * dt * 900)
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

-------------------------------------
-- function st_move_hero
-------------------------------------
function MissileGuid.st_move_hero(owner, dt)

    -- 0.3초동안 직선 운동
    if (owner.m_stateTimer == 0) then
        owner.m_aiParam = owner.m_angularVelocityGuid

    elseif (owner.m_stateTimer >= owner.m_straightWaitTime) and (owner.m_aiParam > 0) then
        owner.m_tergatTimer = owner.m_tergatTimer + dt

        -- 타겟이 없거나, 타겟이 죽었을 경우 .. 0.3 초 이후 매 프레임 타겟을 찾던 것은 제외
        if (owner.m_target == nil or owner.m_target:isDead()) then
            owner.m_target = owner.m_world:findTarget('enemy', owner.pos.x + owner.body.x, owner.pos.y + owner.body.y)
        end

        if owner.m_target then
            owner.m_targetPosX = owner.m_target.pos.x + owner.m_target.body.x
            owner.m_targetPosY = owner.m_target.pos.y + owner.m_target.body.y

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