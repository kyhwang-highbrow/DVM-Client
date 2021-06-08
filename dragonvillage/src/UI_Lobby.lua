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
        m_lobbyLeftTopBtnManager = 'UI_LobbyLeftTopBtnManager',

        -- 버튼 상태
        m_bItemAutoEnabled = 'bool',
        m_bGiftBoxEnabled = 'bool',

        m_bDirtyLeftButtonMenu = 'bool',
        m_bUpdatingHighlights = 'bool',

        -- 로비 진입 시 시작 코루틴에서 의미있는 동작이 모두 완료되었는지 구분
        m_bDoneEntryCoroutine = 'bool',
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
    self.m_bDoneEntryCoroutine = false
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


    -- 좌상단 버튼 관리 매니저 생성
    self.m_lobbyLeftTopBtnManager = UI_LobbyLeftTopBtnManager(self)
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_Lobby:init_after()
    PARENT.init_after(self)
    g_topUserInfo:stopAllUIActions()
    g_topUserInfo:doActionReset()
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

        do
            
        end

		if (g_hotTimeData:isActiveEvent('event_exchange')) then
            co:work()
            cclog('# 교환 이벤트 정보 받는 중')
            g_exchangeEventData:request_eventInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_bingo')) then
            co:work()
            cclog('# 빙고 이벤트 정보 받는 중')
            g_eventBingoData:request_bingoInfo(co.NEXT, required_fail_cb)
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

        if (g_hotTimeData:isActiveEvent('event_image_quiz')) then
            co:work('# 드래곤 이미지 퀴즈 이벤트 정보 받는 중')
            g_eventImageQuizData:request_eventImageQuizInfo(co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_eventLFBagData:canPlay() or g_eventLFBagData:canReward()) then
            co:work('# 소원 구슬 이벤트 정보 받는 중')
            g_eventLFBagData:request_eventLFBagInfo(false, true, co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if g_hotTimeData:isActiveEvent('event_roulette') or g_hotTimeData:isActiveEvent('event_roulette_reward') then
            co:work('# 룰렛 이벤트 정보 받는 중')
            ServerData_EventRoulette:getInstance():request_rouletteInfo(true, false, co.NEXT, required_fail_cb)
            if co:waitWork() then return end
        end

        if (g_eventIncarnationOfSinsData:isActive()) then
            co:work('# 죄악의 화신 토벌작전 이벤트 정보 받는 중')
            g_eventIncarnationOfSinsData:request_eventIncarnationOfSinsInfo(false, co.NEXT, required_fail_cb)
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

        -- 차원문 
        do 
            co:work('# 차원문 정보 받는 중')
            g_dmgateData:request_dmgateInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        -- 구독 상품 정보 받는 중
        co:work('# 구독 상품 정보 받는 중')
        local ui_network = g_subscriptionData:request_subscriptionInfo(co.NEXT, co.ESCAPE)
        ui_network:hideBGLayerColor()
        ui_network:showLoadingAnimation()
        ui_network:setLoadingMsg(Str('네트워크 통신 중...'))
        if co:waitWork() then return end
        
        -- 캡슐 코인 상세 정보 (status)
        -- @mskim 캡슐 코인 남은 수량이 필요해서 임시로 추가
        -- api 정리가 필요 완전 개판임
        if (g_capsuleBoxData.m_refillState == 2) then
            co:work('# 캡슐 코인 상세 정보 받는 중')
            g_capsuleBoxData:request_capsuleBoxStatus(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        do 
            co:work('# 배틀패스 정보 받는 중')
                g_battlePassData:request_battlePassInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

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

            -- 20201223
            -- https://highbrow.atlassian.net/wiki/spaces/dvm/pages/875233281
            -- 우선순위: 신규 유저 D+1 푸시 > 게임 내 공지 > 누적 결제 이벤트 > 풀팝업
			-- =============================================
			-- 풀팝업 출력 조건 예외처리(레벨 5 미만에도 띄워야 할 경우) (신규 유저 대상일 경우)
			-- =============================================
            do 
			    -- 1.출석 보상 정보 (보상 존재할 경우 출력)
                if (g_attendanceData:hasAttendanceReward()) then
                    cclog('# 출석 show')
                    g_fullPopupManager:show(FULL_POPUP_TYPE.ATTENDANCE, show_func)
			    end

                -- 2.신규 유저 환영 이벤트
                if (g_eventData:isPossibleToGetWelcomeNewbieReward()) then
                    cclog('# 신규 유저 환영 이벤트 show')
                    g_fullPopupManager:show(FULL_POPUP_TYPE.EVENT_WELCOME_NEWBIE, show_func)
			    end
            end

            
			-- =============================================
			-- 풀팝업 출력 조건 최근 공지 팝업을 보고 확인을 누르는 액션을 안했을 경우
			-- =============================================
            do 
                -- 풀팝업 출력 함수
                local function show_notice_callback() 
                    co:work()
                    local t_notice = g_mailData:getNewNoticeData()

                    -- 없으면 null이나 Empty string으로 들어온다
                    if not t_notice or t_notice =='' then return end

                    local ui = UI_IngameNoticeFullPopup(t_notice)
                    ui:setCloseCB(co.NEXT)
                    if co:waitWork() then return end
                end
                
			    -- 공지알림 팝업
                if (g_mailData:hasNewNotice()) then
                    cclog('# 인게임 공지팝업')
                    g_fullPopupManager:show(FULL_POPUP_TYPE.INGAME_NOTICE, show_notice_callback)
			    end
            end

            -- =============================================
            -- 로비 알림(lobby_notice)
            local l_struct_lobby_notice = g_lobbyNoticeData:getStructLobbyNoticeList()
            for i,v in ipairs(l_struct_lobby_notice) do
                co:work()
                v:openLobbyNoticePopup(co.NEXT)
                if co:waitWork() then return end
            end
            -- =============================================


            -- =============================================
			-- 풀팝업 출력 조건 
            -- 1. 레벨 5 이상
            -- 2. 최초 로비 실행 시
			-- ============================================= 
            local is_show = (g_fullPopupManager:isTitleToLobby() and (g_userData:get('lv') >= 5))
            
			-- 지정된 풀팝업 리스트 
            if (is_show) then
                cclog('# 풀팝업 show')
                
                local t_showed_popup = {}
                local function show_full_popup_func(pid)
                    -- 한 번 보여준 팝업 리스트에 없다면, 팝업 출력
                    if (not t_showed_popup[pid]) then
                        show_func(pid)
                        t_showed_popup[pid] = true
                    end        
                end

                -- table_lobby_popup에 있는 팝업들 조건 체크, 출력
                g_fullPopupManager:show(FULL_POPUP_TYPE.LOBBY_BY_CONDITION, show_full_popup_func)

                -- table_event_list 에 있는 팝업들 조건 체크, 출력
                g_fullPopupManager:show(FULL_POPUP_TYPE.LOBBY, show_full_popup_func)
				
				-- 타이틀에서 로비 넘어온 플래그 초기화 
                g_fullPopupManager:setTitleToLobby(false)
            end
            

            -- 바이델 축제 패키지
            local struct_product, idx, bonus_num = g_shopDataNew:getSpecialOfferProductWeidel()

            if (struct_product and g_shopDataNew:shouldShowWeidelOfferPopup() == true) then
                cclog('# 바이델 축제 패키지')
                co:work()
                local str_uid = g_userData:get('uid') and tostring(g_userData:get('uid')) or ''
                local weidel_offer_save_key = 'lobby_weidel_package_notice_' .. str_uid
                local currentTime = tonumber(socket.gettime())
                g_settingData:applySettingData(currentTime, weidel_offer_save_key)

                local ui = UI_ButtonSpecialOfferWeidel:showOfferPopup(struct_product)
                ui:setCloseCB(co.NEXT)
                if co:waitWork() then return end
            end

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
	    end   		


        -- @ 차원문 컨텐츠 오픈
        -- 콘텐츠 오픈 팝업
        local has_dmgate_key = g_settingData:get('lobby_dmgate_open_notice') or false

        if (not g_contentLockData:isContentLock('dmgate') and not has_dmgate_key) then
            UI_ContentOpenPopup('dmgate')
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

        -- 필수적인 항목이 모두 완료, UI등장 액션까지 실행된 후에 설정
        self.m_bDoneEntryCoroutine = true

        if (1 < ENTRY_LOBBY_CNT) and (not TutorialManager.getInstance():checkFullPopupBlock()) then
		    self:entryCoroutine_Escapable(co)
	    end
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
-- function entryCoroutine_challengeModePopup
-- @brief 그림자 신전 입장 권유 팝업 조건 체크 코루틴 
-------------------------------------
function UI_Lobby:entryCoroutine_challengeModePopup(co)
    if (not g_challengeMode:checkPromotePopupCondition()) then
        return
    end

    co:work()
    -- 창을 닫으면 다음 코루틴 시작
    local close_cb = function()
        co.NEXT()
    end

    -- 바로가기 버튼 누르면 로비에서 벗어나기 때문에 코루틴 탈출
    local goto_cb = function()
        co.ESCAPE()
    end
    
    UI_ChallengeModePromotePopup(close_cb, goto_cb)
    
	if co:waitWork() then return end
end

-------------------------------------
-- function entryCoroutine_linkAccount
-- @brief 계정 연동 권유 팝업 조건 체크 코루틴 
-------------------------------------
function UI_Lobby:entryCoroutine_linkAccount(co)  
    if (not UI_LinkAccountPopup.checkLinkAccountCondition()) then
        return
    end

    co:work()
    -- 창을 닫으면 다음 코루틴 시작
    local close_cb = function()
        co.NEXT()
    end
    
    local link_popup = UI_LinkAccountPopup()
    link_popup:setCloseCB(close_cb)
    
	if co:waitWork() then return end
end

-------------------------------------
-- function entryCoroutine_personalpack
-- @brief 깜짝 할인 상품 코루틴 
-------------------------------------
function UI_Lobby:entryCoroutine_personalpack(co)
	-- PERSONALPACK push == 조건 체크
    g_personalpackData:push(PERSONALPACK)
    -- 충족한 패키지가 없다면 skip
    if (g_personalpackData:isEmpty()) then
        return
    end
        
    -- coroutine body
	co:work()
    g_personalpackData:pull(co.NEXT)
	if co:waitWork() then return end

    -- 활성화된 패키지가 있는 것이므로 갱신한다.
    self:refresh()
end

-------------------------------------
-- function entryCoroutine_Escapable
-- @brief 코루틴 탈출되어도 상관없는 코루틴 함수
-------------------------------------
function UI_Lobby:entryCoroutine_Escapable(co)
    self:entryCoroutine_personalpack(co)
    self:entryCoroutine_spotSale(co)
    self:entryCoroutine_linkAccount(co)
    --self:entryCoroutine_challengeModePopup(co)
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
    local pushToken = g_localData:get('local', 'push_token') -- fcm 푸시 토큰

	-- ui_network
	local ui_network = UI_Network()
	ui_network:setUrl('/users/lobby')
	ui_network:setParam('uid', uid)
	ui_network:setParam('access_time', time)
	ui_network:setParam('dragon_power', combat_power)
    ui_network:setParam('push_token', pushToken)
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

		local cb_func = function()
            -- 처음 로비 세팅할 때 장식 데이터를 받기 전이라 장식이 없음, 장식 데이터를 받고 추가로 로비 장식 해줌
            local lobbyType = g_lobbyChangeMgr:getLobbyType()

            if (lobbyType == LOBBY_TYPE.NORMAL) then
                if (ENTRY_LOBBY_CNT == 1) then
                    local lobby_map = self.m_lobbyWorldAdapter:getLobbymap()
                    LobbyMapFactory:setDeco(lobby_map, self)
                end
            end

            co.NEXT()
        end

        g_eventData:response_eventList(ret, cb_func)
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

        cclog('# 그림자의 신전 정보 확인 중')
		if (ret['challenge_info']) then
			g_challengeMode:setInfoForLobby(ret['challenge_info'])
		end

        if (ret['arena_info']) then -- 콜로세움 (신규) <-- 닫혀있음 안줌
			g_arenaData:setInfoForLobby(ret['arena_info'])
		end

        cclog('# 누적 결제 보상 정보 확인 중')
        if (ret['purchase_point_info']) then
            g_purchasePointData:applyPurchasePointInfo(ret['purchase_point_info'])
        end

        cclog('# 일일 결제 보상 정보 확인 중')
        if (ret['purchase_daily_info']) then
            g_purchaseDailyData:applyPurchaseDailyInfo(ret['purchase_daily_info'])
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
            g_eventAdventData:setAdventDidList(ret['advent_did_list'])
        end

		cclog('# 깜짝 출현 드래곤 알 정보 받는 중')
		if (ret['xmas_daily_egg_info']) then
            g_eventAdventData:responseDailyAdventEggInfo(ret['xmas_daily_egg_info'])
        end

        cclog('# 환상 던전 보상 여부 정보 받는 중')
        if (ret['event_illusion_reward']) then
            g_illusionDungeonData:setRewardPossible(true)
        else
            g_illusionDungeonData:setRewardPossible(false)
        end

        cclog('# 컨텐츠 오픈 정보 받는 중')
        if (ret['content_unlock_list']) then
			g_contentLockData:applyContentLockByStage(ret['content_unlock_list'])
		end

        cclog('# 클랜전 정보 받는 중') -- 데이터 크기가 작음
        if (ret['clanwar_info']) then
			g_clanWarData:applyClanWarInfo(ret['clanwar_info'])
		end

		cclog('# 신규 유저 환영 이벤트')
		g_eventData:response_eventWelcomeNewbie(ret)

        cclog('# 첫 충전 선물(첫 결제 보상)')
        if ret['first_purchase_event_info'] then
		    g_firstPurchaseEventData:applyFirstPurchaseEvent(ret['first_purchase_event_info'])
        end

        cclog('# 마을 알림 (lobby_notice)')
        if ret['lobby_notice_list'] then
            g_lobbyNoticeData:applyLobbyNoticeListData(ret['lobby_notice_list'])
        end

        cclog('# 보급소(정액제)(supply_list config)')
        g_supply:applySupplyList_fromRet(ret)

        cclog('# 유저 상태 정보')
        if (ret['ustats']) then
            UserStatusAnalyser:analyzeUserStat(ret['ustats'])
            --UserStatusAnalyser:analyzeDragon()
        end

        cclog('# 개인화 패키지 정보')
        if (ret['personalpack_info']) then
            g_personalpackData:response_personalpackInfo(ret['personalpack_info'])
        end

        cclog('# 할로윈 룬 축제(할로윈 이벤트)')
        if (ret['rune_festival_info']) then
            g_eventRuneFestival:applyRuneFestivalInfo(ret['rune_festival_info'])
        end

		co.NEXT()
	end)
	ui_network:setFailCB(required_fail_cb)
	ui_network:hideBGLayerColor()
	ui_network:request()

	if co:waitWork() then return end
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
            -- 로비 진입 시 시작 코루틴에서 의미있는 동작이 모두 완료되었는지 구분하여 동작 (불필요한 시점에 이 코드때문에 UI가 등장함)
            if (self.m_bDoneEntryCoroutine == true) then
                parent_node:stopAllActions()
                self:doAction(nil, nil, 0.5)
                g_topUserInfo:doAction(nil, nil, 0.5)
            end
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
    
    -- 상점
    do
        vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
        self:setShopNoti()
    end
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end) -- 부화소
    vars['runeForgeBtn']:registerScriptTapHandler(function() self:click_runeForgeBtn() end) -- 룬 세공소
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
    vars['fevertimeBtn']:registerScriptTapHandler(function() self:click_fevertimeBtn() end) -- 핫타임 버튼 
    vars['capsuleBtn']:registerScriptTapHandler(function() self:click_capsuleBtn() end)
    vars['itemAutoBtn']:registerScriptTapHandler(function() self:click_itemAutoBtn() end) -- 자동재화(광고)
    vars['itemAutoBtn']:setVisible(false)
    vars['giftBoxBtn']:registerScriptTapHandler(function() self:click_giftBoxBtn() end) -- 랜덤박스(광고)
    vars['exchangeBtn']:registerScriptTapHandler(function() self:click_exchangeBtn() end) -- 교환이벤트
    vars['bingoBtn']:registerScriptTapHandler(function() self:click_bingoBtn() end) -- 빙고 이벤트
    vars['halloweenEventBtn']:registerScriptTapHandler(function() self:click_halloweenEventBtn() end) -- 빙고 이벤트
    vars['diceBtn']:registerScriptTapHandler(function() self:click_diceBtn() end) -- 주사위이벤트
    vars['luckyfortunebagEventBtn']:registerScriptTapHandler(function() self:click_lfbagBtn() end) -- 소원 구슬 이벤트
    vars['alphabetBtn']:registerScriptTapHandler(function() self:click_alphabetBtn() end) -- 알파벳 이벤트
    vars['quizEventBtn']:registerScriptTapHandler(function() self:click_quizEventBtn() end) -- 드래곤 이미지 퀴즈 이벤트
    vars['goldDungeonBtn']:registerScriptTapHandler(function() self:click_goldDungeonBtn() end) -- 황금던전 이벤트
    vars['matchCardBtn']:registerScriptTapHandler(function() self:click_matchCardBtn() end) -- 카드 짝 맞추기 이벤트
    vars['mandragoraBtn']:registerScriptTapHandler(function() self:click_mandragoraBtn() end) -- 만드라고라의 모험 이벤트
    vars['adventBtn']:registerScriptTapHandler(function() self:click_adventBtn() end) -- 깜짝 출현 이벤트
    --
    vars['battlePassBtn']:registerScriptTapHandler(function() self:click_battlePassBtn() end) -- 배틀패스 버튼
    vars['cashShopBtn']:registerScriptTapHandler(function() self:click_packageShopBtn() end) -- 패키지(상점) 버튼



    vars['levelupBtn']:registerScriptTapHandler(function() self:click_lvUpPackBtn() end) -- 레벨업 패키지
    vars['levelupBtn2']:registerScriptTapHandler(function() self:click_lvUpPackBtn2() end) -- 레벨업 패키지 2
    --vars['levelupBtn3']:registerScriptTapHandler(function() self:click_lvUpPackBtn3() end) -- 레벨업 패키지 3
    vars['adventureClearBtn']:registerScriptTapHandler(function() self:click_adventureClearBtn() end) -- 모험돌파 패키지
    vars['adventureClearBtn02']:registerScriptTapHandler(function() self:click_adventureClearBtn02() end) -- 모험돌파 패키지 2
    --vars['adventureClearBtn03']:registerScriptTapHandler(function() self:click_adventureClearBtn03() end) -- 모험돌파 패키지 3 -- 2020.08.24
    
    vars['capsuleBoxBtn']:registerScriptTapHandler(function() self:click_capsuleBoxBtn() end) -- 캡슐 뽑기 버튼
    vars['ddayBtn']:registerScriptTapHandler(function() self:click_ddayBtn() end) -- 출석 이벤트탭 이동
    --vars['dailyShopBtn']:registerScriptTapHandler(function() self:click_dailyShopBtn() end) -- 일일 상점
    vars['randomShopBtn']:registerScriptTapHandler(function() self:click_randomShopBtn() end) -- 랜덤 상점
    vars['randomShopBtn']:setVisible(true) 

    do -- 기타 UI
        local etc_vars = self.m_etcExpendedUI.vars
        etc_vars['settingBtn']:registerScriptTapHandler(function() self:click_settingBtn() end) -- 설정
        etc_vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankingBtn() end) -- 종합 랭킹
        etc_vars['friendBtn']:registerScriptTapHandler(function() self:click_friendBtn() end) -- 친구
        etc_vars['inventoryBtn']:registerScriptTapHandler(function() self:click_inventoryBtn() end)-- 가방
        etc_vars['bookBtn']:registerScriptTapHandler(function() self:click_bookBtn() end) -- 도감 버튼
        etc_vars['communityBtn']:registerScriptTapHandler(function() self:click_communityBtn() end) -- 네이버 카페 버튼
    end

    do -- 클랜 버튼 잠금 상태 처리
        --[[
        local is_content_lock, req_user_lv = g_contentLockData:isContentLock('clan')
        if is_content_lock then
            vars['clanBtn']:setEnabled(false)
            vars['clanLockNode']:setVisible(true)
            vars['clanLockLabel']:setString(Str('레벨 {1}', req_user_lv))
        else
            vars['clanBtn']:setEnabled(true)
            vars['clanLockNode']:setVisible(false)
        end
        --]]
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
    
	-- 서버에서 받는 컨텐츠 오픈 정보 갱신될 때만 update
    self:update_bottomLeftButtons()
    self:update_bottomRightButtons()
    
    -- 오른쪽 배너 갱신
    self:refresh_rightBanner()

    -- 특별 할인 상품 설정
    --self:refreshSpecialOffer()

    -- 좌상단 버튼들 상태 갱신
    if self.m_lobbyLeftTopBtnManager then
        self.m_lobbyLeftTopBtnManager:setDirtyButtonsStatus()
    end

    -- hard refresh
    if (is_hard_refresh) then
        -- update()와 중복
        g_masterRoadData.m_bDirtyMasterRoad = false
        self:update_masterRoad()

        g_dragonDiaryData.m_bDirty = false
        self:update_dragonDiary()

        GoogleHelper.setDirty(false)
        self:update_google()

        -- 2주년 기념 전설 드래곤 확률 업 노티
        self:setHatcheryChanceUpNoti()
    end
