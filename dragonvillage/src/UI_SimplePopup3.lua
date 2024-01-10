local PARENT = UI

-------------------------------------
-- class UI_SimplePopup3
-------------------------------------
UI_SimplePopup3 = class(PARENT,{
        m_popupType = 'POPUP_TYPE',
        m_msg = 'string',
        m_submsg = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
        m_layer = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SimplePopup3:init(popup_type, msg, sub_msg, ok_btn_cb, cancel_btn_cb, layer)
    self.m_popupType = popup_type
    self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_submsg = sub_msg
    self.m_cbCancelBtn = cancel_btn_cb
    self.m_layer = layer

    local vars = self:load('popup_02.ui')
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_SimplePopup3')
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimplePopup3:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimplePopup3:refresh()
    local vars = self.vars

    vars['mainLabel']:setString(Str(self.m_msg))
    vars['subLabel']:setString(Str(self.m_submsg))

    vars['cancelBtn']:setVisible(true)
    vars['okBtn']:setPositionX(121)

end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_SimplePopup3:click_backKey()
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
function UI_SimplePopup3:click_okBtn()
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
function UI_SimplePopup3:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end
-------------------------------------
-- function close
-------------------------------------
function UI_SimplePopup3:close()
    if (self.m_layer) then
        self.m_layer:removeChild(self.root, true)
    end
end