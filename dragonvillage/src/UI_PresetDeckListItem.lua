local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PresetDeckListItem
-------------------------------------
UI_PresetDeckListItem = class(PARENT, {
    m_presetDeck = 'StructPresetDeck',
    m_ownerUI = '',
    m_tableViewUI = 'UIC_TableViewTD',
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
    self:initTableView()
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
-- function initTableView
-------------------------------------
function UI_PresetDeckListItem:initTableView()
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
    table_view_td.m_cellSize = cc.size(95, 95)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_CharacterCard, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setItemList(deck_dragon_list)
    
    table_view_td.m_scrollView:setTouchEnabled(false)
    self.m_tableViewUI = table_view_td
end

-------------------------------------
-- function refreshTableView
-------------------------------------
function UI_PresetDeckListItem:refreshTableView()
    local deck_dragon_list = self:getDeckDragonList()
    local table_view_td = self.m_tableViewUI
    --table_view_td:mergeItemList(deck_dragon_list)

    for i, v in ipairs(deck_dragon_list) do
        table_view_td:replaceItemUI(i, v)
    end
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

    self.m_presetDeck:setDeckMap(curr_deck_info:getDeckMap())
    self.m_presetDeck:setFormation(curr_deck_info:getFormation())
    self.m_presetDeck:setLeader(curr_deck_info:getLeader())

    self:refresh()
    self.m_ownerUI:onChanged(clone(self.m_presetDeck))
end

-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_PresetDeckListItem:click_changeBtn()
    local success_cb = function (preset_deck_new)
        self.m_presetDeck:setDeckMap(preset_deck_new:getDeckMap())
        self.m_presetDeck:setFormation(preset_deck_new:getFormation())
        self.m_presetDeck:setLeader(preset_deck_new:getLeader())

        self:refresh()
        self.m_ownerUI:onChanged(clone(self.m_presetDeck))
    end

    UI_PresetDeckSetting.open(clone(self.m_presetDeck), success_cb)
end

-------------------------------------
-- function click_nameBtn
-------------------------------------
function UI_PresetDeckListItem:click_nameBtn()
    local struct_preset_deck = self.m_presetDeck

    local success_cb = function (name)
        struct_preset_deck:setPresetDeckName(name)
        self:refreshName()
        self.m_ownerUI:onChanged(clone(struct_preset_deck))
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