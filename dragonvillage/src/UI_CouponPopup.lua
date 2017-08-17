-------------------------------------
-- class UI_CouponPopup
-------------------------------------
UI_CouponPopup = class(UI, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopup:init()
    local vars = self:load('coupon_input.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_CouponPopup')

    self:initUI()
    self:initButton()
    self:initEditHandler()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CouponPopup:initUI()
    local vars = self.vars
    vars['editBox']:setMaxLength(12)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CouponPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
	vars['editBtn']:registerScriptTapHandler(function() self:click_editBtn() end)
end

-------------------------------------
-- function initEditHandler
-------------------------------------
function UI_CouponPopup:initEditHandler()
    local vars = self.vars

    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            -- editLabel에 글자를 찍어준다.
            local context = vars['editBox']:getText()
            vars['editLabel']:setString(context)
        end
    end
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function click_editBtn
-- @brief editBtn 클릭시 editBox를 통해 키보드를 open한다.
-------------------------------------
function UI_CouponPopup:click_editBtn()
	self.vars['editBox']:openKeyboard()
end

-------------------------------------
-- function click_okBtn
-- @brief ok~
-------------------------------------
function UI_CouponPopup:click_okBtn()
	ccdisplay('OK~')
    UI_CouponPopup_Confirm()
end