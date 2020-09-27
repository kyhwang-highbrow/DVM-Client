local PARENT = Structure

-------------------------------------
-- class StructEventLFBag
-- @brief 복주머니
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
    })

local THIS = StructEventLFBag
local MAX_LV = 10
local RISK_LV = 8

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
-- function getLv
-------------------------------------
function StructEventLFBag:getLv()
    return math_min(self['level'] + 1, MAX_LV)
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
-- function canStart
-- @brief 복주머니를 열 수 있는지 체크
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
-- function getSuccessProb
-------------------------------------
function StructEventLFBag:getSuccessProb()
    return self['success_prob']
end

local mCachedTable
-------------------------------------
-- function getRewardList
-------------------------------------
function StructEventLFBag:getRewardList()
    if (mCachedTable == nil) then
        require('TableEventLFBag')
        mCachedTable = TableEventLFBag()
    end
    return mCachedTable:getRewardList(self:getLv())
end

-------------------------------------
-- function getCumulativeRewardList
-------------------------------------
function StructEventLFBag:getCumulativeRewardList()
    local l_item = g_itemData:parsePackageItemStr(self['cum_reward_list'])
    return l_item
end








local PARENT = StructUserInfo

-------------------------------------
-- class StructEventLFBagRanking
-- @brief 복주머니
-------------------------------------
StructEventLFBagRanking = class(PARENT, {
        m_rp = 'number',         -- ranking point
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float',-- 월드 랭킹 퍼센트
    })


-------------------------------------
-- function init
-------------------------------------
function StructEventLFBagRanking:init()
    self.m_rp = 0
    self.m_rank = 0
    self.m_rankPercent = 0
end

-------------------------------------
-- function apply
-- @brief 
-------------------------------------
function StructEventLFBagRanking:apply(t_data)
    self.m_uid = t_data['uid']
    self.m_nickname = t_data['nick']
    self.m_lv = t_data['lv']
    self.m_rank = t_data['rank']
    self.m_rankPercent = t_data['rate']
    self.m_rp = t_data['rp']

    self.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    return self
end

-------------------------------------
-- function getUserText
-------------------------------------
function StructEventLFBagRanking:getUserText()
        local str
    if self.m_lv and (0 < self.m_lv) then
        str = Str('Lv.{1} {2}', self.m_lv, self.m_nickname)
    else
        str = self.m_nickname
    end
    return str
end

-------------------------------------
-- function getRankStr
-------------------------------------
function StructEventLFBagRanking:getRankStr()
    return Str('{1}위', comma_value(self.m_rank))
end

-------------------------------------
-- function getScoreStr
-------------------------------------
function StructEventLFBagRanking:getScoreStr()
    return Str('{1}점', comma_value(self.m_rp))
end