local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
        m_hilightTimeStamp = 'time',
        m_masterRoadTimeStamp = 'time',

        m_lobbyWorldAdapter = 'LobbyWorldAdapter',
        m_etcExpendedUI = 'UIC_ExtendedUI',
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
    self.m_bShowChatBtn = true
    self.m_uiBgm = 'bgm_lobby'
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

    -- 로비 진입 시
    self:entryCoroutine()

    -- @ E.T.
    g_errorTracker:cleanupIngameLog()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
    -- 기타 버튼 생성
    local ui = UIC_ExtendedUI:create('lobby_etc_extended.ui')
    self.m_etcExpendedUI = ui
    self.vars['extendedNode']:addChild(ui.m_node)

    self:initLobbyWorldAdapter()

    -- 테이머 아이콘 갱신
    self:refresh_userTamer()

    -- 임시 처리
    local vars = self.vars
    vars['subscriptionLabel']:setVisible(false) -- 월정액 시간 표기 label

    g_topUserInfo:clearBroadcast()
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

        local fail_cb = function(ret) working = false end

        -- 반드시 통신에 성공해야 하는 통신이 실패하면 로비로 재진입
        local required_fail_cb = function(ret)
            local msg = Str('마을에 진입 중 문제가 발생하였습니다.\n잠시 후에 다시 시도해주세요.')
            local ok_cb = function()
                local scene = SceneLobby()
                scene:runScene()
            end
            MakeSimplePopup(POPUP_TYPE.OK, msg, ok_cb)
        end

        --친구 정보 받아옴
        cclog('# 친구 정보 받는 중')
        working = true
        local ui_network = g_friendData:request_friendList(function() working = false end, true)
        if ui_network then
            ui_network:hideBGLayerColor()
            ui_network:setFailCB(required_fail_cb)
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 출석 정보 받는 중')
        working = true
        local ui_network = g_attendanceData:request_attendanceInfo(function(ret) working = false end, required_fail_cb)
        if ui_network then
            ui_network:hideBGLayerColor()
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 이벤트 정보 받는 중')
        working = true
        local ui_network =g_eventData:request_eventList(function(ret) working = false end, required_fail_cb)
        if ui_network then
            ui_network:hideBGLayerColor()
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 접속시간 저장 중')
        working = true
        local ui_network = g_accessTimeData:request_saveTime(function(ret) working = false end, fail_cb)
        if ui_network then
            ui_network:hideBGLayerColor()
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 상점 정보 받는 중')
        working = true
        local ui_network = g_shopDataNew:request_shopInfo(function(ret) working = false end, fail_cb)
        if ui_network then
            ui_network:hideBGLayerColor()
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 드빌전용관 정보 받는 중')
        working = true
        local ui_network = g_highbrowData:request_getHbProductList(function(ret) working = false end, fail_cb)
        if ui_network then
            ui_network:hideBGLayerColor()
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 드래곤 전투력 저장 중')
        working = true
        local ui_network = g_dragonsData:request_updatePower(function(ret) working = false end, fail_cb)
        if ui_network then
            ui_network:hideBGLayerColor()
        end
        while (working) do dt = coroutine.yield() end

        cclog('# 인연의 흔적을 흝어보는 중')
        working = true
        local ui_network = g_secretDungeonData:requestSecretDungeonInfo(function(ret) working = false end)
        if ui_network then
            ui_network:hideBGLayerColor()
            ui_network:setFailCB(required_fail_cb)
        end
        while (working) do dt = coroutine.yield() end

        -- @ MASTER ROAD
        cclog('# 마스터의 길 확인 중')
        working = true
        local _,ui_network = g_masterRoadData:updateMasterRoadAfterReward((function(ret) working = false end))
        if ui_network then
            ui_network:hideBGLayerColor()
            ui_network:setFailCB(required_fail_cb)
        end
        while (working) do dt = coroutine.yield() end

        if (g_tutorialData:isTutorialDone(TUTORIAL.FIRST_START)) then
            -- 패키지 풀팝업 (하드코딩)
            local title_to_lobby = g_localData:get('title_to_lobby') or false
            if (title_to_lobby) then
                local first_login = g_localData:get('first_login') or false

                local t_pid= {90007, 90013, 90012, 90006}
                for _, pid in ipairs(t_pid) do
                    local save_key = string.format('event_full_popup_%d', pid)

                    -- 첫로그인시 봤던 기록 초기화
                    if (first_login) then 
                        g_localData:applyLocalData(false, save_key)
                    end

                    local is_view = g_localData:get(save_key) or false

                    -- 봤던 기록 없는 이벤트 풀팝업 띄워줌
                    if (not is_view) then
                        working = true
                        local ui = UI_EventFullPopup(pid)
                        ui:setCloseCB(function(ret) working = false end)
                        ui:openEventFullPopup()
                        while (working) do dt = coroutine.yield() end
                    end                
                end

                g_localData:applyLocalData(false, 'title_to_lobby')
            end

            -- 이벤트 보상 정보가 있다면 팝업을 띄운다.
            if g_eventData:hasReward() then
                working = true
                local ui = UI_EventPopup()
                ui:setCloseCB(function(ret) working = false end)
                while (working) do dt = coroutine.yield() end
            end
        end

        -- @UI_ACTION 액션 종료 후에는 튜토리얼 시작
        working = true
        self:doAction(function() 
            working = false
            -- @ TUTORIAL
            TutorialManager.getInstance():startTutorial(TUTORIAL.FIRST_START, self)
        end, false)
        g_topUserInfo:doAction()
		self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
        while (working) do dt = coroutine.yield() end

        -- 터치 가능하도록 해제
        block_popup:close()
        coroutine.yield()

        -- @ google achievement
        if (not g_localData:get('is_first_google_login')) then
            g_localData:applyLocalData(true, 'is_first_google_login')

            cclog('# 구글 업적 확인 중')
            working = true
            GoogleHelper.allAchievementCheck((function(ret) working = false end))
            while (working) do dt = coroutine.yield() end
        end
    end

    Coroutine(coroutine_function, '로비 코루틴')
