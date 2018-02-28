local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Lobby
-------------------------------------
UI_Lobby = class(PARENT,{
        m_lobbyWorldAdapter = 'LobbyWorldAdapter',
        m_etcExpendedUI = 'UIC_ExtendedUI',
		m_lobbyGuide = 'UIC_LobbyGuide',

        -- 버튼 상태
        m_bItemAutoEnabled = 'bool',
        m_bGiftBoxEnabled = 'bool',
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
    
    -- @analytics
    Analytics:firstTimeExperience('Lobby_Enter')

    -- @ E.T.
    g_errorTracker:cleanupIngameLog()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Lobby:initUI()
	local vars = self.vars

	-- 로비 가이드
	self.m_lobbyGuide = UIC_LobbyGuide(vars['bottomMasterNode'], vars['roadTitleLabel'], vars['roadDescLabel'], vars['masterRoadNotiSprite'])

    -- 기타 버튼 생성
    local ui = UIC_ExtendedUI:create('lobby_etc_extended.ui')
    self.m_etcExpendedUI = ui
    vars['extendedNode']:addChild(ui.m_node)

    self:initLobbyWorldAdapter()
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
-- function initSnow
-------------------------------------
function UI_Lobby:initSnow()
	-- 저사양 모드에서는 실행하지 않는다.
	if (isLowEndMode()) then
		return
	end

	local particle = cc.ParticleSystemQuad:create("res/ui/particle/dv_snow.plist")
	particle:setAnchorPoint(cc.p(0.5, 1))
	particle:setDockPoint(cc.p(0.5, 1))
	self.root:addChild(particle)
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
		co:work()
		do
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
				cclog('# 상점 정보 받는 중')
				g_shopDataNew:response_shopInfo(ret, co.NEXT)
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

				cclog('# 경쟁 메뉴 보상 정보 확인 중')
				if (ret['ancient_clear_stage']) then
					g_ancientTowerData:setClearStage(ret['ancient_clear_stage'])
				end
				if (ret['quest_info']) then
					g_questData:applyQuestInfo(ret['quest_info'])
				end
				if (ret['season']) then
					g_colosseumData:refresh_playerUserInfo(ret['season'], nil)
				end

				co.NEXT()
			end)
			ui_network:setFailCB(required_fail_cb)
			ui_network:hideBGLayerColor()
			ui_network:request()
		end
		if co:waitWork() then return end

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
            g_eventGoldDungeonData:request_dungeonInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

		-- 강제 튜토리얼 진행 하는 동안 풀팝업, 마스터의 길, 구글 업적 일괄 체크, 막음
        if (not TutorialManager.getInstance():checkFullPopupBlock()) then

            -- 풀팝업 출력 함수
            local function show_func(pid) 
                co:work()
                local ui = UI_EventFullPopup(pid)
                ui:setCloseCB(co.NEXT)
                ui:openEventFullPopup()
				ui:setBtnBlock() -- 코루틴을 종료 시킬 수가 없어 다른 UI로 못가게 막음
                if co:waitWork() then return end
            end

			-- 지정된 풀팝업 리스트 (최초 로비 실행 시 출력)
            if (g_fullPopupManager:isTitleToLobby()) then
                NaverCafeManager:naverCafeStart(0) -- 네이버 카페
                g_fullPopupManager:show(FULL_POPUP_TYPE.LOBBY, show_func)
            end
            
			-- 출석 보상 정보 (보상 존재할 경우 출력)
			if (g_attendanceData:hasAttendanceReward()) then
                g_fullPopupManager:show(FULL_POPUP_TYPE.ATTENDANCE, show_func)
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

    -- 우측 UI
    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end) -- 이벤트(출석) 버튼 
    vars['capsuleBtn']:registerScriptTapHandler(function() self:click_capsuleBtn() end)
    vars['itemAutoBtn']:registerScriptTapHandler(function() self:click_itemAutoBtn() end) -- 자동재화(광고)
    vars['giftBoxBtn']:registerScriptTapHandler(function() self:click_giftBoxBtn() end) -- 랜덤박스(광고)
    vars['exchangeBtn']:registerScriptTapHandler(function() self:click_exchangeBtn() end) -- 교환이벤트
    vars['diceBtn']:registerScriptTapHandler(function() self:click_diceBtn() end) -- 주사위이벤트
    vars['goldDungeonBtn']:registerScriptTapHandler(function() self:click_goldDungeonBtn() end) -- 황금던전 이벤트
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_lvUpPackBtn() end) -- 레벨업 패키지
    vars['adventureClearBtn']:registerScriptTapHandler(function() self:click_adventureClearBtn() end) -- 모험돌파 패키지
	vars['capsuleBoxBtn']:registerScriptTapHandler(function() self:click_capsuleBoxBtn() end) -- 캡슐 뽑기 버튼
    vars['ddayBtn']:registerScriptTapHandler(function() self:click_ddayBtn() end) -- 출석 이벤트탭 이동
    vars['dailyShopBtn']:registerScriptTapHandler(function() self:click_dailyShopBtn() end) -- 일일 상점

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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Lobby:refresh()
    -- 유저 정보 갱신
    self:refresh_userInfo()

    -- 마스터의 길 정보 갱신
    self:refresh_masterRoad()

    -- 드래곤 성장일지
    self:refresh_dragonDiary()

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
    end

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
        local type = g_tamerData:getCurrTamerTable('type')
        local icon = IconHelper:getTamerProfileIcon(type)
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
-- function refresh_masterRoad
-- @brief 마스터의길 안내와 드빌 도우미 안내를 같이 쓴다
-------------------------------------
function UI_Lobby:refresh_masterRoad()
    self.m_lobbyGuide:refresh()
	
	-- 로비 가이드 off이고 성장일지 클리어하지 못했다면 위치 변경
	if (self.m_lobbyGuide:isOffMode()) then
		local is_clear = g_dragonDiaryData:isClearAll()
		if (not is_clear) then
			self.vars['dragonDiaryBtn']:setPositionY(110)
		end
	end
