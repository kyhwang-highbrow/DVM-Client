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
-- function isIndivPassReceivedReward
-------------------------------------
function StructIndivPass:isIndivPassReceivedReward(reward_id)
    if self.rewards == nil then
        return false
    end
    
    return self.rewards[tostring(reward_id)] ~= nil
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