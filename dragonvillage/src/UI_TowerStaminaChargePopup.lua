local PARENT = UI

-------------------------------------
-- class UI_TowerStaminaChargePopup
-------------------------------------
UI_TowerStaminaChargePopup = class(PARENT, {
        m_curChargeCnt = 'number',
        m_chargeLimit = 'number',
        m_chargePerCost = 'number',

        m_chargeCnt = 'number',
     })


-------------------------------------
-- function init
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:init()
    self.m_uiName = 'UI_TowerStaminaChargePopup'
    local vars = self:load('arena_new_scene_popup_purchase.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_TowerStaminaChargePopup')

    local t_stamina_info = g_staminasData:getRef('tower')
    local charge_cnt = (t_stamina_info['charge_cnt'] or 0)
    local charge_cost = (t_stamina_info['charge_cnt'] or 0)
    local price, cnt = TableStaminaInfo:getDailyChargeInfo('tower', charge_cnt)

    self.m_curChargeCnt = charge_cnt
    self.m_chargePerCost = price

    self.m_chargeCnt = 1

    self:initButton()
    self:initUI()
end

-------------------------------------
-- function initButton
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    vars['quantityPlusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(1) end)
    vars['quantityMinusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end)

    vars['quantityPlusBtn']:registerScriptPressHandler(function() self:click_quantityBtn(1, true) end)
    vars['quantityMinusBtn']:registerScriptPressHandler(function() self:click_quantityBtn(-1, true) end)

    self.m_chargeCnt = 0
    vars['purchaseBtn']:setEnabled(true)
    vars['purchaseBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    if (self.m_chargeCnt - 1 <= 0) then
        vars['quantityMinusBtn']:setEnabled(false)
    end
end

-------------------------------------
-- function initUI
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:initUI()
    local vars = self.vars

    self:refresh()
end

-------------------------------------
-- function refresh
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:refresh()
    local vars = self.vars

    vars['quantityLabel']:setString(tostring(self.m_chargeCnt))
    vars['priceLabel']:setString(tostring(self.m_chargeCnt * self.m_chargePerCost))
end

-------------------------------------
-- function click_quantityBtn
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:click_quantityBtn(number, is_pressed)
    local vars = self.vars

    local function adjust_func()
        local temp = self.m_chargeCnt + number

        if (temp <= 1) then
            vars['quantityPlusBtn']:setEnabled(true)
            vars['quantityMinusBtn']:setEnabled(false)

        else
            vars['quantityPlusBtn']:setEnabled(true)
            vars['quantityMinusBtn']:setEnabled(true)

        end

        self.m_chargeCnt = temp
        self:refresh()
    end

    if (not is_pressed) then
        adjust_func()
    else
        local button    
        if (number >= 0) then
            button = vars['quantityPlusBtn']
        else
            button = vars['quantityMinusBtn']
        end

        local function update_level(dt)
            if (not button:isSelected()) or (not button:isEnabled()) then
                self.root:unscheduleUpdate()
            end

            adjust_func()
        end

        self.root:scheduleUpdateWithPriorityLua(function(dt) return update_level(dt) end, 1)
    end
end

-------------------------------------
-- function click_buyBtn
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:click_buyBtn()
    -- 캐쉬가 충분히 있는지 확인
    if (not ConfirmPrice('cash', self.m_chargePerCost)) then
        return
    end
                
    g_staminasData:request_staminaCharge('tower', self.m_chargeCnt)
    self:close()
end