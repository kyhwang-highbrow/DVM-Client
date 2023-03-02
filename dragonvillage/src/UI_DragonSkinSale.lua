local PARENT = UI

-------------------------------------
-- class UI_DragonSkinSale
-- @brief 스킨 상품 판매 팝업
-------------------------------------
UI_DragonSkinSale = class(PARENT,{
    m_eventId = 'string',
    m_tableView = 'UIC_TableView',
    m_cbBuy = 'function'
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinSale:init(package_name, is_popup)
    self.m_uiName = 'UI_DragonSkinSale'
    local vars = self:load('package_dargon_skin.ui')

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- backkey 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyDepot')
    end

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
function UI_DragonSkinSale:initUI()
    local l_dragon_skin_sale = TableDragonSkinSale:getInstance():getDragonSkinSaleMap(true) --
    --local l_dragon_skin_sale = g_shopDataNew:getProductList('dragon_skin')
    cclog('l_dragon_skin_sale', table.count(l_dragon_skin_sale))
   
    local vars = self.vars
    local node = vars['listNode']

    require('UI_ProductDragonSkin')
    local function make_func(dragon_skin_sale)
        local struct_product = dragon_skin_sale:getDragonSkinProduct('money')
        local ui = UI_ProductDragonSkin(struct_product)
        ui.m_structSkinSale = dragon_skin_sale
        return ui
    end

    local function create_func(ui, data)
        ui.vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(data) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local item_per_cell = 3
    local interval = 2
    local cell_width = 250
    local cell_height = 288

    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size((cell_width + interval), (cell_height + interval))
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_nItemPerCell = item_per_cell
    table_view_td:setItemList(l_dragon_skin_sale)

    -- ui_priority로 정렬
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        -- table_supply의 ui_priority로 정렬
        local a_match = a_data['ui_priority'] or 0
        local b_match = b_data['ui_priority'] or 0

        return a_match < b_match
    end

    --table.sort(table_view.m_itemList, sort_func)
    self.m_tableView = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkinSale:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinSale:refresh()
end

-------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DragonSkinSale:click_buyBtn(struct_dragon_skin_sale)
    require('UI_DragonSkinSaleConfirmPopup')
    UI_DragonSkinSaleConfirmPopup.open(struct_dragon_skin_sale)
end

-------------------------------------
-- function update
-------------------------------------
function UI_DragonSkinSale:update(dt)
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_DragonSkinSale)
