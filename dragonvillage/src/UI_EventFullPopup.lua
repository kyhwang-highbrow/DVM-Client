local PARENT = UI

-------------------------------------
-- class UI_EventFullPopup
-------------------------------------
UI_EventFullPopup = class(PARENT,{
        m_popupKey = 'string',
		m_innerUI = 'UI',

        -- @jhakim 로비 풀 팝용이 아닌 용도, 나중에 클래스 분리할 거임
        m_targetUI = 'UI', -- 외부 UI를 이 형식에 맞추어 사용
        m_check_cb = 'function'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventFullPopup:init(popup_key, target_ui, m_check_cb)
    self.m_popupKey = popup_key
    -- @jhakim 로비 풀 팝용이 아닌 용도, 나중에 클래스 분리할 거임
    self.m_targetUI = target_ui
    self.m_check_cb = m_check_cb
end

-------------------------------------
-- function openEventFullPopup
-------------------------------------
function UI_EventFullPopup:openEventFullPopup()
    self.m_uiName = 'UI_EventFullPopup'
    local vars = self:load('event_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventFullPopup')

    self:initUI()
    self:initButton()
    self:refresh()

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventFullPopup:initUI()
    local vars = self.vars
    local popup_key = self.m_popupKey
	local ui
    local is_btn_lock = true

    -- 이벤트 배너
    if (string.find(popup_key, 'banner')) then
        local l_str = plSplit(popup_key, ';')
        local event_data = { banner = l_str[2], url = l_str[3] or '', end_date = l_str[4] or '', start_date = l_str[5] or ''}
        local struct_data = StructEventPopupTab(event_data)
        ui = UI_EventPopupTab_Banner(self, struct_data)

        -- 환상 던전 풀팝업일 경우에만 남은 시간 표기
        if string.find(popup_key, 'event_illusion') then
            if (ui.vars['timeLabel']) then
                if (g_illusionDungeonData:getIllusionState() == Serverdata_IllusionDungeon.STATE['OPEN']) then
                    ui.vars['timeLabel']:setString(Str('이벤트 기간') .. ' ' .. g_illusionDungeonData:getIllusionStatusText())
                else
                    ui.vars['timeLabel']:setString(Str('이벤트 기간') .. ' ' .. g_illusionDungeonData:getIllusionExchanageStatusText())
                end
            end
        end   

    -- 확률업 드래곤 배너
    elseif (popup_key == 'dragon_chance_up') then
        ui = UI_DragonChanceUp()

    -- 신규 드래곤 출시
    elseif (string.find(popup_key, 'event_dragon_launch_legend')) then
        require('UI_EventDragonLaunchLegend')
        ui = UI_EventDragonLaunchLegend(popup_key)

    -- 코스튬
    elseif (popup_key == 'costume_event') then
        ui = UI_CostumeEventPopup()
        
	-- Daily Mission
	elseif string.find(popup_key, 'daily_mission') then
		local l_str = plSplit(popup_key, ';')
		local key = l_str[2]
		if (key == 'clan') then
			ui = UI_DailyMisson_Clan()
		end

	-- 출석
	elseif string.find(popup_key, 'attendance') then
		local l_str = plSplit(popup_key, ';')
		local key = l_str[2] -- category
        local category = l_str[2]
        local atd_id = l_str[3]
        
        -- 기본출석 
		if (key == 'normal') then
			ui = UI_EventPopupTab_Attendance()
        
        -- 이벤트 출석 (오픈, 신규, 복귀)
		elseif (key == 'open_event' or key == 'newbie' or key == 'comeback') then
            if (tonumber(atd_id) < 50031) then
			    ui = UI_EventPopupTab_EventAttendance(key, atd_id) -- @yjkil 22.07.29 신규, 복귀 이벤트를 5일에서 7일로 변경
            else
                require('UI_EventPopupTab_EventAttendanceSpecial')
                ui = UI_EventPopupTab_EventAttendanceSpecial(atd_id)
            end
        
        -- 1주년 스페셜 7일 출석, 축하 메세지 전광판
        -- 2주년 스페셜 7일 출석, 축하 메세지 전광판
        elseif (key == '1st_event') or (key == '2nd_event') or (key == 'newbie_welcome') or (key == 'global_2nd_event') then
            ui = UI_EventPopupTab_EventAttendance1st(key)
        
        -- 구글 피처드. 이미지 바꿔야 해서 따로 처리
        elseif (atd_id == '50010') then
            require('UI_EventPopupTab_EventAttendanceGoogleFeatured')
            ui = UI_EventPopupTab_EventAttendanceGoogleFeatured(atd_id)

        -- 이벤트 공통 UI
        -- 3주년 스페셜 7일 출석, 축하 메세지 전광판
        elseif (category == 'event') then
            require('UI_EventPopupTab_EventAttendanceSpecial')
            ui = UI_EventPopupTab_EventAttendanceSpecial(atd_id)
        end

    -- 패키지 상품 
    elseif string.find(popup_key, 'package') then     
        local package_name = popup_key
        local is_popup = false

        local package_list = g_shopDataNew:getActivatedPackageList(true)


        for index, struct_package_bundle in pairs(package_list) do
            if (struct_package_bundle:getProductName() == package_name) and struct_package_bundle:isBuyable() then
                ui = struct_package_bundle:getTargetUI(nil,nil,nil,true)
            end
        end

        --ui = PackageManager:getTargetUI(package_name, is_popup)

        if (not ui) then
            -- 이벤트 프로덕트 정보 없을 경우 비활성화라고 생각하고 닫아줌 (주말 패키지)
            self:close()
        else
            -- 영웅 드래곤 선택권 패키지에서는 내부 ui의 closeBtn을 사용하도록 한다.
            if (popup_key == 'package_dragon_choice_hero') and ui.vars['closeBtn'] then
                ui.vars['closeBtn']:setVisible(true)
                ui.vars['closeBtn']:setEnabled(true)
                ui.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
                vars['closeBtn']:setVisible(false)

            -- 절전알 패키지 구글 피처드 수정
            elseif (popup_key == 'package_absolute') then
                -- @kwkang 20-12-14 새해맞이로 패키지 재판매하여 하단 주석처리
                -- self:changeTitleSprite(ui.vars)

            -- 풀팝업에서는 퀵 버튼을 끔
            elseif (ui.vars['quickBtn'] ~= nil) then
                ui.vars['quickBtn']:setVisible(false)
            end
        end

    -- 다이아 할인 상품 풀팝업
    elseif string.find(popup_key, 'event_dia_discount') or string.find(popup_key, 'event_gold_bonus') then
        local package_name = popup_key
        local is_popup = false
        ui = PackageManager:getTargetUI(package_name, is_popup)

        if (not ui) then
            -- 이벤트 프로덕트 정보 없을 경우 비활성화라고 생각하고 닫아줌 (주말 패키지)
            self:close()
        end

    -- 일일 상점
    elseif string.find(popup_key, 'shop_daily') then
        ui = UI_ShopDaily()

    -- 수집 이벤트 
    elseif string.find(popup_key, 'event_exchange') then
        local inner_ui = UI_ExchangeEvent()
        local temp_struct_data = StructEventPopupTab({event_type = 'event_exchange'})
        ui = UI_EventPopupTab_Scroll(self, temp_struct_data, inner_ui)

    -- 빙고 이벤트 
    elseif string.find(popup_key, 'event_bingo') then
        local inner_ui = UI_EventBingo()
        local temp_struct_data = StructEventPopupTab({event_type = 'event_exchange'})
        ui = UI_EventPopupTab_Scroll(self, temp_struct_data, inner_ui)

    -- 할로윈 룬 축제(할로윈 이벤트)
    elseif string.find(popup_key, 'event_rune_festival') then
        require('UI_EventRuneFestival')
        ui = UI_EventRuneFestival()

    -- 죄악의 화신 토벌작전 이벤트
    elseif string.find(popup_key, 'event_incarnation_of_sins_popup') then
        require('UI_EventIncarnationOfSinsFullPopup')
        ui = UI_EventIncarnationOfSinsFullPopup()

    -- 만드라고라의 모험 이벤트 
    --elseif string.find(popup_key, 'event_mandraquest') then
        --local inner_ui = UI_EventMandragoraQuest()
        --local temp_struct_data = StructEventPopupTab({event_type = 'event_mandraquest'})
        --ui = UI_EventPopupTab_Scroll(self, temp_struct_data, inner_ui)

	-- 1주년 이벤트 : 복귀 유저 환영 이벤트
	elseif (popup_key == 'event_1st_comeback' or popup_key == 'event_global_1st_comeback') then
		ui = UI_Event1stComeback()

	-- 2주년 이벤트 : 2주년 기념 감사 이벤트
	elseif (string.find(popup_key, 'event_thanks_anniversary') or string.find(popup_key, 'event_dmgate_01')) then
		ui = UI_EventThankAnniversaryNoChoice()--UI_EventThankAnniversary()

    -- 신규 유저 환영 이벤트
	elseif (popup_key == 'event_welcome_newbie') then
        -- 리워드 받을 수 있는 경우에만 풀 팝업 노출
        if (g_eventData:isPossibleToGetWelcomeNewbieReward()) then
		    ui = UI_EventWelcomeNewbie()
        end

    -- 신규 스킨
	elseif (popup_key == 'dragon_skin') then
        -- 리워드 받을 수 있는 경우에만 풀 팝업 노출
        require('UI_DragonSkinSaleFullPopup')
		ui = UI_DragonSkinSaleFullPopup()

    -- 누적 결제 보상 이벤트
    elseif pl.stringx.startswith(popup_key, 'purchase_point') then
		local l_str = plSplit(popup_key, ';')
        local event_version = l_str[2]
        
        if (g_purchasePointData:getPurchasePoint(event_version) > 0) or (g_userData:get('lv') >= 5)then
            ui = UI_EventPopupTab_PurchasePointNew(event_version)
        else
            self:close()
        end
        --if (g_purchasePointData:isNewTypePurchasePointEvent(event_version) == true) then
            --ui = UI_EventPopupTab_PurchasePointNew(event_version)
        --else
            --ui = UI_EventPopupTab_PurchasePoint(event_version)
        --end

    -- 일일 충전 선물 이벤트
    elseif pl.stringx.startswith(popup_key, 'purchase_daily') then
        local l_str = plSplit(popup_key, ';')
        local event_version = l_str[2]
        ui = UI_EventPopupTab_PurchaseDaily(event_version, true) -- params : event_version, is_full_popup

    -- 다르누스 인연 포인트 이벤트
    elseif (string.find(popup_key, 'event_daily_quest')) then
        local l_str = plSplit(popup_key, ';')
        local event_data = { banner = l_str[2], url = l_str[3] or ''}
        local struct_data = StructEventPopupTab(event_data)
        ui = UI_EventPopupTab_Banner(self, struct_data)

    -- 다르누스 인연 포인트 이벤트
    elseif (string.find(popup_key, 'collaboration')) then
        local l_str = plSplit(popup_key, ';')
        local event_data = { banner = l_str[2], url = l_str[3] or ''}
        local struct_data = StructEventPopupTab(event_data)
        ui = UI_EventPopupTab_Banner(self, struct_data)

    -- 아레나 참여 이벤트
    elseif (string.find(popup_key, 'event_arena_play')) then
        require('UI_EventArenaPlay')
        ui = UI_EventArenaPlay(popup_key)

    -- 게임 설치 유도 이벤트
    elseif (popup_key == 'event_crosspromotion') then
        ui = UI_CrossPromotion(popup_key)

	-- VIP 설문조사 
    elseif (string.find(popup_key, 'vip_survey')) then
        ui = UI_EventVIP(popup_key)

    elseif (string.find(popup_key, 'highbrow_vip')) then
        ui = UI_HighbrowVipPopup()

    elseif (self.m_targetUI) then
        ui = self.m_targetUI
    end
    
    if (ui) and (ui.root) then
        -- 패키지 UI 크기에 따라 풀팝업 UI 사이즈 변경후 추가
        do
            local l_children = ui.root:getChildren()
            local tar_menu = l_children[1]

            -- 최상위 메뉴 사이즈로 변경
            if (tar_menu) then
                local size = tar_menu:getContentSize()
                local width = size['width']
                local height = size['height']
                vars['mainNode']:setContentSize(cc.size(width, height))
            end
            vars['eventNode']:addChild(ui.root)
        end

        -- 풀팝업 기본은 버튼 클릭을 막음
        if (is_btn_lock) then
            local btn = ui.vars['bannerBtn']
            if (btn) then
                btn:setEnabled(false)
            end
        
            btn = ui.vars['clickBtn']
            if (btn) then
                btn:setEnabled(false)
            end
        end

    end

	self.m_innerUI = ui
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventFullPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventFullPopup:refresh()
end

-------------------------------------
-- function setBtnBlock
-------------------------------------
function UI_EventFullPopup:setBtnBlock()
	if (not self.m_innerUI) then
		return
	end

	local ui_vars = self.m_innerUI.vars
	if (not ui_vars) then
		return
	end

	local btn = ui_vars['bannerBtn']
	if (btn) then
		btn:setEnabled(false)
	end

	btn = ui_vars['clickBtn']
	if (btn) then
		btn:setEnabled(false)
	end
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_EventFullPopup:click_checkBtn()
    local vars = self.vars
    vars['checkSprite']:setVisible(true)

    if (self.m_check_cb) then
        self.m_check_cb()
    else  
        -- 다시보지않기
        local product_id = self.m_popupKey
        local save_key = tostring(product_id)
        g_settingData:applySettingData(true, 'event_full_popup', save_key)
    end
    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventFullPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function changeTitleSprite
-- @brief 구글 피쳐드 선정 기념. 구글 market -> '구글 피처드 선정 기념 ~', 아니면 '피처드 선정 기념 ~'
-- @brief UI_GoogleFeaturedContentChange를 상속받아 함수의 중복을 없앤다. (쓸모 없는 코드지만 이미 작업을 완료 하였으니 피처드 끝난 이후 커밋하여 코드를 깔끔하게 한다.)
-------------------------------------
function UI_EventFullPopup:changeTitleSprite(ui)
    if (ui['otherMarketSprite'] and ui['googleSprite']) then
        local market, os = GetMarketAndOS()
        local is_google = (market == 'google')
        ui['googleSprite']:setVisible(is_google)
        ui['otherMarketSprite']:setVisible(not is_google)
    end
end

--@CHECK
UI:checkCompileError(UI_EventFullPopup)
