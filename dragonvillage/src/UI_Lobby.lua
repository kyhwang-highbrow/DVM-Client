local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-- UI_Lobby인스턴스가 생성된 횟수 (최초 진입 시를 구별하기 위해 추가)
local ENTRY_LOBBY_CNT = 0

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
        m_lobbyWorldAdapter = 'LobbyWorldAdapter',
        m_etcExpendedUI = 'UIC_ExtendedUI',
		m_lobbyGuide = 'UIC_LobbyGuide',
        m_lobbySpotSaleBtn = 'UI_LobbySpotSaleBtn',

        -- 버튼 상태
        m_bItemAutoEnabled = 'bool',
        m_bGiftBoxEnabled = 'bool',

        m_bDirtyLeftButtonMenu = 'bool',
        m_bUpdatingHighlights = 'bool',
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
    self.m_bDirtyLeftButtonMenu = true
    self.m_bUpdatingHighlights = false
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
    --self:refresh()

    -- 로비 진입 시 - 코루틴 통신 끝난 후에 refresh 함
    self:entryCoroutine()
    
    -- @analytics
    Analytics:firstTimeExperience('Lobby_Enter')

    -- @ E.T.
    g_errorTracker:cleanupIngameLog()

	ENTRY_LOBBY_CNT = (ENTRY_LOBBY_CNT + 1)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
	local vars = self.vars

	-- 로비 가이드
    local function refresh()
        self:update_masterRoad()
    end
	self.m_lobbyGuide = UIC_LobbyGuide(vars['bottomMasterNode'], vars['roadTitleLabel'], vars['roadDescLabel'], vars['masterRoadNotiSprite'], refresh)

    -- 기타 버튼 생성
    local ui = UIC_ExtendedUI:create('lobby_etc_extended.ui')
    self.m_etcExpendedUI = ui
    vars['extendedNode']:addChild(ui.m_node)

    self:initLobbyWorldAdapter()
    g_topUserInfo:clearBroadcast()

    -- 깜짝 할인 상품 버튼 관리 클래스 생성
    self.m_lobbySpotSaleBtn = UI_LobbySpotSaleBtn(self)

    -- particle 관리
	self:initParticle()
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_Lobby:init_after()
    PARENT.init_after(self)
    g_topUserInfo:doActionReset()
end

-------------------------------------
-- function:initParticle
-------------------------------------
function UI_Lobby:initParticle()
    -- 관리 용이하도록 LobbyMapFactory에서 컨트롤 하도록 함.
    LobbyMapFactory.makeLobbyParticle(self)
end

-------------------------------------
-- function entryCoroutine
-------------------------------------
function UI_Lobby:entryCoroutine()
    -- UI 숨김
    self:doActionReset()
    g_topUserInfo:doActionReset()

    -- 로비에서 진입시 모험모드 출전중인 덱으로 표시
    g_deckData:setSelectedDeck('adv')

    local function coroutine_function(dt)
		local co = CoroutineHelper()
		local block_ui = UI_BlockPopup()

        -- 반드시 통신에 성공해야 하는 통신이 실패하면 로비로 재진입
        local required_fail_cb = function(ret)
            local msg = Str('마을에 진입 중 문제가 발생하였습니다.\n잠시 후에 다시 시도해주세요.')
            local ok_cb = function()
                local scene = SceneLobby()
                scene:runScene()
            end
            MakeSimplePopup(POPUP_TYPE.OK, msg, ok_cb)
        end
        
        -- lobby 공통 함수
        self:entryCoroutine_requestUsersLobby(co)

		if (g_hotTimeData:isActiveEvent('event_exchange')) then
            co:work()
            cclog('# 교환 이벤트 정보 받는 중')
            g_exchangeEventData:request_eventInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_dice')) then
            co:work()
            cclog('# 주사위 이벤트 정보 받는 중')
            g_eventDiceData:request_diceInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_gold_dungeon')) then
            co:work('# 황금던전 이벤트 정보 받는 중')
            g_eventGoldDungeonData:request_dungeonInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_match_card')) then
            co:work('# 카드 짝 맞추기 이벤트 정보 받는 중')
            g_eventMatchCardData:request_eventInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_mandraquest')) then
            co:work('# 만드라고라의 모험 이벤트 정보 받는 중')
            g_mandragoraQuest:request_questInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_alphabet')) then
            co:work('# 알파벳 이벤트 정보 받는 중')
            g_eventAlphabetData:request_alphabetEventInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        -- 그림자의 신전 정보
        if (g_hotTimeData:isActiveEvent('event_challenge') or g_hotTimeData:isActiveEvent('event_challenge_reward')) then
        	co:work('# 그림자의 신전 정보 받는 중')
            g_challengeMode:request_challengeModeInfo(nil, co.NEXT, required_fail_cb, false) -- param : stage, finish_cb, fail_cb, include_reward
            if co:waitWork() then return end
        end

        -- 그랜드 콜로세움 (이벤트 PvP 10대10)
        if (g_hotTimeData:isActiveEvent('event_grand_arena') or g_hotTimeData:isActiveEvent('event_grand_arena_reward')) then
        	co:work('# 그랜드 콜로세움 정보 받는 중')
            g_grandArena:request_grandArenaInfo(co.NEXT, required_fail_cb, false) -- param : finish_cb, fail_cb, include_reward
            if co:waitWork() then return end
        end


        -- 네스트 던전 정보 갱신이 필요한 경우 (고대 유적 던전 오픈과 같은 케이스)
        -- requestNestDungeonInfo 내부에서 m_bDirtyNestDungeonInfo가 false인 경우는 통신하지 않으므로 추가
        co:work('# 네스트 정보 갱신 중')
        g_nestDungeonData:requestNestDungeonInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        -- 구독 상품 정보 받는 중
        co:work('# 구독 상품 정보 받는 중')
        local ui_network = g_subscriptionData:request_subscriptionInfo(co.NEXT, co.ESCAPE)
        ui_network:hideBGLayerColor()
        if co:waitWork() then return end
        
        -- hard refresh
        cclog('# UI 갱신')
        self:refresh(true)

		-- 강제 튜토리얼 진행 하는 동안 풀팝업, 마스터의 길, 구글 업적 일괄 체크, 막음
        if (not TutorialManager.getInstance():checkFullPopupBlock()) then
            -- 풀팝업 출력 함수
            local function show_func(pid) 
                co:work()
                local ui = UI_EventFullPopup(pid)
                ui:setCloseCB(co.NEXT)
                ui:openEventFullPopup()
                if co:waitWork() then return end
            end

            -- 5 레벨 미만은 마을에서 네이버 SDK와 풀 팝업을 띄우지 않음
            local is_show = (g_fullPopupManager:isTitleToLobby() and (g_userData:get('lv') >= 5))
            
			-- 지정된 풀팝업 리스트 (최초 로비 실행 시 출력)
            if (is_show) then
                cclog('# 풀팝업 show')
                
                -- 로비 풀팝업 매니저
                self:entryCoroutine_lobbyPopup(co)

                g_fullPopupManager:show(FULL_POPUP_TYPE.LOBBY, show_func)
            end
            
			-- 출석 보상 정보 (보상 존재할 경우 출력)
            if (g_attendanceData:hasAttendanceReward()) then
                cclog('# 출석 show')
                g_fullPopupManager:show(FULL_POPUP_TYPE.ATTENDANCE, show_func)
			end

            -- 카페 플러그 커뮤니티
            -- if (is_show) then
            --     cclog('# 카페 플러그 커뮤니티')
            --     NaverCafeManager:naverCafeStart(0) -- 네이버 카페
            -- end

            -- @ MASTER ROAD
            cclog('# 마스터의 길 확인 중')
            co:work()
            local _,ui_network = g_masterRoadData:updateMasterRoadAfterReward(co.NEXT)
            if ui_network then
                ui_network:hideBGLayerColor()
                ui_network:setFailCB(required_fail_cb)
            end
            if co:waitWork() then return end
    
            -- @ google achievement
            if (g_localData:isGooglePlayConnected()) then
                if (not g_localData:get('is_first_google_login_real')) then
                    co:work()
                    cclog('# 구글 업적 확인 중')
                    g_localData:applyLocalData(true, 'is_first_google_login_real')
                    GoogleHelper.allAchievementCheck(co.NEXT)
                    if co:waitWork() then return end
                end
            end

            -- UIManager:toastNotificationRed('ENTRY_LOBBY_CNT : ' .. ENTRY_LOBBY_CNT)
	        -- 로비 최초 진입 시에는 skip
	        if (1 < ENTRY_LOBBY_CNT) then
		        self:entryCoroutine_spotSale(co)
	        end			
        end
        
        -- @ UI_ACTION
        co:work()
	    self:doAction(function() 
			-- @ TUTORIAL : check tutorial in lobby
			cclog('TutorialManager:checkTutorialInLobby')
			TutorialManager.getInstance():checkTutorialInLobby(self)

			-- block popup 해제
			block_ui:close()

	        co.NEXT()
        end, false)
        g_topUserInfo:doAction()
		self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
        if co:waitWork() then return end
    end

    Coroutine(coroutine_function, '로비 코루틴')
