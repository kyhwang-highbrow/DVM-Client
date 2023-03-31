FULL_POPUP_TYPE = {
    LOBBY = 1,          -- 로비 풀팝업
	ATTENDANCE = 'atdc',-- 출석 풀팝업
    
	AUTO_PICK = 2,      -- 매일매일 다이아 풀팝업
    START_PACK = 3,     -- 스타터 패키지 풀팝업
    LAUNCH_PACK = 4,    -- 런칭 패키지 풀팝업
    ALL_DIA_PACK = 'all_dia_package', -- 몽땅 다이아 패키지 풀팝업
	REINFORCE_PACK = 'reinforce_package', -- 강화 포인트 패키지
    
	ATTR_TOWER = 'attr_tower', -- 시험의 탑 안내
    SHOP_DAILY = 'shop_daily',

    EVENT_WELCOME_NEWBIE = 'event_welcome_newbie',

    INGAME_NOTICE = 'lobby_ingame_notice',

    LOBBY_BY_CONDITION = 5, -- 코드로 조건 체크하는 로비 풀팝업, table_lobby_popup 에 있는 항목들
    EMERGENCY_PROMOTION = 6, -- 정말 긴급하고 중요한 팝업인 경우(ui_priority -1000 으로 설정된 하나만)
}
-------------------------------------
-- class FullPopupManager
-------------------------------------
FullPopupManager = class({
        m_title_to_lobby = 'boolean',
    })

-------------------------------------
-- function initInstance
-------------------------------------
function FullPopupManager:initInstance()
    if g_fullPopupManager then
        return
    end

    g_fullPopupManager = FullPopupManager()
end

-------------------------------------
-- function init
-------------------------------------
function FullPopupManager:init()
    self.m_title_to_lobby = false
end

-------------------------------------
-- function show
-------------------------------------
function FullPopupManager:show(type, show_func)

    -- 로비 진입시 풀팝업
    if (type == FULL_POPUP_TYPE.LOBBY) and (self.m_title_to_lobby) then

        local l_list = g_eventData:getEventFullPopupList()
        for _, pid in ipairs(l_list) do
            local save_key = tostring(pid)
            local is_view = g_settingData:get('event_full_popup', save_key) or false

            -- 봤던 기록 없는 이벤트 풀팝업 띄워줌
            if (not is_view) then
                show_func(pid)
            end                
        end

    elseif (type == FULL_POPUP_TYPE.EMERGENCY_PROMOTION) then
        
        local l_list = g_eventData:getEventFullPopupList(true)
        for _, pid in ipairs(l_list) do
            local save_key = tostring(pid)
            local is_view = g_settingData:get('event_full_popup', save_key) or false

            -- 봤던 기록 없는 이벤트 풀팝업 띄워줌
            if (not is_view) then
                show_func(pid)
            end
        end

  
    -- 출석 보상 있을 시 출석 팝업
    elseif (type == FULL_POPUP_TYPE.ATTENDANCE) then
		for i, v in ipairs(g_attendanceData:getAttendanceDataList()) do
			    local atdc_type = v.attendance_type
                local atdc_category = v.category
                local atdc_id = v.atd_id
            if (v:hasReward()) then
				show_func('attendance_'..atdc_type..';'..atdc_category .. ';' .. atdc_id)
            -- 금일 보상을 이미 받은 이벤트
			else
				show_func('attendance_'..atdc_type..';'..atdc_category .. ';' .. atdc_id)
			end
		end

    -- 일일상점 (상점 진입시)
    -- 조건 : 유저 LV 10 이상
    elseif (type == FULL_POPUP_TYPE.SHOP_DAILY) then
        local lv = g_userData:get('lv')
        local need_lv = 10
        local save_key = 'shop_daily'
        local function cb_func()
            g_settingData:applySettingData(true, 'event_full_popup', save_key)
        end

        local is_view = g_settingData:get('event_full_popup', save_key) or false

        -- 모두 구매한 유저는 노출하지 않음
        local is_buy_all = true
        local l_item_list = g_shopDataNew:getProductList('daily')
        for _, struct_product in pairs(l_item_list) do
            if (struct_product:isItBuyable()) then
                is_buy_all = false
                break
            end
        end
        
        if (lv >= need_lv) and (not is_view) and (not is_buy_all) then 
            local is_popup = true
            local ui = UI_ShopDaily(is_popup)
            ui:setCloseCB(cb_func)
        end

    -- 로비 진입시 (코드로 조건 체크하는) 풀팝업
    elseif (type == FULL_POPUP_TYPE.LOBBY_BY_CONDITION) then

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
        
        for i, data in ipairs(l_lobby_popup) do
            local popup_key = self:getVaildLobbyPopupKey(data) -- t_lobby_popup 관련 코드로 짜여진 조건들 검사
            if (popup_key) then
                show_func(popup_key)
            end
        end

    -- 신규 유저 환영 이벤트
    elseif (type == FULL_POPUP_TYPE.EVENT_WELCOME_NEWBIE) then
        -- 리워드 받을 수 있는 경우에만 풀 팝업 노출
        if (g_eventData:isPossibleToGetWelcomeNewbieReward()) then
            show_func(FULL_POPUP_TYPE.EVENT_WELCOME_NEWBIE)
        end
    -- 인게임 공지 팝업
    elseif (type == FULL_POPUP_TYPE.INGAME_NOTICE) then
        if show_func then show_func() end
    end

    
end

-------------------------------------
-- function showFullPopup
-------------------------------------
function FullPopupManager:showFullPopup(pid)
    local ui = UI_EventFullPopup(pid)
    ui:openEventFullPopup()
    ui.vars['checkBtn']:setVisible(false)
    ui.vars['checkLabel']:setVisible(false)
    ui.vars['mainNode']:setPositionY(0)

    return ui
end

-------------------------------------
-- function setTitleToLobby
-------------------------------------
function FullPopupManager:setTitleToLobby(bool)
    self.m_title_to_lobby = bool
end

-------------------------------------
-- function isTitleToLobby
-------------------------------------
function FullPopupManager:isTitleToLobby()
    return self.m_title_to_lobby 
end

-------------------------------------
-- function getVaildLobbyPopupKey
-------------------------------------
function FullPopupManager:getVaildLobbyPopupKey(data)
    -- 해당 클래스가 load되어 있는지 확인
    local lua_class = data['lua_class']
    if package.loaded[lua_class] then
    
        -- 해당 클래스 require통해서 얻어옴
        local lobby_guide_class = require(lua_class)
        if lobby_guide_class then   
            -- 인스턴스 생성
            local pointer = lobby_guide_class(data)
    
            -- 조건 확인
            pointer:checkCondition()
    
            -- 안내가 유효할 경우
            if (pointer:isActiveGuide() == true) then
                local popup_key = pointer:getPopupKey()
                if popup_key then
                    pointer:startGuide()
    
                    -- 하루동안 보지 않기 풀린 팡업인지 판단
                    local is_view = g_settingData:get('event_full_popup', popup_key) or false

                    -- 봤던 기록 없는 이벤트 풀팝업 띄워줌
                    if (not is_view) then
                        return popup_key
                    end
                end
            end
            pointer = nil
        end
    else
        cclog('## 클래스가 존재하지 않음 lua_class : ' .. tostring(lua_class))
    end

    return nil
end





