local PARENT = UI

-------------------------------------
-- Class UI_NewServerEventRewardPopup
-------------------------------------
UI_NewServerEventRewardPopup = class(PARENT, {

})


-------------------------------------
-- function init
-------------------------------------
function UI_NewServerEventRewardPopup:init()

    local vars = self:load('event_reward_info_popup.ui')

    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_NewServerEventRewardPopup')
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    self:doActionReset()
    self:doAction()


    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_NewServerEventRewardPopup:initUI()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    local reward_info = g_eventIncarnationOfSinsData:getNewServerEventReward()
    local my_rank = g_eventIncarnationOfSinsData.m_eventRankInfo
    
    vars['titleLabel']:setString(Str('테이머님 {1}위 달성을 축하드립니다', my_rank))
    vars['rankLabel']:setString(Str('{1}위 경품', my_rank))

    for rank_info,v in pairs(reward_info) do
        if rank_info == my_rank then
            vars['rewardLabel']:setString(Str('{1}', v))
        end
    end
end



-------------------------------------
-- function initButton
-------------------------------------
function UI_NewServerEventRewardPopup:initButton()
    local vars = self.vars

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
    
end



-------------------------------------
-- function refresh
-------------------------------------
function UI_NewServerEventRewardPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function update
-------------------------------------
function UI_NewServerEventRewardPopup:update(dt)
    local vars = self.vars

    local event_id = 'event_incarnation_of_sins_reward'
    local end_date = g_hotTimeData:getEventEndTime(event_id)
    local remain_date = g_hotTimeData:getEventRemainTime(event_id)

    local remain_time = ServerTime:getInstance():timestampSecToTimeDesc(remain_date, true)
    
    vars['timeLabel']:setString(Str('문의 접수 기간 {1} 남음', remain_time))
end

-------------------------------------
-- function click_linkBtn
-------------------------------------
function UI_NewServerEventRewardPopup:click_linkBtn()
    local is_not_global = (g_localData:getLang() == 'ko')
    local access_key = (is_not_global and 'a93d04e5bb650d54') or '88aa568a2ff202f6'
    local url_param = 'access_key=' .. access_key

    local secret_key = (is_not_global and '61313ed352410a4586c3e9d956a6cf40') or '1426e06449ea8a3ae5f0370fb7e77825'
    url_param = url_param .. '&secret_key=' .. secret_key

    local brand_key = (is_not_global and 'dvm') or 'dvm_g'
    url_param = url_param .. '&brand_key1=' .. brand_key

    local user_name = g_userData:get('nick')
    if user_name then
        url_param = url_param .. '&userName=' .. user_name
    end

    local market, os = GetMarketAndOS()
    if os then
        url_param = url_param .. '&operatingSystem=' .. os
    end

    local device = ErrorTracker:getDevice()
    if device then
        url_param = url_param .. '&deviceModel=' .. device
    end

    local uid = g_userData:get('uid')
    local server = CppFunctions:getTargetServer()
    if uid then
        url_param = url_param .. '&extra_field1=' .. uid
    end
    if server then
        url_param = url_param .. '&extra_field2=' .. server
    end

    if market then
        url_param = url_param .. '&extra_field3=' .. market
    end

    SDKManager:goToWeb('https://highbrow.oqupie.com/portals/finder?' .. url_param)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_NewServerEventRewardPopup:click_infoBtn()
    local event_type = 'event_newserver'
    
    local popup_ui = g_fullPopupManager:showFullPopup(event_type)
    local event_ui = popup_ui.m_innerUI
    if event_ui.vars['linkBtn'] then
        event_ui.vars['linkBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_NewServerEventRewardPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_NewServerEventRewardPopup:click_okBtn()
    local vars = self.vars


end














------------------------------------
-- Class UI_ButtonNewServerEventReward
-------------------------------------
UI_ButtonNewServerEventReward = class(UI_ManagedButton, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonNewServerEventReward:init()
    self:load('button_event_reward_info.ui')

    self:initUI()
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ButtonNewServerEventReward:initUI()
    local vars = self.vars

    vars['rewardLabel']:setString(Str('당첨자 안내 팝업'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ButtonNewServerEventReward:initButton()    
    self.vars['rewardBtn']:registerScriptTapHandler(function() self:click_btn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ButtonNewServerEventReward:refresh()

end

-------------------------------------
-- function click_btn
-------------------------------------
function UI_ButtonNewServerEventReward:click_btn()
    UI_NewServerEventRewardPopup()
end

-------------------------------------
-- function click_btn
-------------------------------------
function UI_ButtonNewServerEventReward:update(dt)

end
