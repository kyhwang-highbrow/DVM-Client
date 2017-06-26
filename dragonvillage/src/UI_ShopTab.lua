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
    --list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(list_table_node)
    table_view.m_defaultCellSize = cc.size(350 + 10, 470)
    table_view:setCellUIClass(UI_Product)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local tab_name = self.m_tabName
    local l_item_list = g_ghopDataNew:getProductList(tab_name)
    table_view:setItemList(l_item_list)
    self.m_tableView = table_view

    -- tab의 visible on/off를 위해
    self.root = table_view.m_scrollView

    self:sortProduct()
end

-------------------------------------
-- function sortProduct
-------------------------------------
function UI_ShopTab:sortProduct()
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        if (a_data:getUIPriority() ~= b_data:getUIPriority()) then
            return a_data:getUIPriority() > b_data:getUIPriority()
        end

        return a_data['product_id'] < b_data['product_id']
    end

    table.sort(self.m_tableView.m_itemList, sort_func)
end