end

-------------------------------------
-- function entryCoroutine_spotSale
-- @brief 깜짝 할인 상품 코루틴 
-------------------------------------
function UI_Lobby:entryCoroutine_spotSale(co)
	-- 깜짝 할인 상품 리스트 확인 후 없으면 skip
	local lack_item_id = g_spotSaleData:getSpotSaleLackItemID()
    if (not lack_item_id) then
        return
    end
    
	co:work()
    local function finish_cb()
        -- 깜짝 할인 상품이 있을 경우 즉시 팝업
        if g_spotSaleData:hasSpotSaleItem() then
            local ui = UI_Package_SpotSale(lack_item_id)
            ui:setCloseCB(co.NEXT)
        else
            co.NEXT()
        end
    end
    g_spotSaleData:request_startSpotSale(lack_item_id, finish_cb)
	if co:waitWork() then return end
end


-------------------------------------
-- function entryCoroutine_requestUsersLobby
-- @brief lobby 공통 함수
-------------------------------------
function UI_Lobby:entryCoroutine_requestUsersLobby(co)
	co:work()
	
    -- param
	local uid = g_userData:get('uid')
	local time = g_accessTimeData:getTime()
	local combat_power = g_dragonsData:getBestCombatPower()

	-- ui_network
	local ui_network = UI_Network()
	ui_network:setUrl('/users/lobby')
	ui_network:setParam('uid', uid)
	ui_network:setParam('access_time', time)
	ui_network:setParam('dragon_power', combat_power)
	ui_network:setRevocable(true)
	ui_network:setSuccessCB(function(ret)

		co:work()
		cclog('# 친구 정보 받는 중')
		g_friendData:response_friendList(ret, co.NEXT)
		if co:waitWork() then return end

		co:work()
		cclog('# 출석 정보 받는 중')
		g_attendanceData:response_attendanceInfo(ret, co.NEXT)
		if co:waitWork() then return end

		co:work()
		cclog('# 핫타임 정보 요청 중')
		g_hotTimeData:response_hottime(ret, co.NEXT)
		if co:waitWork() then return end

		co:work()
		cclog('# 이벤트 정보 받는 중')
		g_eventData:response_eventList(ret, co.NEXT)
		if co:waitWork() then return end

		co:work()
		cclog('# 드래곤의 숲 확인 중')
		ServerData_Forest:getInstance():response_forestInfo(ret, co.NEXT)
		if co:waitWork() then return end

		co:work()
		cclog('# 접속시간 저장 중')
		g_accessTimeData:response_saveTime(ret, co.NEXT)
		if co:waitWork() then return end

		co:work()
		cclog('# 드래곤 전투력 저장 중')
		g_dragonsData:response_updatePower(ret, co.NEXT)
		if co:waitWork() then return end

		cclog('# 인연 던전 확인 중')
		if (ret['secret_dungeon_cnt']) then
			g_secretDungeonData:setSecretDungeonExist(ret['secret_dungeon_cnt'] > 0)
		end

        cclog('# 자동줍기 결과 확인 중')
        if (ret['hours'] and ret['ingame_drop_stats']) then
            g_serverData:networkCommonRespone(ret) -- expired 갱신
			UI_AutoItemPickResultPopup(ret['hours'], ret['ingame_drop_stats'])
		end

		cclog('# 퀘스트 확인 중')
		if (ret['quest_info']) then
			g_questData:applyQuestInfo(ret['quest_info'])
		end

		cclog('# 고대의 탑 정보 확인 중')
		if (ret['ancient_info']) then
			g_ancientTowerData:setInfoForLobby(ret['ancient_info'])
		end

		cclog('# 콜로세움 정보 확인 중')
		if (ret['pvp_info']) then -- 콜로세움 (기존) <-- 닫혀있음 안줌
			g_colosseumData:setInfoForLobby(ret['pvp_info'])
		end

        if (ret['arena_info']) then -- 콜로세움 (신규) <-- 닫혀있음 안줌
			g_arenaData:setInfoForLobby(ret['arena_info'])
		end

        cclog('# 누적 결제 보상 정보 확인 중')
        if (ret['purchase_point_info']) then
            g_purchasePointData:applyPurchasePointInfo(ret['purchase_point_info'])
        end
				
        cclog('# 스킬 이전 가격 정보 받는 중')
        g_dragonsData:setSkillMovePrice(ret)

        cclog('# 확률업 드래곤 정보 받는 중')
        g_eventData:applyChanceUpDragons(ret)

        cclog('# 출시 드래곤 정보 받는 중')
        g_dragonsData:setReleasedDragons(ret)
		
		cclog('# 깜짝 세일 상품 정보 받는 중')
		if (ret['spot_sale']) then
			g_spotSaleData:applySpotSaleInfo(ret['spot_sale'])
		end

        cclog('# 깜짝 출현 드래곤 정보 받는 중')
        if (ret['advent_did_list']) then
            g_eventAdventData:setAdventDragonList(ret['advent_did_list'])
        end

		co.NEXT()
	end)
	ui_network:setFailCB(required_fail_cb)
	ui_network:hideBGLayerColor()
	ui_network:request()

	if co:waitWork() then return end
