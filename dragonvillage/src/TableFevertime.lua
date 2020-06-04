local PARENT = TableClass

-------------------------------------
-- class TableFevertime
-------------------------------------
TableFevertime = class(PARENT, {
    })

local THIS = TableFevertime

-------------------------------------
-- function init
-------------------------------------
function TableFevertime:init()
    self.m_tableName = 'table_fevertime'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getFevertimeName
-------------------------------------
function TableFevertime:getFevertimeName(type)
    if (self == THIS) then
        self = THIS()
    end
    
    return self:getValue(type, 't_name')
end

-------------------------------------
-- function getFevertimeDesc
-------------------------------------
function TableFevertime:getFevertimeDesc(type)
    if (self == THIS) then
        self = THIS()
    end
    
    return self:getValue(type, 't_desc')
end