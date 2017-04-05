local PARENT = TableClass

-------------------------------------
-- class TableRuneMoptStatus
-------------------------------------
TableRuneMoptStatus = class(PARENT, {
    })

local THIS = TableRuneMoptStatus

-------------------------------------
-- function init
-------------------------------------
function TableRuneMoptStatus:init()
    self.m_tableName = 'table_rune_mopt_status'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStatusValue
-------------------------------------
function TableRuneMoptStatus:getStatusValue(vid, lv)
    if (self == THIS) then
        self = THIS()
    end

    local status = self:getValue(vid, 'lv' .. lv)
    return status
end