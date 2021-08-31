local PARENT = UI

-------------------------------------
-- class UI_EventLFBagNoticePopup
-------------------------------------
UI_EventLFBagNoticePopup = class(PARENT,{
        m_popupType = 'POPUP_TYPE',
        m_msg = 'string',
        m_submsg = 'string',
        m_scoreString = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventLFBagNoticePopup:init(popup_type, msg, scoreString, submsg, ok_btn_cb, cancel_btn_cb, ui_z_order)
    self.m_popupType = popup_type
    self.m_msg = submsg
    self.m_scoreString = scoreString
    self.m_submsg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb
    self.m_uiName = 'UI_EventLFBagNoticePopup'
    
    local vars = self:load('event_lucky_bag_popup.ui')
    UIManager:open(self, ui_z_order or UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_EventLFBagNoticePopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventLFBagNoticePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventLFBagNoticePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventLFBagNoticePopup:refresh()
    local vars = self.vars

    vars['mainLabel']:setString(Str(self.m_msg))
    vars['subLabel']:setString(Str(self.m_submsg))
    vars['scoreLabel']:setString(Str(self.m_scoreString))
    
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
-- function click_backKey
-------------------------------------
function UI_EventLFBagNoticePopup:click_backKey()
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
function UI_EventLFBagNoticePopup:click_okBtn()
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
function UI_EventLFBagNoticePopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end

--@CHECK
UI:checkCompileError(UI_EventLFBagNoticePopup)
