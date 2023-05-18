-- 확률업

local PARENT = UI

-------------------------------------
-- class UI_CrossPromotion
-------------------------------------
UI_CrossPromotion = class(PARENT,{
        m_eventData = 'map',
        m_eventId = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CrossPromotion:init(event_type)
    local event_list = g_eventData:getEventPopupTabList(true)
    local event_data = event_list[event_type]
    local ui_name
    -- 확률업에 지정된 드래곤 수에 따라 사용하는 ui와 초기화 함수가 다름
    if (event_data and event_data.m_eventData and event_data.m_eventData['banner']) then
        ui_name = event_data.m_eventData['banner']
        self.m_eventData = event_data.m_eventData
        self.m_eventId = event_data:getEventID()
    end

    if (ui_name == nil) then return end

    self:load(ui_name)
    self:initUI()
    self:initButton()
    self:refresh()

    local vars = self.vars
    if vars['reservationLinkBtn'] ~= nil then 
        self:update_reservation_timer()
        self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update_reservation_timer(dt) end, 0)
    end
end

-------------------------------------
-- function initUI
-- @breif 확률업 드래곤이 2개가 적용되었을 경우 UI 초기화
-------------------------------------
function UI_CrossPromotion:initUI()
    local vars = self.vars
    local linkBtn = vars['linkBtn']
    if (linkBtn) then linkBtn:setVisible(false) end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CrossPromotion:initButton()
    local vars = self.vars
    local linkBtn = vars['linkBtn']

    -- 사전 예약 버튼이 있으면 우선 적용
    if vars['reservationLinkBtn'] ~= nil then
        vars['reservationLinkBtn']:registerScriptTapHandler(function() self:click_reservationBtn() end)
    end

    if (linkBtn) then 
        linkBtn:registerScriptTapHandler(function() self:click_linkBtn() end)
    end
end

-------------------------------------
-- function click_linkBtn
-- @brief
-------------------------------------
function UI_CrossPromotion:click_linkBtn()
    local vars = self.vars
    local linkBtn = vars['linkBtn']
    local isAndroid = CppFunctionsClass:isAndroid()
    if (not linkBtn) then return end
    if (not IS_DEV_SERVER() and not isAndroid) then return end
    if (not self.m_eventData) then return end

    local msg = ''

    local target_app_version = self.m_eventData['target_app_version']

    -- 버전 체크 후 통과
    if target_app_version and (getAppVerNum() < target_app_version) then
        msg = '이벤트에 참여하기 위해 업데이트가 필요합니다.\n지금 업데이트 하시겠습니까?'
        MakeNetworkPopup(POPUP_TYPE.YES_NO, msg, function() SDKManager:goToAppStore() end, function() end)
        return
    end

    -- 마지막으로 깔았는지 확인
    local function confirm_function(result)
        local is_installed = (result ~= nil) and (tonumber(result) == 1)
    
        if (not is_installed) then
            local url = self.m_eventData['url']

            if (url ~= nil) and (url ~= '') then
                SDKManager:goToWeb(url)
            end
            return
        end

        local cross_event_data = g_serverData:get('user', 'cross_promotion_event')

        if (cross_event_data == nil) then
            cross_event_data = {}
        end

        if (self.m_eventData and self.m_eventData['event_id']) then
            local event_id = self.m_eventData['event_id']
            local rewarded = false

            for _, event_name in ipairs(cross_event_data) do
                if (event_name == event_id) then
                    rewarded = true
                    break
                end
            end

            if (not rewarded) then self:request_InstallReward() end
        end
    end

    if CppFunctions:isAndroid() or CppFunctions:isIos() then
        local package_name = self.m_eventData['package_name']
        if (package_name ~= nil) and (package_name ~= '') then
            PerpSocial:SDKEvent('isInstalled', package_name, package_name, confirm_function)
        end
    else
        confirm_function(1)
    end
end

-------------------------------------
-- function click_reservationBtn
-------------------------------------
function UI_CrossPromotion:click_reservationBtn()
    local event_id = self.m_eventData['event_id']

    if g_userData:isAvailableAfterReservationReward(event_id) == true then
        self:request_InstallReward()
        return
    end

    local seconds = g_userData:getAfterReservationSeconds(event_id)
    if seconds == 0 then
        g_userData:saveReservationTime(event_id)
    end

    local url = self.m_eventData['url']
    if (url == '') then
        return
    end

    g_eventData:goToEventUrl(url)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_CrossPromotion:onEnterTab()

end

-------------------------------------
-- function update_reservation_timer
-------------------------------------
function UI_CrossPromotion:update_reservation_timer(dt)
    local vars = self.vars
    local event_id = self.m_eventData['event_id']
    local wait_time = g_userData:getReservationWaitTime(event_id)

    local seconds = g_userData:getAfterReservationSeconds(event_id)
    -- 사전예약 바로가기
    if vars['reservationLinkBtn'] == nil then
        return
    end

    vars['reservationRewardSprite']:setVisible(false)
    if g_userData:isReceivedAfterReservationReward(event_id) == true then
        vars['reservationLinkLabel']:setString(Str('보상 수령 완료'))
    elseif seconds == 0 then

        if string.find(event_id, '_install') ~= nil then
            vars['reservationLinkLabel']:setString(Str('다운로드'))
        else
            vars['reservationLinkLabel']:setString(Str('사전예약하러 가기'))
        end
        
        vars['reservationRewardSprite']:setVisible(true)
    elseif seconds > 0 and seconds < wait_time then
        
        if string.find(event_id, '_install') ~= nil then
            vars['reservationLinkLabel']:setString(Str('다운로드 확인 중'))
        else
            vars['reservationLinkLabel']:setString(Str('보상 확인 중..'))
        end
    else
        vars['reservationLinkLabel']:setString(Str('보상 받기'))
        vars['reservationRewardSprite']:setVisible(true)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CrossPromotion:refresh()
    local vars = self.vars

    local cross_event_data = g_serverData:get('user', 'cross_promotion_event')

    if (cross_event_data == nil) then
        cross_event_data = {}
    end

    local is_link_btn_active = true

    if (self.m_eventData and self.m_eventData['event_id']) then
        local event_id = self.m_eventData['event_id']

        for _, event_name in ipairs(cross_event_data) do
            if (event_name == event_id) then
                is_link_btn_active = false
                break
            end
        end

    else
        is_link_btn_active = false
        
    end

    if (vars['linkBtn']) then 
        vars['linkBtn']:setEnabled(is_link_btn_active)
    end

    -- 마지막으로 깔았는지 확인
    local function confirm_function(result)
        local is_installed = 1 == tonumber(result)
        local linkBtn = vars['linkBtn']

        if (linkBtn) then linkBtn:setVisible(true) end

        -- 보상 받기
        local btnStr

        if (not is_installed) then
            btnStr = Str('게임 다운로드')
        elseif (is_installed) then
            btnStr = Str('보상 받기')
        end

        if (vars['stateLabel']) then vars['stateLabel']:setString(btnStr) end

    end

    if (not is_link_btn_active) then
        if vars['linkBtn'] ~= nil then
            vars['linkBtn']:setVisible(true)
        end
        if (vars['stateLabel']) then vars['stateLabel']:setString(Str('수령 완료')) end
        
    elseif CppFunctions:isAndroid() or CppFunctions:isIos() then
        local package_name = self.m_eventData['package_name']
        if (package_name ~= nil) and (package_name ~= '') then
            PerpSocial:SDKEvent('isInstalled', package_name, package_name, confirm_function)
        end
    else
        confirm_function(1)
    end
end


-------------------------------------
-- function request_InstallReward
-- @brief
-------------------------------------
function UI_CrossPromotion:request_InstallReward()
    -- 유저 ID
    local uid = g_userData:get('uid') 
    local event_id = self.m_eventData['event_id']

    -- 성공 콜백
    local function success_cb(ret)
        local valueTable = {}
        if (ret['cross_promotion_id']) then
            local cross_event_data = g_serverData:get('user', 'cross_promotion_event')
            if (cross_event_data == nil) then cross_event_data = {} end
            
            local refresh_table = {ret['cross_promotion_id']}

            for _, event_name in ipairs(cross_event_data) do
                if (event_name ~= ret['cross_promotion_id']) then
                    table.insert(refresh_table, event_name)
                end
            end

            g_serverData:applyServerData(refresh_table, 'user', 'cross_promotion_event')
        end

        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        self:refresh()

        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
    end

    local function fail_cb(ret)

    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/event_get_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('event_id', event_id)
    ui_network:setParam('event_type', event_type)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


--@CHECK
UI:checkCompileError(UI_CrossPromotion)
