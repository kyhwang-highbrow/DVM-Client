local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunesBulkEquipRuneTab
-------------------------------------
UI_DragonRunesBulkEquipRuneTab = class(PARENT,{
        m_ownerUI = 'UI_DragonRunesBulkEquip',

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManagerRune = 'SortManager_Rune',

        m_setID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_lMoptList = 'list', -- 주옵션 필터 리스트
        m_lSoptList = 'list', -- 보조옵션 필터 리스트
        m_bIncludeEquipped = 'boolean', -- 장착한 룬 필터

        m_selectRoid = 'string',
    })


UI_DragonRunesBulkEquipRuneTab.CARD_SCALE = 0.52
UI_DragonRunesBulkEquipRuneTab.CARD_CELL_SIZE = cc.size(80, 100)

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:init(owner_ui)
    local vars = self:load('dragon_rune_popup_rune.ui')

    self.m_ownerUI = owner_ui

    self.m_setID = 0
    self.m_lMoptList = nil
    self.m_lSoptList = nil
    self.m_bIncludeEquipped = g_settingData:get('option_rune_filter', 'not_include_equipped')

    self.m_selectRoid = nil

end

-------------------------------------
-- function setParentAndInit
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:setParentAndInit(parent_node)
    -- 룬을 출력하는 TableView(runeTableViewNode)가 relative size의 영향을 받는다.
    -- UI가 생성되고 부모 노드에 addChild가 된 후에 해당 노드의 크기가 결정되므로 외부에서 호출하도록 한다.
    -- setTab -> onChangeTab -> initTableView 의 순서로 TableView가 생성됨.
    --self:setTab(1, true)
    
    parent_node:addChild(self.root)

    self:initUI()

    self:initButton()

    self:refresh()

    self:setTab(1, true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:initUI()
    local vars = self.vars

    -- 룬 번호 1~6
    for i = 1, 6 do
        self:addTabWithLabel(i, vars['runeTabBtn' .. i], vars['runeTabLabel' .. i]) -- params : tab, button, label, ...
    end

    -- 룬 필터 초기화
    vars['setSortLabel']:setString(Str('세트'))

    vars['optSortLabel']:setColor(cc.c4b(240, 215, 159))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:initButton()
    local vars = self.vars

    vars['setSortBtn']:registerScriptTapHandler(function() self:click_setSortBtn() end) -- 룬 세트 필터
    vars['optSortBtn']:registerScriptTapHandler(function() self:click_optSortBtn() end) -- 룬 옵션 필터
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:refresh()
    local vars = self.vars


end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:initTableView(slot_idx)
    local vars = self.vars

    local slot_idx = (slot_idx or self.m_currTab)
    local node = self.vars['runeTableViewNode']
    node:removeAllChildren()

    local l_item_list = self:getFilteredRuneList(slot_idx)

    local doid = self.m_ownerUI.m_doid
    local dragon_obj =  g_dragonsData:getDragonDataFromUid(doid)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_DragonRunesBulkEquipRuneTab.CARD_SCALE)
        
        local roid = data['roid']

        -- 현재 장착하고 있는 룬의 경우 체크 스프라이트
        if (self.m_ownerUI:isEquipRune(roid)) then
            self.m_selectRoid = roid
            ui:setCheckSpriteVisible(true)
        end
         		
		-- 새로 획득한 룬 뱃지
        local is_new = data:isNewRune()
        ui:setNewSpriteVisible(is_new)

		-- 클릭 콜백
        local function click_func()
            self:click_runeCard(ui, data)
			
			-- 신규 룬 표시 삭제
			g_highlightData:removeNewRoid(roid)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_DragonRunesBulkEquipRuneTab.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 7
    table_view_td.m_marginFinish = 15
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_RuneCardOption, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('룬 가방이 비어있습니다.\n다양한 전투를 통해 룬을 획득해보세요!'))

    -- 정렬
    if (self.m_sortManagerRune == nil) then
        local sort_manager = SortManager_Rune()

        do -- 정렬 UI 생성
            local uic_sort_list = MakeUICSortList_runeManage(vars['runeSortBtn'], vars['runeSortLabel'])
        
            -- 버튼을 통해 정렬이 변경되었을 경우
            local function sort_change_cb(sort_type)
                sort_manager:pushSortOrder(sort_type)
                self:applyRunesSort()
            end

            uic_sort_list:setSortChangeCB(sort_change_cb)
        end

        do -- 오름차순/내림차순 버튼
            local function click()
                local ascending = (not sort_manager.m_defaultSortAscending)
                sort_manager:setAllAscending(ascending)
                self:applyRunesSort()

                vars['runeSortOrderSprite']:stopAllActions()
                if ascending then
                    vars['runeSortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
                else
                    vars['runeSortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
                end
            end

            vars['runeSortOrderBtn']:registerScriptTapHandler(click)
        end

        self.m_sortManagerRune = sort_manager
    end

    self.m_tableViewTD = table_view_td
    self:applyRunesSort()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:onChangeTab(tab, first)
    local slot_idx = tab

    self.m_selectRoid = nil

    self:initTableView(slot_idx)

	self:refreshRunesCount() -- 룬 개수 갱신

    self.m_ownerUI:focusSlotIndex(slot_idx)
end

-------------------------------------
-- function refreshRunesCount
-- @brief 룬 개수 갱신
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:refreshRunesCount()
    local vars = self.vars

    for slot= 1, 6 do
        local l_item_list = self:getFilteredRuneList(slot)
        local count = table.count(l_item_list)
        vars['runeNumLabel'..slot]:setString(Str('{1}개', comma_value(count)))
    end
end

-------------------------------------
-- function refreshRuneSetFilter
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:refreshRuneSetFilter()
    local vars = self.vars

    local set_id = self.m_setID
    local table_rune_set = TableRuneSet()
    
    local text 
    if (set_id == 0) then
        text = Str('전체')
    elseif (set_id == 'normal') then
        text = Str('일반 룬')
    elseif (set_id == 'ancient') then
        text = Str('고대 룬')
    else
        text = table_rune_set:makeRuneSetNameRichTextWithoutNeed(set_id)
    end

    vars['setSortLabel']:setString(text)

    self:initTableView()

    self:refreshRunesCount() -- 룬 개수 갱신
end

-------------------------------------
-- function refreshRuneOptionFilter
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:refreshRuneOptionFilter()
    local vars = self.vars

    self:initTableView()

    self:refreshRunesCount() -- 룬 개수 갱신
end

-------------------------------------
-- function click_setSortBtn
-- @brief 룬 세트 필터 버튼
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    
    local function close_cb(set_id) 
        self.m_setID = set_id

        self:refreshRuneSetFilter()
    end
    
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_optSortBtn
-- @brief 룬 옵션 필터 버튼
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:click_optSortBtn()
    local l_mopt_list = self.m_lMoptList
    local l_sopt_list = self.m_lSoptList
    local b_include_equipped = self.m_bIncludeEquipped
    local ui = UI_RuneOptionFilter(l_mopt_list, l_sopt_list, not b_include_equipped)

    local function close_cb(l_mopt_list, l_sopt_list, b_include_equipped)
        self.m_lMoptList = l_mopt_list
        self.m_lSoptList = l_sopt_list
        self.m_bIncludeEquipped = b_include_equipped

        local b_is_using_filter = (l_mopt_list ~= nil) or (l_sopt_list ~= nil)

        self.vars['optSortLabel']:setColor((b_is_using_filter == false) and cc.c4b(240, 215, 159) or cc.c4b(255, 215, 0))

        self:refreshRuneOptionFilter()
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function applyRunesSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:applyRunesSort()
    self.m_sortManagerRune:sortExecution(self.m_tableViewTD.m_itemList)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function click_runeCard
-- @brief 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:click_runeCard(ui, data)
    local vars = self.vars

    local roid = data['roid']

    if (self.m_selectRoid) and (self.m_selectRoid == data['roid']) then
        roid = nil
    end

    local slot_idx = self.m_currTab
    self.m_ownerUI:simulateRune(slot_idx, roid)
end

-------------------------------------
-- function unequipRune
-- @brief UI_DragonRunesBulkEquipItem에서 룬 장착/해제한 경우 호출
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:refreshRuneCheck(slot_idx, roid)
    local vars = self.vars
    local roid = roid or ''

    -- 슬롯이 다른 경우 갱신 필요 없음
    if (slot_idx ~= self.m_currTab) then return end

    if (self.m_selectRoid ~= nil) then
        if (self.m_tableViewTD.m_itemMap[self.m_selectRoid]) then
            local selected_ui = self.m_tableViewTD:getCellUI(self.m_selectRoid)
            if (selected_ui ~= nil) then
                selected_ui:setCheckSpriteVisible(false)
            end
        end

        self.m_selectRoid = nil
    end

    -- 룬 장착
    if (roid ~= '') then
        local struct_rune = g_runesData:getRuneObject(roid)    
        local slot_idx = struct_rune['slot']
        
        if (self.m_tableViewTD.m_itemMap[roid]) then
            local ui = self.m_tableViewTD:getCellUI(roid)
            if (ui ~= nil) then
                ui:setCheckSpriteVisible(true)
            end
        end

        self.m_selectRoid = roid
    end
end


-------------------------------------
-- function getFilteredRuneList
-- @brief UI상에서 설정된 필터에 해당하는 StructRuneObject 리스트 (리스트가 아닌 map의 형태임을 주의하자)
-------------------------------------
function UI_DragonRunesBulkEquipRuneTab:getFilteredRuneList(slot_idx)
    local unequipped = not self.m_bIncludeEquipped
    local slot = slot_idx
    local set_id = self.m_setID
    local l_mopt_list = self.m_lMoptList
    local l_sopt_list = self.m_lSoptList

    -- 리스트가 아닌 map의 형태임을 주의하자
    local l_rune_obj = g_runesData:getFilteredRuneList(unequipped, slot, set_id, l_mopt_list, l_sopt_list)
    return l_rune_obj
end
