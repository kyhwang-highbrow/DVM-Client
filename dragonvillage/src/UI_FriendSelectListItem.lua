local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendSelectListItem
-------------------------------------
UI_FriendSelectListItem = class(PARENT, {
        m_tFriendInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendSelectListItem:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
    local vars = self:load('friend_select_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendSelectListItem:initUI()
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
function UI_FriendSelectListItem:initButton()
    local vars = self.vars
    --vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendSelectListItem:refresh()
    local vars = self.vars
end