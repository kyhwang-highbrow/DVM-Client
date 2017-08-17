-------------------------------------
-- class UI_CouponPopup_Confirm
-------------------------------------
UI_CouponPopup_Confirm = class(UI, {
        m_couponId = 'string',
        m_couponData = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_CouponPopup_Confirm:init(couponId, couponData)
    self.m_couponId = couponId
    self.m_couponData = couponData

    local vars = self:load('coupon_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithAction() end, 'UI_CouponPopup_Confirm')

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CouponPopup_Confirm:initUI()
    local vars = self.vars
    
    -- @todo-coupon, 쿠폰 정보 표시
    --self.m_couponData['type']
    --self.m_couponData['no']
    --self.m_couponData['cnt']

    local desc = self.m_couponData['no'] .. ' ' .. tostring(self.m_couponData['cnt']) .. ' ' .. '개'
    -- 임시
    vars['itemLabel']:setString(desc)
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

    -- @todo-coupon, 서버에 쿠폰 사용 요청
    --self.m_couponId
end