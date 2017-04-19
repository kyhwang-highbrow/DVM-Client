local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
        m_lobbyMap = '',
        m_lobbyUserFirstMake = 'bool',
        m_infoBoard = 'UI_NotificationInfo',
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

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    self:initInfoBoard()

    -- 가챠 관련 정보 갱신
    --g_gachaData:refresh_gachaInfo(function() end)
    --g_friendData:request_friendList(function() self:refreshFriendOnlineBuff() end, true)

    -- 로비 진입 시
    self:entryCoroutine()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
    self:initCamera()

    local vars = self.vars
    do -- 테이머 아이콘 갱신
        local type = g_userData:getTamerInfo('type')
        local icon = IconHelper:getTamerProfileIcon(type)
        vars['userNode']:removeAllChildren()
        vars['userNode']:addChild(icon)
    end
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_Lobby:init_after()
    PARENT.init_after(self)
    g_topUserInfo:doActionReset()
end

-------------------------------------
-- function entryCoroutine
-------------------------------------
function UI_Lobby:entryCoroutine()
    -- UI 숨김
    self:doActionReset()
    g_topUserInfo:doActionReset()

    local function coroutine_function(dt)
    
        local working = false

        -- 터치 불가상태로 만들어 놓음
        local block_popup = UI_BlockPopup()
        dt = coroutine.yield()

        --[[
        -- 가챠 정보 받아옴
        cclog('# 가챠 정보 받는 중')
        working = true
        g_gachaData:refresh_gachaInfo(function() working = false end)
        while (working) do dt = coroutine.yield() end

        -- 친구 정보 받아옴
        cclog('# 친구 정보 받는 중')
        working = true
        g_friendData:request_friendList(function() self:refreshFriendOnlineBuff() working = false end, true)
        while (working) do dt = coroutine.yield() end
        --]]

        cclog('# 출석 정보 받는 중')
        working = true
        g_attendanceData:request_attendanceInfo(function(ret) working = false end)
        while (working) do dt = coroutine.yield() end

        if g_eventData:hasReward() then
            working = true
            local ui = UI_EventPopup()
            ui:setCloseCB(function(ret) working = false end)
            while (working) do dt = coroutine.yield() end
        end

        -- @UI_ACTION
        working = true
        self:doAction(function() working = false end, false)
        g_topUserInfo:doAction()
        while (working) do dt = coroutine.yield() end

        -- 터치 가능하도록 해제
        block_popup:close()
        coroutine.yield()
    end


    Coroutine(coroutine_function, '로비 코루틴')
end


-------------------------------------
-- function initCamera
-------------------------------------
function UI_Lobby:initCamera()
    local vars = self.vars
    vars['cameraNode']:setLocalZOrder(-1)
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
-- @breif 로비맵에 있는 모든 테이머를 삭제 후 새로 생성
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
-- function refresh_userTamer
-- @breif 유저의 로비맵 테이머를 갱신한다
-------------------------------------
function UI_Lobby:refresh_userTamer()
    self.m_lobbyMap:refreshLobbyTamerUser()

    local vars = self.vars
    do -- 테이머 아이콘 갱신
        local type = g_userData:getTamerInfo('type')
        local icon = IconHelper:getTamerProfileIcon(type)
        vars['userNode']:removeAllChildren()
        vars['userNode']:addChild(icon)
    end
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
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end)
    vars['giftBtn']:registerScriptTapHandler(function() self:click_giftBtn() end)
	vars['mailBtn']:registerScriptTapHandler(function() self:click_mailBtn() end)
    vars['buffBtn']:registerScriptTapHandler(function() self:click_buffBtn() end)
	vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
    vars['tamerBtn2']:registerScriptTapHandler(function() self:click_tamerBtn() end)
    vars['explorationBtn']:registerScriptTapHandler(function() self:click_explorationBtn() end) -- 탐험 버튼
    vars['collectionBtn']:registerScriptTapHandler(function() self:click_collectionBtn() end) -- 도감 버튼
    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end) -- 이벤트(출석) 버튼 

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
end

-------------------------------------
-- function click_adventureBtn
-- @brief 모험 버튼
-------------------------------------
function UI_Lobby:click_adventureBtn()
    local refresh_adventure_server_data
    local fede_out
    local go_to_adventure_scene

    -- 서버로부터 모험 데이터를 갱신
    refresh_adventure_server_data = function()
        g_adventureData:request_adventureInfo(fede_out, function() end)
    end

    -- 페이드 아웃 연출
    fede_out = function()
        self:sceneFadeOutAndCallFunc(go_to_adventure_scene)
    end

    -- 모험(스테이지 선택) 씬으로 전환
    go_to_adventure_scene = function()
        local stage_id = nil
        local skip_request = true
        g_adventureData:goToAdventureScene(stage_id, skip_request)
    end

    refresh_adventure_server_data()
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
    g_shopData:openShopPopup()
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
-- function click_drawBtn
-- @brief 드래곤 소환 (가챠)
-------------------------------------
function UI_Lobby:click_drawBtn()
    g_dragonSummonData:openDragonSummon()