end

-------------------------------------
-- function entryCoroutine_lobbyPopup
-------------------------------------
function UI_Lobby:entryCoroutine_lobbyPopup(co)
    -- 로비 팝업
    local t_table_lobby_popup = TABLE:get('table_lobby_popup')
    local l_lobby_popup = {}
    for i,v in pairs(t_table_lobby_popup) do
        table.insert(l_lobby_popup, v)
    end

    -- priority가 낮으면 우선 노출
    local function sort_func(a, b)
        return a['priority'] < b['priority']
    end
    table.sort(l_lobby_popup, sort_func)

    -- 풀팝업 출력 함수
    local function show_func(pid) 
        co:work()
        local ui = UI_EventFullPopup(pid)
        ui:setCloseCB(co.NEXT)
        ui:openEventFullPopup()
        if co:waitWork() then return end
    end

    for i,v in ipairs(l_lobby_popup) do
        -- 해당 클래스가 load되어 있는지 확인
        local lua_class = v['lua_class']
        if package.loaded[lua_class] then

            -- 해당 클래스 require통해서 얻어옴
            local lobby_guide_class = require(lua_class)
            if lobby_guide_class then

                -- 인스턴스 생성
                local pointer = lobby_guide_class(v)

                -- 조건 확인
                pointer:checkCondition()

                -- 안내가 유효할 경우
                if (pointer:isActiveGuide() == true) then
                    local popup_key = pointer:getPopupKey()
                    if popup_key then
                        pointer:startGuide()

                        local is_view = g_settingData:get('event_full_popup', popup_key) or false
                        -- 봤던 기록 없는 이벤트 풀팝업 띄워줌
                        if (not is_view) then
                            show_func(popup_key)
                        end 
                    end
                end
                pointer = nil
            end
        else
            cclog('## 클래스가 존재하지 않음 lua_class : ' .. tostring(lua_class))
        end
    end
end

-------------------------------------
-- function initLobbyWorldAdapter
-------------------------------------
function UI_Lobby:initLobbyWorldAdapter()
    local vars = self.vars

    local lobby_ui = self
    local parent_node = vars['cameraNode']
    parent_node:setLocalZOrder(-1)
    local chat_client_socket = g_lobbyChangeMgr:getChatClientSocket()
    local lobby_manager = g_lobbyChangeMgr:getLobbyManager()

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
-- function initButton
-------------------------------------
function UI_Lobby:initButton()
    local vars = self.vars

    -- 하단
    vars['dragonManageBtn']:registerScriptTapHandler(function() self:click_dragonManageBtn() end) -- 드래곤
    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end) -- 테이머
    vars['forestBtn']:registerScriptTapHandler(function() self:click_forestBtn() end) -- 드래곤의숲
    vars['questBtn']:registerScriptTapHandler(function() self:click_questBtn() end) -- 퀘스트
    vars['battleBtn']:registerScriptTapHandler(function() self:click_battleBtn() end) -- 전투
    vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end) -- 상점
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end) -- 부화소
    vars['clanBtn']:registerScriptTapHandler(function() self:click_clanBtn() end) -- 클랜 버튼

    -- 상단
    vars['tamerBtn2']:registerScriptTapHandler(function() self:click_userInfoBtn() end)

    -- 마스터의 길
    vars['masterRoadBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    vars['masterRoadBtn']:registerScriptTapHandler(function() self:click_masterRoadBtn() end)
    vars['etcBtn']:registerScriptTapHandler(function() self:click_etcBtn() end)
    
    -- 드래곤 성장일지
    vars['dragonDiaryBtn']:registerScriptTapHandler(function() self:click_dragonDiaryBtn() end)

    -- 좌측 UI
    vars['mailBtn']:registerScriptTapHandler(function() self:click_mailBtn() end)
    vars['googleGameBtn']:registerScriptTapHandler(function() self:click_googleGameBtn() end)
    vars['googleAchievementBtn']:registerScriptTapHandler(function() self:click_googleAchievementBtn() end)
    vars['expBoosterBtn']:registerScriptTapHandler(function() self:click_expBoosterBtn() end)
    vars['goldBoosterBtn']:registerScriptTapHandler(function() self:click_goldBoosterBtn() end)

    -- 우측 UI
    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end) -- 이벤트(출석) 버튼 
    vars['capsuleBtn']:registerScriptTapHandler(function() self:click_capsuleBtn() end)
    vars['itemAutoBtn']:registerScriptTapHandler(function() self:click_itemAutoBtn() end) -- 자동재화(광고)
    vars['giftBoxBtn']:registerScriptTapHandler(function() self:click_giftBoxBtn() end) -- 랜덤박스(광고)
    vars['exchangeBtn']:registerScriptTapHandler(function() self:click_exchangeBtn() end) -- 교환이벤트
    vars['diceBtn']:registerScriptTapHandler(function() self:click_diceBtn() end) -- 주사위이벤트
    vars['alphabetBtn']:registerScriptTapHandler(function() self:click_alphabetBtn() end) -- 알파벳 이벤트
    vars['goldDungeonBtn']:registerScriptTapHandler(function() self:click_goldDungeonBtn() end) -- 황금던전 이벤트
    vars['matchCardBtn']:registerScriptTapHandler(function() self:click_matchCardBtn() end) -- 카드 짝 맞추기 이벤트
    vars['mandragoraBtn']:registerScriptTapHandler(function() self:click_mandragoraBtn() end) -- 만드라고라의 모험 이벤트
    vars['adventBtn']:registerScriptTapHandler(function() self:click_adventBtn() end) -- 만드라고라의 모험 이벤트
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_lvUpPackBtn() end) -- 레벨업 패키지
    vars['adventureClearBtn']:registerScriptTapHandler(function() self:click_adventureClearBtn() end) -- 모험돌파 패키지
	vars['capsuleBoxBtn']:registerScriptTapHandler(function() self:click_capsuleBoxBtn() end) -- 캡슐 뽑기 버튼
    vars['ddayBtn']:registerScriptTapHandler(function() self:click_ddayBtn() end) -- 출석 이벤트탭 이동
    vars['dailyShopBtn']:registerScriptTapHandler(function() self:click_dailyShopBtn() end) -- 일일 상점
    vars['randomShopBtn']:registerScriptTapHandler(function() self:click_randomShopBtn() end) -- 랜덤 상점
    vars['randomShopBtn']:setVisible(true) 

    do -- 기타 UI
        local etc_vars = self.m_etcExpendedUI.vars
        etc_vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end) -- 설정
        etc_vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankingBtn() end) -- 종합 랭킹
        etc_vars['friendBtn']:registerScriptTapHandler(function() self:click_friendBtn() end) -- 친구
        etc_vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)-- 가방
        etc_vars['bookBtn']:registerScriptTapHandler(function() self:click_bookBtn() end) -- 도감 버튼
        etc_vars['naverCafeBtn']:registerScriptTapHandler(function() self:click_naverCafeBtn() end) -- 네이버 카페 버튼
    end

    do -- 클랜 버튼 잠금 상태 처리
        local is_content_lock, req_user_lv = g_contentLockData:isContentLock('clan')
        if is_content_lock then
            vars['clanBtn']:setEnabled(false)
            vars['clanLockNode']:setVisible(true)
            vars['clanLockLabel']:setString(Str('레벨 {1}', req_user_lv))
        else
            vars['clanBtn']:setEnabled(true)
            vars['clanLockNode']:setVisible(false)
        end
    end

    do -- 왼쪽 버튼 leftMenu
        vars['mailBtn']:setVisible(true)
        vars['goldBoosterBtn']:setVisible(false)
        vars['expBoosterBtn']:setVisible(false)
        vars['googleGameBtn']:setVisible(false)
        vars['googleAchievementBtn']:setVisible(false)
    end
