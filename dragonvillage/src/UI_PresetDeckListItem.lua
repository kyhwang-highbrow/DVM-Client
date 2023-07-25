local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PresetDeckListItem
-------------------------------------
UI_PresetDeckListItem = class(PARENT, {
    m_presetDeck = 'StructPresetDeck',
    m_ownerUI = '',
    m_tableView = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PresetDeckListItem:init(struct_preset_deck, owner_ui)
    self.m_presetDeck = struct_preset_deck
    self.m_ownerUI = owner_ui
    self:load('preset_deck_list_item.ui')
    self:initUI()
    self:initButton()
    self:refresh()
    self:refreshName()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetDeckListItem:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PresetDeckListItem:initButton()
    local vars = self.vars
    vars['importBtn']:registerScriptTapHandler(function() self:click_importBtn() end)
    vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
    vars['nameBtn']:registerScriptTapHandler(function() self:click_nameBtn() end)
    vars['applyBtn']:registerScriptTapHandler(function() self:click_applyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PresetDeckListItem:refresh()
    self:refreshName()
    self:refreshTableView()
end

-------------------------------------
-- function refreshName
-------------------------------------
function UI_PresetDeckListItem:refreshName()
    local vars = self.vars
    local struct_preset_deck = self.m_presetDeck

    do -- 이름
        vars['deckNameLabel']:setString(struct_preset_deck:getPresetDeckName()) 
    end

    local l_align_ui_list = {vars['deckNameLabel'], vars['nameBtn']}
    AlignUIPos(l_align_ui_list, 'HORIZONTAL', 'HEAD', 10)
end

-------------------------------------
-- function refreshTableView
-------------------------------------
function UI_PresetDeckListItem:refreshTableView()
    local vars = self.vars
    local node = vars['dragonListNode']
    node:removeAllChildren()

    local function create_func(ui, t_dragon_data)
        ui.root:setScale(0.6)
        -- 카드 프레임
        ui:makeFrame()

        local function func()
            local doid = t_dragon_data['id']
            if doid and (doid ~= '') then
                UI_SimpleDragonInfoPopup(t_dragon_data)
            end
        end

        local function tap_func()
            self:click_changeBtn()
        end

        ui.vars['clickBtn']:registerScriptPressHandler(func)
        ui.vars['clickBtn']:registerScriptTapHandler(tap_func)
    end

    local deck_dragon_list = self:getDeckDragonList()

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_CharacterCard, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setItemList(deck_dragon_list)
    table_view_td.m_scrollView:setTouchEnabled(false)
    self.m_tableView = table_view_td
end

-------------------------------------
-- function getDeckDragonList
-------------------------------------
function UI_PresetDeckListItem:getDeckDragonList()
    local deck_dragon_map = self.m_presetDeck:getDeckMap()
    local l_dragon_list = {}
    
    for i = 1, 5 do
        local doid = deck_dragon_map[i]
        if doid ~= nil then
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            table.insert(l_dragon_list, t_dragon_data)
        else
            table.insert(l_dragon_list, StructDragonObject())
        end
    end

    return l_dragon_list
end

-------------------------------------
-- function click_importBtn
-------------------------------------
function UI_PresetDeckListItem:click_importBtn()
    local curr_deck_info = self.m_ownerUI:getCurrDeckInfo()
    local struct_preset_deck = self.m_presetDeck

    struct_preset_deck:setDeckMap(curr_deck_info:getDeckMap())
    struct_preset_deck:setFormation(curr_deck_info:getFormation())
    struct_preset_deck:setLeader(curr_deck_info:getLeader())

    self.m_ownerUI:onChanged(struct_preset_deck)
    self:refresh()
end

-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_PresetDeckListItem:click_changeBtn()
    local struct_preset_deck = self.m_presetDeck

    local success_cb = function (preset_deck_new)
        struct_preset_deck:setDeckMap(preset_deck_new:getDeckMap())
        struct_preset_deck:setFormation(preset_deck_new:getFormation())
        struct_preset_deck:setLeader(preset_deck_new:getLeader())
        self:refresh()
        self.m_ownerUI:onChanged(struct_preset_deck)
    end

    UI_PresetDeckSetting.open(struct_preset_deck, success_cb)
end

-------------------------------------
-- function click_nameBtn
-------------------------------------
function UI_PresetDeckListItem:click_nameBtn()
    local struct_preset_deck = self.m_presetDeck

    local success_cb = function (name)
        struct_preset_deck:setPresetDeckName(name)
        self:refreshName()
        self.m_ownerUI:onChanged(struct_preset_deck)
    end

    require('UI_ChangePresetNamePopup')
    local ui = UI_ChangePresetNamePopup(success_cb)
end

-------------------------------------
-- function click_applyBtn
-------------------------------------
function UI_PresetDeckListItem:click_applyBtn()
    local struct_preset_deck = self.m_presetDeck
    self.m_ownerUI:onApply(struct_preset_deck)
end