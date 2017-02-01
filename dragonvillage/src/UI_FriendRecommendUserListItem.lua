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
    local vars = self:load('friend_list_02.ui')

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
function UI_FriendRecommendUserListItem:initButton()
    local vars = self.vars
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendRecommendUserListItem:refresh()
    local vars = self.vars
    local t_friend_info = self.m_tFriendInfo

    if (t_friend_info['invited'] == true) then
        vars['requestBtn']:setVisible(false)
    else
        vars['requestBtn']:setVisible(true)
    end
end

-------------------------------------
-- function click_requestBtn
-------------------------------------
function UI_FriendRecommendUserListItem:click_requestBtn()
    local t_friend_info = self.m_tFriendInfo

    local function finish_cb(ret)
        self:refresh()
        local msg = Str('[{1}]에게 친구 요청을 하였습니다.', t_friend_info['nick'])
        UIManager:toastNotificationGreen(msg)
    end

    local friend_ui = t_friend_info['uid']
    g_friendData:request_invite(friend_ui, finish_cb)
end