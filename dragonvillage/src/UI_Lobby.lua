local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
        m_lobbyMap = '',
        m_lobbyUserFirstMake = 'bool',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Lobby:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Lobby'
    self.m_bVisible = true
    self.m_titleStr = nil
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_Lobby:init()
    local vars = self:load('lobby.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Lobby')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)
    g_topUserInfo:doActionReset()
    g_topUserInfo:doAction()

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
    self:initCamera()
end

-------------------------------------
-- function initCamera
-------------------------------------
function UI_Lobby:initCamera()
    local vars = self.vars
    local lobby_map = LobbyMap(vars['cameraNode'])
    self.m_lobbyMap = lobby_map
    lobby_map:setContainerSize(1280*3, 960)
    
    lobby_map:addLayer(self:makeLobbyLayer(4), 0.7) -- 하늘
    lobby_map:addLayer(self:makeLobbyLayer(3), 0.8) -- 마을
    lobby_map:addLayer(self:makeLobbyLayer(2), 0.9) -- 분수

    local lobby_ground = self:makeLobbyLayer(1) -- 땅
    lobby_map:addLayer_lobbyGround(lobby_ground, 1, 1, self)
    lobby_map.m_groudNode = lobby_ground

    lobby_map:setMoveStartCB(function()
        self:doActionReverse()
        g_topUserInfo:doActionReverse()
    end)

    lobby_map:setMoveEndCB(function()
        self:doAction(nil, nil, 0.5)
        g_topUserInfo:doAction(nil, nil, 0.5)
    end)
end

-------------------------------------
-- function refresh_lobbyUsers
-------------------------------------
function UI_Lobby:refresh_lobbyUsers()
    self.m_lobbyMap:clearAllUser()

    -- 플레이어 유저의 Tamer만 생성하고 싶을 경우 true로 설정하세요.
    local user_only = false

    if user_only then
        local user_info = g_lobbyUserListData:getLobbyUser_playerOnly()
        self.m_lobbyMap:makeLobbyTamerBot(user_info)
    else
        local l_lobby_user_list = g_lobbyUserListData:getLobbyUserList()
        for i,user_info in ipairs(l_lobby_user_list) do
            self.m_lobbyMap:makeLobbyTamerBot(user_info)
        end
    end

    self.m_lobbyUserFirstMake = true
end

-------------------------------------
-- function makeLobbyLayer
-------------------------------------
function UI_Lobby:makeLobbyLayer(idx)
    local node = cc.Node:create()
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setAnchorPoint(cc.p(0.5, 0.5))

    local skip_error_msg = true

    local animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_left/lobby_layer_%.2d_left.vrp', idx, idx), skip_error_msg)
    if (not animator.m_node) then
        animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_left.png', idx))
    end
    animator:setDockPoint(cc.p(0.5, 0.5))
    animator:setAnchorPoint(cc.p(0.5, 0.5))
    animator:setPositionX(-1280)
    node:addChild(animator.m_node)

    local animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_center/lobby_layer_%.2d_center.vrp', idx, idx), skip_error_msg)
    if (not animator.m_node) then
        animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_center.png', idx))
    end
    animator:setDockPoint(cc.p(0.5, 0.5))
    animator:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(animator.m_node)

    local animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_right/lobby_layer_%.2d_right.vrp', idx, idx), skip_error_msg)
    if (not animator.m_node) then
        animator = MakeAnimator(string.format('res/lobby/lobby_layer_%.2d_right.png', idx))
    end
    animator:setDockPoint(cc.p(0.5, 0.5))
    animator:setAnchorPoint(cc.p(0.5, 0.5))
    animator:setPositionX(1280)
    node:addChild(animator.m_node)

    return node
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Lobby:initButton()
    local vars = self.vars
    
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)
    vars['battleBtn']:registerScriptTapHandler(function() self:click_battleBtn() end)
    vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end)
    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
	vars['questBtn']:registerScriptTapHandler(function() self:click_questBtn() end)
    vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)
    vars['friendBtn']:registerScriptTapHandler(function() self:click_friendBtn() end)

    -- FGT버전에서 퀘스트 기능 숨김
    if (TARGET_SERVER == 'FGT') then
        vars['questBtn']:setVisible(false)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Lobby:refresh()

    -- 유저 정보 갱신
    self:refresh_userInfo()

    -- 로비 정보 갱신 (최초로 생성하거나 lobby_user_list정보의 업데이트가 필요한 경우)
    if (not self.m_lobbyUserFirstMake) or (g_lobbyUserListData:checkNeedUpdate_LobbyUserList() == true) then
        local cb_func = function() self:refresh_lobbyUsers() end
        g_lobbyUserListData:requestLobbyUserList_UseUI(cb_func)
    end
