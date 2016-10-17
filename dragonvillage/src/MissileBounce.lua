-------------------------------------
-- class MissileBounce
-------------------------------------
MissileBounce = class(Missile, {
        m_target = 'Enemy',
        m_isHero = '',
        m_lPhysKey = '',

        m_bounceCount = '',
        m_bounceCountMax = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileBounce:init(file_name, body, target, is_hero)
    self.m_target = target
    self.m_isHero = is_hero
    self.m_lPhysKey = {}
    
    self.m_bounceCountMax = 3
    self.m_bounceCount = 0

    self:addAtkCallback(MissileBounce.hitCB)
end

-------------------------------------
-- function hitCB
-- @brief 타겟에 맞았을 경우만 삭제
-------------------------------------
function MissileBounce.hitCB(attacker, defender, i_x, i_y)

    
    local self = attacker
    self.m_bounceCount = self.m_bounceCount + 1

    table.insert(self.m_lPhysKey, defender.phys_idx)
    
    if self.m_isHero then
        self.m_target = attacker.m_world:findTarget('enemy', self.pos.x + self.body.x, self.pos.y + self.body.y, self.m_lPhysKey)
    else
        self.m_target = attacker.m_world:findTarget('hero', self.pos.x + self.body.x, self.pos.y + self.body.y, self.m_lPhysKey)
    end

    if (self.m_bounceCount <= 2) then
        self.speed = self.speed * 1.1
    end

    if (not self.m_target) or (self.m_bounceCount >= self.m_bounceCountMax) then
        self:changeState('dying')
    end
end

-------------------------------------
-- function initState
-------------------------------------
function MissileBounce:initState()
    Missile.initState(self)
    self:addState('move', MissileBounce.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileBounce.st_move(owner, dt)


    -- 타겟의 위치로 계속 쫓아감 (없거나 죽을 경우 직선)
    if owner.m_target and (owner.m_target.m_bDead == false) then
        owner.m_targetPosX = owner.m_target.pos.x + owner.m_target.body.x
        owner.m_targetPosY = owner.m_target.pos.y + owner.m_target.body.y

        local curr_degree = owner.movement_theta
        local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
        owner:setDir(dest_degree)
        owner:setRotation(dest_degree)
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