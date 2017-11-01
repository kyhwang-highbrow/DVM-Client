local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ShopTab
-------------------------------------
UI_ShopTab = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_cbBuy = 'func',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopTab:init(owner_ui)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ShopTab:onEnterTab(first)
    if (not self.m_tableView) then
        self:initUI()
    end
  
    local sub_currency = self.m_tabName
    if (self.m_tabName == 'st') then
        sub_currency = 'amethyst'
    end
    g_topUserInfo:setSubCurrency(sub_currency)
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ShopTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopTab:initUI()
    local vars = self.vars

    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ShopTab:init_TableView()
    local list_table_node = self.m_ownerUI.vars['tableViewNode']

    -- 재료로 사용 가능한 리스트를 얻어옴
    local tab_name = self.m_tabName
    local l_item_list = g_shopDataNew:getProductList(tab_name)

    local scale = 1
    local item_per_cell = 2
    local interval = 15

    -- 탭에서 상품 개수가 6개 이상이 되면 3줄로 노출
    --if (6 < table.count(l_item_list)) then
    --    scale = 0.7
    --    item_per_cell = 3
    --    interval = 0
    --end

    -- 생성 콜백
	local function create_cb_func(ui, data)
        ui:setBuyCB(self.m_cbBuy)
        ui.root:setScale(scale)
	end    

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size((300 + interval) * scale, (280 + interval) * scale)
    table_view_td:setCellUIClass(UI_Product, create_cb_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view_td.m_nItemPerCell = item_per_cell
 
    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    table_view_td:setItemList(l_item_list)
    self.m_tableView = table_view_td

    -- tab의 visible on/off를 위해
    self.root = table_view_td.m_scrollView

    self:sortProduct()
end

-------------------------------------
-- function sortProduct
-- @brief 상품 정렬
-------------------------------------
function UI_ShopTab:sortProduct()
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        -- UI 우선순위 대로 정렬
        if (a_data:getUIPriority() ~= b_data:getUIPriority()) then
            return a_data:getUIPriority() > b_data:getUIPriority()
        end

        -- 우선순위가 동일할 경우 상품 ID가 낮은 순서대로 정렬
        return a_data['product_id'] < b_data['product_id']
    end

    table.sort(self.m_tableView.m_itemList, sort_func)
end

-------------------------------------
-- function clearProductList
-- @brief 상품 리스트 삭제
-------------------------------------
function UI_ShopTab:clearProductList()
    self.m_tableView = nil
    self.root = nil
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_ShopTab:setBuyCB(func)
    self.m_cbBuy = func
end