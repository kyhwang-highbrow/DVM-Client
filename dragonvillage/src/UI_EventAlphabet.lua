local PARENT = UI

-------------------------------------
-- class UI_EventAlphabet
-------------------------------------
UI_EventAlphabet = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAlphabet:init()
    local vars = self:load('alphabet_event.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAlphabet:initUI()
    local vars = self.vars

    local l_word = TableAlphabetEvent:getWordList()

    self.m_eventDataUI = {}
    for i,v in ipairs(l_word) do
        local ui_name

        if (i == 1) then
            ui_name = 'alphabet_event_list_item_01.ui'
        else
            ui_name = 'alphabet_event_list_item_02.ui'
        end

        local list_item = UI_EventAlphabetListItem(ui_name, v)
        vars['itemNode' .. i]:removeAllChildren()
        vars['itemNode' .. i]:addChild(list_item.root)
        list_item:setRefreshCB(function() self:refresh() end)
        self.m_eventDataUI[i] = list_item
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabet:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-- 정보 갱신
-------------------------------------
function UI_EventAlphabet:refresh()
    local vars = self.vars

    -- 이벤트 종료 시간 갱신
    vars['timeLabel']:setString(g_eventAlphabetData:getStatusText())

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
    
    -- 단어 리스트 UI 갱신 (UI_EventAlphabetListItem 클래스의 refresh)
    for i,v in pairs(self.m_eventDataUI) do
        v:refresh()
    end
end

-------------------------------------
-- function click_infoBtn
-- @brief 알파벳 획득처 안내 팝업
-------------------------------------
function UI_EventAlphabet:click_infoBtn()
    UI_EventAlphabetInfoPopup()
end
