local PARENT = UI

-------------------------------------
-- class UI_CrossPromotionFullPopup
-------------------------------------
UI_CrossPromotionFullPopup = class(PARENT,{
        m_eventId = 'string',
        m_url = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CrossPromotionFullPopup:init()
    self.m_uiName = 'UI_CrossPromotionFullPopup'
    self.m_eventId = 'pre_reservation_dvc_install'
    self.m_url = 'https://app.adjust.com/1019cd1g'
    local vars = self:load('cross_promotion_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CrossPromotionFullPopup')

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
function UI_CrossPromotionFullPopup:initUI()
    local vars = self.vars
    if vars['reservationLinkBtn'] ~= nil then 
        self:update_reservation_timer()
        self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update_reservation_timer(dt) end, 0)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CrossPromotionFullPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    -- 사전 예약 버튼이 있으면 우선 적용
    if vars['reservationLinkBtn'] ~= nil then
        vars['reservationLinkBtn']:registerScriptTapHandler(function() self:click_reservationBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CrossPromotionFullPopup:refresh()
end

-------------------------------------
-- function update_reservation_timer
-------------------------------------
function UI_CrossPromotionFullPopup:update_reservation_timer(dt)
    local vars = self.vars
    local event_id = self.m_eventId
    local wait_time = g_userData:getReservationWaitTime(event_id)

    local seconds = g_userData:getAfterReservationSeconds(event_id)
    if vars['reservationLinkBtn'] == nil then
        return
    end

    vars['reservationRewardSprite']:setVisible(false)
    if g_userData:isReceivedAfterReservationReward(event_id) == true then
        vars['reservationLinkLabel']:setString(Str('받기 완료'))
    elseif seconds == 0 then
        vars['reservationLinkLabel']:setString(Str('다운로드'))        
        vars['reservationRewardSprite']:setVisible(true)

    elseif seconds > 0 and seconds < wait_time then
        vars['reservationLinkLabel']:setString(Str('다운로드 확인 중'))

    else
        vars['reservationLinkLabel']:setString(Str('보상 받기'))
        vars['reservationRewardSprite']:setVisible(true)
    end
end

-------------------------------------
-- function click_reservationBtn
-------------------------------------
function UI_CrossPromotionFullPopup:click_reservationBtn()
    local event_id = self.m_eventId

    if g_userData:isAvailableAfterReservationReward(event_id) == true then
        self:request_InstallReward()
        return
    end

    local seconds = g_userData:getAfterReservationSeconds(event_id)
    if seconds == 0 then
        g_userData:saveReservationTime(event_id)
    end

    local url = self.m_url
    if (url == '') then
        return
    end

    g_eventData:goToEventUrl(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_CrossPromotionFullPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function request_InstallReward
-- @brief
-------------------------------------
function UI_CrossPromotionFullPopup:request_InstallReward()
    -- 유저 ID
    local uid = g_userData:get('uid') 
    local event_id = self.m_eventId

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
UI:checkCompileError(UI_CrossPromotionFullPopup)
