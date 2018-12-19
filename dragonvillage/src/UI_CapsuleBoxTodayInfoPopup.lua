local PARENT = UI

-------------------------------------
-- class UI_CapsuleBoxTodayInfoPopup
-------------------------------------
UI_CapsuleBoxTodayInfoPopup = class(PARENT,{
		
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:init()
	local vars = self:load('event_capsule_box_schedule.ui')
	UIManager:open(self, UIManager.POPUP)

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CapsuleBoxTodayInfoPopup')

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:initUI()
	local vars = self.vars
    local capsulebox_data = g_capsuleBoxData:getCapsuleBoxInfo()
    vars['rotationTitleLabel']:setString(capsulebox_data['first']:getCapsuleTitle())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:initButton()
	local vars = self.vars
	
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CapsuleBoxTodayInfoPopup:refresh()
	local vars = self.vars

end


--@CHECK
UI:checkCompileError(UI_CapsuleBoxTodayInfoPopup)
