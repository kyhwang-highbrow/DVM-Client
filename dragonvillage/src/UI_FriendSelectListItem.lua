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

    local time_str = g_friendData:getDragonUseCoolStr(t_friend_info)
    vars['timeLabel']:setString(time_str)

    -- 비활성화 여부
    vars['disableSprite']:setVisible(not t_friend_info['enable_use'])
    vars['selectBtn']:setVisible(t_friend_info['enable_use'])

    do-- 타입별 차별화
        local friendtype = t_friend_info['friendtype']

        -- 일반 친구
        if (friendtype == 1) then
            
        -- 베스트프랜드
        elseif (friendtype == 2) then
            vars['bestfriendSprite']:setVisible(true)

        -- 소울메이트
        elseif (friendtype == 3) then
            vars['soulmateSprite']:setVisible(true)

        else
            errro('friendtype : ' .. friendtype)
        end
    end
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