local PARENT = TableClass

-------------------------------------
-- class TableRuneGrade
-------------------------------------
TableRuneGrade = class(PARENT, {
    })

local THIS = TableRuneGrade

-------------------------------------
-- function init
-------------------------------------
function TableRuneGrade:init()
    self.m_tableName = 'table_rune_grade'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getUnequipPrice
-------------------------------------
function TableRuneGrade:getUnequipPrice(grade)
    if (self == THIS) then
        self = THIS()
    end

    local price = self:getValue(grade, 'unequip_price')
    return price
end