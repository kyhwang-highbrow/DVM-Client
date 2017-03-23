local PARENT = TableClass

-------------------------------------
-- class TableOption
-------------------------------------
TableOption = class(PARENT, {
    })

THIS = TableOption

-------------------------------------
-- function init
-------------------------------------
function TableOption:init()
    self.m_tableName = 'table_option'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRunePrefix
-- @brief
-------------------------------------
function TableOption:getRunePrefix(option)
    if (self == THIS) then
        self = THIS()
    end

    local prefix = self:getValue(option, 't_prefix')
    if prefix then
        return Str(prefix)
    else
        return ''
    end
end

-------------------------------------
-- function getOptionDesc
-- @brief
-------------------------------------
function TableOption:getOptionDesc(option, val_1, val_2, val_3)
    if (self == THIS) then
        self = THIS()
    end

    local t_desc = self:getValue(option, 't_desc')
    local desc = Str(t_desc, val_1, val_2, val_3)
    return desc
end