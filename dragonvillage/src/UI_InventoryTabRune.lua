local PARENT = class(UI_InventoryTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_InventoryTabRune
-------------------------------------
UI_InventoryTabRune = class(PARENT, {
        m_selectedRuneObject = 'StructRuneObject',
        m_mTableViewListMap = 'map',
        m_mSortManagerMap = 'map',

		m_tNotiSprite = 'table',
        m_optionLabel = 'ui',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabRune:init(inventory_ui)
    self.m_mTableViewListMap = {}
    self.m_mSortManagerMap = {}
	self.m_tNotiSprite = {}
    self.m_optionLabel = nil
    local vars = self.vars

    -- 'inventory.ui'를 사용
    for i = 1, 6 do
        self:addTabWithLabel(i, vars['runeTabBtn' .. i], vars['runeTabLabel' .. i], vars['runeTableViewNode' .. i])
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_InventoryTabRune:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    local slot_idx = tab

    self:init_runeTableView(slot_idx)

    -- 테이블 뷰에서 선택된 셀의 변수를 초기화
    local skip_clear_info = true
    self.m_inventoryUI:clearSelectedItem(skip_clear_info)

	self:refresh_noti()
end

-------------------------------------
-- function init_runeTableView
-------------------------------------
function UI_InventoryTabRune:init_runeTableView(slot_idx)

    local node = self.vars['runeTableViewNode' .. slot_idx]
    node:removeAllChildren()

    local l_item_list = g_runesData:getUnequippedRuneList(slot_idx)
	local select_sell_item_ui = self.m_inventoryUI.m_selectSellItemsUI

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_Inventory.CARD_SCALE)
        		
		-- 새로 획득한 룬 뱃지
        local is_new = data:isNewRune()
        ui:setNewSpriteVisible(is_new)

		-- 만약 선택 판매 중이었다면 체크 표시
        if (select_sell_item_ui) then
            local roid = data['roid']
            if select_sell_item_ui.m_bActive then
                if (select_sell_item_ui.m_selectedItemUIMap[roid]) then
                   if (not data['lock']) then
                        ui:setCheckSpriteVisible(true)
                   end
                end
            end
        end
            
		-- 클릭 콜백
        local function click_func()
            self.m_inventoryUI:setSelectedItem(ui, data)
			
			-- 신규 룬 표시 삭제
			local roid = data['roid']
			g_highlightData:removeNewRoid(roid)
        end
        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_Inventory.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('룬 가방이 비어있습니다.\n다양한 전투를 통해 룬을 획득해보세요!'))

    -- 정렬
    local sort_manager = SortManager_Rune()
    sort_manager:sortExecution(table_view_td.m_itemList)
    
    self.m_mSortManagerMap[slot_idx] = sort_manager
    self.m_mTableViewListMap[slot_idx] = table_view_td
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabRune:onEnterInventoryTab(first)
    if first then
        local default_tab = 1
        self:setTab(default_tab)
    end

    PARENT.onEnterInventoryTab(self, first)

    -- "일괄 판매" 버튼
    if self.m_inventoryUI.m_selectSellItemsUI and (not self.m_inventoryUI.m_selectSellItemsUI.m_bActive) then
        self.vars['bulkSellBtn']:setVisible(true)
    end
    self.vars['bulkSellBtn']:registerScriptTapHandler(function() self:click_bulkSellBtn() end)
end

-------------------------------------
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_InventoryTabRune:onChangeSortAscending(ascending)
    PARENT.onChangeSortAscending(self)

    -- 내부 슬롯별 탭 정렬
    for slot_idx,table_view_td in pairs(self.m_mTableViewListMap) do
        local sort_manager = self.m_mSortManagerMap[slot_idx]
        
        sort_manager:setAllAscending(ascending)
        sort_manager:sortExecution(table_view_td.m_itemList)
        table_view_td:setDirtyItemList()
    end
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_InventoryTabRune:onChangeSelectedItem(ui, data)
    local vars = self.vars
    local t_rune_data = data

    do-- 아이콘 표시
        vars['itemNode']:setVisible(true)
        local item = UI_RuneCard(t_rune_data)
        vars['itemNode']:addChild(item.root)

        -- UI 반응 액션
        cca.uiReactionSlow(item.root)
    end

    -- 획득 지역 안내
    vars['hatcheryBtn']:setVisible(false)
    vars['locationBtn']:setVisible(true)
    vars['locationBtn']:registerScriptTapHandler(function() self:openAcuisitionRegionInformation(t_rune_data['rid']) end)

    -- 강화 
    vars['enhanceBtn']:setVisible(true)
    vars['enhanceBtn']:registerScriptTapHandler(function() self:enhanceBtn(t_rune_data) end)

    -- 잠금 여부
    vars['lockBtn']:setVisible(true)
    vars['lockBtn']:registerScriptTapHandler(function() self:runeLockBtn(t_rune_data) end)
    vars['lockSprite']:setVisible(t_rune_data['lock'])


    do -- 아이템 이름
        vars['itemNameLabel']:setVisible(true)
        local name = t_rune_data['name']
        vars['itemNameLabel']:setString(name)
    end
    
    -- 판매 버튼
    if self.m_inventoryUI.m_selectSellItemsUI and (not self.m_inventoryUI.m_selectSellItemsUI.m_bActive) then
        vars['sellBtn']:setVisible(true)
    end
    vars['sellBtn']:registerScriptTapHandler(function() self:sellBtn(t_rune_data) end)

    -- 룬 세트 효과
    vars['itemDscNode2']:setVisible(true)
    local str = t_rune_data:makeRuneSetDescRichText() or ''
    vars['itemDscLabel2']:setString(str)

    self.m_selectedRuneObject = t_rune_data

    -- 룬 옵션 라벨
    self.vars['runeDscNode']:setVisible(true)
    if (not self.m_optionLabel) then
        self.m_optionLabel = self.m_selectedRuneObject:getOptionLabel()
        self.vars['runeDscNode']:addChild(self.m_optionLabel.root)
    end
    self.m_selectedRuneObject:setOptionLabel(self.m_optionLabel, 'use', false)

end

-------------------------------------
-- function sellBtn
-- @brief
-------------------------------------
function UI_InventoryTabRune:sellBtn(t_rune_data)
    if (t_rune_data['lock']) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('잠금 상태입니다.'))
        return
    end

    local ask_item_sell
    local request_item_sell
    
    -- 판매 여부 묻는 팝업
    ask_item_sell = function()
        local item_name = t_rune_data['name']
        local item_price = TableItem():getValue(t_rune_data['rid'], 'sale_price')
        local msg = Str('[{1}](을)를 {2}골드에 판매하시겠습니까?', item_name, comma_value(item_price))
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
    end

    -- 서버에 판매 요청
    request_item_sell = function()
        local rune_oids = t_rune_data['roid']
        local items = nil

        -- 선택된 룬이 판매되었으니 선택 해제
        local function cb(ret)
            self.m_inventoryUI:response_itemSell(ret)
            self.m_inventoryUI:clearSelectedItem()
			self:refresh_noti()
        end

        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    ask_item_sell()