end

-------------------------------------
-- function refreshSpecialOffer
-- @brief 특별 할인 상품 설정
--        로비에서 우편함 아래쪽에 특별 할인 상품 버튼 정보 갱신
-------------------------------------
function UI_Lobby:refreshSpecialOffer()
    local vars = self.vars

    -- 모든 특별 할인 상품 visible을 꺼준다.
    for i=1, 10 do
        local btn = vars['specialOfferBtn' .. i]
        if btn then
            btn:setVisible(false)
        end
    end

    -- 상점에서 특별 할인 상품을 받아온다.
    local struct_product, idx, bonus_num = g_shopDataNew:getSpecialOfferProduct()

    -- UI가 없을 경우
    local button = vars['specialOfferBtn' .. idx]
    local time_label = vars['specialOfferLabel' .. idx]
    if (not button) or (not time_label) then
        return
    end

    -- 특별 할인 상품 유무에 따라서 초기화
    if struct_product then
        button:setVisible(true)

        -- 상품 클릭 시 패키지 팝업
        button:registerScriptTapHandler(function()
            local pid = struct_product['product_id']
            local package_name = TablePackageBundle:getPackageNameWithPid(pid)   
            local ui = UI_Package_Bundle(package_name, true)

            -- 혜택률 표시
            if ui.vars['bonusLabel'] then
                ui.vars['bonusLabel']:setString(Str('{1}%', bonus_num)) -- '800% 이상의 혜택!'
            end

            -- 서버에 따라 보여지는 UI 달리함 (한국은 설날, 글로벌은 2주년)
            local is_korea_server = g_localData:isKoreaServer()
            if ui.vars['koreaMenu'] then
                ui.vars['koreaMenu']:setVisible(is_korea_server)
            end
            if ui.vars['globalMenu'] then
                ui.vars['globalMenu']:setVisible(not is_korea_server)
            end

            ui:doAction()

            -- 팝업이 닫히면 정보 다시 갱신
            ui:setCloseCB(function() self:refreshSpecialOffer() end)
        end)

        -- 매 프레임 남은 시간을 표기한다.
        local function update(dt)
            local time_sec = struct_product:getTimeRemainingForEndOfSale()
            local time_millisec = (time_sec * 1000)
            local str = datetime.makeTimeDesc_timer(time_millisec)
            time_label:setString(str)
        end
        update(0) -- 최초 1번 호출
        time_label.m_node:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
        
    else
        button:setVisible(false)
        time_label.m_node:unscheduleUpdate()
    end

    -- 깜짝 할인 상품의 버튼 위치와 동일하다.
    -- 특별 할인 상품이 활성화 될 경우 깜짝 할인 상품 버튼을 오른쪽으로 이동한다.
    -- 개발 시간상의 이유로 우선 하드코딩한다.
    if (not struct_product) then
        vars['spotSaleBtn1']:setPositionX(56)
        vars['spotSaleBtn2']:setPositionX(56)
        vars['spotSaleBtn3']:setPositionX(56)
    else
        vars['spotSaleBtn1']:setPositionX(56 + 85)
        vars['spotSaleBtn2']:setPositionX(56 + 85)
        vars['spotSaleBtn3']:setPositionX(56 + 85)
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

        do -- 핫타임
            if (
                g_hotTimeData:isHighlightHotTime()
                or g_fevertimeData:isActiveFevertime_adventure()
                or g_fevertimeData:isActiveFevertime_dungeonGdItemUp()
                or g_fevertimeData:isActiveFevertime_dungeonGtItemUp()
                or g_fevertimeData:isActiveFevertime_pvpHonorUp()
                or g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp()
                or g_fevertimeData:isActiveFevertime_dungeonRuneUp()
                or g_fevertimeData:isActiveFevertime_dungeonArStDc()
                or g_fevertimeData:isActiveFevertime_dungeonNmStDc()
                or g_fevertimeData:isActiveFevertime_dungeonGtStDc()
                or g_fevertimeData:isActiveFevertime_dungeonGdStDc()
                or g_fevertimeData:isActiveFevertime_dungeonRgStDc()
            ) then
                vars['battleHotSprite']:setVisible(true)
            end
            
            local is_gacha_active local gacha_value local gacha_ret
            local is_comebine_active local combine_value local combine_ret

            is_gacha_active, gacha_value, gacha_ret = g_fevertimeData:isActiveFevertime_runeGachaUp()
            is_comebine_active, combine_value, combine_ret = g_fevertimeData:isActiveFevertime_runeCombineUp()

            if is_gacha_active then
                vars['runeEventSprite1']:setVisible(true)
                if #gacha_ret then gacha_ret = gacha_ret[1] end
                vars['runeEventLabel1']:setString(Str(gacha_ret['title']))
            elseif is_comebine_active then
     
                vars['runeEventSprite1']:setVisible(true)
                if #combine_ret then combine_ret = combine_ret[1] end
                vars['runeEventLabel1']:setString(Str(combine_ret['title']))
            else
                vars['runeEventSprite1']:setVisible(false)
            end
            
        end

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

		-- 룬
		local rune_box_count = g_userData:get('rune_box') or 0
        local b_rune_gacha_highlight = (rune_box_count > 0)
        vars['runeForgeNotiSprite']:setVisible(g_highlightData:isHighlightRune() or b_rune_gacha_highlight)

		-- 기타 (친구 or 도감 or 가방)
		local is_etc_noti = (etc_vars['friendNotiSprite']:isVisible() or etc_vars['bookNotiSprite']:isVisible() or etc_vars['inventoryNotiSprite']:isVisible())
		vars['etcNotiSprite']:setVisible(is_etc_noti)

		-- 클랜
		vars['clanNotiSprite']:setVisible(
            g_clanData:isHighlightClan()
            or g_fevertimeData:isActiveFevertime_dungeonRuneLegendUp()
            or g_fevertimeData:isActiveFevertime_dungeonRuneUp()
            or g_fevertimeData:isActiveFevertime_dungeonRgStDc()
        )

        do -- 황금 던전
            vars['goldDungeonNotiRed']:setVisible(false)
            vars['goldDungeonNotiYellow']:setVisible(false)

            if ServerData_EventGoldDungeon:getInstance():isHighlightRed_gd() then
                vars['goldDungeonNotiRed']:setVisible(true)
            elseif ServerData_EventGoldDungeon:getInstance():isHighlightYellow_gd() then
                vars['goldDungeonNotiYellow']:setVisible(true)
            end
        end

        do -- 수집 이벤트
            vars['exchangeNotiRed']:setVisible(false)
            vars['exchangeNotiYellow']:setVisible(false)

            if g_hotTimeData:isActiveEvent('event_exchange') then
                if g_exchangeEventData:isHighlightRed_ex() then
                    vars['exchangeNotiRed']:setVisible(true)
                elseif g_exchangeEventData:isHighlightYellow_ex() then
                    vars['exchangeNotiYellow']:setVisible(true)
                end
            end
        end

        do -- 빙고 이벤트
            vars['bingoNotiRed']:setVisible(false)
            vars['bingoNotiYellow']:setVisible(false)

            if g_hotTimeData:isActiveEvent('event_bingo') then
                local struct_bingo = g_eventBingoData:getStructEventBingo()
                if (struct_bingo) then
                    if struct_bingo:isHighlightRed_ex() then
                        vars['bingoNotiRed']:setVisible(true)
                    elseif struct_bingo:isHighlightYellow_ex() then
                        vars['bingoNotiYellow']:setVisible(true)
                    end
                end
            end
        end

        do
            vars['mandragoraNotiSprite']:setVisible(false)
            vars['mandragoraNotiYellow']:setVisible(false)
    
            if (g_hotTimeData:isActiveEvent('event_mandraquest')) then
                -- 만드라고라의 모험 노티
                local function setNoti(ret)
                    local b_show_red_noti = g_mandragoraQuest:isVisible_RedNoti()
                    vars['mandragoraNotiSprite']:setVisible(b_show_red_noti)
                    local b_show_yellow_noti = g_mandragoraQuest:isVisible_YellowNoti()
                    vars['mandragoraNotiYellow']:setVisible(b_show_yellow_noti)
                end
				-- 정확한 퀘스트 상태 확인을 위해 다시 요청(드래곤 소환 등의 퀘스트)
                g_mandragoraQuest:request_questInfo(setNoti)
            end
        end

        

        do -- 할로윈 이벤트
            vars['halloweenNotiSprite']:setVisible(false)
            vars['halloweenNotiYellow']:setVisible(false)

            if g_hotTimeData:isActiveEvent('event_rune_festival') then
                if (g_eventRuneFestival:isDailyStLimit() == false) then
                    vars['halloweenNotiYellow']:setVisible(true)
                end
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

        do -- 핫타임
            vars['fevertimeNotiSprite']:setVisible(g_fevertimeData:isNotUsedFevertimeExist())
        end

        do -- 일일 퀘스트 이벤트 (3주년 신비의 알 100개 부화 이벤트)
            vars['questEventSprite']:setVisible(g_hotTimeData:isActiveEvent('event_daily_quest'))
        end

        do -- 드래곤 이미지 퀴즈 이벤트
            if (g_eventImageQuizData) then
                vars['quizEventNotiSprite']:setVisible(g_eventImageQuizData:isHighlightRed_imageQuiz())
                vars['quizEventNotiYellow']:setVisible(g_eventImageQuizData:isHighlightYellow_imageQuiz())
            end
        end

        do -- 소원 구슬 이벤트
            if (g_eventLFBagData) then
                vars['luckyfortunebagNotiSprite']:setVisible(g_eventLFBagData:isHighlightRed())
                --vars['quizEventNotiYellow']:setVisible(g_eventLFBagData:isHighlightYellow())
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

    local market, os = GetMarketAndOS()

    -- 마켓이 구글인 경우에만 노출
	if (market ~= 'google') then
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
    UINavigator:goTo('quest')
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
-- function click_runeForgeBtn
-- @brief 룬 세공소
-------------------------------------
function UI_Lobby:click_runeForgeBtn()
    UINavigator:goTo('rune_forge', nil)
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
    g_mailData:request_mailList(function() 
    
        local function cb_func(is_dirty)
            if (is_dirty) then
                -- 닉네임 변경으로 인한 처리...
                self:refresh_userInfo()
            end
	    end

        UI_MailPopup():setCloseCB(cb_func) 
    end)
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
-- function click_communityBtn
-------------------------------------
function UI_Lobby:click_communityBtn()
    UI_CommunityPopup()
    --NaverCafeManager:naverCafeStart(0) -- @tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_Lobby:click_eventBtn()
    g_eventData:openEventPopup()
