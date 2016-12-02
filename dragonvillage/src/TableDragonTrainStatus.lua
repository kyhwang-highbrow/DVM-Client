local PARENT = TableClass

-------------------------------------
-- class TableDragonTrainStatus
-------------------------------------
TableDragonTrainStatus = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonTrainStatus:init()
    self.m_tableName = 'table_dragon_train_status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end