end


-------------------------------------
-- function initLobbyWorldAdapter
-------------------------------------
function UI_Lobby:initLobbyWorldAdapter()
    local vars = self.vars

    local lobby_ui = self
    local parent_node = vars['cameraNode']
    parent_node:setLocalZOrder(-1)
    local chat_client_socket = g_chatClientSocket
    local lobby_manager = g_lobbyManager


    self.m_lobbyWorldAdapter = LobbyWorldAdapter(self, parent_node, chat_client_socket, lobby_manager)

    do -- 로비에서 테이머의 이동 상태에 따라 UI를 숨김
        local lobby_map = self.m_lobbyWorldAdapter.m_lobbyMap

        -- 이동하면 UI 노출
        lobby_map:setMoveStartCB(function()
            parent_node:stopAllActions()
            self:doAction(nil, nil, 0.5)
            g_topUserInfo:doAction(nil, nil, 0.5)
        end)

        -- 정지 후 60초 후에 UI를 숨김 (튜토리얼 중에는 설정하지 않음)
        if (g_tutorialData:isTutorialDone(TUTORIAL.FIRST_START)) then
            lobby_map:setMoveEndCB(function()
                parent_node:stopAllActions()

                local function func()
                    self:doActionReverse()
                    g_topUserInfo:doActionReverse()
                end

                cca.reserveFunc(parent_node, 60, func)
            end)
        end
    end
end

