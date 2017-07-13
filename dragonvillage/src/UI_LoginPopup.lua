local PARENT = UI

-------------------------------------
-- class UI_LoginPopup
-------------------------------------
UI_LoginPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoginPopup:init()
    local vars = self:load('login_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_LoginPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoginPopup:initUI()
    local vars = self.vars
	--vars['facebookLabel'] -- LabelTTF
	--vars['gamecenterLabel'] -- LabelTTF
	--vars['highbrowLabel'] -- LabelTTF
	--vars['googleLabel'] -- LabelTTF
	--vars['geustLabel'] -- LabelTTF
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LoginPopup:initButton()
    local vars = self.vars
    self.vars['facebookBtn']:registerScriptTapHandler(function() self:click_facebookBtn() end)
    self.vars['gamecenterBtn']:registerScriptTapHandler(function() self:click_gamecenterBtn() end)
    self.vars['highbrowBtn']:registerScriptTapHandler(function() self:click_highbrowBtn() end)
    self.vars['googleBtn']:registerScriptTapHandler(function() self:click_googleBtn() end)
    self.vars['guestBtn']:registerScriptTapHandler(function() self:click_guestBtn() end)
    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoginPopup:refresh()
end

-------------------------------------
-- function click_facebookBtn
-------------------------------------
function UI_LoginPopup:click_facebookBtn()
    cclog('TODO click_facebookBtn event occurred!')
end

-------------------------------------
-- function click_gamecenterBtn
-------------------------------------
function UI_LoginPopup:click_gamecenterBtn()
    cclog('TODO click_gamecenterBtn event occurred!')
end

-------------------------------------
-- function click_highbrowBtn
-------------------------------------
function UI_LoginPopup:click_highbrowBtn()
    cclog('TODO click_highbrowBtn event occurred!')
end

-------------------------------------
-- function click_googleBtn
-------------------------------------
function UI_LoginPopup:click_googleBtn()
    cclog('TODO click_googleBtn event occurred!')
end

-------------------------------------
-- function click_guestBtn
-------------------------------------
function UI_LoginPopup:click_guestBtn()
    cclog('TODO click_guestBtn event occurred!')
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_LoginPopup:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_LoginPopup)
