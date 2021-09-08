local PARENT = Structure

-------------------------------------
-- class StructEventLFBag
-- @brief 소원 구슬
-------------------------------------
StructEventLFBag = class(PARENT, {
        -- raw data      
        lucky_fortune = 'number',
        score = 'number',
        cum_reward_list = 'string',
        level = 'number',
        end_time = 'timestamp',
        success_prob = 'number',
        
        -- proc data
        l_cum_item_list = 'table',


        ceiling_count = 'number',
        ceiling_max = 'number',
        is_ceiling_exist = 'boolean',
    })

local THIS = StructEventLFBag
local MAX_LV = 5
local RISK_LV = 3

-------------------------------------
-- function init
-------------------------------------
function StructEventLFBag:init()
    self['lucky_fortune'] = 0
    self['score'] = 0
    self['cum_reward_list'] = ''
    self['level'] = 0
    self['end_time'] = 0
    self['success_prob'] = 0

    self['ceiling_count'] = 0
    self['ceiling_max'] = 0
    self['is_ceiling_exist'] = false
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventLFBag:getClassName()
    return 'StructEventLFBag'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventLFBag:getThis()
    return THIS
end

-------------------------------------
-- function apply
-------------------------------------
function StructEventLFBag:apply(t_data)
    for i, v in pairs(self) do
        if (t_data[i] ~= nil) then
            self[i] = t_data[i]
        end
    end

    if (t_data['end_date']) then
        self['end_time'] = t_data['end_date'] / 1000
    end
end

-------------------------------------
-- function getScore
-------------------------------------
function StructEventLFBag:getScore()
    return self['score']
end

-------------------------------------
-- function getCount
-------------------------------------
function StructEventLFBag:getCount()
    return self['lucky_fortune']
end

-------------------------------------
-- function addCount
-------------------------------------
function StructEventLFBag:setCount(lfbag)
    self['lucky_fortune'] = lfbag
end

-------------------------------------
-- function addCount
-------------------------------------
function StructEventLFBag:addCount(lfbag)
    self['lucky_fortune'] = self['lucky_fortune'] + lfbag
end

-------------------------------------
-- function getLv
-------------------------------------
function StructEventLFBag:getLv()
    return math_min(self['level'] + 1, MAX_LV)
end

-------------------------------------
-- function getCurrentLv
-------------------------------------
function StructEventLFBag:getCurrentLv()
    return math_min(self['level'])
end

-------------------------------------
-- function isEmpty
-------------------------------------
function StructEventLFBag:isEmpty()
    return self['lucky_fortune'] == 0
end

-------------------------------------
-- function isMax
-- @brief 최대 레벨
-------------------------------------
function StructEventLFBag:isMax()
    return self['level'] >= MAX_LV
end

-------------------------------------
-- function hasRisk
-- @brief 보상을 받지 못할 확률이 존재
-------------------------------------
function StructEventLFBag:hasRisk()
    return self['level'] + 1 >= RISK_LV
end

-------------------------------------
-- function hasReward
-- @brief 누적 보상 있음
-------------------------------------
function StructEventLFBag:hasReward()
    return table.count(self:getRewardList()) > 0
end

-------------------------------------
-- function canStart
-- @brief 소원 구슬 열 수 있는지 체크
-------------------------------------
function StructEventLFBag:canStart()
    return self['level'] > 0 or self['lucky_fortune'] > 0
end

-------------------------------------
-- function getEndTime
-------------------------------------
function StructEventLFBag:getEndTime()
    return self['end_time']
end

-------------------------------------
-- function getCeilingCount
-------------------------------------
function StructEventLFBag:getCeilingCount()
    return self['ceiling_count']
end

-------------------------------------
-- function getCeilingMax
-------------------------------------
function StructEventLFBag:getCeilingMax()
    return self['ceiling_max']
end

-------------------------------------
-- function isCeilingExist
-------------------------------------
function StructEventLFBag:isCeilingExist()
    return self['is_ceiling_exist']
end

-------------------------------------
-- function getSuccessProb
-------------------------------------
function StructEventLFBag:getSuccessProb()
    return self['success_prob']
end

local mCachedTable
-------------------------------------
-- function getRewardList
-------------------------------------
function StructEventLFBag:getRewardList(step)
    if (mCachedTable == nil) then
        require('TableEventLFBag')
        mCachedTable = TableEventLFBag()
    end

    if (step == nil) then step = self:getLv() end
    return mCachedTable:getRewardList(step)
end

-------------------------------------
-- function getFullRewardList
-------------------------------------
function StructEventLFBag:getFullRewardList()
    if (mCachedTable == nil) then
        require('TableEventLFBag')
        mCachedTable = TableEventLFBag()
    end
    return mCachedTable:getFullRewardList()
end


-------------------------------------
-- function getMaxStep
-------------------------------------
function StructEventLFBag:getMaxStep()
    if (mCachedTable == nil) then
        require('TableEventLFBag')
        mCachedTable = TableEventLFBag()
    end

    return mCachedTable:getMaxStep()
end

-------------------------------------
-- function getCumulativeRewardList
-------------------------------------
function StructEventLFBag:getCumulativeRewardList()
    local l_item = g_itemData:parsePackageItemStr(self['cum_reward_list'])
    return l_item
end