end

-------------------------------------
-- function click_fevertimeBtn
-------------------------------------
function UI_Lobby:click_fevertimeBtn()
    g_eventData:openEventPopup('fevertime')
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
    
    -- if IS_TEST_MODE() then
    --     --UI_DmgateScene(DIMENSION_GATE_MANUS)
    --     require('UI_ShopPackageScene')
    --     UI_ShopPackageScene()
    -- else
        g_advertisingData:showAdvPopup(AD_TYPE.RANDOM_BOX_LOBBY)
    --end
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
-- function click_bingoBtn
-- @brief 빙고 이벤트
-------------------------------------
function UI_Lobby:click_bingoBtn()
    if (not g_hotTimeData:isActiveEvent('event_bingo')) then
        return
    end
    g_eventData:openEventPopup('event_bingo')
end

-------------------------------------
-- function click_halloweenEventBtn
-- @brief 할로윈 룬 축제(할로윈 이벤트)
-------------------------------------
function UI_Lobby:click_halloweenEventBtn()
    if (not g_hotTimeData:isActiveEvent('event_rune_festival')) then
        return
    end
    g_eventData:openEventPopup('event_rune_festival')
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
-- function click_lfbagBtn
-- @brief 주사위 이벤트
-------------------------------------
function UI_Lobby:click_lfbagBtn()
    if (g_eventLFBagData:canPlay()) then
        g_eventData:openEventPopup('event_lucky_fortune_bag')
    
    elseif (g_eventLFBagData:canReward()) then
        g_eventLFBagData:openRankingPopupForLobby()

    end
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
-- function click_quizEventBtn
-- @brief 드래곤 이미지 퀴즈 이벤트
-------------------------------------
function UI_Lobby:click_quizEventBtn()
    if (not g_hotTimeData:isActiveEvent('event_image_quiz')) then
        return
    end
    g_eventData:openEventPopup('event_image_quiz')
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
-- function click_packageShopBtn
-- @brief temp package shop button for season pass
-------------------------------------
function UI_Lobby:click_packageShopBtn()
    UINavigator:goTo('package_shop_test')
