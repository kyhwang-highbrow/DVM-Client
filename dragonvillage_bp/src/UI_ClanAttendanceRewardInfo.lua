local PARENT = UI

-------------------------------------
-- class UI_ClanAttendanceRewardInfo
-------------------------------------
UI_ClanAttendanceRewardInfo = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanAttendanceRewardInfo:init()
    local vars = self:load('clan_attendance_reward.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanAttendanceRewardInfo'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanAttendanceRewardInfo')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanAttendanceRewardInfo:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanAttendanceRewardInfo:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanAttendanceRewardInfo:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanAttendanceRewardInfo:refresh()
    local vars = self.vars
end