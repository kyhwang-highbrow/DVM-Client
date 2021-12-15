local PARENT = UI

-------------------------------------
-- class UI_CustomEnhance
-------------------------------------
UI_CustomEnhance = class(PARENT, {
        m_curChargeCnt = 'number',
        m_chargeLimit = 'number',
        m_chargePerCost = 'number',

        m_upCount = 'number',
     })


-------------------------------------
-- function init
-- @brief 
-------------------------------------
function UI_CustomEnhance:init()
    self.m_uiName = 'UI_CustomEnhance'
    local vars = self:load('dragon_enhance_tooltip.ui')


    self.m_upCount = 1
    self:initButton()
    self:initUI()
    self:refresh()
end

-------------------------------------
-- function initButton
-- @brief 
-------------------------------------
function UI_CustomEnhance:initButton()
    local vars = self.vars

    if (vars['applyBtn']) then vars['applyBtn']:registerScriptTapHandler(function() self:click_applyBtn() end) end
    vars['applyBtn']:setEnabled(true)
    vars['applyLabel']:setColor(COLOR['black'])
    vars['enhanceLabel']:setString('3 강화')
    
    if (vars['plusBtn']) then vars['plusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(1) end) end
    if (vars['minusBtn']) then vars['minusBtn']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end) end

    -- 1번 마이너스 2번 플러스
    --[[
    vars['quantityBtn2']:registerScriptTapHandler(function() self:click_quantityBtn(1) end)
    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_quantityBtn(-1) end)

    vars['quantityBtn2']:registerScriptPressHandler(function() self:click_quantityBtn(1, true) end)
    vars['quantityBtn1']:registerScriptPressHandler(function() self:click_quantityBtn(-1, true) end)]]
end

-------------------------------------
-- function initUI
-- @brief 
-------------------------------------
function UI_CustomEnhance:initUI()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-- @brief 
-------------------------------------
function UI_CustomEnhance:refresh()
    local vars = self.vars


    vars['enhanceLabel']:setString(self.m_upCount)
end

function UI_CustomEnhance:click_applyBtn()
    self.root:removeFromParent()
end

-------------------------------------
-- function click_quantityBtn
-- @brief 
-------------------------------------
function UI_CustomEnhance:click_quantityBtn(number, is_pressed)
    local vars = self.vars

    local function adjust_func()
        self:refresh()
    end

    local cost =  self.m_upCount + number



    if (not is_pressed) then
        self.m_upCount = math.max(self.m_upCount + number, 1)
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
                self.m_upCount = math.max(self.m_upCount + number, 1)
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
function UI_CustomEnhance:click_apply()

    self:close()
end