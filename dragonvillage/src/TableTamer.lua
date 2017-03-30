local PARENT = TableClass

-------------------------------------
-- class TableTamer
-------------------------------------
TableTamer = class(PARENT, {
    })

local THIS = TableTamer

-------------------------------------
-- function init
-------------------------------------
function TableTamer:init()
    self.m_tableName = 'tamer'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTamerType
-------------------------------------
function TableTamer:getTamerType(tamer_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(tamer_id, 'type')
end