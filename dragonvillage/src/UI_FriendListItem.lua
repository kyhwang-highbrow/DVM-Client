local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendListItem
-------------------------------------
UI_FriendListItem = class(PARENT, {
        m_friendUid = '',
        m_bManageMode = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendListItem:init(t_friend_info)
    self.m_friendUid = t_friend_info.m_uid
    self.m_bManageMode = false
    local vars = self:load('friend_item_01.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendListItem:initUI()
    local vars = self.vars
    local t_friend_info = self:getFriendInfo()

    vars['nameLabel']:setString(t_friend_info:getNickText())
    vars['levelLabel']:setString(t_friend_info:getLvText())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendListItem:initButton()
    local vars = self.vars
    local t_friend_info = self:getFriendInfo()
    vars['userNode']:addChild(t_friend_info:getDragonCard())
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendListItem:refresh()
    local vars = self.vars

    local is_manage_mode = self.m_bManageMode

    if is_manage_mode then
        vars['sendBtn']:setVisible(false)
        vars['deleteBtn']:setVisible(true)
    else
        vars['sendBtn']:setVisible(true)
        vars['deleteBtn']:setVisible(false)
    end

    local t_friend_info = self:getFriendInfo()

    vars['timeLabel']:setString(t_friend_info:getPastActiveTimeText())

    -- 보내기 버튼
    vars['sendBtn']:setEnabled(not g_friendData:isSentFp(self.m_friendUid))
end

-------------------------------------
-- function getFriendInfo
-------------------------------------
function UI_FriendListItem:getFriendInfo()
    local t_friend_info = g_friendData:getFriendInfo(self.m_friendUid)
    return t_friend_info
end