end

-------------------------------------
-- function click_battlePassBtn
-- @brief 배틀패스 상점 버튼
-------------------------------------
function UI_Lobby:click_battlePassBtn()
    g_battlePassData:openBattlePassPopup()
    
end
-------------------------------------
-- function click_lvUpPackBtn
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_Lobby:click_lvUpPackBtn()
    UI_Package_LevelUp(nil, true) -- param : struct_product, is_popup
end

-------------------------------------
-- function click_lvUpPackBtn2
-- @brief 레벨업 패키지2 버튼
-------------------------------------
function UI_Lobby:click_lvUpPackBtn2()
    UI_Package_LevelUp_02(nil, true) -- param : struct_product, is_popup
end

-------------------------------------
-- function click_lvUpPackBtn3
-- @brief 레벨업 패키지2 버튼
-------------------------------------
function UI_Lobby:click_lvUpPackBtn3()
    UI_Package_LevelUp_03(nil, true) -- param : struct_product, is_popup
end

-------------------------------------
-- function click_adventureClearBtn
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_Lobby:click_adventureClearBtn()
    UI_Package_AdventureClear(nil, true) -- param : struct_product, is_popup
end

-------------------------------------
-- function click_adventureClearBtn02
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_Lobby:click_adventureClearBtn02()
    require('UI_Package_AdventureClear02')
    UI_Package_AdventureClear02(nil, true) -- param : struct_product, is_popup
