local PARENT = class(UI_InventoryTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_InventoryTabRune
-------------------------------------
UI_InventoryTabRune = class(PARENT, {
        m_mTableViewListMap = 'map',
        m_mSortManagerMap = 'map',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabRune:init(inventory_ui)
    self.m_mTableViewListMap = {}
    self.m_mSortManagerMap = {}

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

    self.m_inventoryUI:setSelectedItem(nil, nil)
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
        
        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    local skip_update = true --정렬 시 update되기 때문에 skip
    table_view_td:setItemList(l_item_list, skip_update)

    -- 정렬
    local sort_manager = SortManager_Rune()
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:expandTemp(0.5)

    self.m_mSortManagerMap[rune_slot_type] = sort_manager
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

    PARENT.onEnterInventoryTab(self, first)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabRune:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    -- 내부 슬롯별 탭 정렬
    for rune_slot_type,table_view_td in pairs(self.m_mTableViewListMap) do
        local sort_manager = self.m_mSortManagerMap[rune_slot_type]
        
        sort_manager:setAllAscending(ascending)
        sort_manager:sortExecution(table_view_td.m_itemList)
        table_view_td:expandTemp(0.5)    
    end
end

-------------------------------------
-- function click_runeItem
-- @brief
-------------------------------------
function UI_InventoryTabRune:click_runeItem(data)
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabRune:onChangeSelectedItem(ui, data)
    local vars = self.vars
    local t_rune_data = data

    do-- 아이콘 표시
        vars['itemNode']:setVisible(true)
        local item = UI_RuneCard(t_rune_data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    local t_rune_information = t_rune_data['information']

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = t_rune_information['full_name']
        vars['itemNameLabel']:setString(name)
    end

    -- 주옵션 문자열
    local main_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['mopt'])
    vars['runeMainOptionLabel']:setVisible(true)
    vars['runeMainOptionLabel']:setString(main_option_str)

    -- 부옵션 문자열
    local sub_option_str = TableRuneStatus:makeRuneOptionStr(t_rune_information['status']['sopt'])
    vars['runeSubOptionLabel']:setVisible(true)
    vars['runeSubOptionLabel']:setString(sub_option_str)

    -- 세트 효과
    local t_rune_set = t_rune_data['rune_set']
    if t_rune_set then
        vars['runeSetLabel']:setVisible(true)
        local str = TableRuneStatus:makeRuneSetOptionStr(t_rune_set)
        vars['runeSetLabel']:setString(str)
    else
        vars['runeSetLabel']:setVisible(false)
    end
end