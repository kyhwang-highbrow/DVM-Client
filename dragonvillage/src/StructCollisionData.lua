-------------------------------------
-- class StructCollisionData
-------------------------------------
StructCollisionData = class({
		m_target = 'Character',
        m_bodyKey = 'number',
        m_distance = 'number',
        m_posX = 'number',
        m_posY = 'number',
	})

-------------------------------------
-- function init
-------------------------------------
function StructCollisionData:init(target, body_key, distance, pos_x, pos_y)
    self.m_target = target
    self.m_bodyKey = body_key
    self.m_distance = math_abs(distance)
    self.m_posX = pos_x
    self.m_posY = pos_y
end

-------------------------------------
-- function getTarget
-------------------------------------
function StructCollisionData:getTarget()
    return self.m_target
end

-------------------------------------
-- function getBodyKey
-------------------------------------
function StructCollisionData:getBodyKey()
    return self.m_bodyKey
end

-------------------------------------
-- function getDistance
-------------------------------------
function StructCollisionData:getDistance()
    return self.m_distance
end

-------------------------------------
-- function getPosX
-------------------------------------
function StructCollisionData:getPosX()
    return self.m_posX
end

-------------------------------------
-- function getPosY
-------------------------------------
function StructCollisionData:getPosY()
    return self.m_posY
end

-------------------------------------
-- function printLog
-------------------------------------
function StructCollisionData:printLog()
    cclog('phys_idx = ' .. self.m_target.phys_idx)
    cclog('body_key = ' .. self.m_bodyKey)
    cclog('distance = ' .. self.m_distance)
    cclog('pos_x = ' .. self.m_posX)
    cclog('pos_y = ' .. self.m_posY)
end