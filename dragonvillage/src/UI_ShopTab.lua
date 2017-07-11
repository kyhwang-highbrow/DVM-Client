local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ShopTab
-------------------------------------
UI_ShopTab = class(PARENT,{
        m_tableView = 'UIC_TableView',
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
    if (first == true) then
        self:initUI()
    end

    g_topUserInfo:setSubCurrency(self.m_tabName)
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

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(300 + 15, 280 + 15)
    table_view_td:setCellUIClass(UI_Product)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
 
    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local tab_name = self.m_tabName
    local l_item_list = g_shopDataNew:getProductList(tab_name)
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