-------------------------------------
-- function refresh_userTamer
-- @breif 유저의 로비맵 테이머를 갱신한다
-------------------------------------
function UI_Lobby:refresh_userTamer()
    local vars = self.vars
    do -- 테이머 아이콘 갱신
        local type = g_tamerData:getCurrTamerTable('type')
        local icon = IconHelper:getTamerProfileIcon(type)
        vars['userNode']:removeAllChildren()
        vars['userNode']:addChild(icon)
    end

    do -- 유저 칭호 갱신
        local title = g_userData:getTamerTitleStr()
        vars['userTitleLabel']:setString(title)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Lobby:initButton()
    local vars = self.vars

    vars['bottomMasterNode']:setLocalZOrder(1)
    vars['bottomButtonMenu']:setLocalZOrder(2)


    -- 하단
    vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end) -- 드래곤
    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end) -- 테이머
    vars['questBtn']:registerScriptTapHandler(function() self:click_questBtn() end) -- 퀘스트
    vars['battleBtn']:registerScriptTapHandler(function() self:click_battleBtn() end) -- 전투
    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end) -- 상점
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end) -- 부화소
    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end) -- 이벤트(출석) 버튼 

    -- 상단
    vars['tamerBtn2']:registerScriptTapHandler(function() self:click_userInfoBtn() end)

    -- 마스터의 길
    vars['masterRoadBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['masterRoadBtn']:registerScriptTapHandler(function() self:click_masterRoadBtn() end)
    vars['etcBtn']:registerScriptTapHandler(function() self:click_etcBtn() end)
    
    -- 좌측 UI
    vars['mailBtn']:registerScriptTapHandler(function() self:click_mailBtn() end)
    vars['googleGameBtn']:registerScriptTapHandler(function() self:click_googleGameBtn() end)
    vars['googleAchievementBtn']:registerScriptTapHandler(function() self:click_googleAchievementBtn() end)

    -- 우측 UI
    vars['subscriptionBtn']:registerScriptTapHandler(function() self:click_subscriptionBtn() end) -- 월정액
    vars['capsuleBtn']:registerScriptTapHandler(function() self:click_capsuleBtn() end)
    vars['itemAutoBtn']:registerScriptTapHandler(function() self:click_itemAutoBtn() end) -- 자동재화(광고)

    do -- 기타 UI
        local etc_vars = self.m_etcExpendedUI.vars
        etc_vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end) -- 설정
        etc_vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankingBtn() end) -- 종합 랭킹
        etc_vars['friendBtn']:registerScriptTapHandler(function() self:click_friendBtn() end) -- 친구
        etc_vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)-- 가방
        etc_vars['bookBtn']:registerScriptTapHandler(function() self:click_bookBtn() end) -- 도감 버튼
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Lobby:refresh()
    -- 유저 정보 갱신
    self:refresh_userInfo()

    -- 마스터의 길 정보 갱신
    self:refresh_masterRoad()

    -- 구글 버튼 처리
    self:refresh_google()
end

-------------------------------------
-- function refresh_highlight
-------------------------------------
function UI_Lobby:refresh_highlight()
    local vars = self.vars
    local etc_vars = self.m_etcExpendedUI.vars

    local function highlight_func()
        -- 전투 메뉴
        vars['battleNotiSprite']:setVisible(g_highlightData:isHighlightExploration() or g_secretDungeonData:isSecretDungeonExist())

        -- 핫타임
        vars['battleHotSprite']:setVisible(g_hotTimeData:isHighlightHotTime())

        -- 퀘스트
        vars['questNotiSprite']:setVisible(g_highlightData:isHighlightQuest())

        -- 우편함
        vars['mailNotiSprite']:setVisible(g_highlightData:isHighlightMail())

        -- 드래곤
        vars['dragonManageNotiSprite']:setVisible(g_highlightData:isHighlightDragon())

        -- 친구 
        etc_vars['friendNotiSprite']:setVisible(g_highlightData:isHighlightFpointSend() or g_highlightData:isHighlightFrinedInvite())
    end

    g_highlightData:request_highlightInfo(highlight_func)

    -- 드래곤 소환
    local highlight, t_highlight = g_hatcheryData:checkHighlight()
    vars['drawNotiSprite']:setVisible(highlight)

    -- 테이머
    vars['tamerNotiSprite']:setVisible(g_tamerData:isHighlightTamer())

    -- 이벤트
    vars['eventManageNotiSprite']:setVisible(g_eventData:isHighlightEvent())

    -- 마스터의 길
    local has_reward, _ = g_masterRoadData:hasRewardRoad()
    vars['masterRoadNotiSprite']:setVisible(has_reward)

	-- 도감
	etc_vars['bookNotiSprite']:setVisible(g_bookData:isHighlightBook())

    -- 기타 (도감과 친구의 합)
    local is_etc_noti = (etc_vars['friendNotiSprite']:isVisible() or etc_vars['bookNotiSprite']:isVisible())
    vars['etcNotiSprite']:setVisible(is_etc_noti)
end

