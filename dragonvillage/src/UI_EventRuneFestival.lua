local PARENT = UI

-------------------------------------
-- class UI_EventRuneFestival
-------------------------------------
UI_EventRuneFestival = class(PARENT,{
        
    })


-------------------------------------
-- function init
-------------------------------------
function UI_EventRuneFestival:init()
    local vars = self:load('event_rune_festival.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventRuneFestival:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventRuneFestival:initButton()
    local vars = self.vars
    
    -- 스테이지 진입 버튼 (난이도별)
    vars['normalStartBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('구현 중')) end)
    vars['hardlStartBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('구현 중')) end)
    vars['helllStartBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('구현 중')) end)
    vars['hellfireStartBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('구현 중')) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventRuneFestival:refresh()
    local vars = self.vars
    
    -- 이벤트 종료까지 {1} 남음
    if vars['timeLabel'] then
        local remain_time_text = g_eventRuneFestival:getStatusText()
        vars['timeLabel']:setString(remain_time_text)
    end

    -- 일일 최대 {1}/{2}개 사용 가능
    if vars['obtainLabel'] then
        local str = g_eventRuneFestival:getRuneFestivalStaminaText()
        vars['obtainLabel']:setString(str)
    end 
end