local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonPaymentShop
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @yjkil 2022.02.11 기준 사용 X
-------------------------------------
UI_ButtonPaymentShop = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonPaymentShop:init()
    self:load('button_payment_shop.ui')

    -- 버튼 설정
    local btn = self.vars['btn']
    if btn then
        btn:registerScriptTapHandler(function() self:click_btn() end)
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonPaymentShop:isActive()
    return true
end

-------------------------------------
-- function click_btn
-- @brief 버튼 클릭
-------------------------------------
function UI_ButtonPaymentShop:click_btn()
    local ui = UI_PaymentShop()

    --[[
    local function close_cb()
        -- 보급소 내에서 상품 상태 변경 시 notiSprite상태 갱신을 위해 호출
        self:callDirtyStatusCB()
    end

    ui:setCloseCB(close_cb)
    --]]
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonPaymentShop:updateButtonStatus()
    -- callDirtyStatusCB을 통해 갱신 요청이 오면 notiSprite상태 갱신
    local vars = self.vars
    local is_highlight, cnt = g_supply:isHighlightSupply()
    vars['notiSprite']:setVisible(is_highlight)
end