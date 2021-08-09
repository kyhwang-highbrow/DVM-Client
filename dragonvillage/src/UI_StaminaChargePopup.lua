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

        m_bChargeSt = 'boolean', -- 해당 팝업에서 날개가 충전되었는가
        m_bOpenSpotSale = 'boolean', -- 스팟 세일 창 관련 로직을 실행할 것인가
        m_finishCB = 'function', -- 종료될 때 실행될 함수
    })

-------------------------------------
-- function init
-------------------------------------
function UI_StaminaChargePopup:init(b_use_cash_label, b_open_spot_sale, finish_cb)
    self.m_uiName = 'UI_StaminaChargePopup'
    local vars = self:load('staminas_charge_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_StaminaChargePopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_bChargeSt = false
    self.m_bOpenSpotSale = b_open_spot_sale
    self.m_finishCB = finish_cb

    if (b_use_cash_label) then
        vars['diaMenu']:setVisible(true)
    end

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_StaminaChargePopup:initUI()
    local vars = self.vars

    self:initTypeVariable('buy')
    self:initTypeVariable('use')

    -- NumberLabel 설정
    if (vars['diaMenu']:isVisible()) then
        vars['diaLabel'] = NumberLabel(vars['diaLabel'], 0, 0.3)
    end
end

-------------------------------------
-- function initTypeVariable
-------------------------------------
function UI_StaminaChargePopup:initTypeVariable(type)
    local vars = self.vars

    if (type == 'buy') then
        local product_id = 10013
        local struct_product = g_shopDataNew:getTargetProduct(product_id)
        local product_price = struct_product.price
        self.m_buyCnt = 1
        self.m_needCash = product_price

    elseif (type == 'use') then
        self.m_useCnt = 1
        do -- 찬란한 날개 생성
            local item_id = 700711
            local count = g_userData:get('st_100') or 0
            local item_card = UI_ItemCard(item_id, count)
            if (count == 0) then
                item_card.vars['disableSprite']:setVisible(true)
                item_card.vars['numberLabel']:setString(tostring(count))
            end

            vars['iconNode']:removeAllChildren()
            vars['iconNode']:addChild(item_card.root)
        end
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

    local buy_total_cnt = 180 * buy_cnt
    local use_total_cnt = 100 * use_cnt
    vars['quantityTotalLabel1']:setString(Str('{1}개', comma_value(buy_total_cnt)))
    vars['quantityTotalLabel2']:setString(Str('{1}개', comma_value(use_total_cnt)))

    if (vars['diaMenu']:isVisible()) then
        local user_cash = g_userData:get('cash') or 0
        vars['diaLabel']:setNumber(user_cash)
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
        cnt = self.m_buyCnt + sign
    elseif (type == 'use') then
        cnt = self.m_useCnt + sign
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

    local product_price = struct_product.price
    local total_price = buy_cnt * product_price
    local user_cash = g_userData:get('cash') or 0
    
    -- 구매 가능한지 검사    
    if (total_price > user_cash) then
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('다이아몬드가 부족합니다.\n상점으로 이동하시겠습니까?'), function() UINavigatorDefinition:goTo('package_shop', 'diamond_shop') end)
        return
    end

    local function finish_cb(ret)
        UIManager:toastNotificationGreen(Str('날개가 충전되었습니다.'))
        
        self.m_bChargeSt = true
        self:initTypeVariable('buy')
        self:refresh()
    end

    local function ok_cb()
        g_shopDataNew:request_buy(struct_product, buy_cnt, finish_cb)
    end

    local buy_total_count = 180 * buy_cnt
    local str = Str('{@item_name}"{1} x{2}"\n{@default}구매하시겠습니까?', Str('날개'), comma_value(buy_total_count))
    MakeSimplePopup(POPUP_TYPE.YES_NO, str, ok_cb)
end

-------------------------------------
-- function click_useBtn
-------------------------------------
function UI_StaminaChargePopup:click_useBtn()
    local item_id = 700711
    local use_cnt = self.m_useCnt

    -- 사용 가능한지 검사
    local user_st_100 = g_userData:get('st_100') or 0
    if (user_st_100 < use_cnt) then
        UIManager:toastNotificationRed(Str('찬란한 날개가 부족합니다.'))  
        return
    end

    local function finish_cb(ret)
        UIManager:toastNotificationGreen(Str('날개가 충전되었습니다.'))
        
        self.m_bChargeSt = true
        self:initTypeVariable('use')
        self:refresh() 
    end

    local function ok_cb()
        g_itemData:request_useItem(item_id, use_cnt, finish_cb)
    end

    local str = Str('{@item_name}"{1} x{2}"\n{@default}사용하시겠습니까?', Str('찬란한 날개'), comma_value(use_cnt))
    MakeSimplePopup(POPUP_TYPE.YES_NO, str, ok_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_StaminaChargePopup:click_closeBtn()
    -- 해당 팝업에서 스테미나 충전이 안된 경우
    if ((self.m_bOpenSpotSale == true) and (self.m_bChargeSt == false)) then
        local finish_cb = self.m_finishCB
        local spot_sale = ServerData_SpotSale:checkSpotSale('st', nil, finish_cb)
        
        if (spot_sale) then
            self:close()
            return
        end
    end

    if (self.m_finishCB) then
        self.m_finishCB()
    end

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
    if (cnt <= 0) or (cnt > 1000) then
        return false
    end

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
