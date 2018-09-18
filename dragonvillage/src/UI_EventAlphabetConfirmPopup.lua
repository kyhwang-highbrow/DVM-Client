local PARENT = UI

-------------------------------------
-- class UI_EventAlphabetConfirmPopup
-------------------------------------
UI_EventAlphabetConfirmPopup = class(PARENT,{
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAlphabetConfirmPopup:init(wild_cnt, ok_btn_cb)
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = nil

    local vars = self:load('alphabet_event_confirm_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventAlphabetConfirmPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(wild_cnt)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAlphabetConfirmPopup:initUI(wild_cnt)
    local vars = self.vars
    local str = Str('부족한 알파벳이 있습니다.\n{@item_name}와일드 알파벳 {1}개{@default}를 사용해야 합니다.', wild_cnt)
    vars['dscLabel']:setString(str)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabetConfirmPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAlphabetConfirmPopup:refresh()
    local vars = self.vars

    -- 와일드 카드 아이콘, 수량 갱신
    local count = g_userData:get('alphabet', tostring(ITEM_ID_ALPHABET_WILD)) or 0
    local item_card = UI_ItemCard(ITEM_ID_ALPHABET_WILD, count)
    item_card.root:setSwallowTouch(false)
    vars['itemNode']:removeAllChildren()
    vars['itemNode']:addChild(item_card.root)
    if (count == 0) then
        item_card.vars['numberLabel']:setString(tostring(count))
    end
    cca.fruitReact(item_card.root, 1) -- 액션
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EventAlphabetConfirmPopup:click_okBtn()
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
function UI_EventAlphabetConfirmPopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    if (not self.closed) then
        self:close()
    end
end

--@CHECK
UI:checkCompileError(UI_EventAlphabetConfirmPopup)
