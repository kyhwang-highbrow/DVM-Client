local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChallengeModeRewardListItem
-------------------------------------
UI_ChallengeModeRewardListItem = class(PARENT, {
        m_rewardInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChallengeModeRewardListItem:init(t_reward_info)
    self.m_rewardInfo = t_reward_info
    local vars = self:load('challenge_mode_reward_list_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChallengeModeRewardListItem:initUI()
    local vars = self.vars
    local t_reward_info = self.m_rewardInfo
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChallengeModeRewardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeRewardListItem:refresh()
end
