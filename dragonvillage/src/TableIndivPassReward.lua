local PARENT = TableClass
-------------------------------------
-- class TableIndivPassReward
-------------------------------------
TableIndivPassReward = class(PARENT, {
    
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableIndivPassReward:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_indiv_pass_reward'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableIndivPassReward instance
-------------------------------------
function TableIndivPassReward:getInstance()
    if (instance == nil) then
        instance = TableIndivPassReward()
    end
    return instance
end

-------------------------------------
-- function getIndivPassLevelDataList
-------------------------------------
function TableIndivPassReward:getIndivPassLevelDataList(pass_id, _type_id)
    local level_list = {}
    local type_id = _type_id or 0

    for k, v in pairs(self.m_orgTable) do
        if v['pg_id'] == pass_id and v['type_id'] == type_id then
            local data = {}
            data['pass_id'] = pass_id
            data['level'] = v['level']
            data['exp'] = v['exp']
            table.insert(level_list, data)
        end
    end

    table.sort(level_list, function(a, b)
        return a['level'] < b['level']
    end)

    return level_list
end

-------------------------------------
-- function getPassRewardNeedExp
-------------------------------------
function TableIndivPassReward:getPassRewardNeedExp(id)
    return self:getValue(id, 'exp')
end

-------------------------------------
-- function getPassRewardItem
-------------------------------------
function TableIndivPassReward:getPassRewardItem(id)
    local reward_str = self:getValue(id, 'item')
    local list = plSplit(reward_str, ';')
    return tonumber(list[1]), tonumber(list[2])
end
