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

-------------------------------------
-- function getLinkType
-------------------------------------
function TableFevertime:getLinkType(type)
    if (self == THIS) then
        self = THIS()
    end
    
    return self:getValue(type, 'link_type')
end

-------------------------------------
-- function getIcon
-------------------------------------
function TableFevertime:getIcon(type)
    if (self == THIS) then
        self = THIS()
    end
    
    return self:getValue(type, 'icon')
end

-------------------------------------
-- function getFevertimeIconLabel
-------------------------------------
function TableFevertime:getFevertimeIconLabel(type)
    if (self == THIS) then
        self = THIS()
    end
    
    return self:getValue(type, 't_icon_label')
end
