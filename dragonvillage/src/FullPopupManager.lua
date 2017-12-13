FULL_POPUP_TYPE = {
    LOBBY = 1,          -- 로비 풀팝업
    AUTO_PICK = 2,      -- 매일매일 다이아 풀팝업
    START_PACK = 3,     -- 스타터 패키지 풀팝업
    LAUNCH_PACK = 4,    -- 런칭 패키지 풀팝업
    ALL_DIA_PACK = 'all_dia_package', -- 몽땅 다이아 패키지 풀팝업
    CAFE_ON = 'hatchry_cafe_on',    -- 부화소 진입시 네이버 카페 노출
	BP_NOTICE = 'bp_notice',		-- 밸런스 패치 안내
	REINFORCE_PACK = 'reinforce_package', -- 강화 포인트 패키지
}
-------------------------------------
-- class FullPopupManager
-------------------------------------
FullPopupManager = class({
        m_first_login = 'boolean',
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
    self.m_first_login = false
    self.m_title_to_lobby = false
end

-------------------------------------
-- function show
-------------------------------------
function FullPopupManager:show(type, show_func)
    -- 첫번째 튜토리얼 끝나지 않으면 조건부 풀팝업 노출 시키지 않음
    if (not g_tutorialData:isTutorialDone(TUTORIAL.FIRST_START)) then
        return
    end

    -- 로비 진입시 풀팝업
    if (type == FULL_POPUP_TYPE.LOBBY) and (self.m_title_to_lobby) then

        local l_list = g_eventData:getEventFullPopupList()
        for _, pid in ipairs(l_list) do
            local save_key = tostring(pid)
            local is_view = g_localData:get('event_full_popup', save_key) or false

            -- 봤던 기록 없는 이벤트 풀팝업 띄워줌
            if (not is_view) then
                show_func(pid)
            end                
        end

        self.m_title_to_lobby = false
    
    -- 매일 매일 다이아 풀팝업 (전투화면 진입시)
    -- 조건 : 구매하지 않은 유저 LV 3 이상
    elseif (type == FULL_POPUP_TYPE.AUTO_PICK) then
        local lv = g_userData:get('lv')
        local need_lv = 3
        local function cb_func()
            if not (g_subscriptionData:getSubscribedInfo()) then
                UI_SubscriptionPopup()
            end
        end
        local save_key = 'auto_pick'
        local is_view = g_localData:get('event_full_popup', save_key) or false
        if (lv >= need_lv) and (not is_view) then 
            g_subscriptionData:request_subscriptionInfo(cb_func)
            g_localData:applyLocalData(true, 'event_full_popup', save_key)
        end

    -- 스타터 패키지 풀팝업 (부화소 진입시)
    -- 조건 : 구매하지 않은 유저 LV 6 이상
    elseif (type == FULL_POPUP_TYPE.START_PACK) then
        local lv = g_userData:get('lv')
        local need_lv = 6
        local pid = 90041
        local save_key = 'start_pack_90041'
        local is_view = g_localData:get('event_full_popup', save_key) or false
        if (lv >= need_lv) and (not is_view) then 
            self:showFullPopup(pid)
            g_localData:applyLocalData(true, 'event_full_popup', save_key)
        end

    -- 런칭 패키지 풀팝업 (상점 진입시)
    -- 조건 : 구매하지 않은 유저 LV 10 이상
    elseif (type == FULL_POPUP_TYPE.LAUNCH_PACK) then
        local lv = g_userData:get('lv')
        local need_lv = 10
        local pid = 90042
        local save_key = 'launch_pack_90042'
        local is_view = g_localData:get('event_full_popup', save_key) or false
        if (lv >= need_lv) and (not is_view) then 
            self:showFullPopup(pid)
            g_localData:applyLocalData(true, 'event_full_popup', save_key)
        end
    
    -- 몽땅 다이아 패키지
    -- 조건 : 기간 체크 함
    elseif (type == FULL_POPUP_TYPE.ALL_DIA_PACK) then
        local pid = 90046
        local save_key = type
        local is_view = g_localData:get('event_full_popup', save_key) or false
        local is_exist = g_shopDataNew:isExist('package', pid)
        if is_exist and (not is_view) then 
            self:showFullPopup(pid)
            g_localData:applyLocalData(true, 'event_full_popup', save_key)
        end

    -- 부화소 네이버 카페 SDK -- 암 오르페우스를 주는 이벤트를 유저들에게 한번 더 알리기 위해서
    elseif (type == FULL_POPUP_TYPE.CAFE_ON) then
        local save_key = type
        local is_view = g_localData:get('event_full_popup', save_key) or false
        if (not is_view) then
            NaverCafeManager:naverCafeStart(0)
            g_localData:applyLocalData(true, 'event_full_popup', save_key)
        end

	-- 밸런스 패치 안내 팝업
    elseif (type == FULL_POPUP_TYPE.BP_NOTICE) then
        local save_key = type
        local is_view = g_localData:get('event_full_popup', save_key) or false
        if (not is_view) then
			local banner_res = g_eventData:getTargetEventFullPopupRes(type)
			if (banner_res) then
				self:showFullPopup(banner_res)
				g_localData:applyLocalData(true, 'event_full_popup', save_key)
			end
        end

    -- 강화 패키지 풀팝업 (드래곤 관리 진입 시)
    -- 조건 : 구매하지 않은 유저 LV 30 이상
    elseif (type == FULL_POPUP_TYPE.REINFORCE_PACK) then
        local lv = g_userData:get('lv')
        local need_lv = 30
        local pid = 90053
        local save_key = type
        local is_view = g_localData:get('event_full_popup', save_key) or false
        if (lv >= need_lv) and (not is_view) then 
            self:showFullPopup(pid)
            g_localData:applyLocalData(true, 'event_full_popup', save_key)
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
-- function initLoacalData
-------------------------------------
function FullPopupManager:initLoacalData()
    g_localData:lockSaveData()
    
    local list = g_localData:get('event_full_popup') or {}
    for k, v in pairs(list) do
        g_localData:applyLocalData(false, 'event_full_popup', k)
    end
    g_localData:unlockSaveData()
end

-------------------------------------
-- function setFirstLogin
-------------------------------------
function FullPopupManager:setFirstLogin(bool)
    self.m_first_login = bool

    -- 로컬데이터 초기화 팝업 보여줄때가 아닌 최초 로그인으로 변경
    if (self.m_first_login == true) then
        self:initLoacalData()
    end
end

-------------------------------------
-- function isFirstLogin
-------------------------------------
function FullPopupManager:isFirstLogin()
    return self.m_first_login 
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





