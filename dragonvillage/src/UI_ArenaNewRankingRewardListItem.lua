local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewRankingRewardListItem
-------------------------------------
UI_ArenaNewRankingRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRankingRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info

    local vars = self:load('arena_new_rank_popup_item_user_reward.ui')

    self:initUI()
    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRankingRewardListItem:initUI()
    local vars = self.vars
    local t_data = self.m_rewardInfo
    local l_reward = TableClass:seperate(t_data['reward'], ',', true)

    if (not l_reward or #l_reward <= 0) then 
        vars['rankLabel']:setString('-')
        vars['rewardLabel1']:setString('-')
        vars['rewardLabel2']:setString('-')
        return 
    end

    for i = 1, #l_reward do
        local l_str = seperate(l_reward[i], ';')
        local item_id = tonumber(l_str[1])
        local cnt = l_str[2] -- 아이콘 수량
        --local item_id = TableItem:getItemIDFromItemType(itemKey) -- 아이템 아이콘

        local icon = IconHelper:getItemIcon(item_id, cnt) 
        
        if (icon) then
			icon:setScale(0.4)
            vars['rewardNode' .. i]:addChild(icon)
        end

        local cntString = ''
        if (cnt and cnd ~= '') then
            cntString = comma_value(cnt)
        end

        vars['rewardLabel' .. i]:setString(cntString)

    end

    local rank_str = StructArenaNewRankReward.getRankName(t_data) 
    vars['rankLabel']:setString(rank_str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRankingRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRankingRewardListItem:refresh()
end
