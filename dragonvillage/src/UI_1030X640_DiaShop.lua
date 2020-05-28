local PARENT = UI

-------------------------------------
-- class UI_1030X640_DiaShop
-- @brief 다이아 상점
-------------------------------------
UI_1030X640_DiaShop = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_cbBuy = 'func',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_1030X640_DiaShop:init()
    self.m_uiName = 'UI_1030X640_DiaShop'
    
    local ui_res = 'dia_shop.ui'
    local vars = self:load(ui_res)

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    --self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_1030X640_DiaShop:initUI()
    self:init_TableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_1030X640_DiaShop:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_1030X640_DiaShop:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_1030X640_DiaShop:update(dt)
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_1030X640_DiaShop:init_TableView()
    local list_table_node = self.vars['tableViewNode']
    list_table_node:removeAllChildren()

    -- 재료로 사용 가능한 리스트를 얻어옴
    local tab_name = 'cash'--self.m_tabName
    local l_item_list = g_shopDataNew:getProductList(tab_name)

	-- 패키지 - 번들인 경우 하나만 ui에 나오도록
	if (tab_name == 'package') then
		self:dietPackageItemTable(l_item_list) -- 테이블 자체를 함수에서 조작한다
	end

    local ui_class = UI_Product
    local item_per_cell = 3
    local interval = 2
    local cell_width = 334
    local cell_height = 316

    -- 탭에서 상품 개수가 7개 이상이 되면 4줄로 노출
    if (7 <= table.count(l_item_list)) then
        ui_class = UI_ProductSmall
        item_per_cell = 4
        interval = 2
        cell_width = 250
        cell_height = 288
    end

    -- 생성 콜백
	local function create_cb_func(ui, data)
        ui:setBuyCB(function()
            self:init_TableView()
        end)
	end    

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size((cell_width + interval), (cell_height + interval))
    table_view_td:setCellUIClass(ui_class, create_cb_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_nItemPerCell = item_per_cell
	--table_view_td:setAlignCenter(true)

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    table_view_td:setItemList(l_item_list)
    self.m_tableView = table_view_td

    -- tab의 visible on/off를 위해
    --self.root = table_view_td.m_scrollView

    self:sortProduct()
end

-------------------------------------
-- function dietPackageItemTable
-- @brief 
-------------------------------------
function UI_1030X640_DiaShop:dietPackageItemTable(l_item_list)

	local copied_item_table = clone(l_item_list)
	local t_bundle_pids_list = {}

	for i, t_product in pairs(copied_item_table) do
		local product_id = t_product['product_id']
		local bundle_pids = TablePackageBundle:getPids(product_id)

		if (bundle_pids) then
			-- 이미 저장한 패키지
			if (t_bundle_pids_list[bundle_pids]) then
				-- 삭제
				l_item_list[product_id] = nil

			-- 패키지 번들 중 최초
			else
				t_bundle_pids_list[bundle_pids] = true
			end
		end
	end
end

-------------------------------------
-- function sortProduct
-- @brief 상품 정렬
-------------------------------------
function UI_1030X640_DiaShop:sortProduct()
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
-- function click_contractBtn
-------------------------------------
function UI_1030X640_DiaShop:click_contractBtn()
    GoToAgreeMentUrl()
end

--@CHECK
UI:checkCompileError(UI_1030X640_DiaShop)
