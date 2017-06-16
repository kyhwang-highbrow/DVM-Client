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
    
    vars['timeLabel']:setString('')
    vars['nameLabel']:setString(t_friend_info['nick'])
    vars['levelLabel']:setString(Str('Lv. {1}', t_friend_info['lv']))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendRequestListItem:initButton()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo

    vars['sendBtn']:setVisible(false)
    vars['cancelBtn']:setVisible(true)

    local t_dragon_data = t_friend_info['leader']
    local card = UI_DragonCard(t_dragon_data)
    card.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(t_friend_info) end)
    vars['userNode']:addChild(card.root)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendRequestListItem:refresh()
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_FriendRequestListItem:click_dragonCard(t_friend_info)
    local visit = true
    UI_UserInfoDetailPopup(t_friend_info, visit)
end