end

-------------------------------------
-- function refresh
-- @comment hard refresh : entryCoroutine, 
--          soft refresh : onFocus, dragonManageInfo close callback
-------------------------------------
function UI_Lobby:refresh(is_hard_refresh)
    self:refresh_userInfo()
    self:refresh_hottime()

    -- update()와 중복 : 강제 동작하되 또 실행되지 않도록 함
    g_eventData.m_bDirty = false
    self:update_rightButtons()

    -- 오른쪽 배너 갱신
    self:refresh_rightBanner()

    -- hard refresh
    if (is_hard_refresh) then
        -- update()와 중복
        g_masterRoadData.m_bDirtyMasterRoad = false
        self:update_masterRoad()

        g_dragonDiaryData.m_bDirty = false
        self:update_dragonDiary()

        GoogleHelper.setDirty(false)
        self:update_google()
    end
end

-------------------------------------
-- function update_highlight
-------------------------------------
function UI_Lobby:update_highlight()
    local vars = self.vars
    local etc_vars = self.m_etcExpendedUI.vars

    local function highlight_func()

        -- 네트워크 통신이 비동기로 실행되기 때문에 UI가 close된 상태에서 콜백이 올 수 있음을 예방함 sgkim
        if self.closed then
            return
        end

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

		-- 이벤트
		vars['eventManageNotiSprite']:setVisible(g_eventData:isHighlightEvent())

		-- 드래곤 소환
		local highlight, t_highlight = g_hatcheryData:checkHighlight()
		vars['drawNotiSprite']:setVisible(highlight)
    
		-- 드래곤의 숲
		vars['forestNotiSprite']:setVisible(ServerData_Forest:getInstance():isHighlightForest())

		-- 테이머
		vars['tamerNotiSprite']:setVisible(g_tamerData:isHighlightTamer())

        -- 드래곤 성장일지
        local has_reward, _ = g_dragonDiaryData:hasRewardRoad()
		vars['dragonDiaryNotiSprite']:setVisible(has_reward)

		-- 도감
		etc_vars['bookNotiSprite']:setVisible(g_bookData:isHighlightBook())

		-- 가방
		etc_vars['inventoryNotiSprite']:setVisible(g_highlightData:isHighlightRune())

		-- 기타 (친구 or 도감 or 가방)
		local is_etc_noti = (etc_vars['friendNotiSprite']:isVisible() or etc_vars['bookNotiSprite']:isVisible() or etc_vars['inventoryNotiSprite']:isVisible())
		vars['etcNotiSprite']:setVisible(is_etc_noti)

		-- 클랜
		vars['clanNotiSprite']:setVisible(g_clanData:isHighlightClan())

        do -- 황금 던전
            vars['goldDungeonNotiRed']:setVisible(false)
            vars['goldDungeonNotiYellow']:setVisible(false)

            if ServerData_EventGoldDungeon:getInstance():isHighlightRed_gd() then
                vars['goldDungeonNotiRed']:setVisible(true)
            elseif ServerData_EventGoldDungeon:getInstance():isHighlightYellow_gd() then
                vars['goldDungeonNotiYellow']:setVisible(true)
            end
        end

        do -- 알파벳 이벤트
            vars['alphabetNotiRed']:setVisible(false)
            vars['alphabetNotiYellow']:setVisible(false)

            if g_eventAlphabetData:isHighlightRed_alphabet() then
                vars['alphabetNotiRed']:setVisible(true)
            elseif g_eventAlphabetData:isHighlightYellow_alphabet() then
                vars['alphabetNotiYellow']:setVisible(true)
            end
        end

        self.m_bUpdatingHighlights = false
    end

    self.m_bUpdatingHighlights = true
    g_highlightData:request_highlightInfo(highlight_func)
end

