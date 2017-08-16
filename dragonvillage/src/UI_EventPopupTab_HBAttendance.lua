local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_HBAttendance
-------------------------------------
UI_EventPopupTab_HBAttendance = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_HBAttendance:init()
    local vars = self:load('event_attendance_dv.ui')

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_HBAttendance:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_HBAttendance:initButton()
	local vars = self.vars
    vars['homepageBtn']:registerScriptTapHandler(function() self:click_homepageBtn() end)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_HBAttendance:onEnterTab()
    local vars = self.vars
end

-------------------------------------
-- function click_homepageBtn
-------------------------------------
function UI_EventPopupTab_HBAttendance:click_homepageBtn()
    -- 하이브로 연동 된 경우
    if (false) then
        SDKManager:goToWeb('http://www.dragonvillage.net')
    else
        SDKManager:goToWeb('https://www.perplelab.com')
    end
end