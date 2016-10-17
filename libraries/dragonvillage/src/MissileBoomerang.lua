-------------------------------------
-- class MissileBoomerang
-------------------------------------
MissileBoomerang = class(Missile, {
        m_leftOrRight = 'boolean',

        -- 던지는 위치를 고정할건지 여부
        m_bFix = 'boolean',
        m_duration = 'number',

        m_bHero = 'boolean',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileBoomerang:init(file_name, body, is_hero)
    self.m_leftOrRight = nil
    self.m_bFix = false
    self.m_duration =  2
    self.m_bHero = is_hero
end

-------------------------------------
-- function initState
-------------------------------------
function MissileBoomerang:initState()
    Missile.initState(self)

    self:addState('move', MissileBoomerang.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileBoomerang.st_move(owner, dt)

    if owner.m_stateTimer == 0 then
        
        -- 방향이 지정되지 않았을 경우 랜덤하게 방향 지정
        if owner.m_leftOrRight == nil then
            owner.m_leftOrRight = (math_random(1, 2) == 1)
        end

        if owner.m_leftOrRight then
            --owner:setDir(180)
            owner:setDir(90)
        else
            --owner:setDir(0)
            owner:setDir(270)
        end

        -- 발사체가 반원을 그리는 동안 수평으로 이동하는 거리의 비율 63%
        local movement_x = 0.63

        local distance = 0
        if owner.m_bHero then
            distance = 500
        else
            -- 수평으로의 이동 거리를 구한 다음 movement_x를 나누어 주면 속도를 구할 수 있다.
            distance = owner.pos.x - GameMgr:getCurHero():getCenterPosX()
        
            -- 고정일 경우 항상 같은 위치로 던짐
            if owner.m_bFix then
                distance = owner.pos.x - 100
            end

            if distance < 0 then
                distance = distance - 100
            else
                distance = distance + 100
            end
        end
        local speed = distance / movement_x / (owner.m_duration / 2)
        owner:setSpeed(speed)

        -- rotation
        --owner.m_aiParam = 270
        owner.m_aiParam = 0
        owner:setRotation(owner.m_aiParam)
    end

    do

        do
            local curr_degree = owner.movement_theta
            local new_degree = curr_degree

            -- 영웅의 경우 반대 방향으로 이동
            if owner.m_bHero then
                if owner.m_leftOrRight then
                    new_degree = new_degree - 45
                else
                    new_degree = new_degree + 45
                end
            else
                  if owner.m_leftOrRight then
                    new_degree = new_degree + 45
                else
                    new_degree = new_degree - 45
                end
            end

            -- 1초만에 도착 지점에 도착해야 하므로(반원) 초당 180도를 회전한다.
            local rotate = 360/owner.m_duration
            local dir = getRotationDegree(curr_degree, new_degree, dt * rotate)
            owner:setDir(dir)

            -- 부메랑처럼 타원의 궤적을 그리기 위해 movement_y의 값을 축소한다.
            owner.movement_y = owner.movement_y * 0.4
        end

        -- 자전
        do
            local curr_degree = owner.m_aiParam
            local new_degree = curr_degree

            -- 영웅의 경우 반대 방향으로 이동
            if owner.m_bHero then
                if owner.m_leftOrRight then
                    new_degree = new_degree - 45
                else
                    new_degree = new_degree + 45
                end
            else
                  if owner.m_leftOrRight then
                    new_degree = new_degree + 45
                else
                    new_degree = new_degree - 45
                end
            end

            local dir = getRotationDegree(curr_degree, new_degree, dt * owner.speed * 2)
            owner.m_aiParam = dir
            owner:setRotation(owner.m_aiParam)
        end

        -- 2초가 지나면 제자리로 돌아오기 때문에 삭제한다.
        if owner.m_stateTimer >= owner.m_duration then
            owner:changeState('dying')
        elseif owner.m_stateTimer >= (owner.m_duration-0.2) then
            local alpha = owner.m_animator:getAlpha()
            alpha = alpha - (dt * 5)
            alpha = math_max(alpha, 0)
            owner.m_animator:setAlpha(alpha)
        end
    end
end