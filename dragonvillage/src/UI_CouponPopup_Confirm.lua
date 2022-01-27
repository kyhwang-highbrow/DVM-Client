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
        UIManager:toastNotificationGreen(Str('아이템 코드의 상품이 우편함으로 지급되었습니다.'))
        MakeSimplePopup(POPUP_TYPE.OK, Str('아이템 코드 사용에 성공하였습니다.'))
        self:close()
    end

    local function result_cb(t_ret)
        if t_ret['status'] == 0 then
            return false
        end

        local msg = ''
        if t_ret['rs'] == 1 then
            msg = Str('유효하지 않은 아이템 코드입니다.\n다시 입력해 주세요.')
        elseif t_ret['rs'] == 2 then
            msg = Str('이미 사용된 아이템 코드입니다.\n다시 입력해 주세요.')
        elseif t_ret['rs'] == 3 then
            msg = Str('본 게임에서 사용할 수 없는 아이템 코드입니다.\n카드를 다시 확인해 주세요.')
        elseif t_ret['rs'] == 6 then
            msg = Str('서버 점검 중입니다.\n잠시 후 다시 시도해 주세요.')
        else
            self:close()
            return false
        end
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        self:close()
        return true
    end

    g_highbrowData:request_couponUse(self.m_couponId, success_cb, result_cb)
end