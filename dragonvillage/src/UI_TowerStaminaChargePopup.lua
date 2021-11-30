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
    local vars = self:load('shop_purchase.ui')
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
    -- 1번 마이너스 2번 플러스
    vars['quantityBtn2']:registerScriptTapHandler(function() self:click_quantityBtn(1) end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end)

    vars['quantityBtn2']:registerScriptPressHandler(function() self:click_quantityBtn(1, true) end)
    vars['quantityBtn1']:registerScriptPressHandler(function() self:click_quantityBtn(-1, true) end)

    vars['purchaseBtn']:setEnabled(true)
    vars['purchaseBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    --[[
    if (self.m_chargeCnt - 1 <= 0) then
        vars['quantityMinusBtn']:setEnabled(false)
    end]]
end

-------------------------------------
-- function initUI
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:initUI()
    local vars = self.vars

    local stamina_id = TableItem():getItemIDFromItemType('tower')
    local t_item = TABLE:get('item')[stamina_id]
    local name = Str(t_item['t_name'])

    -- 상품 이름
    vars['itemLabel']:setString(name)

	-- 상품 아이콘
    local icon = IconHelper:getItemIcon(stamina_id)
    if (icon) then
        icon:setScale(2)
        vars['itemNode']:addChild(icon)
    end

    -- 가격 아이콘
    local diamond_icon = IconHelper:getItemIcon(700001)
    local price_node = vars['priceNode']
    if (diamond_icon) then
        diamond_icon:setScale(0.5)
        price_node:addChild(diamond_icon)
    end

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
    --[[
    if (self.m_chargeCnt <= 1) then
        vars['quantityPlusBtn']:setEnabled(true)
        vars['quantityMinusBtn']:setEnabled(false)
    else
        vars['quantityPlusBtn']:setEnabled(true)
        vars['quantityMinusBtn']:setEnabled(true)

    end]]
end

-------------------------------------
-- function click_quantityBtn
-- @brief 
-------------------------------------
function UI_TowerStaminaChargePopup:click_quantityBtn(number, is_pressed)
    local vars = self.vars

    local function adjust_func()
        self:refresh()
    end

    if (not is_pressed) then
        self.m_chargeCnt = math.max(self.m_chargeCnt + number, 1)
        adjust_func()
    else
        local button    

        -- 버튼 2번이 플러스
        if (number >= 0) then
            button = vars['quantityBtn2']
        else
            button = vars['quantityBtn1']
        end

        local function update_level(dt)
            if (not button:isSelected()) or (not button:isEnabled()) then
                self.root:unscheduleUpdate()
            else
                self.m_chargeCnt = math.max(self.m_chargeCnt + number, 1)
                adjust_func()
            end
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