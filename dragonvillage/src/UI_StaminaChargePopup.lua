local PARENT = UI

-------------------------------------
-- class UI_StaminaChargePopup
-------------------------------------
UI_StaminaChargePopup = class(PARENT,{
        m_buyCnt = 'number', -- 날개 상품 구입하려는 개수
        m_useCnt = 'number', -- 찬란한 날개 사용하려는 개수

        m_needCash = 'number', -- 필요한 다이아 갯수

        m_buyBtnPress = 'UI_CntBtnPress',
        m_useBtnPress = 'UI_CntBtnPress',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_StaminaChargePopup:init(b_use_cash_label)
    self.m_uiName = 'UI_StaminaChargePopup'
    local vars = self:load('staminas_charge_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_StaminaChargePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    if (b_use_cash_label) then
        vars['diaMenu']:setVisible(false)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StaminaChargePopup:initUI()
    local vars = self.vars

    self.m_buyCnt = 0
    self.m_useCnt = 0
    self.m_needCash = 0

    do -- 찬란한 날개 생성
        local item_id = 700711
        local count = g_userData:get('st_100') or 0
        local item_card = UI_ItemCard(item_id, count)
        if (count == 0) then
            item_card.vars['disableSprite']:setVisible(true)
        end

        vars['iconNode']:removeAllChildren()
        vars['iconNode']:addChild(item_card.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_StaminaChargePopup:initButton()
    local vars = self.vars
    
    vars['quantityMinusBtn1']:registerScriptTapHandler(function() self:click_quantityBtn('buy', -1) end)
    vars['quantityMinusBtn2']:registerScriptTapHandler(function() self:click_quantityBtn('use', -1) end)
    
    vars['quantityPlusBtn1']:registerScriptTapHandler(function() self:click_quantityBtn('buy', 1) end)
    vars['quantityPlusBtn2']:registerScriptTapHandler(function() self:click_quantityBtn('use', 1) end)

    vars['quantityMinusBtn1']:registerScriptPressHandler(function() self:press_quantityBtn('buy', -1) end)
    vars['quantityMinusBtn2']:registerScriptPressHandler(function() self:press_quantityBtn('use', -1) end)
    
    vars['quantityPlusBtn1']:registerScriptPressHandler(function() self:press_quantityBtn('buy', 1) end)
    vars['quantityPlusBtn2']:registerScriptPressHandler(function() self:press_quantityBtn('use', 1) end)

    local function buy_cnt_func()
        return self.m_buyCnt
    end

    local function buy_cond_func(cnt)
        return self:conditionFunc('buy', cnt)
    end

    local function use_cnt_func()
        return self.m_useCnt
    end

    local function use_cond_func(cnt)
        return self:conditionFunc('use', cnt)
    end

    local buy_btn_press = UI_CntBtnPress(self, buy_cnt_func, buy_cond_func)
    local use_btn_press = UI_CntBtnPress(self, use_cnt_func, use_cond_func)
    self.m_buyBtnPress = buy_btn_press
    self.m_useBtnPress = use_btn_press

    vars['purchaseBtn']:registerScriptTapHandler(function() self:click_purchaseBtn() end)
    vars['useBtn']:registerScriptTapHandler(function() self:click_useBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_StaminaChargePopup:refresh()
    local vars = self.vars

    local buy_cnt = self.m_buyCnt
    local use_cnt = self.m_useCnt
    local need_cash = self.m_needCash

    vars['quantityLabel1']:setString(comma_value(buy_cnt))
    vars['quantityLabel2']:setString(comma_value(use_cnt))
    vars['priceLabel']:setString(comma_value(need_cash))

    local buy_total_cnt = 140 * buy_cnt
    local use_total_cnt = 100 * use_cnt
    vars['quantityTotalLabel1']:setString(Str('{1}개', comma_value(buy_total_cnt)))
    vars['quantityTotalLabel2']:setString(Str('{1}개', comma_value(use_total_cnt)))

    if (vars['diaMenu']:isVisible()) then
        local user_cash = g_userData:get('cash') or 0
        vars['diaLabel']:setString(comma_value(user_cash))
    end
end

-------------------------------------
-- function click_quantityBtn
-- @param type : ('buy' OR 'use'), 구입인지 사용인지 구분
-- @param sign : (+1 OR -1), 부호
-------------------------------------
function UI_StaminaChargePopup:click_quantityBtn(type, sign)
    local cnt = 0
    if (type == 'buy') then
        cnt = math_max(0, self.m_buyCnt + sign)
    elseif (type == 'use') then
        cnt = math_max(0, self.m_useCnt + sign)
    end

    self:conditionFunc(type, cnt)
end

-------------------------------------
-- function press_quantityBtn
-- @param type : ('buy' OR 'use'), 구입인지 사용인지 구분
-- @param sign : (+1 OR -1), 부호
-------------------------------------
function UI_StaminaChargePopup:press_quantityBtn(type, sign)
    local vars = self.vars
    
    -- 기존에 다른 버튼이 눌리고 있었다면 끄기
    if (self.m_buyBtnPress.m_blockUI ~= nil) then
        self.m_buyBtnPress:resetQuantityBtnPress()
    end

    if (self.m_useBtnPress.m_blockUI ~= nil) then
        self.m_useBtnPress:resetQuantityBtnPress()
    end

    if (type == 'buy') then
        local buy_btn
        if (sign == 1) then
            buy_btn = vars['quantityPlusBtn1']
        else
            buy_btn = vars['quantityMinusBtn1']
        end

        self.m_buyBtnPress:quantityBtnPressHandler(buy_btn, sign)

    elseif (type == 'use') then
        local use_btn
        if (sign == 1) then
            use_btn = vars['quantityPlusBtn2']
        else
            use_btn = vars['quantityMinusBtn2']
        end

        self.m_useBtnPress:quantityBtnPressHandler(use_btn, sign)
    end
end

-------------------------------------
-- function click_purchaseBtn
-------------------------------------
function UI_StaminaChargePopup:click_purchaseBtn()
    local product_id = 10013
    local struct_product = g_shopDataNew:getTargetProduct(product_id)
    local buy_cnt = self.m_buyCnt

    if (buy_cnt == 0) then
        return
    end

    local function finish_cb(ret)
        UIManager:toastNotificationGreen(Str('날개가 충전되었습니다.'))
        self:initUI()
        self:refresh()
    end

    g_shopDataNew:request_buy(struct_product, buy_cnt, finish_cb)
end

-------------------------------------
-- function click_useBtn
-------------------------------------
function UI_StaminaChargePopup:click_useBtn()
    local item_id = 700711
    local use_cnt = self.m_useCnt

    if (use_cnt == 0) then
        return
    end

    local function finish_cb(ret)
        UIManager:toastNotificationGreen(Str('날개가 충전되었습니다.'))
        self:initUI()
        self:refresh() 
    end

    g_itemData:request_useItem(item_id, use_cnt, finish_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_StaminaChargePopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function conditionFunc
-- @param type : ('buy' OR 'use'), 구입인지 사용인지 구분
-- @param cnt : 개수
-- @return cnt가 가능하다면 true 반환
-------------------------------------
function UI_StaminaChargePopup:conditionFunc(type, cnt)
    -- 조건 검사
    if (type == 'buy') then
        -- 날개 180개 묶음 아이템
        local product_id = 10013
        local struct_product = g_shopDataNew:getTargetProduct(product_id)
        local product_price = struct_product.price
        local total_price = cnt * product_price
        local user_cash = g_userData:get('cash') or 0

        if (total_price <= user_cash) then
            self.m_buyCnt = cnt            
            self.m_needCash = total_price            
        else
            -- 경고 메세지
            UIManager:toastNotificationRed(Str('다이아몬드가 부족합니다.'))
            return false
        end

    elseif (type == 'use') then
        local user_st_100 = g_userData:get('st_100') or 0

        if (cnt <= user_st_100) then
            self.m_useCnt = cnt
        else
            -- 경고 메세지
            UIManager:toastNotificationRed(Str('찬란한 날개가 부족합니다.'))
            return false
        end
    end

    self:refresh()
    return true
end

--@CHECK
UI:checkCompileError(UI_StaminaChargePopup)
