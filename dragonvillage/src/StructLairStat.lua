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
    reserve_lock = 'boolean',
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
    self.reserve_lock = false
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
        return 10
    end

    local option_key = TableLairBuffStatus:getInstance():getLairStatOptionKey(self.opt)
    return TableLairBuffStatus:getInstance():getLairStatMaxLevelByOptionKey(option_key)
end

-------------------------------------
-- function isStatOptionMaxLevel
-------------------------------------
function StructLairStat:isStatOptionMaxLevel()
    return self:getStatOptionLevel() >= self:getStatOptionMaxLevel()
end

-------------------------------------
-- function setStatReserveLock
-------------------------------------
function StructLairStat:setStatReserveLock()
    self.reserve_lock = true
end

-------------------------------------
-- function isStatReserveLock
-------------------------------------
function StructLairStat:isStatReserveLock()
    return (self.reserve_lock == true)
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