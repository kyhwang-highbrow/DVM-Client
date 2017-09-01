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
-- function parseOptionKey
-- @brief
-------------------------------------
function TableOption:parseOptionKey(option_str)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(option_str)
    if (not t_table) then
        error('option_str : ' .. option_str)
    end
    
    local status = t_table['status']
    local action = t_table['action']
    return status, action
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

-------------------------------------
-- function getLevelingValue
-- @brief
-------------------------------------
function TableOption:getLevelingValue(option_value, option_max_value, option_lv)
	local formation_max_level = g_constant:get('FORMATION', 'MAX_LEVEL') - 1
    local unit_value = (option_max_value - option_value) / formation_max_level

    return option_value + (unit_value * option_lv)
end

-------------------------------------
-- function parseOptionContentStr
-- @brief
-- @param buff_content_str 'hp_multi;5, atk_multi;5'
-------------------------------------
function TableOption:parseOptionContentStr(buff_content_str)
    local l_option_str = pl.stringx.split(buff_content_str, ',')

    local t_ret = {}

    for i,v in pairs(l_option_str) do
        local v = pl.stringx.strip(v)
        local t_data = pl.stringx.split(v, ';')

        local option = t_data[1]
        local value =  t_data[2] or 0

        table.insert(t_ret, {['option']=option, ['value']=value})
    end

--    {
--        {
--                ['option']='hp_multi';
--                ['value']='5';
--        };
--        {
--                ['option']='atk_multi';
--                ['value']='5';
--        };
--    }
    return t_ret
end