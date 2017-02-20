local PARENT = UI

-------------------------------------
-- class UI_ColosseumFirstRewardListItem
-------------------------------------
UI_ColosseumFirstRewardListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumFirstRewardListItem:init(tier_name)
    local vars = self:load('colosseum_reward_popup_item_02.ui')

    self:initUI(tier_name)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumFirstRewardListItem:initUI(tier_name)
    local vars = self.vars
    local icon = ColosseumUserInfo:makeTierIcon(tier_name, 'big')
    vars['tierNode']:addChild(icon)

    local table_colosseum_reward = TableColosseumReward()

    -- 티어 명칭
    local tier_full_name = ColosseumUserInfo:getTierName(tier_name)
    vars['tierLabel']:setString(Str('{1} 최초 달성 보상', tier_full_name))

    -- 보상
    local cash = table_colosseum_reward:getFirstRewardCash(tier_name)
    vars['rewardLabel']:setString(Str('{1}개', cash))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumFirstRewardListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumFirstRewardListItem:refresh()
end