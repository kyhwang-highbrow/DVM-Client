local PARENT = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable())

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
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()

    self.m_tUserInfo = t_user_info

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

    local nickname = t_user_info['nick'] or Str('닉네임미지정')

    -- 폰트 지정
    local font = 'res/font/common_font_01.ttf'
    --font = Translate:getFontPath()

    -- label 생성
    local label = cc.Label:createWithTTF(nickname, font, 22, 0)
    label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setDockPoint(cc.p(0.5, 0.5))
    label:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    label:setPosition(0, 180)
    self.m_rootNode:addChild(label)
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