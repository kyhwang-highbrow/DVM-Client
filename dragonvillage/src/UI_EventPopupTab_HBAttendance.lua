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
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_HBAttendance:onEnterTab()
    local vars = self.vars
end