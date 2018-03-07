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

        self.m_title_to_lobby = false
  
    -- 출석 보상 있을 시 출석 팝업
    elseif (type == FULL_POPUP_TYPE.ATTENDANCE) then
		for i, v in ipairs(g_attendanceData:getAttendanceDataList()) do
			if (v:hasReward()) then
				local atdc_type = v.attendance_type
                local atdc_category = v.category
				show_func('attendance_'..atdc_type..';'..atdc_category)
			end
		end

    -- 매일 매일 다이아 풀팝업 (전투화면 진입시)
    -- 조건 : 구매하지 않은 유저 LV 10 이상
    elseif (type == FULL_POPUP_TYPE.AUTO_PICK) then
        local lv = g_userData:get('lv')
        local need_lv = 10
        local save_key = 'auto_pick'
        local function cb_func()
            if not (g_subscriptionData:getSubscribedInfo()) then
                g_subscriptionData:openSubscriptionPopup()
                g_settingData:applySettingData(true, 'event_full_popup', save_key)
            end
        end

        local is_view = g_settingData:get('event_full_popup', save_key) or false
        if (lv >= need_lv) and (not is_view) then 
            g_subscriptionData:request_subscriptionInfo(cb_func)
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
        if (lv >= need_lv) and (not is_view) then 
            local is_popup = true
            local ui = UI_ShopDaily(is_popup)
            ui:setCloseCB(cb_func)
        end
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





