local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_RuneForgeManageTab
-------------------------------------
UI_RuneForgeManageTab = class(PARENT,{
        m_selectedRuneObject = 'StructRuneObject',
        m_selectedRuneUI = '',

		m_tNotiSprite = 'table',
        m_optionLabel = 'ui',

        m_bSelectSellActive = 'boolean', -- 현재 선택 판매중인지
        m_mSelectedRuneUIMap = 'map', -- 현재 판매를 위해 선택된 아이템 UI, map[roid] = ui
        m_mSelectedRuneRoidMap = 'map',

        m_openedComboBox = 'UIC_SortList', -- 현재 열려있는 선택창
        m_setID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_mopt = 'string', -- 주옵션 필터
        m_sopt1 = 'string', -- 보조옵션 필터 1
        m_sopt2 = 'string', -- 보조옵션 필터 2
        m_sortManagerRune = 'SortManager_Rune', -- 룬 정렬
        m_tableViewTD = '',
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
   self.m_mSelectedRuneRoidMap = {}

   self.m_setID = 0
   self.m_mopt = 'all'
   self.m_sopt1 = 'all'
   self.m_sopt2 = 'all'
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeManageTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 숨김

    if (first == true) then
        self:initUI()
        self:initButton()
    end

    self.m_mSelectedRuneUIMap = {}
    self.m_mSelectedRuneRoidMap = {}
    self:clearRuneInfo()
    self:setTab(1, true)
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

	self.m_tNotiSprite = {}
    self.m_optionLabel = nil
    local vars = self.vars

    -- 룬 번호 1~6
    for i = 1, 6 do
        self:addTabWithLabel(i, vars['runeTabBtn' .. i], vars['runeTabLabel' .. i]) -- params : tab, button, label, ...
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

    -- 룬 정렬 최초 전체 선택
    vars['setSortLabel']:setString(Str('전체'))

    self:makeComboBox('mopt')
    self:makeComboBox('sopt1')
    self:makeComboBox('sopt2')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeManageTab:initButton()
    local vars = self.vars

    vars['selectSellStartBtn']:registerScriptTapHandler(function() self:setActiveSelectSell(true) end) -- 선택 판매 버튼
    vars['selectSellBtn']:registerScriptTapHandler(function() self:click_selectSellBtn() end) -- 판매 버튼
    vars['selectSellStopBtn']:registerScriptTapHandler(function() self:setActiveSelectSell(false) end) -- 취소 버튼
    vars['bulkSellBtn']:registerScriptTapHandler(function() self:click_bulkSellBtn() end)
    vars['runeInfoBtn']:registerScriptTapHandler(function() self:click_runeInfoBtn() end)
    vars['setSortBtn']:registerScriptTapHandler(function() self:click_setSortBtn() end) -- 룬 정렬
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RuneForgeManageTab:onChangeTab(tab, first)
    local slot_idx = tab
    self.m_mSelectedRuneUIMap = {}
    --self.m_mSelectedRuneRoidMap = {}
    self:init_runeTableView(slot_idx)

    -- 선택된 룬 정보 초기화
    local skip_clear_info = true
    self:clearSelectedRune(skip_clear_info)

	self:refreshRunesCount() -- 룬 개수 갱신
    self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
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
    vars['itemNode']:setVisible(false)
    vars['itemNode']:removeAllChildren()
    vars['dragonNode']:removeAllChildren()
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
            self.m_mSelectedRuneRoidMap[roid] = nil
            self.m_mSelectedRuneUIMap[roid] = nil
        else
            ui:setCheckSpriteVisible(true)
            self.m_mSelectedRuneRoidMap[roid] = data
            self.m_mSelectedRuneUIMap[roid] = {['ui'] = ui, ['data'] = data}
        end
    end
end


-------------------------------------
-- function init_runeTableView
-------------------------------------
function UI_RuneForgeManageTab:init_runeTableView(slot_idx)
    local vars = self.vars

    -- 선택된 룬이 있을 경우 제거
    self:clearSelectedRune() -- params : skip_clear_info

    local slot_idx = (slot_idx or self.m_currTab)
    local node = self.vars['runeTableViewNode']
    node:removeAllChildren()

    local l_item_list = self:getFilteredRuneList(slot_idx)
    --local unequipped = true
    --local slot = slot_idx
    --local set_id = self.m_listFilterSetID

    --local l_item_list = g_runesData:getFilteredRuneList(unequipped, slot, set_id)

    --local l_item_list = g_runesData:getUnequippedRuneList(slot_idx)
    --local l_item_list = g_runesData:getFilteredRuneList(false, slot_idx) -- unequipped, slot, set_id

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_RuneForgeManageTab.CARD_SCALE)
        		
		-- 새로 획득한 룬 뱃지
        local is_new = data:isNewRune()
        ui:setNewSpriteVisible(is_new)

		-- 만약 선택 판매 중이었다면 체크 표시
        if (self.m_bSelectSellActive) then
            local roid = data['roid']
            if (self.m_mSelectedRuneRoidMap[roid]) then
                if (not data['lock']) then
                    ui:setCheckSpriteVisible(true)
                    self.m_mSelectedRuneUIMap[roid] = {['ui'] = ui, ['data'] = data}
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
    self.m_sortManagerRune = sort_manager
    sort_manager:sortExecution(table_view_td.m_itemList)
    
    self.m_tableViewTD = table_view_td

    do -- 정렬 UI 생성
        local uic_sort_list = MakeUICSortList_runeManage(vars['runeSortBtn'], vars['runeSortLabel'])

        -- 버튼을 통해 정렬이 변경되었을 경우
        local function sort_change_cb(sort_type)
            sort_manager:pushSortOrder(sort_type)
            self:apply_runesSort()
        
        end
        
        -- 단 하나의 콤보박스만 켜지도록
        vars['runeSortBtn']:registerScriptTapHandler(function()
            uic_sort_list:toggleVisibility()

            if (uic_sort_list.m_bShow) then
                if ((self.m_openedComboBox) and (self.m_openedComboBox.m_bShow) and (self.m_openedComboBox ~= uic_sort_list)) then
                    self.m_openedComboBox:hide()
                end
                self.m_openedComboBox = uic_sort_list
            end
        end)

        uic_sort_list:setSortChangeCB(sort_change_cb)

        -- 최초 정렬 설정
        uic_sort_list:setSelectSortType('set_id')
    end

    do -- 오름차순/내림차순 버튼
        local function click()
            local ascending = (not sort_manager.m_defaultSortAscending)
            sort_manager:setAllAscending(ascending)
            self:apply_runesSort()

            vars['runeSortOrderSprite']:stopAllActions()
            if ascending then
                vars['runeSortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['runeSortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end

        vars['runeSortOrderBtn']:registerScriptTapHandler(click)
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


    -- 아이템 이름
    vars['itemNameLabel']:setVisible(true)
    local name = t_rune_data['name']
    vars['itemNameLabel']:setString(name)
    
    
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
    self.m_selectedRuneObject:setOptionLabel(self.m_optionLabel, 'use', nil)

    -- 장착 드래곤 표시
    vars['dragonNode']:removeAllChildren()
    if (t_rune_data['owner_doid'] ~= nil) then
        local doid = t_rune_data['owner_doid']
        local t_dragon_data = g_dragonsData:getDragonDataFromUidRef(doid)
        local dragon_card = UI_DragonCard(t_dragon_data)
        
        -- UI 반응 액션
        cca.uiReactionSlow(dragon_card.root)

        vars['dragonNode']:addChild(dragon_card.root)        
    end
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
            self:refreshRunesCount() -- 룬 개수 갱신
            self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
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
            if (self.m_mSelectedRuneRoidMap and roid) then
                self.m_mSelectedRuneRoidMap[roid] = nil
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
-- @brief 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
-------------------------------------
function UI_RuneForgeManageTab:refresh_noti()
	local vars = self.vars

	-- 룬 슬롯 탭
    local t_new_slot = self:getNewRuneSlotTable()
	if (t_new_slot) then
		local t_noti = {}
		for slot, b in pairs(t_new_slot) do
			t_noti['runeTabBtn' .. slot] = true
		end
		UIHelper:autoNoti(t_noti, self.m_tNotiSprite, '', vars)
	end

    self.m_ownerUI:refresh_highlight()
end

-------------------------------------
-- function refresh_selectedRune
-------------------------------------
function UI_RuneForgeManageTab:refresh_selectedRune(new_data)
    -- 새로운 데이터로 갱신
    local table_view = self.m_tableViewTD
    for roid, item in pairs(table_view.m_itemMap) do
        if (new_data['roid'] == roid) then
            table_view:replaceItemUI(roid, new_data)

            self:clearSelectedRune()
            local new_item = table_view:getItem(roid)
            self:setSelectedRune(new_item['ui'], new_item['data'])
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

    -- 테이블뷰 아이템들 중 없어진 아이템 삭제
    local table_view = self.m_tableViewTD
    for roid,_ in pairs(table_view.m_itemMap) do
        if (l_deleted_rune_oids_map[roid] == true) then
            table_view:delItem(roid)
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
        self:refreshRunesCount() -- 룬 개수 갱신
        self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
    end

    ui:setSellCallback(cb)
end

-------------------------------------
-- function click_selectSellBtn
-------------------------------------
function UI_RuneForgeManageTab:click_selectSellBtn()
    local count = table.count(self.m_mSelectedRuneRoidMap)

    if (count <= 0) then
        UIManager:toastNotificationRed(Str('선택된 아이템이 없습니다.'))
        return
    end

    local rune_oids
    local items

    local total_price = 0

    local table_item = TableItem()
    for i,data in pairs(self.m_mSelectedRuneRoidMap) do
        local item_id = data['item_id']

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
        self:refreshRunesCount() -- 룬 개수 갱신
        self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신

        self.m_mSelectedRuneUIMap = {}
        self.m_mSelectedRuneRoidMap = {}
        self:setActiveSelectSell(false) -- '선택 판매' 상태인지 설정
    end

    local function request_item_sell()
        g_inventoryData:request_itemSell(rune_oids, items, cb)
    end

    local msg = Str('{1}개의 아이템을 {2}골드에 판매하시겠습니까?', count, comma_value(total_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end

-------------------------------------
-- function setActiveSelectSell
-- @brief '선택 판매' 상태인지 설정
-------------------------------------
function UI_RuneForgeManageTab:setActiveSelectSell(active)
    local vars = self.vars

    self.m_bSelectSellActive = active

    if (not active) then
        for i,v in pairs(self.m_mSelectedRuneUIMap) do
            local ui = v['ui']
            ui:setCheckSpriteVisible(false)
        end
        self.m_mSelectedRuneRoidMap = {}
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
            self.m_tableViewTD:replaceItemUI(roid, t_rune_data)
            
            self.m_selectedRuneUI = nil
            local new_ui = self.m_tableViewTD:getItem(roid)['ui']
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
        self:refreshRunesCount() -- 룬 개수 갱신
        self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function refresh_runeSetFilter
-------------------------------------
function UI_RuneForgeManageTab:refresh_runeSetFilter(set_id)
    local vars = self.vars
    local table_rune_set = TableRuneSet()
    local text = (set_id == 0) and Str('전체') or table_rune_set:makeRuneSetNameRichText(set_id)
    vars['setSortLabel']:setString(text)

    self.m_setID = set_id
    self:init_runeTableView()

    self:refreshRunesCount() -- 룬 개수 갱신
    self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
end

-------------------------------------
-- function refresh_sortFilter
-------------------------------------
function UI_RuneForgeManageTab:refresh_runeOptionFilter()
    local vars = self.vars

    self:init_runeTableView()

    self:refreshRunesCount() -- 룬 개수 갱신
    self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
end

-------------------------------------
-- function click_setSortBtn
-- @brief 룬 정렬 버튼
-------------------------------------
function UI_RuneForgeManageTab:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    ui:setCloseCB(function(set_id)
        self:refresh_runeSetFilter(set_id)
    end)
end

-------------------------------------
-- function apply_runesSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_RuneForgeManageTab:apply_runesSort()
    self.m_sortManagerRune:sortExecution(self.m_tableViewTD.m_itemList)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function refreshRunesCount
-- @brief 룬 개수 갱신
-------------------------------------
function UI_RuneForgeManageTab:refreshRunesCount()
    local vars = self.vars

    for slot= 1, 6 do
        local l_item_list = self:getFilteredRuneList(slot)
        local count = table.count(l_item_list)
        vars['runeNumLabel'..slot]:setString(Str('{1}개', comma_value(count)))
    end
end

-------------------------------------
-- function getNewRuneSlotTable
-- @brief 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신 정보
-------------------------------------
function UI_RuneForgeManageTab:getNewRuneSlotTable()
	local t_ret = {}

    for slot=1, 6 do
        local l_rune_obj = self:getFilteredRuneList(slot)
        for _, struct_rune in pairs(l_rune_obj) do
            if (struct_rune:isNewRune() == true) then
			    t_ret[slot] = true
            end
        end
    end

	return t_ret
end

-------------------------------------
-- function getFilteredRuneList
-- @brief UI상에서 설정된 필터에 해당하는 StructRuneObject 리스트 (리스트가 아닌 map의 형태임을 주의하자)
-------------------------------------
function UI_RuneForgeManageTab:getFilteredRuneList(slot_idx)
    local unequipped = false
    local slot = slot_idx

    local set_id = self.m_setID
    local mopt = self.m_mopt
    local sopt1 = self.m_sopt1
    local sopt2 = self.m_sopt2

    -- 리스트가 아닌 map의 형태임을 주의하자
    local l_rune_obj = g_runesData:getFilteredRuneList(unequipped, slot, set_id, mopt, sopt1, sopt2)
    return l_rune_obj
end

-------------------------------------
-- function makeComboBox
-------------------------------------
function UI_RuneForgeManageTab:makeComboBox(key)
    local vars = self.vars
    local button = vars[key .. 'SortBtn']
    local label = vars[key .. 'SortLabel']
    local uic_sort_list = MakeUICSortListTD_runeOption(button, label)

    button:registerScriptTapHandler(function()
        uic_sort_list:toggleVisibility()

        if (uic_sort_list.m_bShow) then
            if ((self.m_openedComboBox) and (self.m_openedComboBox.m_bShow) and (self.m_openedComboBox ~= uic_sort_list)) then
                self.m_openedComboBox:hide()
            end
            self.m_openedComboBox = uic_sort_list
        end
    end)

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self['m_' .. key] = sort_type
        self:refresh_runeOptionFilter()        
    end

	uic_sort_list:setSortChangeCB(sort_change_cb)


    -- 최초 정렬 설정
    uic_sort_list:setSelectSortType('all', true)

end