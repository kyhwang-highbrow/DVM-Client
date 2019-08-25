local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversary_rewardPopup
-------------------------------------
UI_EventThankAnniversary_rewardPopup = class(PARENT, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:init(reward_num)
    local vars = self:load('event_thanks_anniversary_popup_02.ui')
	UIManager:open(self, UIManager.POPUP)
   
	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_QuestPopup')

	self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:initButton()
    local vars = self.vars
	vars['okBtn']:registerScriptTapHandler(function() self:close(1) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary_rewardPopup:refresh()

end
