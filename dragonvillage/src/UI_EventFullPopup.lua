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
        local event_data = { banner = l_str[2], url = l_str[3] or ''}
        local struct_data = StructEventPopupTab(event_data)
        ui = UI_EventPopupTab_Banner(self, struct_data)

    -- 확률업 드래곤 배너
    elseif (popup_key == 'dragon_chance_up') then
        ui = UI_DragonChanceUp()

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
		local key = l_str[2]
        -- 기본출석 
		if (key == 'normal') then
			ui = UI_EventPopupTab_Attendance()
        -- 이벤트 출석 (오픈, 신규, 복귀)
		elseif (key == 'open_event' or key == 'newbie' or key == 'comeback') then
			ui = UI_EventPopupTab_EventAttendance(key)
        -- 1주년 스페셜 7일 출석
        elseif (key == '1st_event') then
            ui = UI_EventPopupTab_EventAttendance1st(key)
        end

    -- 패키지 상품 
    elseif string.find(popup_key, 'package') then     
        local package_name = popup_key
        local is_popup = false
        ui = PackageManager:getTargetUI(package_name, is_popup)

        if (not ui) then
            -- 이벤트 프로덕트 정보 없을 경우 비활성화라고 생각하고 닫아줌 (주말 패키지)
            self:close()
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

    -- 카페 플러그 이벤트 (banner와 똑같지만 노출 처리 조건 때문에 타입 추가)
    elseif (string.find(popup_key, 'event_cafe')) then
        local l_str = plSplit(popup_key, ':')
        local event_data = { banner = l_str[2], url = l_str[3] or ''}
        local struct_data = StructEventPopupTab(event_data)
        ui = UI_EventPopupTab_Banner(self, struct_data)
        is_btn_lock = false

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

    -- 만드라고라의 모험 이벤트 
    --elseif string.find(popup_key, 'event_mandraquest') then
        --local inner_ui = UI_EventMandragoraQuest()
        --local temp_struct_data = StructEventPopupTab({event_type = 'event_mandraquest'})
        --ui = UI_EventPopupTab_Scroll(self, temp_struct_data, inner_ui)

	-- 1주년 이벤트 : 복귀 유저 환영 이벤트
	elseif (popup_key == 'event_1st_comeback' or popup_key == 'event_global_1st_comeback') then
		ui = UI_Event1stComeback()

    -- 누적 결제 보상 이벤트
    elseif pl.stringx.startswith(popup_key, 'purchase_point') then
		local l_str = plSplit(popup_key, ';')
        local event_version = l_str[2]
        ui = UI_EventPopupTab_PurchasePoint(event_version)
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

--@CHECK
UI:checkCompileError(UI_EventFullPopup)
