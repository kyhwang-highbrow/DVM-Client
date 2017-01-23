local PARENT = TableClass

-------------------------------------
-- class TableRuneGrade
-------------------------------------
TableRuneGrade = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableRuneGrade:init()
    self.m_tableName = 'rune_grade'
    self.m_orgTable = TABLE:get(self.m_tableName)
end