local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChatMacroListItem
-------------------------------------
UI_ChatMacroListItem = class(PARENT, {
        m_macro = 'string',
        m_idx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatMacroListItem:init(data)
    self.m_macro = data['macro']
    self.m_idx = data['idx']

    local vars = self:load('chat_macro_item.ui')

    self:initUI()
    self:initEditBox()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatMacroListItem:initUI()
    local vars = self.vars

    do -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
        local function editBoxTextEventHandle(strEventName,pSender)
            if (strEventName == "return") then
                self:click_editBtn()
            end
        end
        vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
        vars['editBox']:setMaxLength(CHAT_MAX_MESSAGE_LENGTH) -- 글자 입력 제한 40자
    end
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_ChatMacroListItem:initEditBox()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatMacroListItem:initButton()
    local vars = self.vars

    -- UI_ChatPopup에서 등록
    --vars['macroBtn']:registerScriptTapHandler(function() self:click_macroBtn() end)

    -- edit box로 동작 editBtn은 껍데기
    --vars['editBtn']:registerScriptTapHandler(function() self:click_editBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatMacroListItem:refresh()
    local vars = self.vars
    vars['macroLabel']:setString(self.m_macro)    
end

-------------------------------------
-- function click_editBtn
-------------------------------------
function UI_ChatMacroListItem:click_editBtn()
    local vars = self.vars
    
    self.m_macro = vars['editBox']:getText()
    vars['editBox']:setText('')

    g_chatMacroData:setMacro(self.m_idx, self.m_macro)

    self:refresh()
end