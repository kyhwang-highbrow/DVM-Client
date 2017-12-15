local PARENT = Missile

-------------------------------------
-- class MissileFix
-------------------------------------
MissileFix = class(PARENT, {
        m_target = 'Enemy',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileFix:init(file_name, body, target)
    self.m_target = target
end

-------------------------------------
-- function initState
-------------------------------------
function MissileFix:initState(file_name, body)
    PARENT.initState(self)

    self:addState('move', MissileFix.st_move, 'move', true)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileFix.st_move(owner, dt)

    if (owner.m_stateTimer == 0) then
        owner.m_aiParam = 800
        owner:setSpeed(1000)
        

        local degree = getDegree(owner.pos.x, owner.pos.y, owner.m_target.pos.x, owner.m_target.pos.y)
        degree = degree + math_random(-30, 30)
        owner:setDir(degree)

    elseif (owner.m_stateTimer >= 0.15) and (owner.m_aiParam > 0) then

        if (owner.m_target and not owner.m_target:isDead()) then
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

    --if (owner.m_stateTimer >= 1) or (distance <= 60) then
    if (distance <= 60) then
        owner:changeState('dying')

        MissileFix.fixAttack(owner)
    end

    local speed = owner.speed + (500 * dt)
    speed = math_min(speed, 2000)
    owner:setSpeed(speed)
end

-------------------------------------
-- function fixAttack
-------------------------------------
function MissileFix.fixAttack(owner)
    local target = owner.m_target

    if (not target or target:isDead()) then
        return
    end 

    target:undergoAttack(owner, target, target.pos.x, target.pos.y)    
end

