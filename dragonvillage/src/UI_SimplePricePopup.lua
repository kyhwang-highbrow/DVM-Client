local PARENT = UI

-------------------------------------
-- class UI_SimplePricePopup
-------------------------------------
UI_SimplePricePopup = class(PARENT,{
    m_popupType = 'POPUP_TYPE',
    m_msg = 'string',
    m_submsg = 'string',
    m_cbOKBtn = 'function',
    m_cbCancelBtn = 'function',

    m_priceType = 'string',
    m_priceValue = 'number',

    m_bIsCheckboxActivated = 'boolean',
    m_checkboxCallback = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SimplePricePopup:init(popup_type, msg, submsg, ok_btn_cb, cancel_btn_cb, ui_z_order)
    self.m_popupType = popup_type
    self.m_msg = submsg
    self.m_submsg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb
    self.m_uiName = 'UI_SimplePricePopup'
    
    local vars = self:load('popup_price.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_SimplePricePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function setCheckBoxCallback
-------------------------------------
function UI_SimplePricePopup:setCheckBoxCallback(callback_function)
    self.m_checkboxCallback = callback_function
    self.vars['checkBtn']:setVisible(callback_function ~= nil)
end



-------------------------------------
-- function initUI
-------------------------------------
function UI_SimplePricePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimplePricePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBoxBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimplePricePopup:refresh()
    local vars = self.vars

    vars['mainLabel']:setString(Str(self.m_msg))
    vars['subLabel']:setString(Str(self.m_submsg))
    
    if (self.m_popupType == POPUP_TYPE.OK) then
        vars['cancelBtn']:setVisible(false)
        vars['okBtn']:setPositionX(0)


    elseif (self.m_popupType == POPUP_TYPE.YES_NO) then
        vars['cancelBtn']:setVisible(true)
        vars['okBtn']:setPositionX(103)

    else
        error('self.m_popupType : ' .. self.m_popupType)
    end
end

-------------------------------------
-- function click_checkBoxBtn
-------------------------------------
function UI_SimplePricePopup:click_checkBoxBtn()
    local vars = self.vars
    self.m_bIsCheckboxActivated = (not vars['checkSprite']:isVisible())

    vars['checkSprite']:setVisible(self.m_bIsCheckboxActivated)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_SimplePricePopup:click_backKey()
    if (self.m_popupType == POPUP_TYPE.OK) then
        self:click_okBtn()

    elseif (self.m_popupType == POPUP_TYPE.YES_NO) then
        self:click_cancelBtn()

    else
        error('self.m_popupType : ' .. self.m_popupType)
    end
end


-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_SimplePricePopup:click_okBtn()
    if ConfirmPrice(self.m_priceType, self.m_priceValue) == false then
        self:click_cancelBtn()
        return
    end

    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    if self.m_bIsCheckboxActivated and self.m_checkboxCallback then
        self.m_checkboxCallback()
    end

    if (not self.closed) then
        self:close()
    end
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_SimplePricePopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end


-------------------------------------
-- function setPrice
-------------------------------------
function UI_SimplePricePopup:setPrice(price_type, price_value)
    local vars = self.vars
    self.m_priceType = price_type
    self.m_priceValue = price_value

    local price_icon = IconHelper:getPriceIcon(price_type)
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(price_icon)
    vars['priceLabel']:setString(comma_value(price_value))
end


--@CHECK
UI:checkCompileError(UI_SimplePopup2)

