-- 확률업

local PARENT = UI

-------------------------------------
-- class UI_CrossPromotion
-------------------------------------
UI_CrossPromotion = class(PARENT,{
        m_eventData = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CrossPromotion:init(event_type)
    local event_list = g_eventData:getEventPopupTabList()
    local event_data = event_list[event_type]

    -- 확률업에 지정된 드래곤 수에 따라 사용하는 ui와 초기화 함수가 다름
    local ui_name = 'event_cross_promotion_rise.ui'

    if (event_data and event_data.m_eventData and event_data.m_eventData['banner']) then
        ui_name = event_data.m_eventData['banner']
        self.m_eventData = event_data.m_eventData
    else
        cclog('## UI_CrossPromotion :: ui데이터가 없으니 테이블깞을 확인하시오')
    end

    self:load(ui_name)

    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif 확률업 드래곤이 2개가 적용되었을 경우 UI 초기화
-------------------------------------
function UI_CrossPromotion:initUI()
    local vars = self.vars
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_CrossPromotion:initButton()
    local vars = self.vars
    local linkBtn = vars['linkBtn']

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

    -- 버전 체크 후 통과
    if (getAppVerNum() <= 1003000) then
        msg = '새로운 버전의 게임이 업데이트 되었습니다.\n스토어를 통해 업데이트를 하기바랍니다.'
        MakeNetworkPopup(POPUP_TYPE.YES_NO, msg, function() SDKManager:goToAppStore() end, function() end)
        return
    end

    local function success_cb(ret)
        self:refresh()

        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)
    end

    local function fail_cb(ret)

    end

    self:request_InstallReward(success_cb, fail_cb)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_CrossPromotion:onEnterTab()

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

    if (self.m_eventData and self.m_eventData['event_id']) then
        local event_id = self.m_eventData['event_id']
        local is_link_btn_active = true

        for _, event_name in ipairs(cross_event_data) do
            if (event_name == event_id) then
                is_link_btn_active = false
                break
            end
        end

        if (vars['linkBtn']) then 
            vars['linkBtn']:setEnabled(is_link_btn_active)
        end
    end
end


-------------------------------------
-- function request_InstallReward
-- @brief
-------------------------------------
function UI_CrossPromotion:request_InstallReward(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid') 
    local event_id = self.m_eventData['event_id']
    local event_type = self.m_eventData['event_type']

    -- 성공 콜백
    local function success_cb(ret)
        local valueTable = {}
        if (ret['cross_promotion_type']) then
            local cross_event_data = g_serverData:get('user', 'cross_promotion_event')
            if (cross_event_data == nil) then cross_event_data = {} end
            
            local refresh_table = {ret['cross_promotion_type']}

            for _, event_name in ipairs(cross_event_data) do
                if (event_name ~= ret['cross_promotion_type']) then
                    table.insert(refresh_table, event_name)
                end
            end

            g_serverData:applyServerData(refresh_table, 'user', 'cross_promotion_event')
        end

        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        if finish_cb then finish_cb(ret) end
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
