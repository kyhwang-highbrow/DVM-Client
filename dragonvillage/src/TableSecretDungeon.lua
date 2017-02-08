local PARENT = TableClass

-------------------------------------
-- class TableSecretDungeon
-------------------------------------
TableSecretDungeon = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableSecretDungeon:init()
    self.m_tableName = 'secret_dungeon'
    self.m_orgTable = TABLE:get(self.m_tableName)
end
