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
        ui.root:setScale(0.7)

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
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('진화석 인벤토리가 비어있습니다.\n다양한 전투를 통해 진화석을 획득해보세요!'))

    -- 정렬
    local sort_manager = SortManager_EvolutionStone()
    sort_manager:sortExecution(table_view_td.m_itemList)
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
    table_view_td:setDirtyItemList()
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

    -- 획득 지역 안내
    vars['locationBtn']:setVisible(true)
    vars['locationBtn']:registerScriptTapHandler(function() self:openAcuisitionRegionInformation(data['esid']) end)

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = TableItem():getValue(data['esid'], 't_name')
        vars['itemNameLabel']:setString(name)
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local esid = data['esid']
        local desc = TableItem():getValue(esid, 't_desc')
        vars['itemDscLabel']:setString(desc)
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

    local l_item_list = g_userData:getEvolutionStoneList()
    local l_item_map = {}
    for i,v in pairs(l_item_list) do
        local esid = tonumber(v['esid'])
        local count = v['count']
        l_item_map[esid] = count
    end

    local table_view = self.m_evolutionStoneTableView

    for idx,item in pairs(table_view.m_itemMap) do
        local esid = tonumber(item['data']['esid'])
        if (not l_item_map[esid]) or (l_item_map[esid] == 0) then
            table_view:delItem(idx)
        else
            local count = l_item_map[esid]
            if (item['data']['count'] ~= count) then
                item['data']['count'] = count
                if item['ui'] then
                    item['ui']:setString(Str('{1}', comma_value(count)))
                end
            end
        end
    end
end