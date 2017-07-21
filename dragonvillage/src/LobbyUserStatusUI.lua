local PARENT = class(UI, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyUserStatusUI
-------------------------------------
LobbyUserStatusUI = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_tUserInfo = 'StructUserInfo',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyUserStatusUI:init(t_user_info)

    self:load('lobby_user_info_01.ui')

    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
    self.m_rootNode:addChild(self.root)
    self.root:setPositionY(280)

    self.m_tUserInfo = t_user_info

    self.vars['infoBtn']:registerScriptTapHandler(function() UI_UserInfoMini:open(t_user_info) end)
    self:init_statusUI()
    self:setActive(false)
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyUserStatusUI:onEvent(event_name, t_event, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_rootNode:setPosition(x, y)

        self:dispatch('lobby_user_status_ui_move', {}, self, x, y)
    end
end

-------------------------------------
-- function init_statusUI
-------------------------------------
function LobbyUserStatusUI:init_statusUI()
    local t_user_info = self.m_tUserInfo

    local vars = self.vars

    -- 칭호
    local tamer_title_str = t_user_info:getTamerTitleStr()
    vars['titleLabel']:setString(tamer_title_str)

    -- 닉네임
    local nickname = t_user_info:getNickname()
    vars['nameLabel']:setString(nickname)

    -- 길드 이름
    local guild_name = t_user_info:getGuild()
    vars['guildLabel']:setString(guild_name)

    -- 칭호가 존재하지 않을 경우 정렬
    if (tamer_title_str == '') or (tamer_title_str == nil) then
        vars['nameLabel']:setPositionY(0)
    else
        vars['nameLabel']:setPositionY(-11)
    end
end

-------------------------------------
-- function init_statusUI
-------------------------------------
function LobbyUserStatusUI:refreshUI(struct_user_info)
    if (struct_user_info) then
        self.m_tUserInfo = struct_user_info
    end
    self:init_statusUI()
end

-------------------------------------
-- function setActive
-------------------------------------
function LobbyUserStatusUI:setActive(active)
    local vars = self.vars
    local node = vars['infoBtn']

    if active then
        node:setVisible(true)
    else
        node:setVisible(false)
    end
end

-------------------------------------
-- function release
-------------------------------------
function LobbyUserStatusUI:release()
    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil

    PARENT.release_EventDispatcher(self)
    PARENT.release_EventListener(self)
end