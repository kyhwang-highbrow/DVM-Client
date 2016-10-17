-------------------------------------
-- class MissileDropRandom
-------------------------------------
MissileDropRandom = class(Missile, {
        m_bHero = 'boolean',

        m_randomTime = 'number',
        m_randomDirA = 'number',
        m_randomDirB = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileDropRandom:init(file_name, body, is_hero)
    self.m_bHero = is_hero
    
    -- 기본값
    self.m_randomTime = 0.5
    self.m_randomDirA = -50
    self.m_randomDirB = 50
end

-------------------------------------
-- function initState
-------------------------------------
function MissileDropRandom:initState(file_name, body, is_hero)
    Missile.initState(self)

    self:addState('move', MissileDropRandom.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileDropRandom.st_move(owner, dt)

    -- m_randomTime시간마다 DirA ~ DirB의 각도로 랜덤하게 방향전환
    if owner.m_stateTimer == 0 then
        owner.m_aiParam = 0
    else
        owner.m_aiParam = owner.m_aiParam - dt
        if owner.m_aiParam <= 0 then
            owner.m_aiParam = owner.m_aiParam + owner.m_randomTime

            local random_dir = math_random(owner.m_randomDirA, owner.m_randomDirB)
            owner:setDir(random_dir)
            owner:setRotation(random_dir)
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