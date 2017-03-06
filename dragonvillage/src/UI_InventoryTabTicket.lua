local PARENT = UI_InventoryTab

-------------------------------------
-- class UI_InventoryTabTicket
-------------------------------------
UI_InventoryTabTicket = class(PARENT, {
        m_ticketTableView = 'UIC_TableViewTD',
        m_ticketSortManager = 'SortManager_Ticket',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabTicket:init(inventory_ui)
    local vars = self.vars
end

-------------------------------------
-- function init_ticketTableView
-------------------------------------
function UI_InventoryTabTicket:init_ticketTableView()
    if self.m_ticketTableView then
        return
    end

    local node = self.vars['ticketTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_userData:getTicketList()

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
        local item_id = t_data['ticket_id']
        local count = t_data['count']
        return UI_ItemCard(item_id, count)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(EvolutionStoneCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('티켓 인벤토리가 비어있습니다.'))

    --[[
    -- 정렬
    local sort_manager = SortManager_Ticket()
    sort_manager:sortExecution(table_view_td.m_itemList)
    self.m_ticketSortManager = sort_manager
    --]]
    

    self.m_ticketTableView = table_view_td
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabTicket:onEnterInventoryTab(first)
    if first then
        self:init_ticketTableView()
    end

    PARENT.onEnterInventoryTab(self, first)
end

-------------------------------------
-- function onChangeSortAscending
-------------------------------------
function UI_InventoryTabTicket:onChangeSortAscending()
    PARENT.onChangeSortAscending(self)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabTicket:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    --[[
    local table_view_td = self.m_ticketTableView
    local sort_manager = self.m_ticketSortManager

    -- 오름차순, 내림차순 정렬 변경
    sort_manager:setAllAscending(ascending)
    sort_manager:sortExecution(table_view_td.m_itemList)
    table_view_td:setDirtyItemList()
    --]]
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabTicket:onChangeSelectedItem(ui, data)
    local vars = self.vars

    do-- 아이콘 표시
        -- 열매 아이콘 생성 함수(내부에서 Item Card)
        local function EvolutionStoneCard(t_data)
            local item_id = t_data['ticket_id']
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
    vars['locationBtn']:registerScriptTapHandler(function() self:openAcuisitionRegionInformation(data['ticket_id']) end)

    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = TableItem():getValue(data['ticket_id'], 't_name')
        vars['itemNameLabel']:setString(name)
    end

    do -- 아이템 설명
        vars['itemDscLabel']:setVisible(true)
        local ticket_id = data['ticket_id']
        local desc = TableItem():getValue(ticket_id, 't_desc')
        vars['itemDscLabel']:setString(desc)
    end

    -- 판매 버튼
    if self.m_inventoryUI.m_selectSellItemsUI and (not self.m_inventoryUI.m_selectSellItemsUI.m_bActive) then
        vars['sellBtn']:setVisible(true)
    end
    vars['sellBtn']:registerScriptTapHandler(function() self:sellBtn(data) end)

    -- 사용하기 버튼
    vars['useLabel']:setString(Str('사용'))
    vars['useBtn']:setVisible(true)
    vars['useBtn']:registerScriptTapHandler(function() self:useBtn(data) end)
end

-------------------------------------
-- function sellBtn
-- @brief
-------------------------------------
function UI_InventoryTabTicket:sellBtn(data)
    local item_id = data['ticket_id']
    local count = data['count']

    local function sell_cb(ret)
        self.m_inventoryUI:response_itemSell(ret)
        
        local item = nil
        for i,v in pairs(self.m_ticketTableView.m_itemMap) do
            if (v['data']['ticket_id'] == item_id) then
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
-- function useBtn
-- @brief
-------------------------------------
function UI_InventoryTabTicket:useBtn(data)
    local item_id = data['ticket_id']
    local count = data['count']

    local function cb_func(ret)
        self.m_inventoryUI:response_itemSell(ret)
        self.m_inventoryUI:response_ticketUse(ret)

        -- 기존 아이템 있으면 선택
        local item = nil
        for i,v in pairs(self.m_ticketTableView.m_itemMap) do
            if (v['data']['ticket_id'] == item_id) then
                item = v
                break
            end
        end

        self.m_inventoryUI:clearSelectedItem()
        if item then
            self.m_inventoryUI:setSelectedItem(item['ui'], item['data'])
        end

        do -- 결과 팝업
            local item_id, count, t_sub_data = g_itemData:parseAddedItems_firstItem(ret['added_items'])
            MakeSimpleRewarPopup(Str('뽑기 결과'), item_id, count, t_sub_data)
        end
    end

    g_userData:request_ticketUse(item_id, cb_func)
end

-------------------------------------
-- function refresh_tableView
-------------------------------------
function UI_InventoryTabTicket:refresh_tableView()
    if (not self.m_ticketTableView) then
        return
    end

    local l_item_list = g_userData:getTicketList()
    local l_item_map = {}
    for i,v in pairs(l_item_list) do
        local ticket_id = tonumber(v['ticket_id'])
        local count = v['count']
        l_item_map[ticket_id] = count
    end

    local table_view = self.m_ticketTableView

    for idx,item in pairs(table_view.m_itemMap) do
        local ticket_id = tonumber(item['data']['ticket_id'])
        if (not l_item_map[ticket_id]) or (l_item_map[ticket_id] == 0) then
            table_view:delItem(idx)
        else
            local count = l_item_map[ticket_id]
            if (item['data']['count'] ~= count) then
                item['data']['count'] = count
                if item['ui'] then
                    item['ui']:setString(Str('X{1}', comma_value(count)))
                end
            end
        end
    end
end