local PARENT = UI

-------------------------------------
-- class UI_RuneAutoSellAgreePopup
-------------------------------------
UI_RuneAutoSellAgreePopup = class(PARENT,{
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneAutoSellAgreePopup:init(ok_btn_cb, cancel_btn_cb, t_setting)
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb

    local vars = self:load('popup_rune_auto_sell_agree.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_RuneAutoSellAgreePopup')

    self:initUI()
    self:initButton()
    self:refresh(t_setting)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneAutoSellAgreePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneAutoSellAgreePopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneAutoSellAgreePopup:refresh(t_setting)
    local vars = self.vars

    vars['starSprite1']:setVisible(t_setting[1])
    vars['starSprite2']:setVisible(t_setting[2])
    vars['starSprite3']:setVisible(t_setting[3])
    vars['starSprite4']:setVisible(t_setting[4])
    vars['starSprite5']:setVisible(t_setting[5])
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_RuneAutoSellAgreePopup:click_backKey()
    self:click_cancelBtn()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_RuneAutoSellAgreePopup:click_okBtn()
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
function UI_RuneAutoSellAgreePopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end

--@CHECK
UI:checkCompileError(UI_RuneAutoSellAgreePopup)
