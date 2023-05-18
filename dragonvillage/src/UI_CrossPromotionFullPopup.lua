local PARENT = UI

-------------------------------------
-- class UI_CrossPromotionFullPopup
-------------------------------------
UI_CrossPromotionFullPopup = class(PARENT,{
        m_popupKey = 'string',
		m_innerUI = 'UI',
        m_eventId = 'string',
        m_url = 'string',

        -- @jhakim 로비 풀 팝용이 아닌 용도, 나중에 클래스 분리할 거임
        m_targetUI = 'UI', -- 외부 UI를 이 형식에 맞추어 사용
        m_check_cb = 'function'
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
    local linkBtn = vars['linkBtn']
    if (linkBtn) then linkBtn:setVisible(false) end

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
-- function setBtnBlock
-------------------------------------
function UI_CrossPromotionFullPopup:setBtnBlock()
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
-- function update_reservation_timer
-------------------------------------
function UI_CrossPromotionFullPopup:update_reservation_timer(dt)
    local vars = self.vars
    local event_id = self.m_eventId
    local wait_time = g_userData:getReservationWaitTime(event_id)

    local seconds = g_userData:getAfterReservationSeconds(event_id)
    -- 사전예약 바로가기
    if vars['reservationLinkBtn'] == nil then
        return
    end

    vars['reservationRewardSprite']:setVisible(false)
    if g_userData:isReceivedAfterReservationReward(event_id) == true then
        vars['reservationLinkLabel']:setString(Str('받기 완료'))
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


-------------------------------------
-- function changeTitleSprite
-- @brief 구글 피쳐드 선정 기념. 구글 market -> '구글 피처드 선정 기념 ~', 아니면 '피처드 선정 기념 ~'
-- @brief UI_GoogleFeaturedContentChange를 상속받아 함수의 중복을 없앤다. (쓸모 없는 코드지만 이미 작업을 완료 하였으니 피처드 끝난 이후 커밋하여 코드를 깔끔하게 한다.)
-------------------------------------
function UI_CrossPromotionFullPopup:changeTitleSprite(ui)
    if (ui['otherMarketSprite'] and ui['googleSprite']) then
        local market, os = GetMarketAndOS()
        local is_google = (market == 'google')
        ui['googleSprite']:setVisible(is_google)
        ui['otherMarketSprite']:setVisible(not is_google)
    end
end

--@CHECK
UI:checkCompileError(UI_CrossPromotionFullPopup)
