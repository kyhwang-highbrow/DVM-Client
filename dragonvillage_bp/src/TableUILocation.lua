local PARENT = TableClass

-------------------------------------
-- class TableUILocation
-------------------------------------
TableUILocation = class(PARENT, {
    })

local THIS = TableUILocation

-------------------------------------
-- function init
-------------------------------------
function TableUILocation:init()
    self.m_tableName = 'table_ui_location'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getContentName
-------------------------------------
function TableUILocation:getContentName(location_name)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(location_name, true) -- param : location_name, skip_error_msg
    if (not t_table) then
        return nil
    end

    local content_name = t_table['content_name']

    if (content_name == '') then
        content_name = nil
    end

    return content_name
end