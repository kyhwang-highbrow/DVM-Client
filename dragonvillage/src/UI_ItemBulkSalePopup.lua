local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_RuneBulkSalePopup
-------------------------------------
UI_ItemBulkSalePopup = class(PARENT,{
        m_tableView = '',
        m_sortManagerRune = '',
        m_sellCB = '',
        m_bOptionChanged = 'boolean',
        m_setId = 'number',
        m_runeList = 'StructRune',
        m_itemList = 'items',
        m_total_price = 'commavalue(number)',
        m_request_item_sell = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ItemBulkSalePopup:init(runeList, itemList, total_price, request_item_sell)
    local vars = self:load('inventory_sell_popup_03.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_setId = 0
    self.m_runeList = runeList
    self.m_itemList = itemList
    self.m_total_price = total_price
    self.m_request_item_sell = request_item_sell

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneBulkSalePopup')



    -- 오른쪽 Item 메뉴 생성
    local node = self.vars['listViewNode2']

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_Inventory.CARD_SCALE)
    end

    -- 열매 아이콘 생성 함수(내부에서 Item Card)
    local function make_func(t_data)
        return self:createCard(t_data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_Inventory.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setItemList(self.m_itemList)
    self.m_tableView = table_view_td
    


    -- 왼쪽 Rune 메뉴 생성    
    local node = self.vars['listViewNode']

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_Inventory.CARD_SCALE)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_Inventory.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(self.m_runeList)
    


    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
end


-------------------------------------
-- function createCard
-------------------------------------
function UI_ItemBulkSalePopup:createCard(t_data)
    local item_id = t_data['esid'] or t_data['fid'] or t_data['mid']

    -- itemList을 t_data로 받아오는데, {진화 재료}의 item과 {친밀도 열매, 외형 변형 재료}의 item 형식이 다르기 때문에 아래와 같이 처리해 주어야 함.
    if(item_id == nil) then
        for k, v in pairs(t_data) do
            t_data = v
        end
        item_id = t_data['esid'] or t_data['fid'] or t_data['mid']
    end

    local count = t_data['count']
    local ui = UI_ItemCard(tonumber(item_id), 0)
    ui:setNumberLabel(count)

    return ui
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ItemBulkSalePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ItemBulkSalePopup'
    self.m_bUseExitBtn = true
    self.m_titleStr = Str('룬, 아이템 선택 판매')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ItemBulkSalePopup:initUI()
    local vars = self.vars
    vars['priceaLabel']:setString(self.m_total_price)

    -- 룬, 아이템이 선택되면 스트링 안 보이게 바꾸기
    rune_count = 0
    item_count = 0
    for i, v in pairs(self.m_runeList) do
        rune_count = rune_count + 1
    end

    for i, v in pairs(self.m_itemList) do
        item_count = item_count + 1
    end

    if(rune_count == 0) then
        vars['listViewLabel']:setString('선택한 룬이 없습니다.') -- 번역
    else
        vars['listViewLabel']:setVisible(false)
    end

    if(item_count == 0) then
        vars['listViewLabel2']:setString('선택한 아이템이 없습니다.') -- 번역
    else
        vars['listViewLabel2']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ItemBulkSalePopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function click_setSortBtn
-------------------------------------
function UI_ItemBulkSalePopup:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    ui:setCloseCB(function(set_id)
        self:refresh_runeSetFilter(set_id)
    end)
end

-------------------------------------
-- function tableViewSortAndRefresh
-- @brief 테이블 뷰 정렬, 갱신
-------------------------------------
function UI_ItemBulkSalePopup:tableViewSortAndRefresh()
    local sort_manager = self.m_sortManagerRune
    sort_manager:sortExecution(self.m_tableView.m_itemList)

    self.m_tableView:setDirtyItemList()

    if (self.m_tableView:getItemCount() <= 0) then
        self.vars['listViewLabel']:setVisible(true)
    else
        self.vars['listViewLabel']:setVisible(false)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ItemBulkSalePopup:refresh()
    
end

-------------------------------------
-- function click_checkBox
-------------------------------------
function UI_ItemBulkSalePopup:click_checkBox()
    self.m_bOptionChanged = true
    self:refresh()
end

-------------------------------------
-- function click_cancelBtn
-- @brief "취소(닫기)" 버튼 클릭
-------------------------------------
function UI_ItemBulkSalePopup:click_cancelBtn()
    self:close()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ItemBulkSalePopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_sellBtn
-- @brief "판매" 버튼 클릭
-------------------------------------
function UI_ItemBulkSalePopup:click_sellBtn()
    self.m_request_item_sell()
    self:close()
end

-------------------------------------
-- function setSellCallback
-- @brief 판매 콜백 함수
-- @param sell_cb function(ret)
-------------------------------------
function UI_ItemBulkSalePopup:setSellCallback(sell_cb)
    self.m_sellCB = sell_cb
end

--@CHECK
UI:checkCompileError(UI_ItemBulkSalePopup)
