local PARENT = UI_InventoryTab

-------------------------------------
-- class UI_InventoryTabEgg
-------------------------------------
UI_InventoryTabEgg = class(PARENT, {
        m_eggTableView = 'UIC_TableViewTD',
        m_fruitSortManager = 'SortManager_Fruit',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabEgg:init(inventory_ui)
    local vars = self.vars
end

-------------------------------------
-- function init_eggTableView
-------------------------------------
function UI_InventoryTabEgg:init_eggTableView()
    if self.m_eggTableView then
        return
    end

    local node = self.vars['eggTableViewNode']
    local l_item_list = g_eggsData:getEggList()
        
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
    table_view_td:makeDefaultEmptyDescLabel(Str('보유한 알이 없습니다.'))

    self.m_eggTableView = table_view_td
end

-------------------------------------
-- function createCard
-------------------------------------
function UI_InventoryTabEgg:createCard(t_data)
    local item_id = t_data['egg_id']
    local count = t_data['count']
    local ui = UI_ItemCard(tonumber(item_id), 0)
    ui:setNumberLabel(count)

    return ui
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabEgg:onEnterInventoryTab(first)
    if first then
        self:init_eggTableView()
    end

    PARENT.onEnterInventoryTab(self, first)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabEgg:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    local table_view_td = self.m_eggTableView
    local sort_manager = self.m_fruitSortManager

    -- 오름차순, 내림차순 정렬 변경
    sort_manager:setAllAscending(ascending)
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:setDirtyItemList()
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabEgg:onChangeSelectedItem(ui, data)
    local vars = self.vars

    do-- 아이콘 표시
        vars['itemNode']:setVisible(true)
        local item = self:createCard(data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    -- 획득 지역 안내
    vars['locationBtn']:setVisible(false)

    -- 부화소 바로 가기 
    vars['hatcheryBtn']:setVisible(true)
    vars['hatcheryBtn']:registerScriptTapHandler(function() self:click_hatcheryBtn(data['egg_id']) end)

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = TableItem():getValue(data['egg_id'], 't_name')
        vars['itemNameLabel']:setString(Str(name))
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local egg_id = tonumber(data['egg_id'])
        local desc = TableItem():getValue(egg_id, 't_desc')
        vars['itemDscLabel']:setString(Str(desc))
    end

    -- 판매 버튼
    if self.m_inventoryUI.m_selectSellItemsUI and (not self.m_inventoryUI.m_selectSellItemsUI.m_bActive) then
        vars['sellBtn']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_tableView
-------------------------------------
function UI_InventoryTabEgg:refresh_tableView()
    if (not self.m_eggTableView) then
        return
    end

    local l_item_list = g_eggsData:getEggList()
    local l_item_map = {}
    for i,v in pairs(l_item_list) do
        local egg_id = tonumber(v['egg_id'])
        local count = v['count']
        l_item_map[egg_id] = count
    end

    local table_view = self.m_eggTableView

    for idx,item in pairs(table_view.m_itemMap) do
        local egg_id = tonumber(item['data']['egg_id'])
        if (not l_item_map[egg_id]) or (l_item_map[egg_id] == 0) then
            table_view:delItem(idx)
        else
            local count = l_item_map[egg_id]
            if (item['data']['count'] ~= count) then
                item['data']['count'] = count
                if item['ui'] then
                    item['ui']:setString(Str('{1}', comma_value(count)))
                end
            end
        end
    end
end

-------------------------------------
-- function click_hatcheryBtn
-------------------------------------
function UI_InventoryTabEgg:click_hatcheryBtn(target_id)
    UINavigator:goTo('hatchery', 'incubate', target_id)
end