end

-------------------------------------
-- function click_giftBtn
-- @brief 드래곤 소환 (가챠)
-------------------------------------
function UI_Lobby:click_giftBtn()
    local function func()
        UI_GachaBox()
    end
    g_gachaData:refresh_gachaInfo(func)
end

-------------------------------------
-- function click_mailBtn
-- @brief 우편함
-------------------------------------
function UI_Lobby:click_mailBtn()
    UI_MailPopup()
end

-------------------------------------
-- function initInfoBoard
-------------------------------------
function UI_Lobby:initInfoBoard()
    local buff_board = UI_NotificationInfo()
    buff_board.root:setDockPoint(cc.p(1, 1))
    self.vars['buffNode']:addChild(buff_board.root)
    self.m_infoBoard = buff_board

    do
        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText('{@SKILL_NAME}[베스트프렌드 접속 버프] {@WHITE}(뀨뀨뀨, 김 성 구 접속 중)')
        buff_info:setDescText('{@DEEPSKYBLUE}[베스트프렌드의 응원] {@SKILL_DESC}경험치 +3%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%')
        buff_board:addElement(buff_info)

        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText('{@SKILL_NAME}[친구 드래곤 사용 버프] {@SKILL_DESC}체력 +500')
        buff_info:setDescText('{@DEEPSKYBLUE}[베스트프렌드의 응원] {@SKILL_DESC}경험치 +3%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%')
        buff_board:addElement(buff_info)

        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText('{@SKILL_NAME}[친구 드래곤 사용 버프] {@SKILL_DESC}체력 +500')
        buff_info:setDescText('{@DEEPSKYBLUE}[베스트프렌드의 응원] {@SKILL_DESC}경험치 +3%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%\n{@DEEPSKYBLUE}[베스트프렌드의 행운] {@SKILL_DESC}골드 획득 +10%')
        buff_board:addElement(buff_info)

        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText('{@YELLOW}[이벤트 중] 고급 드래곤 소환 250다이아몬드->200다이아몬드 {@RED}03:13:15{@YELLOW} 후 종료')
        buff_board:addElement(buff_info)
    end
end

-------------------------------------
-- function refreshFriendOnlineBuff
-------------------------------------
function UI_Lobby:refreshFriendOnlineBuff()
    local bestfriend_buff, soulmate_buff, total_buff_list = g_friendData:getFriendOnlineBuff()

    -- 소울메이트 버프
    if soulmate_buff['info_title'] then
        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText(soulmate_buff['info_title'])

        local info_str = nil
        for i,v in ipairs(soulmate_buff['info_list']) do
            if (not info_str) then
                info_str = v
            else
                info_str = info_str .. '\n' .. v
            end
        end
        buff_info:setDescText(info_str)
        
        self.m_infoBoard:addElement(buff_info)
    end

    -- 베스트프랜드 버프
    if bestfriend_buff['info_title'] then
        local buff_info = UI_NotificationInfoElement()
        buff_info:setTitleText(bestfriend_buff['info_title'])

        local info_str = nil
        for i,v in ipairs(bestfriend_buff['info_list']) do
            if (not info_str) then
                info_str = v
            else
                info_str = info_str .. '\n' .. v
            end
        end
        buff_info:setDescText(info_str)
        
        self.m_infoBoard:addElement(buff_info)
    end
end

-------------------------------------
-- function click_buffBtn
-------------------------------------
function UI_Lobby:click_buffBtn()
    self.m_infoBoard:show()
end

-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_Lobby:click_tamerBtn()
	local before_tamer = g_userData:getTamerInfo('type')

	local function close_cb()
		local curr_tamer = g_userData:getTamerInfo('type')

		if (before_tamer ~= curr_tamer) then
			self:refresh_userTamer()
		end
	end

    local ui = UI_TamerManagePopup()
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_explorationBtn
-------------------------------------
function UI_Lobby:click_explorationBtn()
    local function finish_cb()
        UI_Exploration()
    end

    g_explorationData:request_explorationInfo(finish_cb)
end

-------------------------------------
-- function click_collectionBtn
-------------------------------------
function UI_Lobby:click_collectionBtn()
    g_collectionData:openCollectionPopup()
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_Lobby:click_eventBtn()
    g_eventData:openEventPopup()
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_Lobby:click_exitBtn()
    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('종료하시겠습니까?'), yes_cb)
end

--@CHECK
UI:checkCompileError(UI_Lobby)
