-------------------------------------
-- class EnemyLua
-------------------------------------
EnemyLua = class(Enemy, {

        m_luaValue1 = 'number',
        m_luaValue2 = 'number',
        m_luaValue3 = 'number',
        m_luaValue4 = 'number',
        m_luaValue5 = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function EnemyLua:init(file_name, body, ...)
end

-------------------------------------
-- function initLuaValue
-------------------------------------
function EnemyLua:initLuaValue(value1, value2, value3, value4, value5)
    self.m_luaValue1 = value1
    self.m_luaValue2 = value2
    self.m_luaValue3 = value3
    self.m_luaValue4 = value4
    self.m_luaValue5 = value5
end

-------------------------------------
-- function initState
-------------------------------------
function EnemyLua:initState()
    Enemy.initState(self)
    self:addState('move', EnemyLua.st_move, 'idle', true)
end

-------------------------------------
-- function st_move
-------------------------------------
function EnemyLua.st_move(owner, dt)
    local x, y = owner.m_rootNode:getPosition()
    if (owner.pos.x ~= x) or (owner.pos.y ~= y) then
        owner:setPosition(x, y)

        owner.m_homePosX = x
        owner.m_homePosY = y
    end
end

-------------------------------------
-- function luaFinishFunc
-------------------------------------
function EnemyLua:luaFinishFunc()
    return cc.CallFunc:create(function() self:changeState('dying') end)
end