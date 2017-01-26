local PARENT = UI_InventoryTab

-------------------------------------
-- class UI_InventoryTabFruit
-------------------------------------
UI_InventoryTabFruit = class(PARENT, {
        m_fruitsTableView = 'UIC_TableViewTD',
        m_fruitSortManager = 'SortManager_Fruit',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabFruit:init(inventory_ui)
    local vars = self.vars
end

-------------------------------------
-- function init_fruitTableView
-------------------------------------
function UI_InventoryTabFruit:init_fruitTableView()
    if self.m_fruitsTableView then
        return
    end

    local node = self.vars['fruitTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_userData:getFruitList()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.72)
    end

    -- 열매 아이콘 생성 함수(내부에서 Item Card)
    local function FruitCard(t_data)
        local item_id = t_data['fid']
        local count = t_data['count']
        return UI_ItemCard(item_id, count)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(FruitCard, create_func)
    local skip_update = true --정렬 시 update되기 때문에 skip
    table_view_td:setItemList(l_item_list, skip_update)

    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:expandTemp(0.5)
    self.m_fruitSortManager = sort_manager


    self.m_fruitsTableView = table_view_td
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabFruit:onEnterInventoryTab(first)
    if first then
        self:init_fruitTableView()
    end

    PARENT.onEnterInventoryTab(self, first)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabFruit:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    local table_view_td = self.m_fruitsTableView
    local sort_manager = self.m_fruitSortManager

    -- 오름차순, 내림차순 정렬 변경
    sort_manager:setAllAscending(ascending)
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:expandTemp(0.5)    
end