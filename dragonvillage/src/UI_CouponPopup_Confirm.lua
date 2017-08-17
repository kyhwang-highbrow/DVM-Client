-------------------------------------
-- class UI_CouponPopup_Confirm
-------------------------------------
UI_CouponPopup_Confirm = class(UI, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopup_Confirm:init()
    local vars = self:load('coupon_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_CouponPopup_Confirm')

    self:initUI()
    self:initButton()
    self:initEditHandler()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CouponPopup_Confirm:initUI()
    local vars = self.vars
    
    -- 임시
    vars['itemLabel']:setString('골드 5,000,000개')
    local icon = IconHelper:getIcon('res/ui/icons/item/shop_gold_06.png')
    if (icon) then
        vars['itemNode']:addChild(icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CouponPopup_Confirm:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:closeWithAction() end)
	vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function click_okBtn
-- @brief ok~
-------------------------------------
function UI_CouponPopup_Confirm:click_okBtn()
	ccdisplay('OK~')
end