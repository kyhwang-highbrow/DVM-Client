local PARENT = TableClass

-------------------------------------
-- class TableForestStuffLevelInfo
-------------------------------------
TableForestStuffLevelInfo = class(PARENT, {
    })

local THIS = TableForestStuffLevelInfo

local static_stuff_table = nil

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffLevelInfo:init()
    self.m_tableName = 'table_forest_stuff_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getOpenLavel
-------------------------------------
function TableForestStuffLevelInfo:getOpenLavel(stuff_type)
    if (self == THIS) then
        self = THIS
    end

    

end