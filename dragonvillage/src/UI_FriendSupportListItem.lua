local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_FriendSupportListItem
-------------------------------------
UI_FriendSupportListItem = class(PARENT, {
        m_friendUid = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendSupportListItem:init(t_friend_info)
    self.m_friendUid = t_friend_info['uid']
    local vars = self:load('friend_support_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendSupportListItem:initUI()
    local vars = self.vars

    local t_friend_info = self:getFriendInfo()
    
    -- ���� ��û���� �巡�� ������
    local t_dragon_support_request_info = g_friendData:parseDragonSupportRequestInfo(t_friend_info['need_did'])
    local card = MakeSimpleDragonCard(t_dragon_support_request_info['did'])
    vars['dragonNode']:addChild(card.root)

    -- ģ�� �г���
    vars['nameLabel']:setString(t_friend_info['nick'])

    -- ���� ������ �ش� �巡���� ����
    local number = g_dragonsData:getNumOfDragonsByDid(t_dragon_support_request_info['did'])
    vars['haveLabel']:setString(comma_value(number))

    -- �巡���� �������� �� �޴� ��������Ʈ
    local fp_reward = t_dragon_support_request_info['fp_reward']
    vars['fpLabel']:setString(comma_value(fp_reward))

    -- ���� ��û ���� �ð�
    vars['timeLabel']:setString('')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendSupportListItem:initButton()
    local vars = self.vars
    --vars['sendBtn']:setVisible(false)
    --vars['acceptBtn']:setVisible(true)
    --vars['refuseBtn']:setVisible(true)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendSupportListItem:refresh()
end

-------------------------------------
-- function getFriendInfo
-------------------------------------
function UI_FriendSupportListItem:getFriendInfo()
    local t_friend_info = g_friendData:getFriendInfo(self.m_friendUid)
    return t_friend_info
end