end

-------------------------------------
-- function click_adventureClearBtn03
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_Lobby:click_adventureClearBtn03()
    require('UI_Package_AdventureClear03')
    UI_Package_AdventureClear03(nil, true) -- param : struct_product, is_popup
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
    --UI_OverallRankingPopup()
    UINavigatorDefinition:goTo('hell_of_fame')
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

        -- 컴포넌트에 최신 좌표를 알려줘야 한다.
        -- 안그러면 원래 자리로 돌아감
        vars['googleAchievementBtn'].m_originPosX = game_pos_x + 73
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
-- function UI_Lobby:click_dailyShopBtn()
--     local is_popup = true
--     UINavigator:goTo('shop_daily', is_popup)
-- end

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

    -- 레벨업 패키지, 모험돌파 패키지 등 상품 구매했을 경우, 오른쪽 버튼들 갱신
    if (g_levelUpPackageData:getBuyLevelUpPackageDirty()) then
        self:update_rightButtons()
        g_levelUpPackageData:resetBuyLevelUpPackageDirty()
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
        map_check_event['event_exchange'] = 'exchangeLabel' -- 수집 이벤트
        map_check_event['event_bingo'] = 'bingoLabel' -- 빙고 이벤트
        map_check_event['event_lucky_fortune_bag'] = 'luckyfortunebagLabel' -- 소원 구슬 이벤트
        
        for event_name, label_name in pairs(map_check_event) do
            local remain_text = g_hotTimeData:getEventRemainTimeText(event_name)
            local label = vars[label_name]
            if (remain_text) and (label) then
                label:setVisible(true)
                label:setString(remain_text)
            end
        end
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
            self:entryCoroutine_Escapable(co)
        end

        Coroutine(coroutine_function, '로비 코루틴 onFocus')
    end

    -- 상점에서 노티 상품 다 사고 돌아왔을 경우 정보 갱신을 위해
    self:setShopNoti()
end

