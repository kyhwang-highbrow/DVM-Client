local PARENT = UI
-------------------------------------
-- class UI_PresetDeckList
-------------------------------------
UI_PresetDeckList = class(PARENT, {
        m_presetDeckMap = 'List<string>',
        m_currDeck = 'StructPresetDeck',
        m_deckCategory = 'string',
        m_tableView = 'UIC_TableViewTD',
        m_jsonCode = 'string',
        m_applyCb = 'function',
        m_dirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PresetDeckList:init(deck_category, curr_deck, cb_deck_change)
    self.m_uiName = 'UI_PresetDeckList'
    self.m_deckCategory = deck_category
    self.m_currDeck = curr_deck
    
    self.m_dirty = false
    self.m_applyCb = cb_deck_change

    self:load('preset_deck_list.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_PresetDeckList')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetDeckList:initUI()
    local vars = self.vars

    self.m_presetDeckMap = g_deckPresetData:getPresetDeckMap(self.m_deckCategory)

    self.m_jsonCode = dkjson.encode(self.m_presetDeckMap)

    for _, struct_preset_deck in ipairs(self.m_presetDeckMap) do
        struct_preset_deck:correctData()
    end
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_PresetDeckList:initTableView()
    local vars = self.vars
    local node = vars['dragonListNode']
    local deck_map = self.m_presetDeckMap

    local function make_func(data)
        local ui = UI_PresetDeckListItem(data, self)
        return ui
    end

    -- 테이블뷰 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(600, 155)
    table_view:setCellUIClass(make_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(deck_map)
    self.m_tableView = table_view


end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PresetDeckList:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PresetDeckList:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onChanged
-------------------------------------
function UI_PresetDeckList:onChanged(struct_preset_deck)
    local idx = struct_preset_deck:getIndex()
    self.m_presetDeckMap[idx] = struct_preset_deck
end

-------------------------------------
-- function onApply
-------------------------------------
function UI_PresetDeckList:onApply(struct_preset_deck)
    if self.m_applyCb ~= nil then
        self.m_applyCb(struct_preset_deck)
    end
end

-------------------------------------
-- function onApplied
-------------------------------------
function UI_PresetDeckList:onApplied(struct_preset_deck)
    self.m_currDeck = struct_preset_deck

    for i,v in pairs(self.m_tableView.m_itemList) do
        local ui = v['ui']
        if ui ~= nil then
            ui:refresh()
        end
    end
end

-------------------------------------
-- function getCurrDeckInfo
-------------------------------------
function UI_PresetDeckList:getCurrDeckInfo()
    return self.m_currDeck
end

-------------------------------------
-- function setDirty
-------------------------------------
function UI_PresetDeckList:setDirty(dirty)
    self.m_dirty = dirty
end

------------------------------------
-- function click_okBtn
-------------------------------------
function UI_PresetDeckList:click_closeBtn()
    local jsonCode = dkjson.encode(self.m_presetDeckMap)
    --self:close()

    if self.m_jsonCode == jsonCode and self.m_dirty == false then
        self:close()
        return
    end

    local success_cb = function(ret)
        self:close()
    end

    g_deckPresetData:request_setPresetDeck(self.m_deckCategory, jsonCode, success_cb, success_cb)
end

-------------------------------------
-- function open
-------------------------------------
function UI_PresetDeckList.open(deck_name, curr_deck, cb_deck_change)
    local deck_category = g_deckPresetData:getPresetDeckCategory(deck_name)
    local ui = UI_PresetDeckList(deck_category, curr_deck, cb_deck_change)
    return ui
end

--@CHECK
UI:checkCompileError(UI_PresetDeckList)