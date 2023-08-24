local PARENT = TableClass

-------------------------------------
-- class TableOption
-------------------------------------
TableOption = class(PARENT, {
    })

THIS = TableOption
local instance = nil

-------------------------------------
-- function init
-------------------------------------
function TableOption:init()
    self.m_tableName = 'table_option'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableOption
-------------------------------------
function TableOption:getInstance()
    if (instance == nil) then
        instance = TableOption()
    end

    return instance
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
    local desc = Str(t_desc, 
                    val_1 and comma_value(val_1) or '', 
                    val_2 and comma_value(val_2) or '', 
                    val_3 and comma_value(val_3) or '')
    return desc
end

-------------------------------------
-- function getOptionDescWithSkillForm
-- @brief 스킬 설명과 같은 richLabel 칼라 적용
-------------------------------------
function TableOption:getOptionDescWithSkillForm(option, val_1, val_2, val_3)
    if (self == THIS) then
        self = THIS()
    end

    local t_desc = self:getValue(option, 't_desc')
    return DragonSkillCore.getRichTemplate(Str(t_desc, val_1, val_2, val_3))
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

-------------------------------------
-- function getRuneAbilityPointCalcVals
-------------------------------------
function TableOption:getRuneAbilityPointCalcVals(option)
    local str = self:getValue(option, 'rune_ability_pt')
    local list = plSplit(str, ':')

    if list == nil then
        return 'none', 0
    end

    return list[1], tonumber(list[2])
end

-------------------------------------
-- function getRuneAbilityIconRes
-------------------------------------
function TableOption:getRuneAbilityIconRes(option)
    local res = self:getValue(option, 'rune_ability_res')
    return res
end

-------------------------------------
-- function getOptionName
-------------------------------------
function TableOption:getOptionName(option)
    local str = self:getValue(option, 't_name')
    return Str(str)

--[[     if self:getValue(option, 't_desc') ~= nil then
        return Str(str) .. '(%)'
    else
        return Str(str)
    end ]]
end

-------------------------------------
-- function isPercentAbilityValueUnit 
-------------------------------------
function TableOption:isPercentAbilityValueUnit(option)
    local str = self:getValue(option, 't_desc')
    if string.find(str, '%%') ~= nil then
       return true 
    end
    return false
end