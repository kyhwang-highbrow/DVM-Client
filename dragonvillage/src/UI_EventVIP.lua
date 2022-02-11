local PARENT = UI

-------------------------------------
-- function init
-------------------------------------
UI_EventVIP = class(PARENT, {
    m_eventData = '',

    m_vipStatus = 'number',
    m_vipKey = 'string',
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

    local res = self.m_eventData['banner']

    if (res == nil) then return end

    self:load(res)

    local event_type = self.m_eventData['event_type']
    local splitted_str = pl.stringx.split(event_type, 'vip_survey_')

    if splitted_str then
        local key = splitted_str[2]

        self.m_vipKey = key
        self.m_vipStatus = g_userData:getVipInfo(key)
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function InitUI
-------------------------------------
function UI_EventVIP:initUI()
    local vars = self.vars

    local vip_status = self.m_vipStatus
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
-- function onEnterTab
-------------------------------------
function UI_EventVIP:onEnterTab()

end

-------------------------------------
-- function click_surveyBtn
-------------------------------------
function UI_EventVIP:click_surveyBtn()
    local url = self.m_eventData['url']
    local uid = g_userData:get('uid')
    
    local year = self.m_vipKey
    local event_type = self.m_eventData['event_type']

    g_settingData:applySettingData(self.m_eventData['start_date'], 'vip', event_type)
    SDKManager:goToWeb(Str(url, uid))
end