local PARENT = TableClass

-------------------------------------
-- class TableGradeInfo
-------------------------------------
TableGradeInfo = class(PARENT, {
    })

local THIS = TableGradeInfo

-------------------------------------
-- function init
-------------------------------------
function TableGradeInfo:init()
    self.m_tableName = 'grade_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function isMaxLevel
-------------------------------------
function TableGradeInfo:isMaxLevel(grade, level)
    if (self == THIS) then
        self = THIS()
    end

    local max_lv = self:getValue(grade, 'max_lv')
    return (max_lv <= level)
end

-------------------------------------
-- function getMaxLv
-------------------------------------
function TableGradeInfo:getMaxLv(grade)
    if (self == THIS) then
        self = THIS()
    end

    if (not grade) then
        error('grade : ' .. grade)
    end

    local max_lv = self:getValue(grade, 'max_lv')
    return max_lv
end