local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewTierInfoListItem
-------------------------------------
UI_ArenaNewTierInfoListItem = class(PARENT, {
        m_tierInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewTierInfoListItem:init(t_tier_info)
    self.m_tierInfo = t_tier_info
    local vars = self:load('arena_new_popup_tier_reward_item.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewTierInfoListItem:initUI()
    local vars = self.vars
    
    local tierInfo = self.m_tierInfo
    local activeRewardInfo = tierInfo['achieve_reward']
    local l_reward = g_itemData:parsePackageItemStr(activeRewardInfo)

    -- 보상
    if (l_reward and #l_reward > 0) then
        -- 보상은 오직 다이아 뿐임
        local itemCount = comma_value(l_reward[1]['count'])

        vars['rewardLabel']:setString(itemCount)
    else    
        vars['rewardLabel']:setString('-')
    end

    local scoreMin = comma_value(tierInfo['score_min'])
    vars['scoreLabel']:setString(scoreMin)
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewTierInfoListItem:initButton()
    local vars = self.vars 
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewTierInfoListItem:refresh()
end