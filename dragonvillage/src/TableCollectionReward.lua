local PARENT = TableClass

-------------------------------------
-- class TableCollectionReward
-------------------------------------
TableCollectionReward = class(PARENT, {
    })

local THIS = TableCollectionReward

-------------------------------------
-- function init
-------------------------------------
function TableCollectionReward:init()
    self.m_tableName = 'table_collection_reward'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getCollectionReward
-------------------------------------
function TableCollectionReward:getCollectionReward(birthgrade, evolution)
	if (self == THIS) then
        self = THIS()
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

    local reward_dia = self:getValue(birthgrade, evolution_str) or 0
    return reward_dia
end