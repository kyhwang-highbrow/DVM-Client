local PARENT = UI

-------------------------------------
-- class UI_SimplePopup2
-------------------------------------
UI_SimplePopup2 = class(PARENT,{
        m_popupType = 'POPUP_TYPE',
        m_msg = 'string',
        m_submsg = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',

        m_bIsCheckboxActivated = 'boolean',
        m_checkboxCallback = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SimplePopup2:init(popup_type, msg, submsg, ok_btn_cb, cancel_btn_cb, ui_z_order)
    self.m_popupType = popup_type
    self.m_msg = submsg
    self.m_submsg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb
    self.m_uiName = 'UI_SimplePopup2'
    
    local vars = self:load('popup_02.ui')
    UIManager:open(self, ui_z_order or UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_SimplePopup2')

    self:initUI()
    self:initButton()
    self:refresh()

    MakeSimplePopupLog(msg, submsg)
end

-------------------------------------
-- function setCheckBoxCallback
-------------------------------------
function UI_SimplePopup2:setCheckBoxCallback(callback_function)
    self.m_checkboxCallback = callback_function
    self.vars['checkBtn']:setVisible(callback_function ~= nil)
end



-------------------------------------
-- function initUI
-------------------------------------
function UI_SimplePopup2:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimplePopup2:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBoxBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimplePopup2:refresh()
    local vars = self.vars

    vars['mainLabel']:setString(Str(self.m_msg))
    vars['subLabel']:setString(Str(self.m_submsg))
    
    if (self.m_popupType == POPUP_TYPE.OK) then
        vars['cancelBtn']:setVisible(false)
        vars['okBtn']:setPositionX(0)


    elseif (self.m_popupType == POPUP_TYPE.YES_NO) then
        vars['cancelBtn']:setVisible(true)
        vars['okBtn']:setPositionX(121)

    else
        error('self.m_popupType : ' .. self.m_popupType)
    end
end

-------------------------------------
-- function click_checkBoxBtn
-------------------------------------
function UI_SimplePopup2:click_checkBoxBtn()
    local vars = self.vars
    self.m_bIsCheckboxActivated = (not vars['checkSprite']:isVisible())

    vars['checkSprite']:setVisible(self.m_bIsCheckboxActivated)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_SimplePopup2:click_backKey()
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
function UI_SimplePopup2:click_okBtn()
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
function UI_SimplePopup2:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end




--@CHECK
UI:checkCompileError(UI_SimplePopup2)
