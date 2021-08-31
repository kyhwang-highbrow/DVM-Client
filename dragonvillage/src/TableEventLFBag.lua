local PARENT = TableClass

-------------------------------------
-- class TableEventLFBag 
-------------------------------------
TableEventLFBag = class(PARENT, {
        m_rewardList = 'table'
    })

local THIS = TableEventLFBag

-------------------------------------
-- function init
-------------------------------------
function TableEventLFBag:init()
    self.m_tableName = 'table_lucky_fortune_bag'
    self.m_orgTable = TABLE:get(self.m_tableName)

    self:makeRewardList()
end

-------------------------------------
-- function getRewardList
-------------------------------------
function TableEventLFBag:getRewardList(lv)
    if (self == THIS) then
        self = THIS()
    end

    if lv then
        return self.m_rewardList[lv]
    else
        return self.m_rewardList
    end
end

-------------------------------------
-- function getFullRewardList
-------------------------------------
function TableEventLFBag:getFullRewardList()
    if (self == THIS) then
        self = THIS()
    end

    return self.m_rewardList
end

-------------------------------------
-- function makeRewardList
-------------------------------------
function TableEventLFBag:makeRewardList()
    self.m_rewardList = {}

    -- lv 1부터 1씩 증가하며 확인
    for lv = 1, 99 do
        local l_lv = self:filterList('step', lv)

        -- 해당 lv이 없다면 break
        if (table.count(l_lv) == 0) then
            break
        end

        -- 같은 레벨의 아이템을 하나의 테이블로 모음
        local l_ret = {}
        local sum_pw = 0
        for _, t_data in ipairs(l_lv) do
            -- 인덱스 정렬
            l_ret[t_data['idx']] = t_data
            sum_pw = sum_pw + t_data['pick_weight']
        end

        -- pick_weight sum 반영하여 rate 계산
        for _, t_data in ipairs(l_ret) do
            t_data['pick_percent'] = UIHelper:makeFormatedFloatStr(t_data['pick_weight'] / sum_pw) --tostring(math_floor( * 1000 ) / 10)
        end
        table.insert(self.m_rewardList, l_ret)
    end
end











-------------------------------------
-- class TableEventLFBagRank 
-------------------------------------
TableEventLFBagRank = class(PARENT, {
        m_rewardList = 'table'
    })

-------------------------------------
-- function init
-------------------------------------
function TableEventLFBagRank:init()
    self.m_tableName = 'table_lucky_fortune_bag_rank'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRankRewardList
-------------------------------------
function TableEventLFBagRank:getRankRewardList()
    local l_ret = {}
    for _, v in pairs(self.m_orgTable) do
        table.insert(l_ret, v)
    end
    table.sort(l_ret, function(a, b) 
        return a['rank_id'] < b['rank_id']
    end)
    return l_ret
end
