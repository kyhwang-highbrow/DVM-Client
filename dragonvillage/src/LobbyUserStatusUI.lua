local PARENT = class(UI, IEventDispatcher:getCloneTable(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyUserStatusUI
-------------------------------------
LobbyUserStatusUI = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_tUserInfo = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyUserStatusUI:init(t_user_info)

    self:load('lobby_user_info_01.ui')

    -- rootNode 생성
    self.m_rootNode = cc.Node:create()
    self.m_rootNode:addChild(self.root)
    self.root:setPositionY(180)

    self.m_tUserInfo = t_user_info

    self.vars['infoBtn']:registerScriptTapHandler(function() UI_LobbyUserInfoPopup(t_user_info) end)
    self:init_statusUI()
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyUserStatusUI:onEvent(event_name, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_rootNode:setPosition(x, y)

        self:dispatch('lobby_user_status_ui_move', self, x, y)
    end
end

-------------------------------------
-- function init_statusUI
-------------------------------------
function LobbyUserStatusUI:init_statusUI()
    local t_user_info = self.m_tUserInfo

    local vars = self.vars

    -- 닉네임
    local nickname = t_user_info['nick']
    vars['nameLabel']:setString(nickname)

    -- 길드 이름
    local guild_name = t_user_info['guild']
    vars['guildLabel']:setString(guild_name)
end

-------------------------------------
-- function setActive
-------------------------------------
function LobbyUserStatusUI:setActive(active)
    -- 시연 버전을 위해서 기능 off
    if true then
        return
    end
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