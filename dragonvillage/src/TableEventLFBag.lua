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

    return self.m_rewardList[lv]
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
        for _, t_data in ipairs(l_lv) do
            local t_item = 
            {
                item_id = t_data['item_id'],
                count = t_data['val']
            }
            -- 인덱스 정렬
            l_ret[t_data['idx']] = t_item
        end

        table.insert(self.m_rewardList, l_ret)
    end
end