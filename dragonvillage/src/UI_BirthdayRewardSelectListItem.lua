local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_BirthdayRewardSelectListItem
-------------------------------------
UI_BirthdayRewardSelectListItem = class(PARENT, {
        m_tItemData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BirthdayRewardSelectListItem:init(t_item_data)
    self.m_tItemData = t_item_data

    local vars = self:load('event_birthday_reward_select_popup_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BirthdayRewardSelectListItem:initUI()
    local vars = self.vars

    local did = self.m_tItemData['did']
    local name = Str(self.m_tItemData['t_name'])

    local card = MakeSimpleDragonCard(did)

    vars['dragonNode']:addChild(card.root)

    vars['nameLabel']:setString(name)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BirthdayRewardSelectListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BirthdayRewardSelectListItem:refresh()
end