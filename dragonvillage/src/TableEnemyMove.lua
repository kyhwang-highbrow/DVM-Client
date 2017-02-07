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