-------------------------------------
-- function refresh_hottime
-- @brief 핫타임 관련 UI 갱신
-------------------------------------
function UI_Lobby:refresh_hottime()
	local vars = self.vars

    -- 핫타임 정보 갱신
    if (
        g_hotTimeData:isHighlightHotTime()
        or g_fevertimeData:isActiveFevertime_adventure()
        or g_fevertimeData:isActiveFevertime_dungeonGdItemUp()
        or g_fevertimeData:isActiveFevertime_dungeonGtItemUp()
        or g_fevertimeData:isActiveFevertime_pvpHonorUp()
    ) then
        vars['battleHotSprite']:setVisible(true)
    end

    
    local is_gacha_active local gacha_value local gacha_ret
    local is_comebine_active local combine_value local combine_ret

    is_gacha_active, gacha_value, gacha_ret = g_fevertimeData:isActiveFevertime_runeGachaUp()
    is_comebine_active, combine_value, combine_ret = g_fevertimeData:isActiveFevertime_runeCombineUp()

    if is_gacha_active then
        vars['runeEventSprite1']:setVisible(true)
        if #gacha_ret then gacha_ret = gacha_ret[1] end
        vars['runeEventLabel1']:setString(Str(gacha_ret['title']))
    elseif is_comebine_active then
        vars['runeEventSprite1']:setVisible(true)
        if #combine_ret then combine_ret = combine_ret[1] end
        vars['runeEventLabel1']:setString(Str(combine_ret['title']))
    else
        vars['runeEventSprite1']:setVisible(false)
    end
	
	-- 할인 이벤트
	local l_dc_event = g_fevertimeData:getDiscountEventList()
    for i, dc_target in ipairs(l_dc_event) do
        -- @sgkim 2020.10.19 핫타임(구버전)과 피버타임(신버전)의 꼬임 문제로 추가
        if (dc_target == 'rune' or dc_target == 'runelvup' or dc_target == 'skillmove' or dc_target == 'reinforce') then
            g_fevertimeData:setDiscountEventNode(dc_target, vars, 'dragonEventSprite'..i)
        end
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
    
    -- 190822 @jhakim 로비 정리로 드빌전용관 노출 x
    vars['capsuleBtn']:setVisible(false)

    -- 교환소 버튼 (수집 이벤트)
    vars['exchangeBtn']:setVisible(g_hotTimeData:isActiveEvent('event_exchange'))

    -- 주사위 버튼
    vars['diceBtn']:setVisible(g_hotTimeData:isActiveEvent('event_dice'))

    -- 빙고 이벤트 버튼
    vars['bingoBtn']:setVisible(g_hotTimeData:isActiveEvent('event_bingo'))

    -- 할로윈 룬 축제(할로윈 이벤트)
    vars['halloweenEventBtn']:setVisible(g_hotTimeData:isActiveEvent('event_rune_festival'))

    -- 알파벳 이벤트
    vars['alphabetBtn']:setVisible(g_hotTimeData:isActiveEvent('event_alphabet'))

    -- 드래곤 이미지 퀴즈 이벤트
    vars['quizEventBtn']:setVisible(g_hotTimeData:isActiveEvent('event_image_quiz'))
    
    -- 소원 구슬 이벤트
    vars['luckyfortunebagEventBtn']:setVisible(g_eventLFBagData:isActive())
    
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

    -- 깜짝 출현 이벤트 버튼
    if g_hotTimeData:isActiveEvent('event_advent') then
        vars['adventBtn']:setVisible(true)
    else
        vars['adventBtn']:setVisible(false)
    end

	-- 캡슐 신전 버튼
	if (not g_contentLockData:isContentLock('capsule')) then
		vars['capsuleBoxBtn']:setVisible(true)
        -- lobby ui 에서 capsule refill 정보 표시 여부
        local is_refill, is_refill_completed = g_capsuleBoxData:isRefillAndCompleted(--[[is_lobby: ]]false)
        vars['refillMenu']:setVisible(is_refill)
        if (is_refill) then
            vars['refillReservedMenu']:setVisible(not is_refill_completed)
            vars['refillCompletedMenu']:setVisible(is_refill_completed)
        end
	else
		vars['capsuleBoxBtn']:setVisible(false)
	end
    
    do
        -- 레벨업 패키지 버튼
        if g_levelUpPackageData:isVisible_lvUpPack(LEVELUP_PACKAGE_PRODUCT_ID) then
            vars['levelupBtn']:setVisible(true)
        else
            vars['levelupBtn']:setVisible(false)
        end

        -- 레벨업 패키지2 버튼
        if g_levelUpPackageData:isVisible_lvUpPack(LEVELUP_PACKAGE_2_PRODUCT_ID) then
            vars['levelupBtn2']:setVisible(true)
        else
            vars['levelupBtn2']:setVisible(false)
        end

        -- -- 레벨업 패키지3 버튼
        -- if g_levelUpPackageData:isVisible_lvUpPack(LEVELUP_PACKAGE_3_PRODUCT_ID) then
        --     vars['levelupBtn3']:setVisible(true)
        -- else
        vars['levelupBtn3']:setVisible(false)
        -- end

        -- 레벨업 패키지 노티
        local is_noti = g_levelUpPackageData:isVisible_levelUpPackNoti(LEVELUP_PACKAGE_PRODUCT_ID)
        vars['levelupNotiSprite']:setVisible(is_noti)
        
        -- 레벨업 패키지2 노티
        local is_noti = g_levelUpPackageData:isVisible_levelUpPackNoti(LEVELUP_PACKAGE_2_PRODUCT_ID)
        vars['levelupNotiSprite2']:setVisible(is_noti)

        -- 레벨업 패키지3 노티
        -- local is_noti = g_levelUpPackageData:isVisible_levelUpPackNoti(
        --                     LEVELUP_PACKAGE_3_PRODUCT_ID)
        vars['levelupNotiSprite3']:setVisible(false)
    end

    -- 일일상점 버튼
    --vars['dailyShopBtn']:setVisible(true)

    -- 모험돌파 버튼
    do
        -- 모험돌파 버튼
        if g_adventureClearPackageData:isVisible_adventureClearPack() then
            vars['adventureClearBtn']:setVisible(true)
        else
            vars['adventureClearBtn']:setVisible(false)
        end
           
        -- 모험돌파 패키지 노티
        local is_noti = g_adventureClearPackageData:isVisible_adventureClearPackNoti()
        vars['adventureClearNotiSprite']:setVisible(is_noti)
    end

    -- 모험돌파 버튼 2
    do
        -- 모험돌파 버튼
        if g_adventureClearPackageData02:isVisible_adventureClearPack() then
            vars['adventureClearBtn02']:setVisible(true)
        else
            vars['adventureClearBtn02']:setVisible(false)
        end
           
        -- 모험돌파 패키지 노티
        local is_noti = g_adventureClearPackageData02:isVisible_adventureClearPackNoti()
        vars['adventureClearNotiSprite02']:setVisible(is_noti)
    end

    -- 모험돌파 버튼 3 2020.08.24
    do
        -- 모험돌파 버튼
        --local is_visible = g_adventureClearPackageData03:isVisible_adventureClearPack()
        --vars['adventureClearBtn03']:setVisible(is_visible)
        vars['adventureClearBtn03']:setVisible(false)

        -- 모험돌파 패키지 노티
        local is_noti = g_adventureClearPackageData03:isVisible_adventureClearPackNoti()
        vars['adventureClearNotiSprite03']:setVisible(is_noti)
    end

    -- 마녀의 상점
    local is_random_shop_open = not g_contentLockData:isContentLock('shop_random')
    vars['randomShopBtn']:setVisible(is_random_shop_open)

    -- 일일 상점
    --local is_daily_shop_open = not g_contentLockData:isContentLock('daily_shop')
    --vars['dailyShopBtn']:setVisible(is_daily_shop_open)

    do -- 핫타임
        -- if (g_fevertimeData:isHighlightFevertime() == true) then
        --     vars['fevertimeBtn']:setVisible(true)
        --     vars['fevertimeNotiSprite']:setVisible(g_fevertimeData:isNotUsedFevertimeExist())
        -- else
            vars['fevertimeBtn']:setVisible(false)
            vars['fevertimeNotiSprite']:setVisible(false)
        --end
    end

    do -- 배틀 패스
        --g_battlePassData:isValidTime() or 
        -- g_LevelUpPackageData:isUnclearedAnyPackage()
        -- 
        local is_visible = (g_battlePassData:isAnyValidProduct() and g_battlePassData:isThereAnyUnreceivedReward())
                            or g_adventureClearPackageData:isVisible_adventureClearPack()
                            or g_adventureClearPackageData02:isVisible_adventureClearPack()
                            or g_adventureClearPackageData03:isVisibleAtBattlePassShop()
        vars['battlePassBtn']:setVisible(is_visible)
        local is_noti_visible = g_battlePassData:isThereAnyAvailableReward()
                                or g_levelUpPackageData:isVisibleNotiAtLobby(LEVELUP_PACKAGE_3_PRODUCT_ID)
                                or g_adventureClearPackageData03:isVisibleNotiAtLobby()
                                or g_dmgatePackageData:isNotiVisible()
        vars['battlePassNotiSprite']:setVisible(is_noti_visible)


        --vars['battlePassNotiSprite']:setVisible(g_battlePassData:isThereAnyAvailableReward())
        --vars['battlePassNotiSprite']:setVisible(g_levelUpPackageData:isVisibleNotiAtLobby(LEVELUP_PACKAGE_3_PRODUCT_ID))
        --vars['battlePassNotiSprite']:setVisible(g_adventureClearPackageData03:isVisibleNotiAtLobby())
    end

    do -- 패키지
        -- TODO (YOUNGJIN) : TEMP         
        vars['cashShopBtn']:setVisible(true)
        vars['cashShopNotiSprite']:setVisible(false)
    end
    -- 인덱스 1번이 오른쪽
    local t_btn_name = {}
    table.insert(t_btn_name, 'capsuleBtn')
    table.insert(t_btn_name, 'itemAutoBtn')
    table.insert(t_btn_name, 'giftBoxBtn')

    -- 이벤트
    table.insert(t_btn_name, 'matchCardBtn')
    table.insert(t_btn_name, 'mandragoraBtn')
    table.insert(t_btn_name, 'bingoBtn')
    table.insert(t_btn_name, 'halloweenEventBtn')
    table.insert(t_btn_name, 'diceBtn')
    table.insert(t_btn_name, 'alphabetBtn')
    table.insert(t_btn_name, 'exchangeBtn')
    table.insert(t_btn_name, 'adventBtn')
    table.insert(t_btn_name, 'quizEventBtn')
    table.insert(t_btn_name, 'luckyfortunebagEventBtn')
    
    -- 패키지
    table.insert(t_btn_name, 'levelupBtn')
    table.insert(t_btn_name, 'levelupBtn2')
    --table.insert(t_btn_name, 'levelupBtn3')
    table.insert(t_btn_name, 'adventureClearBtn')
    table.insert(t_btn_name, 'adventureClearBtn02')
    --table.insert(t_btn_name, 'adventureClearBtn03')

    table.insert(t_btn_name, 'capsuleBoxBtn')
    table.insert(t_btn_name, 'goldDungeonBtn')
    --table.insert(t_btn_name, 'dailyShopBtn')
    table.insert(t_btn_name, 'randomShopBtn')
    --table.insert(t_btn_name, 'fevertimeBtn')
    table.insert(t_btn_name, 'eventBtn')
    table.insert(t_btn_name, 'battlePassBtn')
    table.insert(t_btn_name, 'cashShopBtn')
    
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
-- function update_bottomLeftButtons
-- @brief 아래 버튼 정렬 (드래곤, 테이머, 드래곤의 숲, 퀘스트)
-------------------------------------
function UI_Lobby:update_bottomLeftButtons()
    local vars = self.vars
    local t_btn_name = {}
    -- @sgkim 2020.12.14 퀘스트 버튼은 좌상단의 우편함 옆으로 이동
    --local l_content = {'quest', 'forest', 'tamer', 'runeForge', 'dragonManage'}
    local l_content = {'forest', 'tamer', 'runeForge', 'dragonManage'}
    for _, content_name in ipairs(l_content) do
        local is_content_lock = g_contentLockData:isContentLock(content_name)
        local btn_label = content_name .. 'Btn'
        if (not is_content_lock) then
            table.insert(t_btn_name, btn_label)
            vars[btn_label]:setVisible(true)
        else
            vars[btn_label]:setVisible(false)
        end
    end
    
    -- visible이 켜진 버튼들 리스트
    local l_btn_list = {}
    for _,name in ipairs(t_btn_name) do
        local btn = vars[name]
        if (btn and btn:isVisible()) then
            table.insert(l_btn_list, btn)
        end
    end

    -- @kwkang 20-12-09 룬 관리 추가로 버튼들 위치 값 변경
    local pos_x
    local interval
    -- 아직 드래곤의 숲이 열리지 않은 경우
    if (table.count(l_btn_list) <= 4) then
        pos_x = -140
        interval = -119
    
    -- 왼쪽 하단에 속해있는 모든 컨텐츠가 열려있는 경우
    else
        pos_x = -120
        interval = -108
    end

    -- 버튼들의 위치 지정
    for i,v in ipairs(l_btn_list) do
        local _pos_x = pos_x + ((i-1) * interval)
        if (v:getPositionX() ~= _pos_x) then
            v:setPositionX(_pos_x)
        end
    end
