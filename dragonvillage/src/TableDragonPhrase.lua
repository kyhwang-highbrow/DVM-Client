local PARENT = TableClass

-------------------------------------
-- class TableDragonPhrase
-------------------------------------
TableDragonPhrase = class(PARENT, {
    })

local THIS = TableDragonPhrase

-------------------------------------
-- function init
-------------------------------------
function TableDragonPhrase:init()
    self.m_tableName = 'table_dragon_phrase'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonPhrase
-------------------------------------
function TableDragonPhrase:getDragonPhrase(did, flv)
    
end