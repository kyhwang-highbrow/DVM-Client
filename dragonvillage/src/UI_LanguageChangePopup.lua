local PARENT = UI

-------------------------------------
---@class UI_LanguageChangePopup
---@brief popup_02.ui 사용하는 SimplePopup
-------------------------------------
UI_LanguageChangePopup = Class(PARENT,{
        m_msg = 'string',
        m_subMsg = 'string',
        m_cbOKBtn = 'function',
        m_cbCloseBtn = 'function',
    })

-------------------------------------
---@function init
-------------------------------------
function UI_LanguageChangePopup:init(msg, sub_msg, ok_btn_cb, close_btn_cb)
    self.m_uiName = 'UI_LanguageChangePopup'
    self.m_msg = msg
    self.m_subMsg = sub_msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCloseBtn = close_btn_cb

    local vars = self:load('popup_language.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_LanguageChangePopup')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
---@function initUI
-------------------------------------
function UI_LanguageChangePopup:initUI()
    local vars = self.vars

    -- textLabel1 : 본문
    -- textLabel2 : 부연 설명
    vars['textLabel1']:setString(self.m_msg)
    vars['textLabel2']:setString(self.m_subMsg)
end

-------------------------------------
---@function initButton
-------------------------------------
function UI_LanguageChangePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
---@function refresh
-------------------------------------
function UI_LanguageChangePopup:refresh()
    local vars = self.vars
end

-------------------------------------
---@function click_backKey
-------------------------------------
function UI_LanguageChangePopup:click_backKey()
    self:click_closeBtn()
end

-------------------------------------
---@function click_okBtn
-------------------------------------
function UI_LanguageChangePopup:click_okBtn()
    SafeFuncCall(self.m_cbOKBtn)

    if (not self.m_isClosed) then
        self:close()
    end
end

-------------------------------------
---@function click_closeBtn
-------------------------------------
function UI_LanguageChangePopup:click_closeBtn()
    SafeFuncCall(self.m_cbCloseBtn)

    if (not self.m_isClosed) then
        self:close()
    end
end


--@CHECK
UI:checkCompileError(UI_LanguageChangePopup)
