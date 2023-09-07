local PARENT = UI_RunePreset
-------------------------------------
-- class UI_DragonRunesBulkEquipPresetTab
-------------------------------------
UI_DragonRunesBulkEquipPresetTab = class(PARENT, {
})


-------------------------------------
-- function load_after
-------------------------------------
function UI_DragonRunesBulkEquipPresetTab:load_after()
    self:load('rune_preset_apply_list.ui')
end

-------------------------------------
-- function setParentAndInit
-------------------------------------
function UI_DragonRunesBulkEquipPresetTab:setParentAndInit(parent_node)
    parent_node:addChild(self.root)
    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipPresetTab:initButton()
    local vars = self.vars
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonRunesBulkEquipPresetTab:onChangeTab(tab, first)
    self.m_selectPresetIdx = 0
    self.m_selectPresetRuneSlotIdx = 0
    self:makeTableView()
end

-------------------------------------
-- function makeTableView
-------------------------------------
function UI_DragonRunesBulkEquipPresetTab:makeTableView()
    local vars = self.vars

    local node = vars['itemList']
    node:removeAllChildren()

    local function make_func(data)
        return UI_RunePresetItem(data, self)
    end

    local function create_func(ui, data)
        local apply_preset_cb = function ()
            local l_roids = ui.m_presetRune:getRunesMap()
            local idx = ui.m_presetRune:getIndex()

            self.m_selectPresetIdx = idx
            self.m_selectPresetRuneSlotIdx = 0

            self:setFocusRuneSlotIndex(0)
            self.m_ownerUI:simulatePresetRune(l_roids)
        end

        ui.m_selectRuneCB = apply_preset_cb
        ui.vars['clickMenu']:setVisible(true)
        ui.vars['clickBtn']:registerScriptTapHandler(apply_preset_cb)
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