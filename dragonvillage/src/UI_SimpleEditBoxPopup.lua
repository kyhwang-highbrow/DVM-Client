local PARENT = UI

-------------------------------------
-- class UI_SimpleEditBoxPopup
-------------------------------------
UI_SimpleEditBoxPopup = class(PARENT,{
        m_confirmCB = 'function',
        m_retType = 'string', -- 'ok', 'cancel'
        m_str = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleEditBoxPopup:init()
    self.m_uiName = 'UI_SimpleEditBoxPopup'

    local vars = self:load('chat_editbox_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:closeWithRetType('cancel') end, 'UI_SimpleEditBoxPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

--[[
-------------------------------------
-- function close
-------------------------------------
function UI_SimpleEditBoxPopup:close()
    if not self.enable then return end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 0.5, false)
end
--]]

-------------------------------------
-- function initUI
-------------------------------------
function UI_SimpleEditBoxPopup:initUI()
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
    do -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
        local function editBoxTextEventHandle(strEventName,pSender)
            if (strEventName == "return") then
                -- 규석: IOS에서는 return과 동시에 close콜백 호출하면 스크립트 이벤트가 실행되고 editbox가 null이 아닌경우로 판단하여 오류남
                --self:click_okBtn()
            end
        end
        vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
    end



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
function UI_SimpleEditBoxPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:closeWithRetType('cancel') end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimpleEditBoxPopup:refresh()
end

-------------------------------------
-- function setPopupTitle
-------------------------------------
function UI_SimpleEditBoxPopup:setPopupTitle(str)
    local vars = self.vars
    --vars['titleLabel']:setString(str)
end

-------------------------------------
-- function setPopupDsc
-------------------------------------
function UI_SimpleEditBoxPopup:setPopupDsc(str)
    local vars = self.vars
    vars['dscLabel']:setString(str)
end

-------------------------------------
-- function setPlaceHolder
-------------------------------------
function UI_SimpleEditBoxPopup:setPlaceHolder(str)
    local vars = self.vars
    vars['editBox']:setPlaceHolder(str)
end

-------------------------------------
-- function setConfirmCB
-------------------------------------
function UI_SimpleEditBoxPopup:setConfirmCB(func)
    self.m_confirmCB = func
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_SimpleEditBoxPopup:click_okBtn()
    if self.m_confirmCB then
        local vars = self.vars
        local str = vars['editBox']:getText()
        
        if (not self.m_confirmCB(str)) then
            return
        end

        self.m_str = str
    end

    self:closeWithRetType('ok')
end

-------------------------------------
-- function closeWithRetType
-------------------------------------
function UI_SimpleEditBoxPopup:closeWithRetType(ret_type)
    if (ret_type == 'ok') then
    elseif (ret_type == 'cancel') then
    else
        error('ret_type : ' .. ret_type)
    end

    self.m_retType = ret_type
    self:close()
end



--@CHECK
UI:checkCompileError(UI_SimpleEditBoxPopup)
