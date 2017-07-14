local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ShopPopup
-------------------------------------
UI_ShopPopup = class(PARENT, {
        m_tableView = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopPopup:init()
    local vars = self:load('shop_popup.ui')
    UIManager:open(self, UIManager.SCENE)
    
	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPopup')
	
	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

    self:initUI()
	self:initButton()
	self:refresh()

    self:init_TableView()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_ShopPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ShopPopup'
    self.m_titleStr = Str('상점')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ShopPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ShopPopup:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ShopPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ShopPopup:init_TableView()
    local list_table_node = self.vars['tableViewNode']

    -- 생성 콜백
	local function create_cb_func(ui, data)
        ui.root:setScale(0.66)
        ui:setBuyCB(function(ret) self:buyResult(ret) end)
	end    

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(300 * 0.66 + 15, 280 * 0.66 + 15)
    table_view_td:setCellUIClass(UI_Product, create_cb_func)
    table_view_td.m_nItemPerCell = 3
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
 
    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local item_type = 701151
    local l_item_list = g_shopDataNew:getProductList_byItemType(item_type)
    table_view_td:setItemList(l_item_list)
    self.m_tableView = table_view_td

    self:sortProduct()
end

-------------------------------------
-- function sortProduct
-- @brief 상품 정렬
-------------------------------------
function UI_ShopPopup:sortProduct()
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
-- function buyResult
-------------------------------------
function UI_ShopPopup:buyResult(ret)
    if (not g_shopDataNew.m_bDirty) then
        return
    end

    -- 상점의 모든 테이블 뷰 삭제
    self.vars['tableViewNode']:removeAllChildren()

    -- 테이블 뷰 초기화
    for i,v in pairs(self.m_mTabData) do
        local ui = v['ui']
        if ui then
            ui:clearProductList()
        end
    end

    -- 서버에서 데이터 받고 다시 생성
    local function cb_func(ret)
        self:setTab(self.m_currTab, true)
    end

    g_shopDataNew:request_shopInfo(cb_func)
end