local PARENT = Entity

-------------------------------------
-- class EffectHeal
-------------------------------------
EffectHeal = class(PARENT, {
        m_target = 'Character',
        m_aiParam = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function EffectHeal:init(file_name, body, ...)
    
end

-------------------------------------
-- function initState
-------------------------------------
function EffectHeal:initState()
    self:addState('move', EffectHeal.st_move, 'missile_effect', true)
    self:addState('dying', EffectHeal.st_dying, nil, nil, 10)
end

-------------------------------------
-- function init_EffectHeal
-------------------------------------
function EffectHeal:init_EffectHeal(x, y, target)
    self:setPosition(x, y)
    self.m_target = target
end

-------------------------------------
-- function st_move
-------------------------------------
function EffectHeal.st_move(owner, dt)

    if (owner.m_stateTimer == 0) then
        owner.m_aiParam = 800
        owner:setSpeed(1000)
        

        local degree = getDegree(owner.pos.x, owner.pos.y, owner.m_target.pos.x, owner.m_target.pos.y)
        degree = degree + math_random(-30, 30)
        owner:setDir(degree)

    elseif (owner.m_stateTimer >= 0.15) and (owner.m_aiParam > 0) then

        if owner.m_target then
            owner.m_targetPosX, owner.m_targetPosY = owner.m_target:getCenterPos()

            local curr_degree = owner.movement_theta
            local dest_degree = getDegree(owner.pos.x, owner.pos.y, owner.m_targetPosX, owner.m_targetPosY)
            local new_degree, gap = getRotationDegree(curr_degree, dest_degree, dt * owner.m_aiParam)

            owner:setDir(new_degree)
            owner:setRotation(new_degree)

            owner.m_aiParam = owner.m_aiParam + (dt * 2000)
        end
    end

    local distance = getDistance(owner.pos.x, owner.pos.y, owner.m_target.pos.x, owner.m_target.pos.y)

    if (owner.m_stateTimer >= 1) or (distance <= 60) then
        owner:changeState('dying')
    end

    local speed = owner.speed + (500 * dt)
    speed = math_min(speed, 2000)
    owner:setSpeed(speed)
end

-------------------------------------
-- function st_dying
-------------------------------------
function EffectHeal.st_dying(owner, dt)
    return true
end