-------------------------------------
-- function refresh_userInfo
-- @brief 유저 정보 갱신
-------------------------------------
function UI_Lobby:refresh_userInfo()
    local vars = self.vars

    -- 칭호 + 닉네임
    do
        local label_width = 240
        local tamer_title_str = g_userData:getTamerTitleStr()
        local nickname = g_userData:get('nick')

        -- 칭호와 닉네임을 붙여서 처리
        if tamer_title_str and (tamer_title_str ~= '') then
            nickname = string.format('{@user_title}%s {@white}%s', tamer_title_str, nickname)
        end
        vars['userNameLabel']:setString(nickname)

        -- 여백을 위해 10픽셀을 더해줌
        local str_width = vars['userNameLabel']:getStringWidth() + 10
        if (label_width < str_width) then
            vars['userNameLabel']:setScale(label_width / str_width)
        else
            vars['userNameLabel']:setScale(1)
        end
    end

    do -- 테이머 아이콘 갱신
        local icon = IconHelper:getTamerProfileIconWithCostumeID()
        vars['userNode']:removeAllChildren()
        vars['userNode']:addChild(icon)
    end

    -- 클랜
    local struct_clan = g_clanData:getClanStruct()
    if (struct_clan) then
        vars['clanLabel']:setVisible(true)
        vars['markNode']:setVisible(true)

        local clan_name = struct_clan:getClanName()
        vars['clanLabel']:setString(clan_name)

        local clan_icon = struct_clan:makeClanMarkIcon()
        vars['markNode']:addChild(clan_icon)
    else
        vars['clanLabel']:setVisible(false)
        vars['markNode']:setVisible(false)
    end
    
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
-- function update_masterRoad
-- @brief 마스터의길 안내와 드빌 도우미 안내를 같이 쓴다
-------------------------------------
function UI_Lobby:update_masterRoad()
    self.vars['masterMenu']:setVisible(true)
    self.m_lobbyGuide:refresh()
	
	-- 로비 가이드 off이고 성장일지 클리어하지 못했다면 위치 변경
	if (not self.vars['bottomMasterNode']:isVisible()) then
		local is_clear = g_dragonDiaryData:isClearAll()
		if (not is_clear) then
			self.vars['dragonDiaryBtn']:setPositionY(0)
		end
	end
end

-------------------------------------
-- function update_dragonDiary
-------------------------------------
function UI_Lobby:update_dragonDiary()
    local vars = self.vars
    
    local is_clear = g_dragonDiaryData:isClearAll()
    vars['dragonDiaryBtn']:setVisible(not is_clear)
    vars['dragonDiaryNode']:setVisible(not is_clear)

    -- 현재 목표 출력
    if (not is_clear) then
        local frame_res = g_dragonDiaryData:getStartDragonFrameRes()
        local frame = cc.Scale9Sprite:create(frame_res)
        frame:setDockPoint(CENTER_POINT)
	    frame:setAnchorPoint(CENTER_POINT)
        vars['dragonDiaryNode']:addChild(frame)

        local rid = g_dragonDiaryData:getFocusRid()
        local t_diary = TableDragonDiary():get(rid)

        local title = g_dragonDiaryData:getTitleText()
        vars['dragonDiaryTitle']:setString(title)

        local desc = Str(t_diary['t_desc'])
        vars['dragonDiaryLabel']:setString(desc)
    end
end

-------------------------------------
-- function update_attendanceDday
-------------------------------------
function UI_Lobby:update_attendanceDday()
    local vars = self.vars
    local target_info, target_day, target_item_id = g_attendanceData:getAttendanceDdayInfo()
    local btn = vars['ddayBtn']

    if (target_info) then
        btn:setVisible(true)
        vars['ddayLabel']:setString(string.format('D-%d', target_day))

        local item_name = getItemNameWithStar(target_item_id)
        vars['ddayItemLabel']:setString(item_name)

        local visual = vars['ddayVisual']
        local socketNode = visual.m_node:getSocketNode('lobby_item')
        local icon = IconHelper:getItemIcon(target_item_id)
        socketNode:addChild(icon)

        -- 획득하는 날은 안받은 상태에서만 노출
        local received = target_info['received']
        if (target_day == 0) and (received == true) then
            btn:setVisible(false)
        end
    else
        btn:setVisible(false)
    end

    self:onRefresh_banner()
end

-------------------------------------
-- function update_google
-------------------------------------
function UI_Lobby:update_google()
    local vars = self.vars

	if (not CppFunctions:isAndroid()) then
		vars['googleGameBtn']:setVisible(false)
	elseif (g_localData:isGoogleLogin()) then
        vars['googleGameBtn']:setVisible(true)
    else
        vars['googleGameBtn']:setVisible(false)
    end

    -- 그냥 즉시 갱신하도록 수정 (매 프레임 콜이 되지 않기때문에 부담 없음)
    --self.m_bDirtyLeftButtonMenu = true
    self:update_leftButtons()
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
	self.m_lobbyGuide:onClick()
end

-------------------------------------
-- function click_dragonDiaryBtn
-- @brief 드래곤 성장일지 버튼
-------------------------------------
function UI_Lobby:click_dragonDiaryBtn()
    UINavigator:goTo('dragon_diary')
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
-- function click_clanBtn
-- @brief 클랜 버튼
-------------------------------------
function UI_Lobby:click_clanBtn()
    UINavigator:goTo('clan')
end

-------------------------------------
-- function click_mailBtn
-- @brief 우편함
-------------------------------------
function UI_Lobby:click_mailBtn()
	local function cb_func(is_dirty)
        if (is_dirty) then
            -- 닉네임 변경으로 인한 처리...
            self:refresh_userInfo()
        end
	end
    UI_MailPopup():setCloseCB(cb_func)
end

-------------------------------------
-- function click_userInfoBtn
-------------------------------------
function UI_Lobby:click_userInfoBtn()
    RequestUserInfoDetailPopup(g_userData:get('uid'), false, close_cb) -- uid, is_visit, close_cb
end

-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_Lobby:click_tamerBtn()
    -- @ comment click_userInfoBtn의 주석과 동일
	local function close_cb()
		self:refresh_userInfo()
	end
	UINavigator:goTo('tamer', nil, close_cb)
end

-------------------------------------
-- function click_forestBtn
-------------------------------------
function UI_Lobby:click_forestBtn()
    UINavigatorDefinition:goTo('forest')
end

-------------------------------------
-- function click_bookBtn
-------------------------------------
function UI_Lobby:click_bookBtn()
	UI_Book()
end

-------------------------------------
-- function click_naverCafeBtn
-------------------------------------
function UI_Lobby:click_naverCafeBtn()
    NaverCafeManager:naverCafeStart(0) -- @tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_Lobby:click_eventBtn()
    g_eventData:openEventPopup()
end

-------------------------------------
-- function click_itemAutoBtn
-- @brief 자동재화 버튼 (광고 보기)
-------------------------------------
function UI_Lobby:click_itemAutoBtn()
    -- 2017-09-21 sgkim 매일매일 다이아를 자동 줍기에 더 비중을 두어 변경
    --g_advertisingData:showAdvPopup(AD_TYPE.AUTO_ITEM_PICK)
    g_subscriptionData:openSubscriptionPopup()
end

-------------------------------------
-- function click_giftBoxBtn
-- @brief 선물상자 버튼 (광고 보기)
-------------------------------------
function UI_Lobby:click_giftBoxBtn()
    g_advertisingData:showAdvPopup(AD_TYPE.RANDOM_BOX_LOBBY)
end

-------------------------------------
-- function click_exchangeBtn
-- @brief 교환 이벤트
-------------------------------------
function UI_Lobby:click_exchangeBtn()
    if (not g_hotTimeData:isActiveEvent('event_exchange')) then
        return
    end
    g_eventData:openEventPopup('event_exchange')
