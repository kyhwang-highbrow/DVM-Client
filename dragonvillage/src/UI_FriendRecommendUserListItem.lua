local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendRecommendUserListItem
-------------------------------------
UI_FriendRecommendUserListItem = class(PARENT, {
        m_tFriendInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendRecommendUserListItem:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
    local vars = self:load('friend_item_02.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendRecommendUserListItem:initUI()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo
    
    vars['timeLabel']:setString(t_friend_info:getPastActiveTimeText())
    vars['nameLabel']:setString(t_friend_info:getNickText())
    vars['levelLabel']:setString(t_friend_info:getLvText())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendRecommendUserListItem:initButton()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo
    vars['userNode']:addChild(t_friend_info:getDragonCard())
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendRecommendUserListItem:refresh()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo

    local uid = t_friend_info.m_uid
    if (g_friendData.m_mInvitedUserList[uid] == true) then
        vars['requestBtn']:setVisible(false)
    else
        vars['requestBtn']:setVisible(true)
    end
end
