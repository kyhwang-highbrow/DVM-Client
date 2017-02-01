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

    local t_friend_info = self.m_tFriendInfo
    
    local t_dragon_data = t_friend_info['leader']
    local card = UI_DragonCard(t_dragon_data)
    vars['userNode']:addChild(card.root)

    vars['timeLabel']:setString('')
    vars['nameLabel']:setString(t_friend_info['nick'])
    vars['levelLabel']:setString(Str('Lv. {1}', t_friend_info['lv']))

    do-- 시간
        local next_invalid_time = t_friend_info['next_invalid_time']
        local server_time = Timer:getServerTime()
        
        if (server_time < next_invalid_time) then
            local gap = (next_invalid_time - server_time)
            local showSeconds = true
            local firstOnly = false
            local text = datetime.makeTimeDesc(gap, showSeconds, firstOnly)
            local msg = Str('{1} 후 사용 가능', text)
            vars['timeLabel']:setString(msg)
        else
            vars['timeLabel']:setString('즉시 사용 가능')
        end
    end
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