end

-------------------------------------
-- function click_diceBtn
-- @brief 주사위 이벤트
-------------------------------------
function UI_Lobby:click_diceBtn()
    if (not g_hotTimeData:isActiveEvent('event_dice')) then
        return
    end
    g_eventData:openEventPopup('event_dice')
end

-------------------------------------
-- function click_alphabetBtn
-- @brief 알파벳 이벤트
-------------------------------------
function UI_Lobby:click_alphabetBtn()
    if (not g_hotTimeData:isActiveEvent('event_alphabet')) then
        return
    end
    g_eventData:openEventPopup('event_alphabet')
end

-------------------------------------
-- function click_goldDungeonBtn
-- @brief 황금던전 이벤트
-------------------------------------
function UI_Lobby:click_goldDungeonBtn()
    if (not g_hotTimeData:isActiveEvent('event_gold_dungeon')) then
        return
    end
    g_eventData:openEventPopup('event_gold_dungeon')
end

-------------------------------------
-- function click_matchCardBtn
-- @brief 카드 짝 맞추기 이벤트
-------------------------------------
function UI_Lobby:click_matchCardBtn()
    if (not g_hotTimeData:isActiveEvent('event_match_card')) then
        return
    end
    g_eventData:openEventPopup('event_match_card')
end

-------------------------------------
-- function click_mandragoraBtn 
-- @brief 만드라고라의 모험 이벤트
-------------------------------------
function UI_Lobby:click_mandragoraBtn()
    if (not g_hotTimeData:isActiveEvent('event_mandraquest')) then
        return
    end
    g_eventData:openEventPopup('event_mandraquest')
end

-------------------------------------
-- function click_adventBtn 
-- @brief 깜짝 출현 이벤트
-------------------------------------
function UI_Lobby:click_adventBtn()
    if (not g_hotTimeData:isActiveEvent('event_advent')) then
        return
    end
    g_eventData:openEventPopup('event_advent')
end

-------------------------------------
-- function click_lvUpPackBtn
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_Lobby:click_lvUpPackBtn()
    UI_Package_LevelUp(nil, true) -- param : struct_product, is_popup
end

-------------------------------------
-- function click_adventureClearBtn
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_Lobby:click_adventureClearBtn()
    UI_Package_AdventureClear(nil, true) -- param : struct_product, is_popup
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
	if (not g_localData:isGooglePlayConnected()) then
		GoogleHelper.loginPlayServices()
		return
	end

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
            cca.makeBasicEaseMove(0.2, game_pos_x + 73, achv_pos_y)
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
-- function click_expBoosterBtn
-------------------------------------
function UI_Lobby:click_expBoosterBtn()
    local vars = self.vars
    g_hotTimeData:makeHotTimeToolTip('buff_exp', vars['expBoosterBtn'])
end

-------------------------------------
-- function click_goldBoosterBtn
-------------------------------------
function UI_Lobby:click_goldBoosterBtn()
    local vars = self.vars
    g_hotTimeData:makeHotTimeToolTip('buff_gold', vars['goldBoosterBtn'])
end

-------------------------------------
-- function click_capsuleBtn
-------------------------------------
function UI_Lobby:click_capsuleBtn()
    g_eventData:openEventPopup('highbrow_shop')
end

-------------------------------------
-- function click_capsuleBoxBtn
-------------------------------------
function UI_Lobby:click_capsuleBoxBtn()
	g_capsuleBoxData:openCapsuleBoxUI()
end

-------------------------------------
-- function click_ddayBtn
-------------------------------------
function UI_Lobby:click_ddayBtn()
    local target_info = g_attendanceData:getAttendanceDdayInfo()
    if (target_info) then
        g_attendanceData:openEventPopup(target_info)
    end
end

-------------------------------------
-- function click_dailyShopBtn
-------------------------------------
function UI_Lobby:click_dailyShopBtn()
    local is_popup = true
    UINavigator:goTo('shop_daily', is_popup)
end

