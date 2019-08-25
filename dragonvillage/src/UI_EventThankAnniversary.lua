local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversary
-------------------------------------
UI_EventThankAnniversary = class(PARENT, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversary:init(content_type, list_cnt)
    local vars = self:load('event_thanks_anniversary.ui')

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_QuestPopup')

    self:initUI()
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventThankAnniversary:initUI()
    local vars = self.vars
    local user_state = 1 -- 1: 신규 2 : 복귀 3: 기존
    vars['userLabel1']:setVisible(false)
    vars['userLabel2']:setVisible(false)
    vars['userLabel3']:setVisible(false)
    
    if (user_state == 1) then
        vars['userLabel1']:setVisible(true)
    elseif (user_state == 2) then
        vars['userLabel2']:setVisible(true)
    else
        vars['userLabel3']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversary:initButton()
    local vars = self.vars
    vars['rewardBtn1']:registerScriptTapHandler(function() self:click_chooseBtn(1) end)
    vars['rewardBtn2']:registerScriptTapHandler(function() self:click_chooseBtn(2) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary:refresh()

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary:onEnterTab()
end

-------------------------------------
-- function click_chooseBtn
-------------------------------------
function UI_EventThankAnniversary:click_chooseBtn(reward_num)
	UI_EventThankAnniversary_showDetaillPopup(reward_num)
end

