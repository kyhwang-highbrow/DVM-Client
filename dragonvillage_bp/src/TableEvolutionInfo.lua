local PARENT = TableClass

-------------------------------------
-- class TableEvolutionInfo
-------------------------------------
TableEvolutionInfo = class(PARENT, {
    })

local THIS = TableEvolutionInfo

-------------------------------------
-- function init
-------------------------------------
function TableEvolutionInfo:init()
    self.m_tableName = 'evolution_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getBonusStatusLv
-------------------------------------
function TableEvolutionInfo:getBonusStatusLv(evolution)
    if (self == THIS) then
        self = THIS
    end

    local evolution_str
    if (evolution == 1) then
        evolution_str = 'hatch'
    elseif (evolution == 2) then
        evolution_str = 'hatchling'
    elseif (evolution == 3) then
        evolution_str = 'adult'
    else
        error('evolution ' .. evolution)
    end

    local lv = self:getValue(evolution_str, 'bonus_status_lv')
    return lv
end