-------------------------------------
-- function refresh_userInfo
-- @brief 유저 정보 갱신
-------------------------------------
function UI_Lobby:refresh_userInfo()
   local vars = self.vars

    -- 칭호
    local title = g_userData:getTamerTitleStr()
    vars['userTitleLabel']:setString(title)

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
-- function refresh_masterRoad
-------------------------------------
function UI_Lobby:refresh_masterRoad()
    local vars = self.vars
    local desc = ''
    
    -- 마지막까지 클리어했다면..?
    if (g_masterRoadData:isClearAllRoad()) then
        --desc = Str('마스터의 길은 계속될겁니다.')
        vars['bottomMasterNode']:setVisible(false)

    -- 현재 목표 출력
    else
        local rid = g_masterRoadData:getFocusRoad()
        local t_road = TableMasterRoad():get(rid)
        desc = Str(t_road['t_desc'], t_road['desc_1'], t_road['desc_2'], t_road['desc_3'])

    end
    vars['roadDescLabel']:setString(desc)
end

-------------------------------------
-- function refresh_google
-------------------------------------
function UI_Lobby:refresh_google()
    local vars = self.vars

    if (g_localData:isGooglePlayConnected()) then
        vars['googleGameBtn']:setVisible(true)
    else
        vars['googleGameBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_battleBtn
-- @brief "전투" 버튼
-------------------------------------
function UI_Lobby:click_battleBtn()
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
    g_shopDataNew:openShopPopup()
end

-------------------------------------
-- function click_questBtn
-- @brief 퀘스트 버튼
-------------------------------------
function UI_Lobby:click_questBtn()
    UI_QuestPopup()
end

-------------------------------------
-- function click_masterRoadBtn
-- @brief 마스터의 길 버튼
-------------------------------------
function UI_Lobby:click_masterRoadBtn()
    UI_MasterRoadPopup()
end

-------------------------------------
-- function click_etcBtn
-- @brief 기타 버튼
-------------------------------------
function UI_Lobby:click_etcBtn()
    self.m_etcExpendedUI:toggleVisibility()
end


-------------------------------------
-- function click_inventoryBtn
-- @brief 가방 버튼
-------------------------------------
function UI_Lobby:click_inventoryBtn()
    UI_Inventory()
end

-------------------------------------
-- function click_friendBtn
-- @brief 친구
-------------------------------------
function UI_Lobby:click_friendBtn()
    UINavigator:goTo('friend')
end

-------------------------------------
-- function click_drawBtn
-- @brief 드래곤 소환 (가챠)
-------------------------------------
function UI_Lobby:click_drawBtn()
    UINavigator:goTo('hatchery', nil)
end

-------------------------------------
-- function click_mailBtn
-- @brief 우편함
-------------------------------------
function UI_Lobby:click_mailBtn()
    UI_MailPopup():setCloseCB(function(is_dirty)
        -- 노티 정보를 갱신하기 위해서 호출
        g_highlightData:setLastUpdateTime()

        if (is_dirty) then
            -- 닉네임 변경으로 인한 처리...
            self:refresh_userInfo()
        end
    end)
end

-------------------------------------
-- function click_userInfoBtn
-------------------------------------
function UI_Lobby:click_userInfoBtn()
    -- @ comment mskim
    -- 로비맵 테이머&드래곤은 채팅서버에 의해 변경되고
    -- 클라에서 직접 조작할 것은 좌상단 테이머 아이콘뿐
    -- 매번 교체한다고 하여도 부하가 크지 않으니 가독성을 위해서 항상 교체
	local function close_cb()
        self:refresh_userTamer()

        -- 닉네임
        local nickname = g_userData:get('nick')
        self.vars['userNameLabel']:setString(nickname)
	end
    RequestUserInfoDetailPopup(g_userData:get('uid'), false, close_cb) -- uid, is_visit, close_cb
end

-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_Lobby:click_tamerBtn()
    -- @ comment 상단과 동일
	local function close_cb()
		self:refresh_userTamer()
	end
	UI_TamerManagePopup():setCloseCB(close_cb)
end

-------------------------------------
-- function click_bookBtn
-------------------------------------
function UI_Lobby:click_bookBtn()
    local function close_cb()
    	-- 노티 정보를 갱신하기 위해서 호출
        g_highlightData:setLastUpdateTime()
    end
	UI_Book():setCloseCB(close_cb)
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_Lobby:click_eventBtn()
    g_eventData:openEventPopup()
end

-------------------------------------
-- function click_subscriptionBtn
-- @brief 월정액 버튼
-------------------------------------
function UI_Lobby:click_subscriptionBtn()
    g_subscriptionData:openSubscriptionPopup()
end

-------------------------------------
-- function click_itemAutoBtn
-- @brief 자동재화 버튼 (광고 보기)
-------------------------------------
function UI_Lobby:click_itemAutoBtn()
    g_advertisingData:showAdvPopup(AD_TYPE.AUTO_ITEM_PICK)
end

-------------------------------------
-- function click_guildBtn
-------------------------------------
function UI_Lobby:click_guildBtn()
    UIManager:toastNotificationRed('"길드"는 준비 중입니다.')
end

-------------------------------------
-- function click_settingBtn
-- @설정
-------------------------------------
function UI_Lobby:click_settingBtn()
    UI_Setting()
end

-------------------------------------
-- function click_rankingBtn
-------------------------------------
function UI_Lobby:click_rankingBtn()
    UI_OverallRankingPopup()
end

-------------------------------------
-- function click_googleGameBtn
-------------------------------------
function UI_Lobby:click_googleGameBtn()
    local vars = self.vars
    local game_pos_x = vars['googleGameBtn']:getPositionX()
    local achv_pos_y = vars['googleAchievementBtn']:getPositionY()

    -- 구글 업적 버튼 열려있는 상태 -> 닫기
    if (vars['googleAchievementBtn']:isVisible()) then
        vars['googleAchievementBtn']:runAction(cc.Sequence:create(
            cca.makeBasicEaseMove(0.2, game_pos_x, achv_pos_y),
            cc.Hide:create()  
        ))

    -- 닫혀 있는 상태 -> 열기
    else
        vars['googleAchievementBtn']:runAction(cc.Sequence:create(
            cc.MoveTo:create(0, cc.p(game_pos_x, achv_pos_y)),
            cc.Show:create(),
            cca.makeBasicEaseMove(0.2, game_pos_x + 100, achv_pos_y)
        ))
    end
end

-------------------------------------
-- function click_googleAchievementBtn
-------------------------------------
function UI_Lobby:click_googleAchievementBtn()
    GoogleHelper.showAchievement()
end

-------------------------------------
-- function click_capsuleBtn
-------------------------------------
function UI_Lobby:click_capsuleBtn()
    g_eventData:openEventPopup('highbrow_shop')
end

-------------------------------------
-- function click_exitBtn
-- @brief 종료
-------------------------------------
function UI_Lobby:click_exitBtn()
    local function yes_cb()
        closeApplication()
    end
    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('종료하시겠습니까?'), yes_cb)
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_Lobby:update(dt)
    -- noti 갱신
    if (g_highlightData.m_lastUpdateTime ~= self.m_hilightTimeStamp) then
        self.m_hilightTimeStamp = g_highlightData.m_lastUpdateTime
        self:refresh_highlight()
    end
    
    -- 마스터의 길 정보 갱신
    if (g_masterRoadData.m_bDirtyMasterRoad) then
        g_masterRoadData.m_bDirtyMasterRoad = false
        self:refresh_masterRoad()
    end

    -- 구글 버튼 처리
    if (GoogleHelper.isDirty) then
        GoogleHelper.setDirty(false)
        self:refresh_google()
    end

    -- 자동 획득 처리
    do
        local node = self.vars['itemAutoLabel']
        node:setString(g_advertisingData:getCoolTimeStr(AD_TYPE.AUTO_ITEM_PICK))
    end
end

-------------------------------------
-- function onDestroyUI
-- @brief
-------------------------------------
function UI_Lobby:onDestroyUI()
    PARENT.onDestroyUI(self)

    if (self.m_lobbyWorldAdapter) then
        self.m_lobbyWorldAdapter:onDestroy()
        self.m_lobbyWorldAdapter = nil
    end
end



--@CHECK
UI:checkCompileError(UI_Lobby)
