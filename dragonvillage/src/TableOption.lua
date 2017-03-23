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
-- @brief Î£¨Ïùò ?†Îãà???µÏÖò???òÌï¥ Î∂ôÍ≤å?òÎäî ?ëÎëê??
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