-------------------------------------
-- class MissileDropGuid
-------------------------------------
MissileDropGuid = class(Missile, {
        m_baseSpeed = '',
        m_bHero = 'boolean',
        m_target = 'Enemy',
        m_tergatTimer = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileDropGuid:init(file_name, body, is_hero)
    self.m_baseSpeed = 0
    self.m_bHero = is_hero
    self.m_target = nil
    self.m_tergatTimer = 0
end

-------------------------------------
-- function initState
-------------------------------------
function MissileDropGuid:initState(file_name, body, is_hero)
    Missile.initState(self)

    self:addState('move', MissileDropGuid.st_move, 'move', true)
    self:addState('wait', MissileDropGuid.st_wait, 'move', true)

    if is_hero then
        self:addState('move_drop', MissileDropGuid.st_move_drop_hero, 'move', true)
    else
        self:addState('move_drop', MissileDropGuid.st_move_drop, 'move', true)
    end
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileDropGuid.st_move(owner, dt)

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
function MissileDropGuid.st_wait(owner, dt)
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
function MissileDropGuid.st_move_drop(owner, dt)
    if owner.m_stateTimer == 0 then
        owner.m_aiParam = 180
        owner:setDir(270)
    elseif owner.m_aiParam > 0 then
        local target = owner.m_world:findTarget('hero', owner.pos.x + owner.body.x, owner.pos.y + owner.body.y)

        if (target and not target:isDead()) then
            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, target.pos.x, target.pos.y)
            local new_degree, gap = getRotationDegree(curr_degree, dest_degree, dt * owner.m_aiParam)

            --if gap <= 45 then
                --owner:setTargetPos(owner.ai_param.pos.x, owner.ai_param.pos.y)
                owner:setDir(new_degree)
                owner:setRotation(new_degree)
            --end
        end

        owner.m_aiParam = owner.m_aiParam - (dt * 225)

    elseif owner.m_stateTimer > 5 then
        owner:changeState('dying')
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

    -- 옵션 체크
    owner:updateMissileOption(dt)
end

-------------------------------------
-- function st_move_drop_hero
-------------------------------------
function MissileDropGuid.st_move_drop_hero(owner, dt)
    -- 0.3초동안 직선 운동
    if owner.m_stateTimer == 0 then
        owner.m_aiParam = 240
        owner:setDir(90)

    elseif (owner.m_stateTimer >= 0.3) and (owner.m_aiParam > 0) then
        owner.m_tergatTimer = owner.m_tergatTimer + dt

        -- 타겟이 없거나, 타겟이 죽었거나, 타겟 시간이 초과되었을 경우
        if (owner.m_target == nil) or (owner.m_target:isDead()) or (owner.m_tergatTimer >= 0.3) then
            --------------------------------------------------------------
            local enemy = nil
            local boss_enemy = nil
            local distance = nil
            for i,v in pairs(GameMgr.m_rightParticipants) do
                if not isInstanceOf(v, Monster) then
                elseif v:isDead() then
                elseif checkDefaultRange(v.pos.x, v.pos.y) then
                else
                    -- 보스 확인
                    local is_boss_enemy = isInstanceOf(v, Boss) or isInstanceOf(v, Castle) or isInstanceOf(v, SubBoss)
                    if is_boss_enemy then
                        boss_enemy = v
                    end

                    local cur_dir = owner.movement_theta
                    local dest_dir = getDegree(owner.pos.x, owner.pos.y, v.pos.x, v.pos.y)
                    local new_degree, gap = getRotationDegree(cur_dir, dest_dir, 360)

                    if gap < 90 then
                        local dist = getDistanceFromTwoPoint({x=owner.pos.x, y=owner.pos.y}, {x=v.pos.x, y=v.pos.y})
                        if (not distance) or (dist < distance) then
                            distance = dist
                            enemy = v
                        end
                    end
                end
            end
            owner.m_target = boss_enemy or enemy
            --------------------------------------------------------------
        end

        if owner.m_target then
            owner.m_targetPosX = owner.m_target.pos.x + owner.m_target.body.x
            owner.m_targetPosY = owner.m_target.pos.y + owner.m_target.body.y

            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
            local new_degree, gap = getRotationDegree(curr_degree, dest_degree, dt * owner.m_aiParam)

            owner:setDir(new_degree)
            owner:setRotation(new_degree)

            owner.m_aiParam = owner.m_aiParam - (dt * 400)
        end

    -- 5초 이상 지속 시 미사일 삭제
    elseif owner.m_stateTimer >= 5 then
        owner:changeState('dying')
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

    -- 옵션 체크
    owner:updateMissileOption(dt)
end