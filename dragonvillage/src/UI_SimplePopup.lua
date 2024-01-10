local PARENT = UI

-------------------------------------
-- class UI_SimplePopup
-------------------------------------
UI_SimplePopup = class(PARENT,{
        m_popupType = 'POPUP_TYPE',
        m_msg = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SimplePopup:init(popup_type, msg, ok_btn_cb, cancel_btn_cb, ui_z_order)
    self.m_popupType = popup_type
    self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb

    local vars = self:load('popup_01.ui')
    UIManager:open(self, ui_z_order or UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_SimplePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SimplePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimplePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimplePopup:refresh()
    local vars = self.vars

    vars['titleLabel']:setString(Str('확인'))

    vars['dscLabel']:setString(Str(self.m_msg))
    
    if (self.m_popupType == POPUP_TYPE.OK) then
        vars['cancelBtn']:setVisible(false)
        vars['okBtn']:setPositionX(0)


    elseif (self.m_popupType == POPUP_TYPE.YES_NO) then
        vars['cancelBtn']:setVisible(true)
        vars['okBtn']:setPositionX(121)

    else
        error('self.m_popupType : ' .. self.m_popupType)
    end

    vars['closeBtn']:setVisible(false)
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_SimplePopup:click_backKey()
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
function UI_SimplePopup:click_okBtn()
    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    if (not self.closed) then
        self:close()
    end
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_SimplePopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end

--@CHECK
UI:checkCompileError(UI_SimplePopup)