end

-------------------------------------
-- function refresh_dragonDiary
-------------------------------------
function UI_Lobby:refresh_dragonDiary()
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
-- function refresh_attendanceDday
-------------------------------------
function UI_Lobby:refresh_attendanceDday()
    local vars = self.vars
    local target_info, target_day = g_attendanceData:getLegendaryDragonDayInfo()
    if (target_info) then
        local received = target_info['received']
        vars['ddayBtn']:setVisible(true)
        vars['ddayLabel']:setString(string.format('D-%d', target_day))

        -- 획득하는 날은 안받은 상태에서만 노출
        if (target_day == 0) and (received == true) then
            vars['ddayBtn']:setVisible(false)
        end
    else
        vars['ddayBtn']:setVisible(false)
    end
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
	self.m_lobbyGuide:onClick()
end

-------------------------------------
-- function click_dragonDiaryBtn
-- @brief 마스터의 길 버튼
-------------------------------------
function UI_Lobby:click_dragonDiaryBtn()
    UI_DragonDiaryPopup()
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
	UI_TamerManagePopup():setCloseCB(close_cb)
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
-- function click_capsuleBoxBtn
-------------------------------------
function UI_Lobby:click_capsuleBoxBtn()
	g_capsuleBoxData:openCapsuleBoxUI()
end

-------------------------------------
-- function click_ddayBtn
-------------------------------------
function UI_Lobby:click_ddayBtn()
    local target_info, target_day = g_attendanceData:getLegendaryDragonDayInfo()
    if (target_info) then
        g_attendanceData:openEventPopup(target_info)
    end
end

