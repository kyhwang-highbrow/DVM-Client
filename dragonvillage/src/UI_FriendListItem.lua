local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendListItem
-------------------------------------
UI_FriendListItem = class(PARENT, {
        m_tFriendInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendListItem:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
    local vars = self:load('friend_list_01.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendListItem:refresh()
end