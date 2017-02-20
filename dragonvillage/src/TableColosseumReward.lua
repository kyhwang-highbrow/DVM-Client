local PARENT = TableClass

-------------------------------------
-- class TableColosseumReward
-------------------------------------
TableColosseumReward = class(PARENT, {
        m_mTierNumber = 'map',
        m_lTierNumber = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function TableColosseumReward:init()
    self.m_tableName = 'colosseum_reward'
    self.m_orgTable = TABLE:get(self.m_tableName)

    self.m_lTierNumber = {}
    table.insert(self.m_lTierNumber, 'legend')
    table.insert(self.m_lTierNumber, 'master')
    table.insert(self.m_lTierNumber, 'challenger')
    table.insert(self.m_lTierNumber, 'diamond')
    table.insert(self.m_lTierNumber, 'platinum')
    table.insert(self.m_lTierNumber, 'gold')
    table.insert(self.m_lTierNumber, 'silver')
    table.insert(self.m_lTierNumber, 'bronze')

    self.m_mTierNumber = {}

    for i,v in ipairs(self.m_lTierNumber) do
        self.m_mTierNumber[v] = i
    end
end

-------------------------------------
-- function getMinRP
-------------------------------------
function TableColosseumReward:getMinRP(tier, grade)
    local key = tier
    grade = grade or 1
    if (tier ~= 'legend') then
        key = tier .. '_' .. grade
    end

    local min_rp = self:getValue(key, 'min_score')
    return min_rp
end

-------------------------------------
-- function getWeeklyRewardCash
-------------------------------------
function TableColosseumReward:getWeeklyRewardCash(tier, grade)
    local key = tier
    grade = grade or 1
    if (tier ~= 'legend') then
        key = tier .. '_' .. grade
    end

    local reward_str = self:getValue(key, 'weekly_reward')
    
    local l_item_list = ServerData_Item:parsePackageItemStr(reward_str)

    local cash = 0

    local table_item = TableItem()
    for i,v in ipairs(l_item_list) do
        local item_id = v['item_id']
        local item_count = v['count']
        if (item_id == table_item:getItemIDFromItemType('cash')) then
            cash = cash + item_count
        end
    end

    return cash
end

-------------------------------------
-- function getFirstRewardCash
-------------------------------------
function TableColosseumReward:getFirstRewardCash(tier)
    local key = tier
    if (tier ~= 'legend') then
        key = tier .. '_' .. 1
    end

    local reward_str = self:getValue(key, 'first_get_reward')
    
    local l_item_list = ServerData_Item:parsePackageItemStr(reward_str)

    local cash = 0

    local table_item = TableItem()
    for i,v in ipairs(l_item_list) do
        local item_id = v['item_id']
        local item_count = v['count']
        if (item_id == table_item:getItemIDFromItemType('cash')) then
            cash = cash + item_count
        end
    end

    return cash
end