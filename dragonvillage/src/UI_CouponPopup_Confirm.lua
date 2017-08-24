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
    
    local t_item = {
        ['item_id'] = self.m_couponData['item_id'],
        ['count'] = self.m_couponData['count']
    }
    local desc = UIHelper:makeItemName(t_item)
    vars['itemLabel']:setString(desc)

    local item_card = UI_ItemCard(t_item['item_id'], t_item['count'])
    if (item_card) then
        vars['itemNode']:addChild(item_card.root)
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
    local function success_cb(t_ret)
        UI_ToastPopup()
        self:close()
    end

    local function result_cb(t_ret)
        --ccdump(t_ret)
        self:close()
        return false
    end

    local t_data = {}
    t_data['couponId'] = self.m_couponId
    --t_data['payload'] = self.m_couponData['payload']
    g_highbrowData:request_couponUse(t_data, success_cb, result_cb)
end