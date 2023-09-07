local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())
-------------------------------------
-- class UI_RunePreset
-------------------------------------
UI_RunePreset = class(PARENT, {
    m_ownerUI = 'UI_RuneForgePresetTab',
    m_presetTableView = 'UIC_TableView',
    m_selectUI = '',
    m_presetRuneData = '',
    m_selectPresetIdx = 'number',
    m_selectPresetRuneSlotIdx = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_RunePreset:init(ower_ui)
    self.m_ownerUI = ower_ui
    self.m_selectUI = nil
    self.m_selectPresetIdx = 1
    self.m_selectPresetRuneSlotIdx = 1
    self.m_presetRuneData = clone(g_runePresetData:getRunePresetGroups())
    self:load_after()
end

-------------------------------------
-- function load_after
-------------------------------------
function UI_RunePreset:load_after()
    self:load('rune_preset_list.ui')
    self:initButton()
    self:initUI()
    self:initTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RunePreset:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_RunePreset:initTab()
    local vars = self.vars

    for i = 1, g_runePresetData:getPresetGroupCount() do
        local struct_preset_group = self.m_presetRuneData['rune_' .. i]
        vars[i .. 'TabLabel']:setString(struct_preset_group:getPresetGroupName())
        self:addTabAuto(i, vars)
    end

    self:setTab(1)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RunePreset:initButton()
    local vars = self.vars
    vars['nameBtn']:registerScriptTapHandler(function() self:click_nameBtn() end)
end

-------------------------------------
-- function getCurTabPresetGroup
-------------------------------------
function UI_RunePreset:getCurTabPresetGroup()
    return self.m_presetRuneData['rune_' .. self.m_currTab]
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_RunePreset:makeTableView()
    local vars = self.vars

    local node = vars['itemList']
    node:removeAllChildren()

    local function make_func(data)
        return UI_RunePresetItem(data, self)
    end

    local function create_func(ui, data)
        local select_rune_cb = function (preset_idx, rune_slot_idx)
            self.m_selectPresetIdx = preset_idx
            self.m_selectPresetRuneSlotIdx = rune_slot_idx

            self:setFocusRuneSlotIndex(rune_slot_idx)
            
            self.m_selectUI = ui
            self.m_ownerUI:onFocusSlotIndex(rune_slot_idx)
        end

        if self.m_selectUI == nil then
            self.m_selectUI = ui
        end

        ui.m_selectRuneCB = select_rune_cb
    end

    local m_rune_group = self:getCurTabPresetGroup()
    local table_view = UIC_TableViewTD(node)
    table_view.m_cellSize = cc.size(250, 168)
    table_view:setCellUIClass(make_func, create_func)
    table_view.m_nItemPerCell = 2
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(m_rune_group:getPresets())
    table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view:setCellCreatePerTick(3)
    self.m_presetTableView = table_view

end

-------------------------------------
-- function refreshTableView
-------------------------------------
function UI_RunePreset:refreshTableView(refresh_func)
    local struct_preset_group = self:getCurTabPresetGroup()
    self.m_presetTableView:mergeItemList(struct_preset_group:getPresets(), refresh_func)
end

-------------------------------------
-- function setFocusRune
-------------------------------------
function UI_RunePreset:setFocusRune(slot_idx, roid)
    local struct_preset_group = self:getCurTabPresetGroup()
    local preset_map = struct_preset_group:getPresets()
    local struct_preset = preset_map[self.m_selectPresetIdx]

    local function refresh_func(item, data)        
        local ui = item['ui']
        if ui ~= nil then
            ui.m_presetRune =  data
            ui:refresh()
        end
    end

    if struct_preset ~= nil then
        if roid == nil then
            struct_preset:setRune(slot_idx, nil)
        elseif type(roid) == 'table' then
            struct_preset.l_runes = roid
        else
            struct_preset:setRune(slot_idx, roid)
        end
        
        self:refreshTableView(refresh_func)
    end
end

-------------------------------------
-- function setFocusRuneSlotIndex
-------------------------------------
function UI_RunePreset:setFocusRuneSlotIndex(slot_idx)
    self.m_selectPresetRuneSlotIdx = slot_idx

    local function refresh_func(item, data)
        local ui = item['ui']
        if ui ~= nil then
            ui.m_presetRune =  data
            ui:refreshSelect()
        end
    end

    self:refreshTableView(refresh_func)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RunePreset:onChangeTab(tab, first)
    self.m_selectPresetIdx = 1
    self.m_selectPresetRuneSlotIdx = 1
    self.m_selectUI = nil
    self.m_ownerUI:onFocusSlotIndex(self.m_selectPresetRuneSlotIdx)
    
    self:makeTableView()
    self:refresh()
end

-------------------------------------
-- function getSelectPresetIdx
-------------------------------------
function UI_RunePreset:getSelectPresetIdx()
    return self.m_selectPresetIdx
end

-------------------------------------
-- function getSelectPresetSlotIdx
-------------------------------------
function UI_RunePreset:getSelectPresetSlotIdx()
    return self.m_selectPresetRuneSlotIdx
end

-------------------------------------
-- function getCurrentPresetData
-------------------------------------
function UI_RunePreset:getCurrentPresetData()
    return self.m_presetRuneData
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RunePreset:refresh()
    local vars = self.vars

    if vars['tabNameLabel'] ~= nil then
        local struct_preset_group = self:getCurTabPresetGroup()
        local group_name = struct_preset_group:getPresetGroupName()
        vars['tabNameLabel']:setString(group_name)

        local l_align_ui_list = {vars['tabNameLabel'], vars['nameBtn']}
        AlignUIPos(l_align_ui_list, 'HORIZONTAL', 'HEAD', 5)
    end

    for i = 1, g_runePresetData:getPresetGroupCount() do
        local struct_preset_group = self.m_presetRuneData['rune_' .. i]
        vars[i .. 'TabLabel']:setString(struct_preset_group:getPresetGroupName())
    end
end

-------------------------------------
-- function resetPresetData
-------------------------------------
function UI_RunePreset:resetPresetData()
    self.m_presetRuneData = clone(g_runePresetData:getRunePresetGroups())
    self:onChangeTab()
end

-------------------------------------
-- function click_nameBtn
-------------------------------------
function UI_RunePreset:click_nameBtn()
    local ok_cb = function (name)
        local success_cb = function()
            local struct_preset_group = self:getCurTabPresetGroup()
            struct_preset_group:setPresetGroupName(name)
    
            self:refresh()
    
            local t_tab_data = self.m_mTabData[self.m_currTab]
            t_tab_data['label']:setString(name)
        end

        g_runePresetData:setPresetGroupName(self.m_currTab, name)
        g_runePresetData:request_setRunePreset(nil, success_cb)
    end

    require('UI_ChangePresetNamePopup')
    local ui = UI_ChangePresetNamePopup(ok_cb)
end