local PARENT = UI

-------------------------------------
-- class UI_ObtainPopup
-------------------------------------
UI_ObtainToastPopup = class(PARENT, {
        m_lReward = 'list',
    })

-------------------------------------
-- function createObtainToastPopup
-------------------------------------
function UI_ObtainToastPopup.createObtainToastPopup(l_reward_item)
    local ui_obtain_toast_popup = UI_ObtainToastPopup()
    ui_obtain_toast_popup:setReward(l_reward_item)

    return ui_obtain_toast_popup
end

-------------------------------------
-- function init
-------------------------------------
function UI_ObtainToastPopup:init()
    local vars = self:load('popup_toast_reward.ui')

	self.m_uiName = 'UI_ObtainToastPopup'

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function setReward
-------------------------------------
function UI_ObtainToastPopup:setReward(l_reward_item)
    self.m_lReward = l_reward_item
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ObtainToastPopup:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ObtainToastPopup:initButton()
    local vars = self.vars

    --vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ObtainToastPopup:refresh()
	local vars = self.vars
end
