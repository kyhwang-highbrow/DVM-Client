local PARENT = TableClass

-------------------------------------
-- class TableSummonGacha
-------------------------------------
TableSummonGacha = class(PARENT, {
    })

local THIS = TableSummonGacha

-------------------------------------
-- function init
-------------------------------------
function TableSummonGacha:init()
    self.m_tableName = 'table_gacha_probability'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getMinGrade
-------------------------------------
function TableSummonGacha:getMinGrade(egg_id)
    if (self == THIS) then
        self = THIS()
    end

    local min_grade = self:getValue(tonumber(egg_id), 'birthgrade_min')
    return min_grade
end

-------------------------------------
-- function isRareSummon
-- @brief 고등급용 소환 (3성 이상)
-------------------------------------
function TableSummonGacha:isRareSummon(egg_id)
    if (self == THIS) then
        self = THIS()
    end

    local rarity = self:getValue(tonumber(egg_id), 'rarity')
    return (rarity == 1) and true or false
end

-------------------------------------
-- function isFixSummon
-- @brief 확정등급 소환
-------------------------------------
function TableSummonGacha:isFixSummon(egg_id)
    if (self == THIS) then
        self = THIS()
    end

    local min_grade = self:getValue(tonumber(egg_id), 'birthgrade_min')
    local max_grade = self:getValue(tonumber(egg_id), 'birthgrade_max')
    return (min_grade == max_grade) and true or false
end

-------------------------------------
-- function getUIPriority
-- @brief 정렬 순서 값
-------------------------------------
function TableSummonGacha:getUIPriority(egg_id)
    if (self == THIS) then
        self = THIS()
    end

    local egg_id = tonumber(egg_id)
    local ui_priority = self:getValue(tonumber(egg_id), 'ui_priority')
    return ui_priority or -1
end