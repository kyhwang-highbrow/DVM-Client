-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructLairStat:Structure
-------------------------------------
StructLairStat = class(PARENT, {
})

local THIS = StructLairStat
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructLairStat:getClassName()
    return 'StructLairStat'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructLairStat:getThis()
    return THIS
end
