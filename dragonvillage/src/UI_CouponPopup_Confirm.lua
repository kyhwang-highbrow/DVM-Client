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
    
    -- self.m_couponData['item_id'] 가 nil 이거나 0 인 경우에 대한 예외 처리 필요
    local t_item = {
        ['item_id'] = self.m_couponData['item_id'],
        ['count'] = self.m_couponData['count']
    }
    local desc = UIHelper:makeItemName(t_item)
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
    -- @todo-coupon, 서버에 쿠폰 사용 요청
    local function cb_func(t_ret)
        UI_ToastPopup()
        self:closeWithAction()
    end
    g_highbrowData:request_couponUse(self.m_couponId, cb_func)
end