end

-------------------------------------
-- function enhanceBtn
-------------------------------------
function UI_InventoryTabRune:enhanceBtn(t_rune_data)
    local ui = UI_DragonRunesEnhance(t_rune_data)

    local function close_cb()
        if (self.m_selectedRuneObject['updated_at'] ~= ui.m_runeObject['updated_at']) then
            local new_data = ui.m_runeObject
            self:refresh_selectedRune(new_data)
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function runeLockBtn
-- @brief 룬 잠금
-------------------------------------
function UI_InventoryTabRune:runeLockBtn(t_rune_data)
    local roid = t_rune_data['roid']

    local function finish_cb()
        local new_data = g_runesData:getRuneObject(roid)
        
		-- 잠금했던 룬이라면 잠금여부에 따라 roid 삭제
        local select_sell_item_ui = self.m_inventoryUI.m_selectSellItemsUI
        if (new_data['lock'] == true) and (select_sell_item_ui) then
            if select_sell_item_ui.m_bActive then
                if (select_sell_item_ui.m_selectedItemUIMap and roid) then
                    select_sell_item_ui.m_selectedItemUIMap[roid] = nil
                end
            end
        end

		-- 룬 갱신 (cell을 새로 생성한다)
        if (t_rune_data['updated_at'] ~= new_data['updated_at']) then
            self:refresh_selectedRune(new_data)
        end
    end

    g_runesData:request_runesLock_toggle(roid, nil, finish_cb)
end

-------------------------------------
-- function refresh_noti
-------------------------------------
function UI_InventoryTabRune:refresh_noti()
	local vars = self.vars

	-- 상단의 룬 탭
	vars['runeNotiSprite']:setVisible(g_highlightData:isHighlightRune())
	
	-- 하단의 슬롯 탭
	local t_new_slot = g_highlightData:getNewRuneSlotTable()
	if (t_new_slot) then
		local t_noti = {}
		for slot, b in pairs(t_new_slot) do
			t_noti['runeTabBtn' .. slot] = true
		end
		UIHelper:autoNoti(t_noti, self.m_tNotiSprite, '', vars)
	end
end

-------------------------------------
-- function refresh_selectedRune
-------------------------------------
function UI_InventoryTabRune:refresh_selectedRune(new_data)

    -- 룬 슬롯 타입 세개 순회
    for i,v in pairs(self.m_mTableViewListMap) do
        local rune_slot_type = i
        local table_view = v
        
        -- 새로운 데이터로 갱신
        for roid, item in pairs(table_view.m_itemMap) do
            if (new_data['roid'] == roid) then
                table_view:replaceItemUI(roid, new_data)

                self.m_inventoryUI:clearSelectedItem()
                local new_item = table_view:getItem(roid)
                self.m_inventoryUI:setSelectedItem(new_item['ui'], new_item['data'])
            end
        end
    end
end

-------------------------------------
-- function refresh_tableView
-------------------------------------
function UI_InventoryTabRune:refresh_tableView(l_deleted_rune_oids)

    -- roid로 바로 찾기위해 map형태로 변환
    local l_deleted_rune_oids_map = {}
    for i,v in pairs(l_deleted_rune_oids) do
        l_deleted_rune_oids_map[v] = true
    end

    -- 룬 슬롯 타입 세개 순회
    for i,v in pairs(self.m_mTableViewListMap) do
        local rune_slot_type = i
        local table_view = v
        
        -- 테이블뷰 아이템들 중 없어진 아이템 삭제
        for roid,_ in pairs(table_view.m_itemMap) do
            if (l_deleted_rune_oids_map[roid] == true) then
                table_view:delItem(roid)
            end
        end
    end
end

-------------------------------------
-- function click_bulkSellBtn
-- @brief "일괄 판매" 버튼 클릭
-------------------------------------
function UI_InventoryTabRune:click_bulkSellBtn()
    local ui = UI_RuneBulkSalePopup()

    local function cb(ret)
        self.m_inventoryUI:response_itemSell(ret)
        self.m_inventoryUI:clearSelectedItem()
		self:refresh_noti()
    end
    ui:setSellCallback(cb)
end


-------------------------------------
-- function clearTabFirstInfo
-- @brief
-------------------------------------
function UI_InventoryTabRune:clearTabFirstInfo()
    for i,v in pairs(self.m_mTabData) do
        v['first'] = true
    end
end
