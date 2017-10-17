-------------------------------------
-- class MissileCurve
-------------------------------------
MissileCurve = class(Missile, {
        m_target = '',
        m_bHero = 'boolean',

        m_cStartPosX = '',
        m_cStartPosY = '',
        m_cDir = '',

        m_boomerangCalc = 'BoomerangCalc',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileCurve:init(file_name, body, is_hero, target)
    self.m_bHero = is_hero
    self.m_target = target
end

-------------------------------------
-- function initState
-------------------------------------
function MissileCurve:initState()
    Missile.initState(self)

    self:addState('move', MissileCurve.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileCurve.st_move(owner, dt)
    if owner.m_stateTimer == 0 then
        owner.m_cStartPosX = owner.pos.x
        owner.m_cStartPosY = owner.pos.y


        local target_x = 0
        local target_y = 0

        if (not owner.m_target) then
            if owner.m_bHero then
                owner.m_target = owner.m_world:findTarget('enemy', owner.pos.x + owner.body.x, owner.pos.y + owner.body.y)
            else
                owner.m_target = owner.m_world:findTarget('hero', owner.pos.x + owner.body.x, owner.pos.y + owner.body.y)
            end
        end

        if owner.m_target then
            target_x = owner.m_target.pos.x
            target_y = owner.m_target.pos.y
        end

        local dist = getDistance(owner.m_cStartPosX, owner.m_cStartPosY, target_x, target_y)
        owner.m_boomerangCalc = BoomerangCalc(BoomerangCalc.DIR_RIGHT, dist)

        owner.m_cDir = getDegree(owner.m_cStartPosX, owner.m_cStartPosY, target_x, target_y)

        owner:setSpeed(0)
        owner:setRotation(owner.m_cDir + 90)
    else
        owner.m_boomerangCalc:update(dt)

        local dir = getDegree(0, 0, owner.m_boomerangCalc.m_posX, owner.m_boomerangCalc.m_posY)
        local dist = getDistance(0, 0, owner.m_boomerangCalc.m_posX, owner.m_boomerangCalc.m_posY)
        local pos = getPointFromAngleAndDistance(owner.m_cDir + dir, dist)

        local x = owner.m_cStartPosX + pos['x']
        local y = owner.m_cStartPosY + pos['y']
        owner:setPosition(x, y)
    end


    -- 2초가 지나면 제자리로 돌아오기 때문에 삭제한다.
    if owner.m_stateTimer >= BoomerangCalc.DURATION then
        owner:changeState('dying')
    elseif owner.m_stateTimer >= (BoomerangCalc.DURATION-0.2) then
        local alpha = owner.m_animator:getAlpha()
        alpha = alpha - (dt * 5)
        alpha = math_max(alpha, 0)
        owner.m_animator:setAlpha(alpha)
    end
end


-------------------------------------
-- class BoomerangCalc
-- @brief 0도를 기준으로 발사되는 부메랑 궤적을 계산
-------------------------------------
BoomerangCalc = class({
        m_movementTheta = 'number',
        m_movementX = 'number',
        m_movementY = 'number',

        m_dirType = '',

        m_speed = 'number',
        m_distance = 'number',

        m_posX = 'number',
        m_posY = 'number',
    })

BoomerangCalc.DIR_RIGHT = 1
BoomerangCalc.DIR_LEFT = 2
BoomerangCalc.DURATION = 4

-------------------------------------
-- function init
-------------------------------------
function BoomerangCalc:init(dir, distance)

    self.m_dirType = dir

    if (dir == BoomerangCalc.DIR_RIGHT) then
        self:setDir(270)
    else--if (dir == BoomerangCalc.DIR_LEFT) then
        self:setDir(90)
    end

    self.m_distance = distance
    self.m_speed = distance / 0.63 / (BoomerangCalc.DURATION / 2)

    self.m_posX = 0
    self.m_posY = 0

end

-------------------------------------
-- function setDir
-------------------------------------
function BoomerangCalc:setDir(theta)
    self.m_movementTheta = theta
    self.m_movementX = math_cos(math_rad(theta))
    self.m_movementY = math_sin(math_rad(theta))
end


-------------------------------------
-- function update
-------------------------------------
function BoomerangCalc:update(dt)
    local curr_degree = self.m_movementTheta
    local new_degree = curr_degree


    if (self.m_dirType == BoomerangCalc.DIR_RIGHT) then
        new_degree = new_degree + 45
    else--if (dir == BoomerangCalc.DIR_LEFT) then
        new_degree = new_degree - 45
    end

    -- 1초만에 도착 지점에 도착해야 하므로(반원) 초당 180도를 회전한다.
    local rotate = 360 / BoomerangCalc.DURATION
    local dir = getRotationDegree(curr_degree, new_degree, dt * rotate)
    self:setDir(dir)

    -- 부메랑처럼 타원의 궤적을 그리기 위해 movement_y의 값을 축소한다.
    self.m_movementY = self.m_movementY * 0.2

    -- 이동
    self.m_posX = self.m_posX + (self.m_speed * self.m_movementX * dt)
    self.m_posY = self.m_posY + (self.m_speed * self.m_movementY * dt)
end