-------------------------------------
-- function click_dailyShopBtn
-------------------------------------
function UI_Lobby:click_dailyShopBtn()
    local target_product = TablePackageBundle:getPidsWithName('package_daily_shop')
    local pid = tonumber(target_product[1])

    -- 일일 상점 탭 설정
    UINavigator:goTo('package_shop', pid)
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
		g_highlightData:setDirty(false)
		self:refresh_highlight()
	end

    -- 마스터의 길 정보 갱신
    if (g_masterRoadData.m_bDirtyMasterRoad) then
        g_masterRoadData.m_bDirtyMasterRoad = false
        self:refresh_masterRoad()
    end

    -- 드래곤 성장일지 정보 갱신
    if (g_dragonDiaryData.m_bDirty) then
        g_dragonDiaryData.m_bDirty = false
        self:refresh_dragonDiary()
    end
    
    -- 구글 버튼 처리
    if (GoogleHelper.isDirty) then
        GoogleHelper.setDirty(false)
        self:refresh_google()
    end

    -- 이벤트 갱신된 경우
    if (g_eventData.m_bDirty) then
        g_eventData.m_bDirty = false
        self:refresh_rightButtons()
    end

    -- 로비 출석 D-day 표시
    if (g_attendanceData.m_bDirtyAttendanceInfo) then
        g_attendanceData.m_bDirtyAttendanceInfo = false
        self:refresh_attendanceDday()
    end

    -- 광고 (자동재화, 선물상자 정보)
    do
        -- 자동줍기
        local vars = self.vars
        local msg1, enable1 = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
        vars['itemAutoLabel']:setString(msg1)
        --vars['itemAutoBtn']:setEnabled(enable1) -- 매일매일 다이아 ui를 띄우는 것으로 변경함 (항상 enabled로!) 2017-09-21 sgkim
        if (self.m_bItemAutoEnabled == nil) or (self.m_bItemAutoEnabled ~= enable1) then
            self.m_bItemAutoEnabled = enable1
            vars['itemAutoBtn']:setAutoShake(self.m_bItemAutoEnabled)
        end

        -- 선물상자
        local msg2, enable2 = g_advertisingData:getCoolTimeStatus(AD_TYPE.RANDOM_BOX_LOBBY)
        vars['giftBoxLabel']:setString(msg2)
        vars['giftBoxBtn']:setEnabled(enable2)
        if (self.m_bGiftBoxEnabled == nil) or (self.m_bGiftBoxEnabled ~= enable2) then
            self.m_bGiftBoxEnabled = enable2
            vars['giftBoxBtn']:setAutoShake(self.m_bGiftBoxEnabled)
        end
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
function UI_Lobby:onFocus()
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

    -- 핫타임 정보 갱신
    vars['battleHotSprite']:setVisible(g_hotTimeData:isHighlightHotTime())
	
	-- 룬 할인 이벤트
	local dc_text = g_hotTimeData:getDiscountEventText('rune')
	if (dc_text) then
		vars['eventRemoveLabel']:setString(dc_text)
		vars['eventRemoveSprite']:setVisible(true)
	else
		vars['eventRemoveSprite']:setVisible(false)
	end

    self:refresh_userInfo()
    self:refresh_rightButtons()
end

-------------------------------------
-- function refresh_rightButtons
-- @brief
-------------------------------------
function UI_Lobby:refresh_rightButtons()
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

    -- 황금던전 버튼
    if g_hotTimeData:isActiveEvent('event_gold_dungeon') then
        vars['goldDungeonBtn']:setVisible(true)
    else
        vars['goldDungeonBtn']:setVisible(false)
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
    table.insert(t_btn_name, 'levelupBtn')
    table.insert(t_btn_name, 'adventureClearBtn')
    table.insert(t_btn_name, 'capsuleBoxBtn')
    table.insert(t_btn_name, 'goldDungeonBtn')
    table.insert(t_btn_name, 'dailyShopBtn')
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


--@CHECK
UI:checkCompileError(UI_Lobby)