-------------------------------------
-- function click_randomShopBtn
-------------------------------------
function UI_Lobby:click_randomShopBtn()
    UINavigator:goTo('shop_random')
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
    -- 드래곤의 숲
    ServerData_Forest:getInstance():update(dt)

    -- noti 갱신
	if (g_highlightData:isDirty()) then
        if (not self.m_bUpdatingHighlights) then
		    g_highlightData:setDirty(false)
		    self:update_highlight()
        end
	end

    -- 마스터의 길 정보 갱신
    if (g_masterRoadData.m_bDirtyMasterRoad) then
        g_masterRoadData.m_bDirtyMasterRoad = false
        self:update_masterRoad()
    end

    -- 드래곤 성장일지 정보 갱신
    if (g_dragonDiaryData.m_bDirty) then
        g_dragonDiaryData.m_bDirty = false
        self:update_dragonDiary()
    end
    
    -- 구글 버튼 처리
    if (GoogleHelper.isDirty) then
        GoogleHelper.setDirty(false)
        self:update_google()
    end

    -- 이벤트 갱신된 경우
    if (g_eventData.m_bDirty) then
        g_eventData.m_bDirty = false
        self:update_rightButtons()
    end

    -- 로비 출석 D-day 표시
    if (g_attendanceData.m_bDirtyAttendanceInfo) then
        g_attendanceData.m_bDirtyAttendanceInfo = false
        self:update_attendanceDday()
    end

    local vars = self.vars

    -- 캡슐뽑기 노티 (1개 이상 보유시)
    do
        local visible = (g_userData:get('capsule_coin') > 0)
        vars['capsuleBoxNotiSprite']:setVisible(visible)
    end
    
    -- 랜덤 상점 노티 (상품 갱신시)
    do
        local is_highlight = g_randomShopData:isHightlightShop()
        vars['randomShopNotiSprite']:setVisible(is_highlight)
        vars['randomShopLabel']:setVisible(not is_highlight)
        vars['randomShopLabel']:setString(g_randomShopData:getRefreshRemainTimeText())
    end

    -- 광고 (자동재화, 선물상자 정보)
    do
        -- 자동줍기
        local msg1, enable1 = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
        vars['itemAutoLabel']:setString(msg1)
        --vars['itemAutoBtn']:setEnabled(enable1) -- 매일매일 다이아 ui를 띄우는 것으로 변경함 (항상 enabled로!) 2017-09-21 sgkim
        if (self.m_bItemAutoEnabled == nil) or (self.m_bItemAutoEnabled ~= enable1) then
            self.m_bItemAutoEnabled = enable1
            vars['itemAutoBtn']:setAutoShake(self.m_bItemAutoEnabled)
        end
        
        -- 2018-11-28 상품 끝나기 3일 전에 구독상품 연장구매 가능하다고 알림
        local is_auto_3day = g_autoItemPickData:checkSubsAlarm('subscription', 3) -- param : auto_type, day
        vars['itemAutoNotiSprite']:setVisible(is_auto_3day)

        -- 선물상자
        local msg2, enable2 = g_advertisingData:getCoolTimeStatus(AD_TYPE.RANDOM_BOX_LOBBY)
        vars['giftBoxLabel']:setString(msg2)
        vars['giftBoxBtn']:setEnabled(enable2)
        if (self.m_bGiftBoxEnabled == nil) or (self.m_bGiftBoxEnabled ~= enable2) then
            self.m_bGiftBoxEnabled = enable2
            vars['giftBoxBtn']:setAutoShake(self.m_bGiftBoxEnabled)
        end
    end

    if (g_hotTimeData.m_boosterInfoDirty) then
        g_hotTimeData.m_boosterInfoDirty = false
        self:update_boosterButtons() 
    end

    -- 경험치 부스터
    do
        local str, state = g_hotTimeData:getHotTimeBuffText('buff_exp2x')
        local is_used = state == BOOSTER_ITEM_STATE.INUSE
        vars['expBoosterLabel']:setString(is_used and str or '')

        -- 로비에서 종료될 경우
        if (not is_used and vars['expBoosterBtn']:isVisible()) then
            self:update_boosterButtons() 
        end
    end

    -- 골드 부스터
    do
        local str, state = g_hotTimeData:getHotTimeBuffText('buff_gold2x')
        local is_used = state == BOOSTER_ITEM_STATE.INUSE
        vars['goldBoosterLabel']:setString(is_used and str or '')

        -- 로비에서 종료될 경우
        if (not is_used and vars['goldBoosterBtn']:isVisible()) then
            self:update_boosterButtons() 
        end
    end

    -- 이벤트 남은 시간 표시
    do
        local map_check_event = {}
        map_check_event['event_match_card'] = 'matchCardLabel' -- 카드 짝 맞추기
        map_check_event['event_gold_dungeon'] = 'goldDungeonLabel' -- 황금 던전 (골드라고라 던전)
        map_check_event['event_alphabet'] = 'alphabetLabel' -- 알파벳 이벤트

        for event_name, label_name in pairs(map_check_event) do
            local remain_text = g_hotTimeData:getEventRemainTimeText(event_name)
            local label = vars[label_name]
            if (remain_text) and (label) then
                label:setVisible(true)
                label:setString(remain_text)
            end
        end
    end

	-- 깜짝 할인 상품 버튼 상태 갱신
    if self.m_lobbySpotSaleBtn then
        self.m_lobbySpotSaleBtn:update()
    end

    -- 왼쪽 버튼 리스트 업데이트
    if self.m_bDirtyLeftButtonMenu then
        self.m_bDirtyLeftButtonMenu = false
        self:update_leftButtons()
    end

    
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData_checkNumber()
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

-------------------------------------
-- function onFocus
-- @brief 탑바가 Lobby UI에 포커싱 되었을 때
-------------------------------------
function UI_Lobby:onFocus(is_push)
	local vars = self.vars

    SpineCacheManager:getInstance():purgeSpineCacheData()
    
    -- 채팅 다시 연결 확인
    if (g_chatManager and g_chatManager.m_chatClientSocket) then
        g_chatManager.m_chatClientSocket:checkRetryConnect()
    end

    -- 클랜 채팅 다시 연결 확인
    if g_clanChatManager then
        g_clanChatManager:checkRetryClanChat()
    end

    self:refresh()

    -- is_push가 true이면 최초에 UI 생성시에 호출된 경우
    -- 로비에서 onFocus 코루틴은 최초 생성 시에는 skip
    if (not is_push) then
        local function coroutine_function(dt)
            local co = CoroutineHelper()
            self:entryCoroutine_spotSale(co)
        end

        Coroutine(coroutine_function, '로비 코루틴 onFocus')
    end
end