end

-------------------------------------
-- function update_bottomRightButtons
-- @brief 아래 버튼 정렬 (클랜, 상점, 부화소, 기타)
-------------------------------------
function UI_Lobby:update_bottomRightButtons()
    local vars = self.vars
    local t_btn_name = {}
    local l_content = {'clan','shop', 'draw', 'etc'}
    for _, content_name in ipairs(l_content) do
        local is_content_lock = g_contentLockData:isContentLock(content_name)
        local btn_label = content_name .. 'Btn'
        if (not is_content_lock) then
            table.insert(t_btn_name, btn_label)
            vars[btn_label]:setVisible(true)
        else
            vars[btn_label]:setVisible(false)
        end
    end
    
    -- visible이 켜진 버튼들 리스트
    local l_btn_list = {}
    for _,name in ipairs(t_btn_name) do
        local btn = vars[name]
        if (btn and btn:isVisible()) then
            table.insert(l_btn_list, btn)
        end
    end

    local pos_x = 140
    local interval = 119

    -- 버튼들의 위치 지정
    for i,v in ipairs(l_btn_list) do
        local _pos_x = pos_x + ((i-1) * interval)
        if (v:getPositionX() ~= _pos_x) then
            v:setPositionX(_pos_x)
        end
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
    pos_x = 219 -- @sgkim 2020.12.14 퀘스트 버튼이 우편함 옆으로 오면서 위치 조정
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
    -- local state = g_challengeMode:getChallengeModeState_Routine()
    -- if isExistValue(state, ServerData_ChallengeMode.STATE['OPEN'], ServerData_ChallengeMode.STATE['REWARD']) then
    --     if (not vars['banner_challenge_mode']) then
    --         local banner = UI_BannerChallengeMode()
    --         vars['bannerMenu']:addChild(banner.root)
    --         banner.root:setDockPoint(cc.p(1, 1))
    --         banner.root:setAnchorPoint(cc.p(1, 1))
    --         vars['banner_challenge_mode'] = banner
    --     else
    --         vars['banner_challenge_mode']:refresh()
    --     end
    -- else
    --     if vars['banner_challenge_mode'] then
    --         vars['banner_challenge_mode'].root:removeFromParent()
    --         vars['banner_challenge_mode'] = nil
    --     end
    -- end


    -- 그랜드 콜로세움
    local state = g_grandArena:getGrandArenaState()
    if isExistValue(state, ServerData_GrandArena.STATE['PRESEASON'], ServerData_GrandArena.STATE['OPEN'], ServerData_GrandArena.STATE['REWARD']) then
        if (not vars['banner_grand_arena']) then
            local banner = UI_BannerGrandArena()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_grand_arena'] = banner
        else
            vars['banner_grand_arena']:refresh()
        end
    else
        if vars['banner_grand_arena'] then
            vars['banner_grand_arena'].root:removeFromParent()
            vars['banner_grand_arena'] = nil
        end
    end

    -- 환상던전 이벤트
    local state = g_illusionDungeonData:getIllusionState()
    if isExistValue(state, Serverdata_IllusionDungeon.STATE['OPEN'], Serverdata_IllusionDungeon.STATE['REWARD']) then
        if (not vars['banner_illusion']) then
            local banner = UI_BannerIllusion()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_illusion'] = banner
        else
            vars['banner_illusion']:refresh()
        end
    else
        if vars['banner_illusion'] then
            vars['banner_illusion'].root:removeFromParent()
            vars['banner_illusion'] = nil
        end
    end

    -- 명예의 전당 배너
    local state = false
    if (state) then
        if (not vars['banner_hall_of_fame']) then
            local banner = UI_BannerHallOfFame()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_hall_of_fame'] = banner
        end
    else
        if vars['banner_hall_of_fame'] then
            vars['banner_hall_of_fame'].root:removeFromParent()
            vars['banner_hall_of_fame'] = nil
        end
    end

    --클랜전 배너
    if (g_clanWarData:isShowLobbyBanner() == true) then
        local t_data = g_clanWarData:getMyClanMatchInfoForBanner() -- my_match_info
        local end_date = g_clanWarData.today_end_time

        if (not vars['banner_clanwar']) then
            require('UI_BannerClanWar')
            local banner = UI_BannerClanWar(t_data, end_date)
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_clanwar'] = banner
        else
            vars['banner_clanwar']:initUI(t_data, end_date)
        end
    else
        if vars['banner_clanwar'] then
            vars['banner_clanwar'].root:removeFromParent()
            vars['banner_clanwar'] = nil
        end
    end

	--클랜전 배너 (공격 중)
    local is_attacking, attacking_uid, end_date = g_clanWarData:isMyClanWarMatchAttackingState()
    if (is_attacking) then
        if (not vars['banner_clanwar_attack']) then
            local banner = UI_BannerClanWarAttacking(attacking_uid, end_date)
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_clanwar_attack'] = banner
        end
    else
        if vars['banner_clanwar_attack'] then
            vars['banner_clanwar_attack'].root:removeFromParent()
            vars['banner_clanwar_attack'] = nil
        end
    end

    -- 룬 축제 이벤트 배너
    if (g_hotTimeData:isActiveEvent('event_rune_festival') == true) then
        if (not vars['banner_rune_festival']) then
            require('UI_BannerRuneFestival')
            local banner = UI_BannerRuneFestival()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_rune_festival'] = banner
        else
            vars['banner_rune_festival']:refresh()
        end
    else
        if vars['banner_rune_festival'] then
            vars['banner_rune_festival'].root:removeFromParent()
            vars['banner_rune_festival'] = nil
        end
    end

    -- 죄악의 화신 토벌작전 이벤트 배너
    if (g_eventIncarnationOfSinsData:isActive()) then
        if (not vars['banner_incarnation_of_sins']) then
            require('UI_BannerIncarnationOfSins')
            local banner = UI_BannerIncarnationOfSins()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(cc.p(1, 1))
            banner.root:setAnchorPoint(cc.p(1, 1))
            vars['banner_incarnation_of_sins'] = banner
        else
            vars['banner_incarnation_of_sins']:refresh()
        end
    else
        if vars['banner_incarnation_of_sins'] then
            vars['banner_incarnation_of_sins'].root:removeFromParent()
            vars['banner_incarnation_of_sins'] = nil
        end
    end

    -- 차원문 오픈 배너
    if g_dmgateData:isShowLobbyBanner() then
        if (not vars['banner_dmgate']) then
            local banner = UI_BannerDmgate()
            vars['bannerMenu']:addChild(banner.root)
            banner.root:setDockPoint(TOP_RIGHT)
            banner.root:setAnchorPoint(TOP_RIGHT)
            vars['banner_dmgate'] = banner
        else
            vars['banner_dmgate']:refresh()
        end
    else
        if vars['banner_dmgate'] then
            vars['banner_dmgate'].root:removeFromParent()
            vars['banner_dmgate'] = nil
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

    -- 그랜드 콜로세움
    if vars['banner_grand_arena'] then
        table.insert(l_node, vars['banner_grand_arena'].root)
    end
    
    -- 환상 던전
    if vars['banner_illusion'] then
        table.insert(l_node, vars['banner_illusion'].root)
    end

    -- 명예의 전당
    if vars['banner_hall_of_fame'] then
        table.insert(l_node, vars['banner_hall_of_fame'].root)
    end

    -- 클랜전
    if vars['banner_clanwar'] then
        table.insert(l_node, vars['banner_clanwar'].root)
    end

    -- 클랜전 공격 중
    if vars['banner_clanwar_attack'] then
        table.insert(l_node, vars['banner_clanwar_attack'].root)
    end

    -- 룬 축제 이벤트 배너
    if vars['banner_rune_festival'] then
        table.insert(l_node, vars['banner_rune_festival'].root)
    end

    -- 죄악의 화신 토벌작전 이벤트 배너
    if vars['banner_incarnation_of_sins'] then
        table.insert(l_node, vars['banner_incarnation_of_sins'].root)
    end

    -- 차원문 오픈 배너
    if vars['banner_dmgate'] then
        table.insert(l_node, vars['banner_dmgate'].root)
    end

    local pos_y = 0
    local interval = -90

    -- 위치 지정
    for i,v in ipairs(l_node) do
        local _pos_y = pos_y + ((i-1) * interval)
        v:setPositionY(_pos_y)
    end
end

-------------------------------------
-- function setShopNoti
-------------------------------------
function UI_Lobby:setShopNoti()
    local vars = self.vars
    if (not g_shopDataNew) then
        return
    end

    if (g_shopDataNew:checkDiaSale()) then
        vars['shopBonusNoti']:setVisible(true)
    else
        vars['shopBonusNoti']:setVisible(false)
    end
end

-------------------------------------
-- function setHatcheryChanceUpNoti
-------------------------------------
function UI_Lobby:setHatcheryChanceUpNoti()
    local vars = self.vars
    if (g_hotTimeData:isActiveEvent('event_legend_chance_up') or  g_fevertimeData:isActiveFevertime_summonLegendUp()) then
        vars['chanceUpNoti']:setVisible(true)
    else
        vars['chanceUpNoti']:setVisible(false)
    end
end


--@CHECK
UI:checkCompileError(UI_Lobby)
