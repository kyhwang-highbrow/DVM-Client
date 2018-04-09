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

    local is_all = true
    local l_item_list = g_evolutionStoneData:getEvolutionStoneList(is_all)
    local function make_func(data)
        return self:createCard(data)
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_Inventory.CARD_SCALE)

        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 열매 아이콘 생성 함수(내부에서 Item Card)
    local function make_func(t_data)
        return self:createCard(t_data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_Inventory.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    local sort_manager = SortManager_EvolutionStone()
    sort_manager:sortExecution(table_view_td.m_itemList)
    self.m_evolutionStoneSortManager = sort_manager
    
    self.m_evolutionStoneTableView = table_view_td
end

-------------------------------------
-- function createCard
-------------------------------------
function UI_InventoryTabEvolutionStone:createCard(t_data)
    local item_id = t_data['esid']
    local count = t_data['count']
    local ui = UI_ItemCard(tonumber(item_id), 0)
    ui:setAniNumber(count)

    return ui
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
    table_view_td:setDirtyItemList()
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabEvolutionStone:onChangeSelectedItem(ui, data)
    local vars = self.vars

    do-- 아이콘 표시
        vars['itemNode']:setVisible(true)
        local item = self:createCard(data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    -- 획득 지역 안내
    vars['hatcheryBtn']:setVisible(false)
    vars['locationBtn']:setVisible(true)
    vars['locationBtn']:registerScriptTapHandler(function() self:openAcuisitionRegionInformation(data['esid']) end)

    -- 조합/분해
    vars['combineBtn']:setVisible(true)
    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn(data['esid']) end)

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = TableItem():getValue(data['esid'], 't_name')
        vars['itemNameLabel']:setString(Str(name))
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local esid = data['esid']
        local desc = TableItem():getValue(esid, 't_desc')
        vars['itemDscLabel']:setString(Str(desc))
    end

    -- 판매 버튼
    if self.m_inventoryUI.m_selectSellItemsUI and (not self.m_inventoryUI.m_selectSellItemsUI.m_bActive) then
        vars['sellBtn']:setVisible(true)
    end
    vars['sellBtn']:registerScriptTapHandler(function() self:sellBtn(data) end)


end

-------------------------------------
-- function sellBtn
-- @brief
-------------------------------------
function UI_InventoryTabEvolutionStone:sellBtn(data)
    local item_id = data['esid']
    local count = data['count']

    local function sell_cb(ret)
        self.m_inventoryUI:response_itemSell(ret)
        
        local item = nil
        for i,v in pairs(self.m_evolutionStoneTableView.m_itemMap) do
            if (v['data']['esid'] == item_id) then
                item = v
                break
            end
        end

        self.m_inventoryUI:clearSelectedItem()
        if item then
            self.m_inventoryUI:setSelectedItem(item['ui'], item['data'])
        end
    end

    UI_InventorySellItems(item_id, count, sell_cb)
end

-------------------------------------
-- function refresh_tableView
-------------------------------------
function UI_InventoryTabEvolutionStone:refresh_tableView()
    if (not self.m_evolutionStoneTableView) then
        return
    end

    local function refresh_func(item, new_data)
        local old_data = item['data']
        if (old_data['esid'] == new_data['esid']) then
            self.m_evolutionStoneTableView:replaceItemUI(new_data['esid'], new_data)
        end
    end

    local is_all = true
    local l_item_list = g_evolutionStoneData:getEvolutionStoneList(is_all)
    self.m_evolutionStoneTableView:mergeItemList(l_item_list, refresh_func)
end

-------------------------------------
-- function click_combineBtn
-------------------------------------
function UI_InventoryTabEvolutionStone:click_combineBtn(item_id)
    local function update_cb()
        self.m_inventoryUI:clearSelectedItem()
        self:refresh_tableView()
    end
    -- 진화재료 조합/분해 진입시 선택판매는 비활성화로 변경 
    self.m_inventoryUI.m_selectSellItemsUI:setActive(false)

    local ui = UI_EvolutionStoneCombine(item_id)
    ui:setCloseCB(update_cb)
end