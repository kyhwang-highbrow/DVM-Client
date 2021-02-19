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