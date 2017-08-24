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
        --ccdump(t_ret)
        UIManager:toastNotificationGreen(Str('아이템 코드에 대한 상품이 우편함으로 지급되었습니다.'))
        MakeSimplePopup(POPUP_TYPE.OK, Str('아이템 코드 사용에 성공하였습니다.'))
        self:close()
    end

    local function result_cb(t_ret)
        --ccdump(t_ret)
        if t_ret['status'] ~= 0 then
            self:close()
        end
        return false
    end

    g_highbrowData:request_couponUse(self.m_couponId, success_cb, result_cb)
end