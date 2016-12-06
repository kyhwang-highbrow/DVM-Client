local PARENT = TableClass

-------------------------------------
-- class TableDragonTrainInfo
-------------------------------------
TableDragonTrainInfo = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonTrainInfo:init()
    self.m_tableName = 'dragon_train_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getGoodbyeLacteaCnt
-- @brief 작별 시 획득하는 라테아 양
-------------------------------------
function TableDragonTrainInfo:getGoodbyeLacteaCnt(dragon_grade, dragon_evolution)
    local t_dragon_train_info = self:get(dragon_grade)

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

    local lactea = t_dragon_train_info[key]
    return lactea
end

-------------------------------------
-- function getReqLactea
-- @brief 수련 시 필요한 라테아 양
-------------------------------------
function TableDragonTrainInfo:getReqLactea(dragon_grade, dragon_rarity)
    local t_dragon_train_info = self:get(dragon_grade)

    local key = 'req_' .. dragon_rarity

    local lactea = t_dragon_train_info[key]
    return lactea
end