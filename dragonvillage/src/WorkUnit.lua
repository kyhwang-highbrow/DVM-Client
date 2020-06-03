-------------------------------------
-- class WorkUnit
-------------------------------------
WorkUnit = class({
        m_name = 'string',
        m_onEnter = 'function',
        m_onWork = 'function',
        m_onExit = 'function',
    })

local THIS = WorkUnit

-------------------------------------
-- function init
-------------------------------------
function WorkUnit:init()
end

-------------------------------------
-- function getClassName
-------------------------------------
function WorkUnit:getClassName()
    return 'WorkUnit'
end

-------------------------------------
-- function getThis
-------------------------------------
function WorkUnit:getThis()
    return THIS
end

-------------------------------------
-- function setName
-------------------------------------
function WorkUnit:setName(name)
    self:log('setName : ' .. tostring(name))
    self.m_name = name
end

-------------------------------------
-- function registerEnterHandler
-------------------------------------
function WorkUnit:registerEnterHandler(func)
    self:log('registerEnterHandler')
    self.m_onEnter = func
end

-------------------------------------
-- function registerWorkHandler
-------------------------------------
function WorkUnit:registerWorkHandler(func)
    self:log('registerWorkHandler')
    self.m_onWork = func
end

-------------------------------------
-- function registerExitHandler
-------------------------------------
function WorkUnit:registerExitHandler(func)
    self:log('registerExitHandler')
    self.m_onExit = func
end

-------------------------------------
-- function log
-------------------------------------
function WorkUnit:log(msg)
    local skip = false
    if (skip == true) then
        return
    end

    cclog('##' .. self:getClassName() .. ' log## : ' .. tostring(msg))
end