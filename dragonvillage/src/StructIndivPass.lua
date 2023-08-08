-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure
-------------------------------------
---@class StructIndivPass:Structure
-------------------------------------
StructIndivPass = class(PARENT, {
    pass_id = 'number', 
    type_id = 'number',
    exp = 'number',
    d_exp = 'number',
    rewards = 'Map<idx, doid>',

    start_time = 'timestamp',
    end_time = 'timestamp',

    product_id = 'number',
    m_uiPriority = 'number',
    package_res = 'string',
    package_res_2 = 'string',
    package_class = 'Class',

    m_passLevelList = '',
})

local THIS = StructIndivPass
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructIndivPass:getClassName()
    return 'StructIndivPass'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructIndivPass:getThis()
    return THIS
end

-------------------------------------
-- function getIndivPassExp
-------------------------------------
function StructIndivPass:getIndivPassExp()
    return self.exp
end

-------------------------------------
-- function getIndivPassCurrentBuyType
-------------------------------------
function StructIndivPass:getIndivPassCurrentBuyType()
    return self.type_id
end

-------------------------------------
-- function getIndivPassName
-------------------------------------
function StructIndivPass:getIndivPassName()
    local id = self.pass_id
    local name = TableIndivPass:getInstance():getIndivPassName(id)
    return name
end

-------------------------------------
-- function getAdvancePassPid
-------------------------------------
function StructIndivPass:getAdvancePassPid()
    local id = self.pass_id
    return TableIndivPass:getInstance():getAdvancePassPid(id)
end

-------------------------------------
-- function getPremiumPassPid
-------------------------------------
function StructIndivPass:getPremiumPassPid()
    local id = self.pass_id
    return TableIndivPass:getInstance():getPremiumPassPid(id)
end


-------------------------------------
-- function getIndivPassProduct
-------------------------------------
function StructIndivPass:getIndivPassProduct(type_id)
    local product_map = g_shopDataNew:getProductList('indiv_pass') or {}

    if type_id == 0 then
        return nil
    elseif type_id == 1 then
        return product_map[self:getAdvancePassPid()]
    elseif type_id == 2 then
        return product_map[self:getPremiumPassPid()]
    end

    return nil
end


-------------------------------------
-- function isIndivPassReceivedReward
-------------------------------------
function StructIndivPass:isIndivPassReceivedReward(reward_id)
    if self.rewards == nil then
        return false
    end
    
    return self.rewards[tostring(reward_id)] ~= nil
end

-------------------------------------
-- function getIndivPassStartTime
-------------------------------------
function StructIndivPass:getIndivPassStartTime()
    return self.start_time
end

-------------------------------------
-- function isIndivPassValidTime
-------------------------------------
function StructIndivPass:isIndivPassValidTime()
    local curr_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()

    if curr_time >= self.start_time and curr_time <= self.end_time then
        return true
    end

    return false
end

-------------------------------------
-- function getIndivPassUserLevel
-------------------------------------
function StructIndivPass:getIndivPassUserLevel()
    local user_exp = self:getIndivPassExp()
    if self.m_passLevelList == nil then
        self.m_passLevelList = TableIndivPassReward:getInstance():getIndivPassLevelDataList(self.pass_id)
    end

    for i = #self.m_passLevelList, 1, -1 do
        local v = self.m_passLevelList[i]
        if user_exp >= v['exp'] then
            return v['level']
        end
    end

    return 0
end

-------------------------------------
-- function isIndivPassAvailableReward
-------------------------------------
function StructIndivPass:isIndivPassAvailableReward(type_id)
    local list = self:getIndivPassAvailableRewardIdList(type_id, true)
    return #list > 0
end

-------------------------------------
-- function getIndivPassAvailableRewardIdList
-------------------------------------
function StructIndivPass:getIndivPassAvailableRewardIdList(type_id, check_available)
    local user_exp = self:getIndivPassExp()
    local user_type = self:getIndivPassCurrentBuyType()

    if self.m_passLevelList == nil then
        self.m_passLevelList = TableIndivPassReward:getInstance():getIndivPassLevelDataList(self.pass_id)
    end

    local reward_id_list = {}
    for level, t_data in ipairs(self.m_passLevelList) do
        local reward_id = (self.pass_id * 10000) + (type_id * 100) + level
        local is_clear = (user_exp >= t_data['exp'])
        local is_rewarded = self:isIndivPassReceivedReward(reward_id)
        local is_reach = user_type >= type_id
        local is_available = is_reach == true and is_clear == true and is_rewarded == false        

        if is_available == true then
            table.insert(reward_id_list, reward_id)
            if check_available == true then
                return reward_id_list
            end
        end
    end

    return reward_id_list
end


-------------------------------------
-- function getIndivPassAllItemList
-------------------------------------
function StructIndivPass:getIndivPassAllItemList(type_id)

    if self.m_passLevelList == nil then
        self.m_passLevelList = TableIndivPassReward:getInstance():getIndivPassLevelDataList(self.pass_id)
    end

    local item_list = {}
    for level, t_data in ipairs(self.m_passLevelList) do
        local reward_id = (self.pass_id * 10000) + (type_id * 100) + level
        local item_id, item_count = TableIndivPassReward:getInstance():getPassRewardItem(reward_id)
        local t_item = {}

        t_item['item_id'] = item_id
        t_item['count'] = item_count

        table.insert(item_list, t_item)
    end

    return item_list
end

-------------------------------------
-- function getRemainTimeText
-------------------------------------
function StructIndivPass:getRemainTimeText()
    local remain_time = (self.end_time or 0) - ServerTime:getInstance():getCurrentTimestampMilliseconds()
    remain_time = remain_time/1000
    return Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(remain_time, true))
end

-------------------------------------
-- function makeBadgeIcon
-------------------------------------
function StructIndivPass:makeBadgeIcon()
	return nil
end

-------------------------------------
-- function getProductID
-------------------------------------
function StructIndivPass:getProductID()
	return self.product_id
end
