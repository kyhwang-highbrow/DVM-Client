local PARENT = UI

-------------------------------------
-- class UI_ArenaNewStaminaChargePopup
-------------------------------------
UI_ArenaNewStaminaChargePopup = class(PARENT, {
        m_curChargeCnt = 'number',
        m_chargeLimit = 'number',
        m_chargePerCost = 'number',

        m_availableCnt = 'number',

        m_chargeCnt = 'number',

        m_isChangableTitle = 'boolean',
     })


-------------------------------------
-- function init
-- @brief 
-------------------------------------
function UI_ArenaNewStaminaChargePopup:init()
    self.m_uiName = 'UI_ArenaNewStaminaChargePopup'
    local vars = self:load('arena_new_scene_popup_purchase.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNew')

    local charge_limit = TableStaminaInfo:getDailyChargeLimit('arena_new')
    local t_stamina_info = g_staminasData:getRef('arena_new')
    local charge_cnt = (t_stamina_info['charge_cnt'] or 0)
    local charge_cost = (t_stamina_info['charge_cnt'] or 0)
    local price, cnt = TableStaminaInfo:getDailyChargeInfo('arena_new', charge_cnt)


    self.m_chargeLimit = charge_limit
    self.m_curChargeCnt = charge_cnt
    self.m_chargePerCost = price
    self.m_isChangableTitle = g_staminasData:hasStaminaCount(ARENA_NEW_STAGE_ID, 1)

    self.m_availableCnt = charge_limit - charge_cnt
    self.m_chargeCnt = 1

    local is_enough, insufficient_num = g_staminasData:hasStaminaCount(ARENA_NEW_STAGE_ID, 1)

    self:initButton()
    self:initUI()
end

-------------------------------------
-- function initButton
-- @brief 
-------------------------------------
function UI_ArenaNewStaminaChargePopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    vars['quantityPlusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(1) end)
    vars['quantityMinusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end)

    vars['quantityPlusBtn']:registerScriptPressHandler(function() self:click_quantityBtn(1) end)
    vars['quantityMinusBtn']:registerScriptPressHandler(function() self:click_quantityBtn(-1) end)

    local is_over_charge_limit = self.m_curChargeCnt >= self.m_chargeLimit

    if (not is_over_charge_limit) then
        vars['purchaseBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    else
        self.m_chargeCnt = 0
        vars['purchaseBtn']:setEnabled(false)
    end

    if (self.m_chargeCnt + 1 > self.m_availableCnt) then
        vars['quantityPlusBtn']:setEnabled(false)
    end

    if (self.m_chargeCnt - 1 <= 0) then
        vars['quantityMinusBtn']:setEnabled(false)
    end
end

-------------------------------------
-- function initUI
-- @brief 
-------------------------------------
function UI_ArenaNewStaminaChargePopup:initUI()
    local vars = self.vars
    local msg = Str('콜로세움 입장권') .. string.format(' %s/%s', tostring(self.m_curChargeCnt), tostring(self.m_chargeLimit))

    if (not self.m_isChangableTitle) then
        vars['titleLabel']:setString(msg)
    end

    self:refresh()
end

-------------------------------------
-- function refresh
-- @brief 
-------------------------------------
function UI_ArenaNewStaminaChargePopup:refresh()
    local vars = self.vars

    if (self.m_isChangableTitle) then
        local msg = Str('입장권이 부족합니다.\n{@possible}입장권 {1}개{@default}를 충전하시겠습니까?\n{@impossible}(1일 {2}회 구매 가능. 현재 {3}회 구매)', self.m_chargeCnt, self.m_chargeLimit, self.m_curChargeCnt)
        vars['titleLabel']:setString(msg)
    end

    vars['quantityLabel']:setString(tostring(self.m_chargeCnt))
    vars['priceLabel']:setString(tostring(self.m_chargeCnt * self.m_chargePerCost))
end

-------------------------------------
-- function click_quantityBtn
-- @brief 
-------------------------------------
function UI_ArenaNewStaminaChargePopup:click_quantityBtn(number)
    local vars = self.vars

    local temp = self.m_chargeCnt + number

    if (temp >= self.m_availableCnt) then
        vars['quantityPlusBtn']:setEnabled(false)
        vars['quantityMinusBtn']:setEnabled(true)
        
    elseif (temp <= 1) then
        vars['quantityPlusBtn']:setEnabled(true)
        vars['quantityMinusBtn']:setEnabled(false)

    else
        vars['quantityPlusBtn']:setEnabled(true)
        vars['quantityMinusBtn']:setEnabled(true)

    end

    self.m_chargeCnt = temp
    self:refresh()
end

-------------------------------------
-- function click_buyBtn
-- @brief 
-------------------------------------
function UI_ArenaNewStaminaChargePopup:click_buyBtn()
    -- 캐쉬가 충분히 있는지 확인
    if (not ConfirmPrice('cash', self.m_chargePerCost)) then
        return
    end
                
    g_staminasData:request_staminaCharge('arena_new', self.m_chargeCnt)
    self:close()
end