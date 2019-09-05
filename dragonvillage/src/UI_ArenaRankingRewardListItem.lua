local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaRankingRewardListItem
-------------------------------------
UI_ArenaRankingRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankingRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('arena_rank_popup_item_user_reward.ui')

    self:initUI()
    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankingRewardListItem:initUI()
    local vars = self.vars
    local t_data = self.m_rewardInfo
    local l_reward = TableClass:seperate(t_data['reward'], ',', true)

    for i = 1, #l_reward do
        local l_str = seperate(l_reward[i], ';')
        local item_id = TableItem:getItemIDFromItemType(l_str[1]) -- 아이템 아이콘
        local icon = IconHelper:getItemIcon(item_id) 

        local cnt = l_str[2] -- 아이콘 수량
        
        if (icon and cnt) then
			icon:setScale(0.4)
		    vars['rewardLabel' .. i]:setString(comma_value(cnt))
            vars['rewardNode' .. i]:addChild(icon)
        end
    end

    local rank_str = StructRankReward.getRankName(t_data) 
    vars['rankLabel']:setString(rank_str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankingRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankingRewardListItem:refresh()
end
