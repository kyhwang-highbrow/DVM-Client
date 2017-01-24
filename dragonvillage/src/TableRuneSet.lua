local PARENT = TableClass

-------------------------------------
-- class TableRuneSet
-------------------------------------
TableRuneSet = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableRuneSet:init()
    self.m_tableName = 'rune_set'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRuneSet
-------------------------------------
function TableRuneSet:getRuneSet(color, grade)
    if (self == TableRuneSet) then
        self = TableRuneSet()
    end

    local apply_trim = true
    local l_key = self:getSemicolonSeparatedValues(color, 'key_grade' .. grade, apply_trim)
    local l_act = self:getSemicolonSeparatedValues(color, 'act_grade' .. grade, apply_trim)
    local l_value = self:getSemicolonSeparatedValues(color, 'value_grade' .. grade, apply_trim)

    ccdump(l_key)
    ccdump(l_act)
    ccdump(l_value)
end