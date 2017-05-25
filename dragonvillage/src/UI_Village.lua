local PARENT = UI

-------------------------------------
-- class UI_Village
-- @brief
-------------------------------------
UI_Village = class(PARENT, {
    })

-------------------------------------
-- function init
-- @brief 생성자
-------------------------------------
function UI_Village:init()
    local vars = self:load('empty.ui')
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
    -- 소켓 생성
    local chat_client_socket = ChatClientSocket('192.168.1.63', '3927')

    -- 유저 정보 입력
    local t_data = {}
    t_data['uid'] = '501'
    t_data['nickname'] = '김성구'
    t_data['did'] = '120014'
    t_data['level'] = 99999
    chat_client_socket:setUserInfo(t_data)

    -- 로비 매니저 생성
    local lobby_manager = LobbyManager()
    lobby_manager:setChatClientSocket(chat_client_socket)
    chat_client_socket:addRegularListener(lobby_manager)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Village:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Village:refresh()
end