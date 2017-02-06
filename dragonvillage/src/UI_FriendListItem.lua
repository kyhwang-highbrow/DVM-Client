local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendListItem
-------------------------------------
UI_FriendListItem = class(PARENT, {
        m_tFriendInfo = '',
        m_bManageMode = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendListItem:init(t_friend_info)
    self.m_tFriendInfo = t_friend_info
    self.m_bManageMode = false
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

    local t_friend_info = self.m_tFriendInfo
    
    local t_dragon_data = t_friend_info['leader']
    local card = UI_DragonCard(t_dragon_data)
    vars['userNode']:addChild(card.root)

    vars['nameLabel']:setString(t_friend_info['nick'])
    vars['levelLabel']:setString(Str('레벨 {1}', t_friend_info['lv']))

    -- 최종 접속 시간(지나간 시간 출력)
    vars['timeLabel']:setString(g_friendData:getPastActiveTimeStr(t_friend_info))
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
    local vars = self.vars

    local is_manage_mode = self.m_bManageMode

    if is_manage_mode then
        vars['sendBtn']:setVisible(false)
        vars['deleteBtn']:setVisible(true)
    else
        vars['sendBtn']:setVisible(true)
        vars['deleteBtn']:setVisible(false)
    end
end