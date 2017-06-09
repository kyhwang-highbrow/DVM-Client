-------------------------------------
-- class StructCollisionData
-------------------------------------
StructCollisionData = class({
		m_target = 'Character',
        m_bodyKey = 'number',
        m_distance = 'number'
	})

-------------------------------------
-- function init
-------------------------------------
function StructCollisionData:init(target, body_key, distance)
    self.m_target = target
    self.m_bodyKey = body_key
    self.m_distance = distance
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