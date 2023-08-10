local PARENT = UI
-------------------------------------
-- class UI_RunePreset
-------------------------------------
UI_RunePreset = class(PARENT, {
    m_presetTableView = 'UIC_TableView',
    m_selectGroup = 'number',
     })
-------------------------------------
-- function init
-------------------------------------
function UI_RunePreset:init()
    self.m_selectGroup = 1
    self:load('rune_preset_list.ui')
    self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RunePreset:initUI()
    local vars = self.vars
    local m_rune_group = g_runePresetData:getRunePresetGroups()

    for index, _ in ipairs(m_rune_group) do
        local str_btn = string.format('%dGroupBtn', index)
        vars[str_btn]:registerScriptTapHandler(function() self:click_groupBtn(index) end)
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RunePreset:initButton()
    local vars = self.vars
end

-------------------------------------
-- function initCombineTableView
-- @brief 오른쪽 합성 테이블뷰 생성
-------------------------------------
function UI_RunePreset:initCombineTableView()
    local vars = self.vars

    local node = vars['itemList']
    node:removeAllChildren()

    local function create_func(ui, data)
    end

    local m_rune_group = g_runePresetData:getRunePresets(self.m_selectGroup)
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(530, 105)
    table_view:setCellUIClass(UI_RuneForgeCombineItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view:setItemList(m_rune_group)
    self.m_presetTableView = table_view
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RunePreset:refresh()
    local vars = self.vars
    local m_rune_group = g_runePresetData:getRunePresetGroups()

    for index, _ in ipairs(m_rune_group) do
        local is_selected = self.m_selectGroup == index

        local str_btn = string.format('%dGroupBtn', index)
        vars[str_btn]:setEnabled(is_selected)

        local str_label = string.format('%GroupLabel', index)
        local color = is_selected and COLOR['DESC'] or COLOR['b']
        vars[str_label]:setColor(color)
    end
end

-------------------------------------
-- function click_groupBtn
-------------------------------------
function UI_RunePreset:click_groupBtn(group_num)
    local vars = self.vars

    self.m_selectGroup = 1

    self:initCombineTableView()

    self:refresh()
end