-------------------------------------
-- function refresh_hottime
-- @brief 핫타임 관련 UI 갱신
-------------------------------------
function UI_Lobby:refresh_hottime()
	local vars = self.vars

    -- 핫타임 정보 갱신
    vars['battleHotSprite']:setVisible(g_hotTimeData:isHighlightHotTime())
	
	-- 할인 이벤트
	local l_dc_event = g_hotTimeData:getDiscountEventList()
    for i, dc_target in ipairs(l_dc_event) do
        g_hotTimeData:setDiscountEventNode(dc_target, vars, 'dragonEventSprite'..i)
    end
	
    -- 할인 이벤트에 따라 마스터로드, 성장일지 올려줌
    if (#l_dc_event > 0) then
        local interval = 28
        vars['masterMenu']:setPositionY(130 + (interval * #l_dc_event))
    end
end

-------------------------------------
-- function update_boosterButtons
-- @brief
-------------------------------------
function UI_Lobby:update_boosterButtons()
    local vars = self.vars

    do
        local str, state = g_hotTimeData:getHotTimeBuffText('buff_exp2x')
        vars['expBoosterBtn']:setVisible(state == BOOSTER_ITEM_STATE.INUSE)
    end
    
    do
        local str, state = g_hotTimeData:getHotTimeBuffText('buff_gold2x')
        vars['goldBoosterBtn']:setVisible(state == BOOSTER_ITEM_STATE.INUSE)
    end

    -- 버튼들의 위치 조정
    self.m_bDirtyLeftButtonMenu = true
end

-------------------------------------
-- function update_rightButtons
-- @brief
-------------------------------------
function UI_Lobby:update_rightButtons()
    local vars = self.vars
    
    -- 드빌 전용관은 한국서버에서만 노출
    if g_localData:isShowHighbrowShop() then
        vars['capsuleBtn']:setVisible(true)
    else
        vars['capsuleBtn']:setVisible(false)
    end

    -- 교환소 버튼
    if g_hotTimeData:isActiveEvent('event_exchange') then
        vars['exchangeBtn']:setVisible(true)
    else
        vars['exchangeBtn']:setVisible(false)
    end

    -- 주사위 버튼
    if g_hotTimeData:isActiveEvent('event_dice') then
        vars['diceBtn']:setVisible(true)
    else
        vars['diceBtn']:setVisible(false)
    end

    -- 주사위 버튼
    local visible = g_hotTimeData:isActiveEvent('event_alphabet')
    vars['alphabetBtn']:setVisible(visible)

    -- 황금던전 버튼
    if g_hotTimeData:isActiveEvent('event_gold_dungeon') then
        vars['goldDungeonBtn']:setVisible(true)
        local remain_sec = g_hotTimeData:getEventRemainSec('event_gold_dungeon')
        if remain_sec and (remain_sec <= datetime.dayToSecond(1)) then
            if (not vars['goldDungeonAlarm']) then
                vars['goldDungeonAlarm'] = UIC_AlarmClockIcon:create()
                vars['goldDungeonBtn']:addChild(vars['goldDungeonAlarm'].m_node)
                vars['goldDungeonAlarm']:runAction()
            end
        else
            if vars['goldDungeonAlarm'] then
                vars['goldDungeonAlarm']:removeFromParent()
                vars['goldDungeonAlarm'] = nil
            end
        end
    else
        vars['goldDungeonBtn']:setVisible(false)
    end

    -- 황금던전이 항상 열려있는 모드이면 마을에서 노출하지 않음
    if GOLD_DUNGEON_ALWAYS_OPEN then
        vars['goldDungeonBtn']:setVisible(false)
    end

    -- 카드 짝 맞추기 버튼
    if g_hotTimeData:isActiveEvent('event_match_card') then
        vars['matchCardBtn']:setVisible(true)
    else
        vars['matchCardBtn']:setVisible(false)
    end

    -- 만드라고라의 모험 버튼
    if g_hotTimeData:isActiveEvent('event_mandraquest') then
        vars['mandragoraBtn']:setVisible(true)
    else
        vars['mandragoraBtn']:setVisible(false)
    end

    -- 만드라고라의 모험 버튼
    if g_hotTimeData:isActiveEvent('event_advent') then
        vars['adventBtn']:setVisible(true)
    else
        vars['adventBtn']:setVisible(false)
    end

	-- 캡슐 신전 버튼
	if (g_capsuleBoxData:isOpen()) then
		vars['capsuleBoxBtn']:setVisible(true)
	else
		vars['capsuleBoxBtn']:setVisible(false)
	end

    -- 레벨업 패키지 버튼
    if g_levelUpPackageData:isVisible_lvUpPack() then
        vars['levelupBtn']:setVisible(true)
    else
        vars['levelupBtn']:setVisible(false)
    end

    -- 모험돌파 버튼
    if g_adventureClearPackageData:isVisible_adventureClearPack() then
        vars['adventureClearBtn']:setVisible(true)
    else
        vars['adventureClearBtn']:setVisible(false)
    end
        
    -- 일일상점 버튼
    vars['dailyShopBtn']:setVisible(true)

    -- 인덱스 1번이 오른쪽
    local t_btn_name = {}
    table.insert(t_btn_name, 'capsuleBtn')
    table.insert(t_btn_name, 'itemAutoBtn')
    table.insert(t_btn_name, 'giftBoxBtn')
    table.insert(t_btn_name, 'exchangeBtn')
    table.insert(t_btn_name, 'diceBtn')
    table.insert(t_btn_name, 'alphabetBtn')
    table.insert(t_btn_name, 'levelupBtn')
    table.insert(t_btn_name, 'adventureClearBtn')
    table.insert(t_btn_name, 'capsuleBoxBtn')
    table.insert(t_btn_name, 'goldDungeonBtn')
    table.insert(t_btn_name, 'matchCardBtn')
    table.insert(t_btn_name, 'mandragoraBtn')
    table.insert(t_btn_name, 'dailyShopBtn')
    table.insert(t_btn_name, 'randomShopBtn')
    table.insert(t_btn_name, 'adventBtn')
    table.insert(t_btn_name, 'eventBtn')
    
    -- visible이 켜진 버튼들 리스트
    local l_btn_list = {}
    for _,name in ipairs(t_btn_name) do
        local btn = vars[name]
        if (btn and btn:isVisible()) then
            table.insert(l_btn_list, btn)
        end
    end

    local pos_x = -60
    local interval = -90

    -- 버튼들의 위치 지정
    for i,v in ipairs(l_btn_list) do
        local _pos_x = pos_x + ((i-1) * interval)
        v:setPositionX(_pos_x)
    end
end

-------------------------------------
-- function update_leftButtons
-- @brief 왼쪽 버튼 정렬 (우편함, 구글 버튼, 부스터 버튼 등)
-------------------------------------
function UI_Lobby:update_leftButtons()
    local vars = self.vars

    -- 인덱스 1번이 오른쪽
    local t_btn_name = {}

    -- mailBtn은 가장 왼쪽에 고정
    table.insert(t_btn_name, 'goldBoosterBtn')
    table.insert(t_btn_name, 'expBoosterBtn')
    table.insert(t_btn_name, 'googleGameBtn')
    -- googleAchievementBtn은 googleGameBtn의 오른쪽에 자동으로 위치함

    -- visible이 켜진 버튼들 리스트
    local l_btn_list = {}
    for _,name in ipairs(t_btn_name) do
        local btn = vars[name]
        if (btn and btn:isVisible()) then
            table.insert(l_btn_list, btn)
        end
    end

    local pos_x = 135
    local interval = 73

    -- 버튼들의 위치 지정
    for i,v in ipairs(l_btn_list) do
        local _pos_x = pos_x + ((i-1) * interval)
        v:setPositionX(_pos_x)
    end
end

-------------------------------------
-- function refresh_rightBanner
-- @brief 오른쪽에 배너 갱신
-------------------------------------
function UI_Lobby:refresh_rightBanner()
    local vars = self.vars

    -- 그림자의 신전
    local state = g_challengeMode:getChallengeModeState()
    if isExistValue(state, ServerData_ChallengeMode.STATE['OPEN'], ServerData_ChallengeMode.STATE['REWARD']) then
        if (not vars['banner_challenge_mode']) then
            local banner = UI_BannerChallengeMode()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_challenge_mode'] = banner
        else
            vars['banner_challenge_mode']:refresh()
        end
    else
        if vars['banner_challenge_mode'] then
            vars['banner_challenge_mode'].root:removeFromParent()
            vars['banner_challenge_mode'] = nil
        end
    end

    self:onRefresh_banner()
end

-------------------------------------
-- function onRefresh_banner
-- @brief 오른쪽에 배너 갱신
-------------------------------------
function UI_Lobby:onRefresh_banner()
    local vars = self.vars
    local l_node = {}

    -- 출석 보상 d-day
    if (vars['ddayBtn'] and vars['ddayBtn']:isVisible()) then
        table.insert(l_node, vars['ddayBtn'])
    end

    -- 그림자의 신전
    if vars['banner_challenge_mode'] then
        table.insert(l_node, vars['banner_challenge_mode'].root)
    end

    local pos_y = 0
    local interval = -80

    -- 위치 지정
    for i,v in ipairs(l_node) do
        local _pos_y = pos_y + ((i-1) * interval)
        v:setPositionY(_pos_y)
    end
end

--@CHECK
UI:checkCompileError(UI_Lobby)
