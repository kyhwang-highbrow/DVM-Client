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
function UI_FriendListItem:initButton()
    local vars = self.vars
    local t_friend_info = self:getFriendInfo()
    vars['userNode']:addChild(t_friend_info:getDragonCard())

    -- 친구 대전
    local pvp_node = vars['friendshipBtn']
    -- 콜로세움 (신규) 모드 친구 대전 불가
--    if IS_ARENA_OPEN() then
--        pvp_node:setVisible(false)
--    end
    
    pvp_node:registerScriptTapHandler(function() self:click_friendshipBtn() end)
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
        vars['friendshipBtn']:setVisible(false)
    else
        vars['sendBtn']:setVisible(true)
        vars['deleteBtn']:setVisible(false)
        vars['friendshipBtn']:setVisible(true)

        -- 콜로세움 (신규) 모드 친구 대전 불가
--        if IS_ARENA_OPEN() then
--            vars['friendshipBtn']:setVisible(false)
--        end
    end

    local t_friend_info = self:getFriendInfo()

    vars['timeLabel']:setString(t_friend_info:getPastActiveTimeText())

    -- 보내기 버튼
    local is_send = g_friendData:isSentFp(self.m_friendUid)
    vars['sendBtn']:setEnabled(not is_send)
    vars['sendDisableSprite']:setVisible(is_send)
end

-------------------------------------
-- function getFriendInfo
-------------------------------------
function UI_FriendListItem:getFriendInfo()
    local t_friend_info = g_friendData:getFriendInfo(self.m_friendUid)
    return t_friend_info
end

-------------------------------------
-- function click_friendshipBtn
-------------------------------------
function UI_FriendListItem:click_friendshipBtn()
    --if IS_TEST_MODE() then
    local vs_uid = self.m_friendUid
    
    if IS_ARENA_NEW_OPEN() then
        g_friendMatchData:request_arenaInfo(FRIEND_MATCH_MODE.FRIEND, vs_uid)
    else

        local function goto_ready()
            UI_FriendMatchReady(FRIEND_MATCH_MODE.FRIEND)
        end

        g_friendMatchData:request_colosseumInfo(vs_uid, goto_ready)
    end
    --else
    --    UIManager:toastNotificationRed(Str('준비 중입니다.'))
    --end
end