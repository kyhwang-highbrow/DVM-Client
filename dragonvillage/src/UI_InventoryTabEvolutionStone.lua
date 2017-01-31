local PARENT = UI_InventoryTab

-------------------------------------
-- class UI_InventoryTabEvolutionStone
-------------------------------------
UI_InventoryTabEvolutionStone = class(PARENT, {
        m_evolutionStoneTableView = 'UIC_TableViewTD',
        m_evolutionStoneSortManager = 'SortManager_EvolutionStone',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabEvolutionStone:init(inventory_ui)
    local vars = self.vars
end

-------------------------------------
-- function init_evolutionStoneTableView
-------------------------------------
function UI_InventoryTabEvolutionStone:init_evolutionStoneTableView()
    if self.m_evolutionStoneTableView then
        return
    end

    local node = self.vars['materialTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_userData:getEvolutionStoneList()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.72)

        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 열매 아이콘 생성 함수(내부에서 Item Card)
    local function EvolutionStoneCard(t_data)
        local item_id = t_data['esid']
        local count = t_data['count']
        return UI_ItemCard(item_id, count)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(EvolutionStoneCard, create_func)
    local skip_update = true --정렬 시 update되기 때문에 skip
    table_view_td:setItemList(l_item_list, skip_update)

    -- 정렬
    local sort_manager = SortManager_EvolutionStone()
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:expandTemp(0.5)
    self.m_evolutionStoneSortManager = sort_manager
    

    self.m_evolutionStoneTableView = table_view_td
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabEvolutionStone:onEnterInventoryTab(first)
    if first then
        self:init_evolutionStoneTableView()
    end

    PARENT.onEnterInventoryTab(self, first)
end

-------------------------------------
-- function onChangeSortAscending
-------------------------------------
function UI_InventoryTabEvolutionStone:onChangeSortAscending()
    PARENT.onChangeSortAscending(self)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabEvolutionStone:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    local table_view_td = self.m_evolutionStoneTableView
    local sort_manager = self.m_evolutionStoneSortManager

    -- 오름차순, 내림차순 정렬 변경
    sort_manager:setAllAscending(ascending)
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:expandTemp(0.5)    
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabEvolutionStone:onChangeSelectedItem(ui, data)
    local vars = self.vars

    do-- 아이콘 표시
        -- 열매 아이콘 생성 함수(내부에서 Item Card)
        local function EvolutionStoneCard(t_data)
            local item_id = t_data['esid']
            local count = t_data['count']
            return UI_ItemCard(item_id, count)
        end

        vars['itemNode']:setVisible(true)
        local item = EvolutionStoneCard(data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local esid = data['esid']
        local desc = TableItem():getValue(esid, 't_desc')
        vars['itemDscLabel']:setString(desc)
    end
end