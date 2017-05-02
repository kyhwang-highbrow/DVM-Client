local PARENT = TableClass

-------------------------------------
-- class TableLactea
-------------------------------------
TableLactea = class(PARENT, {
    })

local THIS = TableLactea

-------------------------------------
-- function init
-------------------------------------
function TableLactea:init()
    self.m_tableName = 'table_lactea'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getGoodbyeLacteaCnt
-- @brief 작별 시 획득하는 라테아 양
-------------------------------------
function TableLactea:getGoodbyeLacteaCnt(dragon_grade, dragon_evolution)
    if true then
        return 100
    end

    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(dragon_grade)

    local key = nil
    if (dragon_evolution == 1) then
        key = 'lactea_hatch'
    elseif (dragon_evolution == 2) then
        key = 'lactea_hatchling'
    elseif (dragon_evolution == 3) then
        key = 'lactea_adult'
    else
        error()
    end

    local lactea = t_table[key]
    return lactea
end