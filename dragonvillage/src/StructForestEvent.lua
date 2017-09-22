local PARENT = Structure

-------------------------------------
-- class StructForestEvent
-------------------------------------
StructForestEvent = class({
    object = 'ForestObject',
    pos_x = 'number',
    pos_y = 'number',
    speed = 'number',
    stuff = 'string',
    happy = 'number',
    ret = 'table',
})

-------------------------------------
-- function getObject
-------------------------------------
function StructForestEvent:getObject()
    return self.object
end

-------------------------------------
-- function setObject
-------------------------------------
function StructForestEvent:setObject(obj)
    self.object = obj
end

-------------------------------------
-- function getPosition
-------------------------------------
function StructForestEvent:getPosition()
    return self.pos_x, self.pos_y
end

-------------------------------------
-- function setPosition
-------------------------------------
function StructForestEvent:setPosition(x, y)
    self.pos_x = x
    self.pos_y = y
end

-------------------------------------
-- function getSpeed
-------------------------------------
function StructForestEvent:getSpeed()
    return self.speed
end

-------------------------------------
-- function setSpeed
-------------------------------------
function StructForestEvent:setSpeed(speed)
    self.speed = speed
end

-------------------------------------
-- function getStuff
-------------------------------------
function StructForestEvent:getStuff()
    return self.stuff
end

-------------------------------------
-- function setStuff
-------------------------------------
function StructForestEvent:setStuff(stuff)
    self.stuff = stuff
end

-------------------------------------
-- function getHappy
-------------------------------------
function StructForestEvent:getHappy()
    return self.happy
end

-------------------------------------
-- function setHappy
-------------------------------------
function StructForestEvent:setHappy(happy)
    self.happy = happy
end

-------------------------------------
-- function getResponse
-------------------------------------
function StructForestEvent:getResponse()
    return self.ret
end

-------------------------------------
-- function setResponse
-------------------------------------
function StructForestEvent:setResponse(ret)
    self.ret = ret
end