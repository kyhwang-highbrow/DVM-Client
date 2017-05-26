local PARENT = UI

-------------------------------------
-- class UI_Village
-- @brief
-------------------------------------
UI_Village = class(PARENT, {
        m_lobbyManager = '',
    })

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function UI_Village:init()
    local vars = self:load('chat_lobby.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Village')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Village:initUI()
    self:initChatClientSocket()
    self:initEditBox()
    self:initWorld()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Village:initButton()
    local vars = self.vars
    vars['moveBtn1']:registerScriptTapHandler(function() self:click_moveBtn1() end)
    vars['moveBtn2']:registerScriptTapHandler(function() self:click_moveBtn2() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Village:refresh()
end


-------------------------------------
-- function initWorld
-------------------------------------
function UI_Village:initWorld()
    local vars = self.vars
    local lobby_map = LobbyMapFactory:createLobbyWorld(vars['worldNode'])

    
    -- 유저 설정
    local struct_user_info = self.m_lobbyManager.m_playerUserInfo
    lobby_map:makeLobbyTamerBot(struct_user_info)
end

-------------------------------------
-- function initChatClientSocket
-------------------------------------
function UI_Village:initChatClientSocket()
    -- 소켓 생성
    local chat_client_socket = ChatClientSocket('192.168.1.63', '3927')

    -- 유저 정보 입력
    local uid = g_serverData:get('local', 'uid')
    local nickname = g_userData:get('nick')
    local lv = g_userData:get('lv')

    local t_data = {}
    t_data['uid'] = tostring(uid)
    t_data['nickname'] = nickname
    t_data['did'] = '120014'
    t_data['level'] = lv
    chat_client_socket:setUserInfo(t_data)

    -- 로비 매니저 생성
    local lobby_manager = LobbyManager()
    lobby_manager:setChatClientSocket(chat_client_socket)
    chat_client_socket:addRegularListener(lobby_manager)
    self.m_lobbyManager = lobby_manager
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_Village:initEditBox()
    local vars = self.vars

    -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
    local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            --self:click_enterBtn()
            local msg = pSender:getText()
            local len = string.len(msg)
            if (len <= 0) then
                UIManager:toastNotificationRed('메시지를 입력하세요.')
                return
            end

            if self.m_lobbyManager:sendNormalMsg(msg) then
                vars['editBox']:setText('')
            else
                UIManager:toastNotificationRed('메시지 전송에 실패하였습니다.')
            end
        end
    end
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function click_moveBtn1
-------------------------------------
function UI_Village:click_moveBtn1()
    self.m_lobbyManager:requestCharacterMove(math_random(1, 999), 100)
end

-------------------------------------
-- function click_moveBtn2
-------------------------------------
function UI_Village:click_moveBtn2()
    self.m_lobbyManager:requestCharacterMove(math_random(1, 999), 200)
end