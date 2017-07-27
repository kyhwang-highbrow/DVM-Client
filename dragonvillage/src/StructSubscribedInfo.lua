local PARENT = Structure

-------------------------------------
-- class StructSubscribedInfo
-------------------------------------
StructSubscribedInfo = class(PARENT, {
    })

local THIS = StructSubscribedInfo

-------------------------------------
-- function init
-------------------------------------
function StructSubscribedInfo:init(data)
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructSubscribedInfo:getClassName()
    return 'StructSubscribedInfo'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructSubscribedInfo:getThis()
    return THIS
end