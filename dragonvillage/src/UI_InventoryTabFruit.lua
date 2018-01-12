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
        ui.root:setScale(0.7)

        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
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
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('열매 가방이 비어있습니다.\n다양한 전투를 통해 열매을 획득해보세요!'))

    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view_td.m_itemList)
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
    table_view_td:setDirtyItemList()
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabFruit:onChangeSelectedItem(ui, data)
    local vars = self.vars

    do-- 아이콘 표시
        -- 열매 아이콘 생성 함수(내부에서 Item Card)
        local function FruitCard(t_data)
            local item_id = t_data['fid']
            local count = t_data['count']
            return UI_ItemCard(item_id, count)
        end

        vars['itemNode']:setVisible(true)
        local item = FruitCard(data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    -- 획득 지역 안내
    vars['locationBtn']:setVisible(true)
    vars['locationBtn']:registerScriptTapHandler(function() self:openAcuisitionRegionInformation(data['fid']) end)

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = TableItem():getValue(data['fid'], 't_name')
        vars['itemNameLabel']:setString(Str(name))
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local fid = data['fid']
        local desc = TableItem():getValue(fid, 't_desc')
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
function UI_InventoryTabFruit:sellBtn(data)
    local item_id = data['fid']
    local count = data['count']

    local function sell_cb(ret)
        self.m_inventoryUI:response_itemSell(ret)
        
        local item = nil
        for i,v in pairs(self.m_fruitsTableView.m_itemMap) do
            if (v['data']['fid'] == item_id) then
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
function UI_InventoryTabFruit:refresh_tableView()
    if (not self.m_fruitsTableView) then
        return
    end

    local l_item_list = g_userData:getFruitList()
    local l_item_map = {}
    for i,v in pairs(l_item_list) do
        local fid = tonumber(v['fid'])
        local count = v['count']
        l_item_map[fid] = count
    end

    local table_view = self.m_fruitsTableView

    for idx,item in pairs(table_view.m_itemMap) do
        local fid = tonumber(item['data']['fid'])
        if (not l_item_map[fid]) or (l_item_map[fid] == 0) then
            table_view:delItem(idx)
        else
            local count = l_item_map[fid]
            if (item['data']['count'] ~= count) then
                item['data']['count'] = count
                if item['ui'] then
                    item['ui']:setString(Str('{1}', comma_value(count)))
                end
            end
        end
    end
end