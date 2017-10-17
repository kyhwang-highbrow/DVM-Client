local PARENT = UI

-------------------------------------
-- class UI_EditBoxPopup
-------------------------------------
UI_EditBoxPopup = class(PARENT,{
        m_confirmCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EditBoxPopup:init()
    local vars = self:load('editbox_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_EditBoxPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function close
-------------------------------------
function UI_EditBoxPopup:close()
    if not self.enable then return end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 0.5, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EditBoxPopup:initUI()
    -- titleLabel
    -- dscLabel
    -- editBox
    -- okBtn

    local vars = self.vars

    vars['editBox']:setMaxLength(9)

    -- began
    -- changed
    -- ended
    -- return
    vars['editBox']:registerScriptEditBoxHandler(function(event)
        --cclog('### event ' .. event)
    end)

    --vars['editBox']:openKeyboard()

    -- getText()
    -- setText('')
    -- openKeyboard()
    -- setMaxLength(20)
    -- setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    -- registerScriptEditBoxHandler(function(event)

    local len = uc_len(nickName)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EditBoxPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EditBoxPopup:refresh()
end

-------------------------------------
-- function setPopupTitle
-------------------------------------
function UI_EditBoxPopup:setPopupTitle(str)
    local vars = self.vars
    vars['titleLabel']:setString(str)
end

-------------------------------------
-- function setPopupDsc
-------------------------------------
function UI_EditBoxPopup:setPopupDsc(str)
    local vars = self.vars
    vars['dscLabel']:setString(str)
end

-------------------------------------
-- function setPlaceHolder
-------------------------------------
function UI_EditBoxPopup:setPlaceHolder(str)
    local vars = self.vars
    vars['editBox']:setPlaceHolder(str)
end

-------------------------------------
-- function setConfirmCB
-------------------------------------
function UI_EditBoxPopup:setConfirmCB(func)
    self.m_confirmCB = func
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EditBoxPopup:click_okBtn()
    if self.m_confirmCB then
        local vars = self.vars
        local str = vars['editBox']:getText()

        if (not self.m_confirmCB(str)) then
            return
        end
    end

    self:close()
end



--@CHECK
UI:checkCompileError(UI_EditBoxPopup)
