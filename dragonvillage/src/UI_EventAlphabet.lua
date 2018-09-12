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

    if true then
        return
    end

    -- 이벤트 종료 시간
    vars['timeLabel']:setString(event_data:getStatusText())
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabet:initButton()
    if true then
        return
    end

    local vars = self.vars
    vars['dungeonBtn']:registerScriptTapHandler(function() self:click_dungeonBtn() end)
    vars['dungeonInfoBtn']:registerScriptTapHandler(function() self:click_dungeonInfoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAlphabet:refresh()
    local vars = self.vars

    for i,v in pairs(self.m_eventDataUI) do
        v:refresh()
    end
end

-------------------------------------
-- function click_dungeonBtn
-- @brief 던전 입장
-------------------------------------
function UI_EventAlphabet:click_dungeonBtn()
    UI_ReadySceneNew(EVENT_GOLD_STAGE_ID)


    -- 전투 준비 화면에서 1일 1회 황금 던전 설명 팝업 띄움
    local save_key = 'event_gold_dungeon'
    local is_view = g_settingData:get('event_full_popup', save_key) or false
    if (is_view == true) then
        return
    end

    local function cb_func()
        g_settingData:applySettingData(true, 'event_full_popup', save_key)
    end

    local ui = UI_EventAlphabetPopup()
    ui:setCloseCB(cb_func)
end

-------------------------------------
-- function click_dungeonInfoBtn
-- @brief 황금 던전 설명 팝업
-------------------------------------
function UI_EventAlphabet:click_dungeonInfoBtn()
    UI_EventAlphabetPopup()
end
