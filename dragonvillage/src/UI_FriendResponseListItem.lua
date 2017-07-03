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

    vars['timeLabel']:setString(t_friend_info:getPastActiveTimeText())
    vars['nameLabel']:setString(t_friend_info:getNickText())
    vars['levelLabel']:setString(t_friend_info:getLvText())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendResponseListItem:initButton()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo
    
    vars['sendBtn']:setVisible(false)
    vars['acceptBtn']:setVisible(true)
    vars['refuseBtn']:setVisible(true)
    vars['userNode']:addChild(t_friend_info:getDragonCard())    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendResponseListItem:refresh()
end
