local PARENT = TableClass

-------------------------------------
-- class TableDragonTrainInfo
-------------------------------------
TableDragonTrainInfo = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonTrainInfo:init()
    self.m_tableName = 'dragon_train_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end