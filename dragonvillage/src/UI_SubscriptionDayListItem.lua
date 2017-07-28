local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SubscriptionDayListItem
-------------------------------------
UI_SubscriptionDayListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SubscriptionDayListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('shop_package_daily_dia_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SubscriptionDayListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionDayListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SubscriptionDayListItem:refresh()
end
