local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventPopup
-- @yjkil 2022.02.11 기준 사용 X
-------------------------------------
UI_EventPopup = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
        m_mTabUI = 'map',

        m_noti = 'boolean',
        m_enterTabMap = 'Map<string>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopup:init(noti)
    self.m_noti = noti or false
    self.m_enterTabMap = {}

    local vars = self:load('event.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_EventPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_EventPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_EventPopup'
    self.m_titleStr = Str('이벤트')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'amethyst'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopup:initUI()
    self:init_tableView()
    self:initTab()

    g_broadcastManager:setEnableNotice(false) -- 운영 공지는 비활성화 - 웹뷰때문에 뎁스 꼬임

    local vars = self.vars

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopup:initButton()
    local vars = self.vars 
    vars['packageTabBtn']:registerScriptTapHandler(function() self:click_packageTabBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopup:refresh()
    
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_EventPopup:init_tableView()
    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = self:getEventPopupTabList()

    -- 생성 콜백
    local function create_func(ui, data)
        local res = data:getTabIcon()
        if res then
            res = Translate:getTranslatedPath(res)
            local icon = cc.Sprite:create(res)
            if icon then
                icon:setDockPoint(cc.p(0.5, 0.5))
                ui.vars['iconNode']:removeAllChildren()
                ui.vars['iconNode']:addChild(icon)
            end
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(264, 104 + 5)
    table_view:setCellUIClass(UI_EventPopupTabButton, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 테이블 뷰 아이템 바로 생성하고 정렬할 경우 애니메이션이 예쁘지 않음.
    -- 애니메이션 생략하고 바로 정렬하게 수정
    local function sort_func()
        table.sort(table_view.m_itemList, function(a, b)
            return a['data'].m_sortIdx < b['data'].m_sortIdx
        end)
    end
    table_view:setItemList3(l_item_list, sort_func)

    self.m_tableView = table_view
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EventPopup:initTab()
    local vars = self.vars

    self.m_lContainerForEachType = {}

    local initial_tab = nil
    for i,v in pairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type
        local ui = v['ui'] or v['generated_ui']

        local continer_node = cc.Node:create()
        continer_node:setDockPoint(cc.p(0.5, 0.5))
        continer_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['eventNode']:addChild(continer_node)
        self.m_lContainerForEachType[type] = continer_node
        self:addTab(type, ui.vars['listBtn'], continer_node, ui.vars['selectSprite'])

        if (not initial_tab) then
            initial_tab = type
        end
    end

    if (not self:checkNotiList()) then
        self:setTab(initial_tab)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventPopup:onChangeTab(tab, first)
    --전면 웹뷰가 아닌 부분 웹뷰일때는 방송, 채팅 꺼줌
    do
        local enable = (tab ~= 'notice') and (tab ~= 'highbrow_shop')
        -- 공지, 하이브로 상점
        g_topUserInfo:setEnabledBraodCast(enable)
    end

    local item = self.m_tableView:getItem(tab)

    if first then
        local container = self.m_lContainerForEachType[tab]
        local ui = self:makeEventPopupTab(tab)
        if ui then
            container:addChild(ui.root)

            if checkMemberInMetatable(ui, 'm_tabButtonCallback') then
                local function callback()
                    item['ui']:refresh()
                end
                ui.m_tabButtonCallback = callback
            end
        end
    else
        if (self.m_mTabUI[tab]) then
            self.m_mTabUI[tab]:onEnterTab()
        end
    end

    -- 입장 탭
    self.m_enterTabMap[tab] = true
end

-------------------------------------
-- function makeEventPopupTab
-------------------------------------
function UI_EventPopup:makeEventPopupTab(tab)
    if (not self.m_mTabUI) then
        self.m_mTabUI = {}
    end

    local ui = nil
    local item = self.m_tableView:getItem(tab)
    local struct_event_popup_tab = item['data']   

	-- 출석 (일반)
    if string.find(tab, 'attendance') then
        local event_type = struct_event_popup_tab.m_eventData['event_type']
		local event_id = struct_event_popup_tab.m_eventData['event_id']
        local atd_id = tonumber(event_id)
        
        -- 신규, 복귀유저 이벤트인지 구분하기 위함
        -- 어텐던스 정보를 받아와서 있으면 event_id를 category로 설정
        if (atd_id and atd_id ~= '') then
            local attendanceInfo = g_attendanceData:getAttendanceDataByAtdId(atd_id)
            if (attendanceInfo and attendanceInfo['category']) then
                local category = attendanceInfo['category']

                if (category == 'open_event' or category == 'newbie' or category == 'comeback') then
                    event_id = category
                end
            end
        end

        -- 기본 출석
		if (event_id == 'normal') then
			ui = UI_EventPopupTab_Attendance()

        -- 2021-11-16 복귀유저 이벤트 특별 작업!
        -- 1회용임으로 미관에 영향을 준다고 판단되면 삭제할것
        elseif (atd_id == 50023 and event_id == 'comeback') then
            require('UI_EventPopupTab_EventAttendanceSpecial')
			ui = UI_EventPopupTab_EventAttendanceSpecial(atd_id)

        -- 이벤트 출석 (오픈, 신규, 복귀)
		elseif (event_id == 'open_event' or event_id == 'newbie' or event_id == 'comeback') then
            require('UI_EventPopupTab_EventAttendanceSpecial')
            if (atd_id < 50031) then
			    ui = UI_EventPopupTab_EventAttendance(event_id, atd_id)
            else -- @yjkil 22.07.29 신규, 복귀 이벤트를 5일에서 7일로 변경
                ui = UI_EventPopupTab_EventAttendanceSpecial(atd_id)
            end
        
        -- 1주년 스페셜 7일 출석, 축하 메세지 전광판
        -- 2주년 스페셜 7일 출석, 축하 메세지 전광판
        elseif (event_id == '1st_event') or (event_id == '2nd_event') or (event_id == 'newbie_welcome') or (event_id == 'global_2nd_event')then
            ui = UI_EventPopupTab_EventAttendance1st(event_id)

        -- 구글 피쳐드 이벤트
        elseif (tab == 'attendance_event50010') then
            require('UI_EventPopupTab_EventAttendanceGoogleFeatured')
            ui = UI_EventPopupTab_EventAttendanceGoogleFeatured(atd_id)

        -- 이벤트 공통 UI
        -- 3주년 스페셜 7일 출석, 축하 메세지 전광판
        elseif (event_type == 'attendance_event') then
            require('UI_EventPopupTab_EventAttendanceSpecial')
            ui = UI_EventPopupTab_EventAttendanceSpecial(atd_id)
		end

    -- 접속시간 이벤트
    elseif (tab == 'access_time') then
        ui = UI_EventPopupTab_AccessTime(self)

    -- 하이브로 상점
    elseif (tab == 'highbrow_shop') then
        ui = UI_EventPopupTab_HBShop()
        self:addNodeToTabNodeList(tab, ui.m_webView)

    -- 배너
    elseif (string.find(tab, 'banner')) then
        ui = UI_EventPopupTab_Banner(self, struct_event_popup_tab)

    -- 소환 확률업
    elseif (tab == 'dragon_chance_up') then
        ui = UI_DragonChanceUp()

    -- 핫타임
    elseif (tab == 'fevertime') then
        require('UI_Fevertime')
        ui = UI_Fevertime()

    -- 코스튬
    elseif (tab == 'costume_event') then
        ui = UI_CostumeEventPopup()

    -- 업데이트 공지 
    elseif (tab == 'notice') then
        ui = UI_EventPopupTab_Notice(self, struct_event_popup_tab)
        self:addNodeToTabNodeList(tab, ui.m_webView)

    -- 수집 교환 이벤트
    elseif (tab =='event_exchange') then
        local inner_ui = UI_ExchangeEvent()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 빙고 이벤트
    elseif (tab =='event_bingo') then
        local inner_ui = UI_EventBingo()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 할로윈 룬 축제(할로윈 이벤트)
    elseif (tab =='event_rune_festival') then
        require('UI_EventRuneFestival')
        ui = UI_EventRuneFestival()

    -- 죄악의 화신 토벌작전 이벤트
    elseif (tab == 'event_incarnation_of_sins_popup') then
        require('UI_EventIncarnationOfSinsFullPopup')
        ui = UI_EventIncarnationOfSinsFullPopup()

    -- 주사위 이벤트
    elseif (tab =='event_dice') then
        local inner_ui = UI_DiceEvent(self)
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 황금던전 이벤트
    elseif (tab =='event_gold_dungeon') then
        local inner_ui = UI_EventGoldDungeon()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 알파벳 이벤트
    elseif (tab =='event_alphabet') then
        local inner_ui = UI_EventAlphabet()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 카드 짝 맞추기 이벤트
    elseif (tab =='event_match_card') then
        local inner_ui = UI_EventMatchCard()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 만드라고라의 모험 이벤트
    elseif (tab =='event_mandraquest') then
        local inner_ui = UI_EventMandragoraQuest()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 신화 드래곤 투표 이벤트
    elseif (tab =='event_vote') then
        ui = UI_EventPopupTab_EventVote(self, struct_event_popup_tab)

    -- 신화 드래곤 인기 투표 가챠 이벤트
    elseif (tab =='event_popularity') then
        ui = UI_EventPopupTab_DragonPopularityGacha(false, self)

	-- Daily Mission
	elseif (tab == 'daily_mission') then
		local key = struct_event_popup_tab.m_eventData['event_id']
		-- 클랜 출석 이벤트
		if (key == 'clan') then
			ui = UI_DailyMisson_Clan()
		end

    -- 1주년 이벤트 : 복귀 유저 환영 이벤트
	elseif (tab == 'event_1st_comeback') then
		ui = UI_Event1stComeback()
    
    -- 2주년 이벤트 : 2주년 기념 감사 이벤트
	elseif (string.find(tab, 'event_thanks_anniversary') or string.find(tab, 'event_dmgate_01')) then
		ui = UI_EventThankAnniversaryNoChoice()--UI_EventThankAnniversary()

    -- 3주년 이벤트 : 이미지 퀴즈 이벤트
    elseif (tab == 'event_image_quiz') then
        require('UI_EventImageQuiz')
        local inner_ui = UI_EventImageQuiz()
        ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)

    -- 소원 구슬 이벤트
    elseif (tab == 'event_lucky_fortune_bag') then
        ui = UI_EventLFBag()
        g_eventLFBagData:tryShowRewardPopup()

    -- 어린이날 룰렛 이벤트
    elseif (tab == 'event_roulette') or (tab == 'event_roulette_reward') then
        -- local inner_ui = UI_EventRoulette()
        -- ui = UI_EventPopupTab_Scroll(self, struct_event_popup_tab, inner_ui)
        -- ui.m_scrollView:setTouchEnabled(false)
        ui = UI_EventRoulette()
        
    -- 죄악의 화신 토벌작전 이벤트
    elseif (tab == 'event_incarnation_of_sins') then
        require('UI_EventIncarnationOfSins')
        ui = UI_EventIncarnationOfSins()

    -- 딜킹 이벤트
    elseif (string.find(tab, 'event_dealking')) then
        require('UI_EventDealking')
        ui = UI_EventDealking()

    -- 신규 유저 환영 이벤트
	elseif (tab == 'event_welcome_newbie') then
		ui = UI_EventWelcomeNewbie()

    -- 스토리 던전 소환 이벤트
	elseif (tab == 'story_dungeon_gacha') then
        require('UI_EventPopupTab_StoryDungeonGacha')
        ui = UI_EventPopupTab_StoryDungeonGacha()

    -- 누적 결제 보상 이벤트 
    elseif pl.stringx.startswith(tab, 'purchase_point') then
        local event_version = struct_event_popup_tab.m_eventData['version'] or struct_event_popup_tab.m_eventData['event_id']
        ui = UI_EventPopupTab_PurchasePointNew(event_version)
        
        --if (g_purchasePointData:isNewTypePurchasePointEvent(event_version) == true) then
          --  ui = UI_EventPopupTab_PurchasePointNew(event_version)
        --else
          --  ui = UI_EventPopupTab_PurchasePoint(event_version)
        --end

    -- 일일 결제 보상 이벤트 
    elseif pl.stringx.startswith(tab, 'purchase_daily') then
        local event_version = struct_event_popup_tab.m_eventData['version'] or struct_event_popup_tab.m_eventData['event_id']
        ui = UI_EventPopupTab_PurchaseDaily(event_version)
        
    -- 깜짝 출현 이벤트
    elseif (tab =='event_advent') then
        ui = UI_EventAdvent()

    -- 신규 드래곤 출시
    elseif string.find(tab, 'event_dragon_launch_legend') then
        require('UI_EventDragonLaunchLegend')
        local event_type = struct_event_popup_tab.m_eventData['event_type']
        local event_id = struct_event_popup_tab.m_eventData['event_id']
        ui = UI_EventDragonLaunchLegend(event_type .. ';' .. event_id)

    -- 다르누스 인포 이벤트
    elseif string.find(tab, 'event_daily_quest') then
        require('UI_EventDailyQuest')
        ui = UI_EventDailyQuest()

    -- 콜로세움 참여 이벤트
    elseif string.find(tab, 'event_arena_play') then
        require('UI_EventArenaPlay')
        ui = UI_EventArenaPlay()

    -- 레이드 참여 이벤트
    elseif string.find(tab, 'event_raid_play') then
        require('UI_EventLeagueRaid')
        ui = UI_EventLeagueRaid()

    -- 게임 설치 유도 이벤트
    elseif (tab == 'event_crosspromotion') then
        ui = UI_CrossPromotion(tab)

	-- VIP 설문조사
    elseif string.find(tab, 'vip_survey') then
        ui = UI_EventVIP(struct_event_popup_tab.m_eventData)
    end

    self.m_mTabUI[tab] = ui
    return ui
end

-------------------------------------
-- function onFocus
-------------------------------------
function UI_EventPopup:onFocus()
    self:refresh_PurchasePointTab()
end

-------------------------------------
-- function refresh_PurchasePointTab
-------------------------------------
function UI_EventPopup:refresh_PurchasePointTab()
    -- 누적 결제의 경우, 패키지로 들어가 상품 구매했을 때 갱신 필요
    for tab, ui in pairs(self.m_mTabUI) do
        if pl.stringx.startswith(tab, 'purchase_point') then
            self.m_mTabUI[tab]:refresh()
        end
    end
end
-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventPopup:click_exitBtn()
    if (not self:checkNotiList()) then
        self:close()

        -- 노티 정보를 갱신하기 위해서 호출
        g_highlightData:setDirty(true)

        -- 방송 활성화
        g_topUserInfo:setEnabledBraodCast(true)

        -- 운영공지 활성화
        g_broadcastManager:setEnableNotice(true) 
    end
end

-------------------------------------
-- function click_packageTabBtn
-------------------------------------
function UI_EventPopup:click_packageTabBtn()
	-- 하이브로... 웹뷰가 남아있는 케이스가 있어 제거
	if (self.m_currTab == 'highbrow_shop') then
		local ui = self.m_mTabUI[self.m_currTab]
		local webview = ui.m_webView
		if (webview) then
			webview:setVisible(false)
		end
	end
    UINavigator:goTo('package_shop')
end

-------------------------------------
-- function refreshTabList
-------------------------------------
function UI_EventPopup:refreshTabList()
    for i,v in pairs(self.m_tableView.m_itemList) do
        local ui = v['ui']
        ui:refresh()
    end
end

-------------------------------------
-- function checkNotiList
-------------------------------------
function UI_EventPopup:checkNotiList()
    if (not self.m_noti) then 
        return
    end

    for i,v in pairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type        
        if self.m_enterTabMap[type] ~= true and 
            v['data']:isNotiVisible() == true then
            self:setTab(type)
            self.m_tableView:relocateContainerFromIndex(i, true)
            return true
        end
    end

    return false
end

-------------------------------------
-- function getEventPopupTabList
-------------------------------------
function UI_EventPopup:getEventPopupTabList()
    local l_item_list = g_eventData:getEventPopupTabList()

    -- purchase
    local l_item_list_purchase_point = g_purchasePointData:getEventPopupTabList()

    -- map형태의 탭 리스트를 merge
    for key,value in pairs(l_item_list_purchase_point) do
        l_item_list[key] = value
    end

    do-- purchase_daily
        local l_item_list_purchase_daily = g_purchaseDailyData:getEventPopupTabList()

            -- map형태의 탭 리스트를 merge
        for key,value in pairs(l_item_list_purchase_daily) do
            l_item_list[key] = value
        end
    end

    return l_item_list
end

--@CHECK
UI:checkCompileError(UI_EventPopup)
