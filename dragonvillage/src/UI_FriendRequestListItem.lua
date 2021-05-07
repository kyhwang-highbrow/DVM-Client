local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendRequestListItem
-------------------------------------
UI_FriendRequestListItem = class(PARENT, {
        m_tFriendInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendRequestListItem:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
    local vars = self:load('friend_item_01.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendRequestListItem:initUI()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo
    
    vars['timeLabel']:setString(t_friend_info:getPastActiveTimeText())
    vars['nameLabel']:setString(t_friend_info:getNickText())
    vars['levelLabel']:setString(t_friend_info:getLvText())

    -- 티어 아이콘
    local tier = t_friend_info:getArenaTier()

    vars['tierNode']:removeAllChildren()
    local icon = StructUserInfoArenaNew:makeTierIcon(tier, 'big')
    vars['tierNode']:addChild(icon)

    -- 티어 이름
    local tier_name = StructUserInfoArenaNew:getTierName(tier)
    vars['tierLabel']:setString(tier_name)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendRequestListItem:initButton()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo

    vars['sendBtn']:setVisible(false)
    vars['cancelBtn']:setVisible(true)
    vars['userNode']:addChild(t_friend_info:getDragonCard())
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendRequestListItem:refresh()
end
