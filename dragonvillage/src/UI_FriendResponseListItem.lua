local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendResponseListItem
-------------------------------------
UI_FriendResponseListItem = class(PARENT, {
        m_tFriendInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendResponseListItem:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
    local vars = self:load('friend_item_01.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendResponseListItem:initUI()
    local vars = self.vars

    local t_friend_info = self.m_tFriendInfo
    
    local t_dragon_data = t_friend_info['leader']
    local card = UI_DragonCard(t_dragon_data)
    vars['userNode']:addChild(card.root)

    vars['timeLabel']:setString('')
    vars['nameLabel']:setString(t_friend_info['nick'])
    vars['levelLabel']:setString(Str('Lv. {1}', t_friend_info['lv']))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendResponseListItem:initButton()
    local vars = self.vars
    vars['sendBtn']:setVisible(false)
    vars['acceptBtn']:setVisible(true)
    vars['refuseBtn']:setVisible(true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendResponseListItem:refresh()
end