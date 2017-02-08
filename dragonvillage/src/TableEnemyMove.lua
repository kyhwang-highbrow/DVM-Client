local PARENT = TableClass

-------------------------------------
-- class TableEnemyMove
-------------------------------------
TableEnemyMove = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableEnemyMove:init()
    self.m_tableName = 'enemy_move'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getMovePosKey
-------------------------------------
function TableEnemyMove:getMovePosKey(type, idx)
    local t_move = self.m_orgTable[type]
    if (not t_move) then return end

    local key = t_move[string.format('pos_%02d', idx)]
    if (key == 'x') then
        key = nil
    end

    return key
end