local PARENT = UI

-------------------------------------
-- function init
-------------------------------------
UI_EventVIP = class(PARENT, {
    m_eventData = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVIP:init(event_data)

    if (type(event_data) ~= 'table') then
        self.m_eventData = g_eventData:getEventInByEventType(event_data)
    else
        self.m_eventData = event_data    
    end

    self:load('event_vip_survey.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function InitUI
-------------------------------------
function UI_EventVIP:initUI()
    local vars = self.vars

    local vip_status = g_userData:getVipInfo()
    local vip_str = ''

    if (vip_status == 1) then
        vip_str = Str('골드')
    elseif (vip_status == 2) then
        vip_str = 'VIP'
    elseif (vip_status == 3) then
        vip_str = 'VIP'
    end

    local origin_str = vars['titleLabel']:getString()
    vars['titleLabel']:setString(Str(origin_str, vip_str))

    local origin_str = vars['infoLabel1']:getString()
    vars['infoLabel1']:setString(Str(origin_str, vip_str))

    local origin_str = vars['infoLabel2']:getString()
    vars['infoLabel2']:setString(Str(origin_str, vip_str))
end

-------------------------------------
-- function InitButton
-------------------------------------
function UI_EventVIP:initButton()
    local vars = self.vars

    vars['surveyBtn']:registerScriptTapHandler(function() self:click_surveyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVIP:refresh()
    
end

-------------------------------------
-- function click_surveyBtn
-------------------------------------
function UI_EventVIP:click_surveyBtn()
    local url = 'https://docs.google.com/forms/d/e/1FAIpQLSffM6ga8eLlNiG7XFa_MKxG8qt2MRIYYcHuo-Lqu_Nl_shSqg/viewform?usp=pp_url&entry.1127202750={1}'
    local uid = g_userData:get('uid')

    g_settingData:applySettingData(self.m_eventData['start_date'], 'vip', 'survey')
    SDKManager:goToWeb(Str(url, uid))
end