end

-------------------------------------
-- function refresh_userInfo
-- @brief 유저 정보 갱신
-------------------------------------
function UI_Lobby:refresh_userInfo()
   local vars = self.vars

    -- TODO 어떤 기준으로 출력??
    vars['userTitleLabel']:setString(Str('수습테이머'))

    -- 닉네임
    local nickname = g_userData:get('nick')
    vars['userNameLabel']:setString(nickname)

    -- 레벨
    local lv = g_userData:get('lv')
    vars['userLvLabel']:setString(Str('레벨 {1}', lv))

    -- 경헙치
    local table_user_level = TableUserLevel()
    local exp = g_userData:get('exp')
    local exp_percentage = table_user_level:getUserLevelExpPercentage(lv, exp)
    vars['userExpLabel']:setString(Str('{1}%', exp_percentage))
    vars['userExpGg']:setPercentage(exp_percentage)

    -- 대표 드래곤 아이콘
    --[[
    local t_leader_dragon_data = g_dragonsData:getLeaderDragon()
    if t_leader_dragon_data then
        local dragon_id = t_leader_dragon_data['did']
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[dragon_id]

        local sprite = IconHelper:getHeroIcon(t_dragon['icon'], t_leader_dragon_data['evolution'], t_dragon['attr'])
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['userNode']:removeAllChildren()
        vars['userNode']:addChild(sprite)
    end
    --]]
end

-------------------------------------
-- function click_adventureBtn
-- @brief 모험 버튼
-------------------------------------
function UI_Lobby:click_adventureBtn()
    local func = function()
        local scene = SceneAdventure()
        scene:runScene()
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_battleBtn
-- @brief "전투" 버튼
-------------------------------------
function UI_Lobby:click_battleBtn()
    if (TARGET_SERVER == 'FGT') then
        UIManager:toastNotificationRed('"전투"는 준비 중입니다.')
        return
    end

    UI_BattleMenu()
end

-------------------------------------
-- function click_dragonManageBtn
-- @brief 드래곤 관리 버튼
-------------------------------------
function UI_Lobby:click_dragonManageBtn()
    local func = function()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            self:sceneFadeInAction()
            self:refresh()
        end
        ui:setCloseCB(close_cb)
    end

    self:sceneFadeOutAndCallFunc(func)
end

-------------------------------------
-- function click_shopBtn
-- @brief 상점 버튼
-------------------------------------
function UI_Lobby:click_shopBtn()
    UI_ShopPopup()
end

-------------------------------------
-- function click_questBtn
-- @brief 퀘스트 버튼
-------------------------------------
function UI_Lobby:click_questBtn()
    UI_QuestPopup()
end

-------------------------------------
-- function click_inventoryBtn
-- @brief 인벤토리 버튼
-------------------------------------
function UI_Lobby:click_inventoryBtn()
    UI_Inventory()
end

-------------------------------------
-- function click_friendBtn
-- @brief 친구
-------------------------------------
function UI_Lobby:click_friendBtn()
    UI_FriendPopup()
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_Lobby:click_exitBtn()
    local function yes_cb()
        cc.Director:getInstance():endToLua()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('종료하시겠습니까?'), yes_cb)
end

--@CHECK
UI:checkCompileError(UI_Lobby)
