-------------------------------------
-- function init_alarmTab
-------------------------------------
function UI_Setting:init_alarmTab()
    local vars = self.vars

    -- 전체 알림
    vars['allOnBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
    vars['allOffBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)

    -- 게임 알림
    vars['gameAlarmOnBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
    vars['gameAlarmOffBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)

    -- 이벤트 알림
    vars['eventOnBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
    vars['eventOffBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)

    -- 심야 시간 알림
    vars['nightOnBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
    vars['nightOffBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('준비 중입니다.')) end)
end