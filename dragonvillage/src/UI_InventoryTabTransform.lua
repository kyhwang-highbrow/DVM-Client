local PARENT = UI_InventoryTab

-------------------------------------
-- class UI_InventoryTabTransform
-------------------------------------
UI_InventoryTabTransform = class(PARENT, {
        m_transformTableView = 'UIC_TableViewTD',
        m_transformSortManager = 'SortManager_Transform',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabTransform:init(inventory_ui)
    local vars = self.vars
end

-------------------------------------
-- function init_transformTableView
-------------------------------------
function UI_InventoryTabTransform:init_transformTableView()
    if self.m_transformTableView then
        return
    end

    local node = self.vars['transformTableViewNode']

    local is_all = true
    local l_item_list = g_userData:getTransformList(is_all)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_Inventory.CARD_SCALE)

        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 외형변환 아이콘 생성 함수(내부에서 Item Card)
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
    local sort_manager = SortManager_Transform()
    sort_manager:sortExecution(table_view_td.m_itemList)
    self.m_transformSortManager = sort_manager

    self.m_transformTableView = table_view_td
end

-------------------------------------
-- function createCard
-------------------------------------
function UI_InventoryTabTransform:createCard(t_data)
    local item_id = t_data['mid']
    local count = t_data['count']
    local ui = UI_ItemCard(tonumber(item_id), 0)
    ui:setNumberLabel(count)

    return ui
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabTransform:onEnterInventoryTab(first)
    if first then
        self:init_transformTableView()
    end

    PARENT.onEnterInventoryTab(self, first)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabTransform:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    local table_view_td = self.m_transformTableView
    local sort_manager = self.m_transformSortManager

    -- 오름차순, 내림차순 정렬 변경
    sort_manager:setAllAscending(ascending)
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:setDirtyItemList()
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabTransform:onChangeSelectedItem(ui, data)
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
    vars['locationBtn']:registerScriptTapHandler(function() self:openAcuisitionRegionInformation(data['mid']) end)

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = TableItem():getValue(data['mid'], 't_name')
        vars['itemNameLabel']:setString(Str(name))
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local mid = data['mid']
        local desc = TableItem():getValue(mid, 't_desc')
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
function UI_InventoryTabTransform:sellBtn(data)
    local item_id = tonumber(data['mid'])
    local count = data['count']

    local function sell_cb(ret)
        self.m_inventoryUI:response_itemSell(ret)
        
        local item = nil
        for i,v in pairs(self.m_transformTableView.m_itemMap) do
            if (v['data']['mid'] == item_id) then
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
function UI_InventoryTabTransform:refresh_tableView()
    if (not self.m_transformTableView) then
        return
    end

    local is_all = true
    local l_item_list = g_userData:getTransformList(is_all)
    local l_item_map = {}
    for i,v in pairs(l_item_list) do
        local mid = tonumber(v['mid'])
        local count = v['count']
        l_item_map[mid] = count
    end

    self.m_inventoryUI:clearSelectedItem()

    local table_view = self.m_transformTableView
    for idx,item in pairs(table_view.m_itemMap) do
        local mid = tonumber(item['data']['mid'])
        if (not l_item_map[mid]) then
            table_view:delItem(idx)
        else
            local count = l_item_map[mid]
            if (item['data']['count'] ~= count) then
                item['data']['count'] = count
                local ui = item['ui']
                if (ui) then
                    ui:setNumberLabel(comma_value(count))
                    ui:setCheckSpriteVisible(false)
                    ui:setHighlightSpriteVisible(false)
                end
            end
        end
    end
end