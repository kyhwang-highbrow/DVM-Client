local PARENT = class(UI_InventoryTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_InventoryTabRune
-------------------------------------
UI_InventoryTabRune = class(PARENT, {
        m_mTableViewListMap = 'map',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabRune:init(inventory_ui)
    self.m_mTableViewListMap = {}

    local vars = self.vars

    -- 'inventory.ui'를 사용
    self:addTab(g_runesData:getSlotName(1), vars['runeBtn1'], vars['runeTableViewNode1'])
    self:addTab(g_runesData:getSlotName(2), vars['runeBtn2'], vars['runeTableViewNode2'])
    self:addTab(g_runesData:getSlotName(3), vars['runeBtn3'], vars['runeTableViewNode3'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_InventoryTabRune:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    local rune_slot_type = tab

    if first then
        self:init_runeTableView(rune_slot_type)
    else
        local table_view_td = self.m_mTableViewListMap[rune_slot_type]
        local animated = false
        table_view_td:relocateContainerDefault(animated)
    end
end

-------------------------------------
-- function init_runeTableView
-------------------------------------
function UI_InventoryTabRune:init_runeTableView(rune_slot_type)

    local slot_idx = g_runesData:getSlotIdx(rune_slot_type)
    local node = self.vars['runeTableViewNode' .. slot_idx]
    --node:removeAllChildren()

    local l_item_list = g_runesData:getUnequippedRuneList(rune_slot_type)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.72)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    local skip_update = true --정렬 시 update되기 때문에 skip
    table_view_td:setItemList(l_item_list, skip_update)

    -- 정렬
    local sort_type = 'default'
    local rune_sort_manager = RuneSortManager()
    local function sort_func(a, b)
        return rune_sort_manager:sortFunc(a, b)
    end
    table_view_td:insertSortInfo(sort_type, sort_func)
    local b_force = false
    table_view_td:sortTableView(sort_type, b_force)


    self.m_mTableViewListMap[rune_slot_type] = table_view_td
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabRune:onEnterInventoryTab(first)
    if first then
        local default_tab = g_runesData:getSlotName(1)
        self:setTab(default_tab)
    end
end