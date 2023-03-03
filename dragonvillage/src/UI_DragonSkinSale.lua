local PARENT = UI

-------------------------------------
-- class UI_DragonSkinSale
-- @brief 스킨 상품 판매 팝업
-------------------------------------
UI_DragonSkinSale = class(PARENT,{
    m_eventId = 'string',
    m_tableViewTD = 'UIC_TableView',
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
    local vars = self.vars
    local node = vars['listNode']
    node:removeAllChildren()
    -- 테이블 뷰 인스턴스 생성
    local item_per_cell = 3
    local interval = 2
    local cell_width = 300
    local cell_height = 290

    require('UI_ProductDragonSkin')
    local function make_func(dragon_skin_sale)
        --local struct_product = dragon_skin_sale:getDragonSkinProduct('money')
        local ui = UI_ProductDragonSkin(dragon_skin_sale)
        return ui
    end

    local function create_func(ui, data)
        ui.vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(data) end)
    end

    -- ui_priority로 정렬
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        local a_match = a_data:getUIPriority()
        local b_match = b_data:getUIPriority()

        if a_match == b_match then
            return a_data:getSkinID() <  b_data:getSkinID()
        end

        return a_match > b_match
    end

    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size((cell_width + interval), (cell_height + interval))
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:insertSortInfo('default', sort_func)
    table_view_td.m_nItemPerCell = item_per_cell
    table_view_td:setItemList({})
    self.m_tableViewTD = table_view_td
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
    local l_dragon_skin_sale = g_dragonSkinData:getDragonSkinSaleMap(true)
    -- 리스트 머지 (조건에 맞는 항목만 노출)
    self.m_tableViewTD:mergeItemList(l_dragon_skin_sale)
    self.m_tableViewTD:sortTableView('default')
end

-------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DragonSkinSale:click_buyBtn(struct_dragon_skin_sale)
    local did = struct_dragon_skin_sale:getDragonSkinDId()
    local ret = g_dragonsData:getDragonsByDid(did)

    if g_dragonsData:getNumOfDragonsByDid(did) == 0 then
        local msg = Str('현재 보유 중인 드래곤이 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    require('UI_DragonSkinSaleConfirmPopup')
    UI_DragonSkinSaleConfirmPopup.open(struct_dragon_skin_sale, function() 
        self:initUI()
        self:refresh()
    end)
end

-------------------------------------
-- function update
-------------------------------------
function UI_DragonSkinSale:update(dt)
    local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_DragonSkinSale)
