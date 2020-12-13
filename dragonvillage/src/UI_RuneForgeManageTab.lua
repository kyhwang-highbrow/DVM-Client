local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_RuneForgeManageTab
-------------------------------------
UI_RuneForgeManageTab = class(PARENT,{
        m_selectedRuneObject = 'StructRuneObject',
        m_selectedRuneUI = '',
        m_mTableViewListMap = 'map',
        m_mSortManagerMap = 'map',

		m_tNotiSprite = 'table',
        m_optionLabel = 'ui',

        m_bSelectSellActive = 'boolean', -- 현재 선택 판매중인지
        m_mSelectedRuneUIMap = 'map', -- 현재 판매를 위해 선택된 아이템 UI, map[roid] = ui
    })


UI_RuneForgeManageTab.CARD_SCALE = 0.52
UI_RuneForgeManageTab.CARD_CELL_SIZE = cc.size(80, 80)

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeManageTab:init(owner_ui)
    local vars = self:load('rune_forge_manage.ui')
   
   self.m_bSelectSellActive = false
   self.m_mSelectedRuneUIMap = {}
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeManageTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 숨김

    if (first == true) then
        self:initUI()
        self:initButton()
        self:setTab(1)
        self:clearRuneInfo()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeManageTab:onExitTab()
    
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeManageTab:initUI()
    local vars = self.vars

    self.m_mTableViewListMap = {}
    self.m_mSortManagerMap = {}
	self.m_tNotiSprite = {}
    self.m_optionLabel = nil
    local vars = self.vars

    for i = 1, 6 do
        self:addTabWithLabel(i, vars['runeTabBtn' .. i], vars['runeTabLabel' .. i], vars['runeTableViewNode' .. i])
    end

     if (IS_TEST_MODE()) then
        self.vars['manageDevBtn']:setVisible(true)
        self.vars['manageDevBtn']:registerScriptTapHandler(function() self:click_manageDevBtn() end)
        self.vars['addDevBtn']:setVisible(true)
        self.vars['addDevBtn']:registerScriptTapHandler(function() self:click_addDevBtn() end)

    else
        self.vars['manageDevBtn']:setVisible(false)
        self.vars['addDevBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeManageTab:initButton()
    local vars = self.vars

    -- "선택 판매" 버튼
    vars['selectSellStartBtn']:registerScriptTapHandler(function()
        self:setActiveSelectSell(true)
    end)

    -- "판매" 버튼
    vars['selectSellBtn']:registerScriptTapHandler(function() 
        self:click_selectSellBtn() 
    end)

    -- "취소" 버튼
    vars['selectSellStopBtn']:registerScriptTapHandler(function()
        self:setActiveSelectSell(false)
    end)

    vars['bulkSellBtn']:registerScriptTapHandler(function() 
        self:click_bulkSellBtn() 
    end)

    vars['runeInfoBtn']:registerScriptTapHandler(function() 
        self:click_runeInfoBtn() 
    end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RuneForgeManageTab:onChangeTab(tab, first)
    local slot_idx = tab

    self:init_runeTableView(slot_idx)

    -- 선택된 룬 정보 초기화
    local skip_clear_info = true
    self:clearSelectedRune(skip_clear_info)

	self:refresh_noti()
end

-------------------------------------
-- function clearSelectedRune
-- @brief
-------------------------------------
function UI_RuneForgeManageTab:clearSelectedRune(skip_clear_info)
    self.m_selectedRuneUI = nil
    self.m_selectedRuneObject = nil

    if (not skip_clear_info) then
        self:clearRuneInfo()
    end
end

-------------------------------------
-- function clearRuneInfo
-- @brief
-------------------------------------
function UI_RuneForgeManageTab:clearRuneInfo()
    local vars = self.vars

    vars['lockSprite']:setVisible(false)
    vars['lockBtn']:setVisible(false)
    vars['itemDscLabel']:setVisible(false)
    vars['itemNameLabel']:setVisible(false)
    vars['sellBtn']:setVisible(false)
    vars['enhanceBtn']:setVisible(false)
    vars['locationBtn']:setVisible(false)
    vars['itemDscNode2']:setVisible(false)
    vars['runeDscNode']:setVisible(false)
    vars['itemNode']:removeAllChildren()
    vars['itemNode']:setVisible(false)
end

-------------------------------------
-- function setSelectedRune
-- @brief
-------------------------------------
function UI_RuneForgeManageTab:setSelectedRune(ui, data)
    if (ui == nil) then
        return
    end
    
    if self.m_selectedRuneUI then
        self.m_selectedRuneUI:setHighlightSpriteVisible(false)
    end

    self.m_selectedRuneUI = ui
    self.m_selectedRuneObject = data

    self:clearRuneInfo()
    self:onChangeSelectedItem(ui, data)
    cca.uiReactionSlow(ui.root, UI_RuneForgeManageTab.CARD_SCALE, UI_RuneForgeManageTab.CARD_SCALE)

    ui:setHighlightSpriteVisible(true)

    -- 선택 판매 시 사용
    if (self.m_bSelectSellActive) then
        if (data['lock']) then
            UIManager:toastNotificationRed(Str('잠금 상태입니다.'))
            return
        end
        local roid = data['roid']

        if self.m_mSelectedRuneUIMap[roid] then
            ui:setCheckSpriteVisible(false)
            self.m_mSelectedRuneUIMap[roid] = nil
        else
            ui:setCheckSpriteVisible(true)
            self.m_mSelectedRuneUIMap[roid] = {['ui'] = ui, ['data'] = data}
        end
    end
end

-------------------------------------
-- function init_runeTableView
-------------------------------------
function UI_RuneForgeManageTab:init_runeTableView(slot_idx)

    local node = self.vars['runeTableViewNode' .. slot_idx]
    node:removeAllChildren()

    local l_item_list = g_runesData:getUnequippedRuneList(slot_idx)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_RuneForgeManageTab.CARD_SCALE)
        		
		-- 새로 획득한 룬 뱃지
        local is_new = data:isNewRune()
        ui:setNewSpriteVisible(is_new)

		-- 만약 선택 판매 중이었다면 체크 표시
        if (self.m_bSelectSellActive) then
            local roid = data['roid']
            if (self.m_mSelectedRuneUIMap[roid]) then
                if (not data['lock']) then
                    ui:setCheckSpriteVisible(true)
                end
            end
        end
            
		-- 클릭 콜백
        local function click_func()
            self:setSelectedRune(ui, data)
			
			-- 신규 룬 표시 삭제
			local roid = data['roid']
			g_highlightData:removeNewRoid(roid)
        end
        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_RuneForgeManageTab.CARD_CELL_SIZE
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
-- function onChangeSortAscending
-- @brief 오름차순, 내림차순이 변경되었을 때
-------------------------------------
function UI_RuneForgeManageTab:onChangeSortAscending(ascending)
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
function UI_RuneForgeManageTab:onChangeSelectedItem(ui, data)
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
    vars['locationBtn']:setVisible(true)
    vars['locationBtn']:registerScriptTapHandler(function() UI_AcquisitionRegionInformation:create(t_rune_data['rid']) end)

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
    if (not self.m_bSelectSellActive) then
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
function UI_RuneForgeManageTab:sellBtn(t_rune_data)
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
            self:refresh_tableView(ret['deleted_rune_oids'])
            self:clearSelectedRune()
			self:refresh_noti()
        end

        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    ask_item_sell()
end

-------------------------------------
-- function enhanceBtn
-------------------------------------
function UI_RuneForgeManageTab:enhanceBtn(t_rune_data)
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
function UI_RuneForgeManageTab:runeLockBtn(t_rune_data)
    local roid = t_rune_data['roid']

    local function finish_cb()
        local new_data = g_runesData:getRuneObject(roid)
        
		-- 잠금했던 룬이라면 잠금여부에 따라 roid 삭제
        if (new_data['lock'] == true) and (self.m_bSelectSellActive) then
            if (self.m_mSelectedRuneUIMap and roid) then
                self.m_mSelectedRuneUIMap[roid] = nil
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
function UI_RuneForgeManageTab:refresh_noti()
	local vars = self.vars

	-- 룬 슬롯 탭
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
function UI_RuneForgeManageTab:refresh_selectedRune(new_data)

    -- 룬 슬롯 타입 세개 순회
    for i,v in pairs(self.m_mTableViewListMap) do
        local rune_slot_type = i
        local table_view = v
        
        -- 새로운 데이터로 갱신
        for roid, item in pairs(table_view.m_itemMap) do
            if (new_data['roid'] == roid) then
                table_view:replaceItemUI(roid, new_data)

                self:clearSelectedRune()
                local new_item = table_view:getItem(roid)
                self:setSelectedRune(new_item['ui'], new_item['data'])
            end
        end
    end
end

-------------------------------------
-- function refresh_tableView
-------------------------------------
function UI_RuneForgeManageTab:refresh_tableView(l_deleted_rune_oids)

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
function UI_RuneForgeManageTab:click_bulkSellBtn()
    local ui = UI_RuneBulkSalePopup()

    local function cb(ret)
        self:refresh_tableView(ret['deleted_rune_oids'])
        self:clearSelectedRune()
		self:refresh_noti()
    end

    ui:setSellCallback(cb)
end

-------------------------------------
-- function click_selectSellBtn
-------------------------------------
function UI_RuneForgeManageTab:click_selectSellBtn()
    local count = table.count(self.m_mSelectedRuneUIMap)

    if (count <= 0) then
        UIManager:toastNotificationRed(Str('선택된 아이템이 없습니다.'))
        return
    end

    local rune_oids
    local items

    local total_price = 0

    local table_item = TableItem()
    for i,v in pairs(self.m_mSelectedRuneUIMap) do
        local ui = v['ui']
        local data = v['data']
        local item_id = ui.m_itemID

        local price = table_item:getValue(item_id, 'sale_price')
        local item_count = 1

        -- 룬 판매
        local roid = i
        if (not rune_oids) then
            rune_oids = roid
        else
            rune_oids = rune_oids .. ',' .. roid
        end

        total_price = total_price + (price * item_count)
    end

    -- 선택된 룬이 판매되었으니 선택 해제
    local function cb(ret)
        self:refresh_tableView(ret['deleted_rune_oids'])
        self:clearSelectedRune()

        self.m_mSelectedRuneUIMap = {}
        self.m_bSelectSellActive = false
    end

    local function request_item_sell()
        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    local msg = Str('{1}개의 아이템을 {2}골드에 판매하시겠습니까?', count, comma_value(total_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end

-------------------------------------
-- function setActive
-------------------------------------
function UI_RuneForgeManageTab:setActiveSelectSell(active)
    local vars = self.vars

    self.m_bSelectSellActive = active

    if (not active) then
        for i,v in pairs(self.m_mSelectedRuneUIMap) do
            local ui = v['ui']
            ui:setCheckSpriteVisible(false)
        end
        self.m_mSelectedRuneUIMap = {}
    end

    if active then
        vars['selectSellStartBtn']:setVisible(false)
        vars['selectSellBtn']:setVisible(true)
        vars['selectSellStopBtn']:setVisible(true)

        vars['bulkSellBtn']:setVisible(false)
        vars['sellBtn']:setVisible(false)
    else
        vars['selectSellStartBtn']:setVisible(true)
        vars['selectSellBtn']:setVisible(false)
        vars['selectSellStopBtn']:setVisible(false)

        vars['bulkSellBtn']:setVisible(true)

        -- 선택된 아이템이 있을 경우
        if (self.m_selectedRuneUI) then
            vars['sellBtn']:setVisible(true)
        end
    end
end

-------------------------------------
-- function click_runeInfoBtn
-- @brief 룬 도움말
-------------------------------------
function UI_RuneForgeManageTab:click_runeInfoBtn()
    UI_HelpRune()
end

-------------------------------------
-- function click_useDevBtn
-- @brief (임시로 룬 개발 API 팝업 호출)
-------------------------------------
function UI_RuneForgeManageTab:click_manageDevBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local roid = self.m_selectedRuneObject.roid
    local ui = UI_RuneDevApiPopup(roid)

    local function close_cb()
        local t_rune_data = g_runesData:getRuneObject(roid)

        if (self.m_selectedRuneObject['updated_at'] ~= t_rune_data['updated_at']) then
            -- 룬 카드 및 정보 갱신
            local slot_idx = self.m_currTab
            self.m_mTableViewListMap[slot_idx]:replaceItemUI(roid, t_rune_data)
            
            self.m_selectedRuneUI = nil
            local new_ui = self.m_mTableViewListMap[slot_idx]:getItem(roid)['ui']
            self:setSelectedRune(new_ui, t_rune_data)
        end
    end

    ui:setCloseCB(close_cb)
end

------------------------------------
-- function click_addDevBtn
-- @brief 개발용 룬 획득 API 팝업 호출
-------------------------------------
function UI_RuneForgeManageTab:click_addDevBtn()
    require('UI_RuneSelectDevApiPopup')
    local ui = UI_RuneSelectDevApiPopup()

    local function close_cb()
        local slot_idx = self.m_currTab
        self:init_runeTableView(slot_idx)
        self:clearSelectedRune(true)
        self:refresh_noti()
    end

    ui:setCloseCB(close_cb)
end