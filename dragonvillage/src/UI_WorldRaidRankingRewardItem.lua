
local PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
--- @class UI_WorldRaidRankingRewardItem
-------------------------------------
UI_WorldRaidRankingRewardItem = class(PARENT,{
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidRankingRewardItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    self:load('world_raid_ranking_popup_item_reward.ui')
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidRankingRewardItem:initUI()
    local vars = self.vars
    local t_data = self.m_rewardInfo
    local l_reward = g_itemData:parsePackageItemStr(self.m_rewardInfo['reward'])

    for i = 1, #l_reward do
        local item_id = l_reward[i]['item_id']
        local cnt = l_reward[i]['count']
        
        local item_card = UI_ItemCard(item_id, cnt)
        item_card.root:setScale(0.62)
        item_card.root:setSwallowTouch(false)
        -- itemNode 는 좌 -> 우 1,2,3,4,5 총 5개를 갖는다
        -- 리워드가 5개 미만일 때 총 슬롯과 리워드 차이만큼
        -- 앞칸을 비워서 우측정렬을 실현
        local insert_idx = i + ( 5 - #l_reward )

        -- 혹시라도 인덱스 벗어나는 일이 있으면 멈추자.
        if (insert_idx < 1 or insert_idx > 5) then
            break
        end

        if vars['itemNode' .. insert_idx] then 
            vars['itemNode' .. insert_idx]:addChild(item_card.root)
        end
    end

    local rank_str = StructRankReward.getRankName(t_data) 
    vars['rankLabel']:setString(rank_str)
end