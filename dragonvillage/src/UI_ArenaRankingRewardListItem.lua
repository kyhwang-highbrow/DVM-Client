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
    self.m_rewardInfo = t_rank_info
    local vars = self:load('arena_rank_popup_item_user_reward.ui')

    --self:initUI()
    --self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankingRewardListItem:initUI()
    local vars = self.vars
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
