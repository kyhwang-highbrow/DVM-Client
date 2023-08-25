-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructLairStat:Structure
-------------------------------------
StructLairStat = class(PARENT, {
    opt = 'number',
    use = 'number',
    lock = 'boolean',
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


-------------------------------------
-- function initVariables
-------------------------------------
function StructLairStat:initVariables()
    self.opt = 0
    self.lock = false
    self.use = 0
end

-------------------------------------
-- function getStatId
-------------------------------------
function StructLairStat:getStatId()
    return self.opt
end

-------------------------------------
-- function getStatOptionKey
-------------------------------------
function StructLairStat:getStatOptionKey()
    if self.opt == 0 then
        return 'none'
    end

    return  TableLairBuffStatus:getInstance():getLairStatOptionKey(self.opt)
end

-------------------------------------
-- function getStatOptionValue
-------------------------------------
function StructLairStat:getStatOptionValue()
    if self.opt == 0 then
        return 0
    end

    return  TableLairBuffStatus:getInstance():getLairStatOptionValue(self.opt)
end

-------------------------------------
-- function getStatOptionLevel
-------------------------------------
function StructLairStat:getStatOptionLevel()
    if self.opt == 0 then
        return 0
    end

    return TableLairBuffStatus:getInstance():getLairStatLevel(self.opt)
end

-------------------------------------
-- function getStatOptionMaxLevel
-------------------------------------
function StructLairStat:getStatOptionMaxLevel()
    if self.opt == 0 then
        return 0
    end

    return TableLairBuffStatus:getInstance():getLairStatLevel(self.opt)
end

-------------------------------------
-- function isStatLock
-------------------------------------
function StructLairStat:isStatLock()
    return self.lock
end

-------------------------------------
-- function getStatPickCount
-------------------------------------
function StructLairStat:getStatPickCount()
    return self.use
end