local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_RuneForgePresetTab
-------------------------------------
UI_RuneForgePresetTab = class(PARENT,{
        m_selectedRuneObject = 'StructRuneObject',
        m_selectedRuneUI = '',
        m_focusRuneUI = '',

		m_tNotiSprite = 'table',
        m_optionLabel = 'ui',

        m_bSelectSellActive = 'boolean', -- 현재 선택 판매중인지
        m_mSelectedRuneUIMap = 'map', -- 현재 판매를 위해 선택된 아이템 UI, map[roid] = ui
        m_mSelectedRuneRoidMap = 'map',

        m_openedComboBox = 'UIC_SortList', -- 현재 열려있는 선택창
        m_setID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_lMoptList = 'list', -- 주옵션 필터 리스트
        m_lSoptList = 'list', -- 보조옵션 필터 리스트
        m_bIncludeEquipped = 'boolean', -- 장착한 룬 필터

        m_sortManagerRune = 'SortManager_Rune', -- 룬 정렬
        m_tableViewTD = '',
    })


UI_RuneForgePresetTab.CARD_SCALE = 0.52
UI_RuneForgePresetTab.CARD_CELL_SIZE = cc.size(80, 100)

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgePresetTab:init(owner_ui)
    local vars = self:load('rune_forge_preset.ui')
   
   self.m_bSelectSellActive = false
   self.m_mSelectedRuneUIMap = {}
   self.m_mSelectedRuneRoidMap = {}
   self.m_bIncludeEquipped = g_settingData:get('option_rune_filter', 'not_include_equipped_2')

   self.m_setID = 0
   self.m_lMoptList = nil
   self.m_lSoptList = nil
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgePresetTab:onEnterTab(first)
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
function UI_RuneForgePresetTab:onExitTab()
    
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgePresetTab:initUI()
    local vars = self.vars
	self.m_tNotiSprite = {}
    self.m_optionLabel = nil

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
function UI_RuneForgePresetTab:initButton()
    local vars = self.vars

    vars['runeInfoBtn']:registerScriptTapHandler(function() self:click_runeInfoBtn() end)
    vars['setSortBtn']:registerScriptTapHandler(function() self:click_setSortBtn() end) -- 룬 세트 필터
    vars['optSortBtn']:registerScriptTapHandler(function() self:click_optSortBtn() end) -- 룬 옵션 필터
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RuneForgePresetTab:onChangeTab(tab, first)
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
function UI_RuneForgePresetTab:clearSelectedRune(skip_clear_info)
    self.m_selectedRuneUI = nil
    self.m_focusRuneUI = nil
    self.m_selectedRuneObject = nil

    if (not skip_clear_info) then
        self:clearRuneInfo()
    end
end

-------------------------------------
-- function clearRuneInfo
-- @brief
-------------------------------------
function UI_RuneForgePresetTab:clearRuneInfo()
    local vars = self.vars

end

-------------------------------------
-- function setSelectedRune
-- @brief
-------------------------------------
function UI_RuneForgePresetTab:setSelectedRune(ui, data)
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
    cca.uiReactionSlow(ui.root, UI_RuneForgePresetTab.CARD_SCALE, UI_RuneForgePresetTab.CARD_SCALE)

    ui:setHighlightSpriteVisible(true)

    -- 선택 판매 시 사용
    if (self.m_bSelectSellActive) then

        if (data['owner_doid']) then
            UIManager:toastNotificationRed(Str('장착 중인 룬입니다.'))
            return
        end

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
function UI_RuneForgePresetTab:init_runeTableView(slot_idx)
    local vars = self.vars

    -- 선택된 룬이 있을 경우 제거
    self:clearSelectedRune() -- params : skip_clear_info

    local slot_idx = (slot_idx or self.m_currTab)
    local node = self.vars['runeTableViewNode']
    node:removeAllChildren()

    local l_item_list = self:getFilteredRuneList(slot_idx)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(UI_RuneForgePresetTab.CARD_SCALE)       

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

        -- UI_RuneCard의 press_clickBtn으로 열린 UI_ItemInfoPopup이 닫힐 때 불리는 callback function
        local function close_info_callback()
            -- 룬이 잠금처리 되어 있을 경우
            if self.m_selectedRuneObject and (ui.m_runeData:getObjectId() == self.m_selectedRuneObject:getObjectId()) then
                self.m_selectedRuneObject:setLock(ui:isRuneLock())
                self.vars['lockSprite']:setVisible(self.m_selectedRuneObject:getLock())
            end
        end
        
        ui:setCloseInfoCallback(close_info_callback)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_RuneForgePresetTab.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 8
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
            uic_sort_list:setSelectSortType('set_id', true)
            self.vars['runeSortLabel']:setString(Str('정렬'))
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

        self.m_sortManagerRune = sort_manager
    end

    self.m_tableViewTD = table_view_td
    self.m_sortManagerRune:sortExecution(table_view_td.m_itemList)
end

-------------------------------------
-- function onChangeSelectedItem
-------------------------------------
function UI_RuneForgePresetTab:onChangeSelectedItem(ui, data)
    local vars = self.vars
end

-------------------------------------
-- function sellBtn
-- @brief
-------------------------------------
function UI_RuneForgePresetTab:sellBtn(t_rune_data)
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
-- function refresh_noti
-- @brief 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
-------------------------------------
function UI_RuneForgePresetTab:refresh_noti()
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
function UI_RuneForgePresetTab:refresh_selectedRune(new_data)
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
function UI_RuneForgePresetTab:refresh_tableView(l_deleted_rune_oids)
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
-- function click_runeInfoBtn
-- @brief 룬 도움말
-------------------------------------
function UI_RuneForgePresetTab:click_runeInfoBtn()
    UI_HelpRune()
end

-------------------------------------
-- function refresh_runeSetFilter
-------------------------------------
function UI_RuneForgePresetTab:refresh_runeSetFilter()
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

    self:init_runeTableView()

    self:refreshRunesCount() -- 룬 개수 갱신
    self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
end

-------------------------------------
-- function refresh_sortFilter
-------------------------------------
function UI_RuneForgePresetTab:refresh_runeOptionFilter()
    local vars = self.vars

    self:init_runeTableView()

    self:refreshRunesCount() -- 룬 개수 갱신
    self:refresh_noti() -- 룬 번호(슬롯) 별 new가 붙은 룬 수량 갱신
end

-------------------------------------
-- function click_setSortBtn
-- @brief 룬 세트 필터 버튼
-------------------------------------
function UI_RuneForgePresetTab:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    
    local function close_cb(set_id) 
        self.m_setID = set_id

        self:refresh_runeSetFilter()
    end
    
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_optSortBtn
-- @brief 룬 옵션 필터 버튼
-------------------------------------
function UI_RuneForgePresetTab:click_optSortBtn()
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

        self:refresh_runeOptionFilter()
    end

    ui:setCloseCB(close_cb)
end

-----------------------------
-- function click_setBtn
-- @brief 세트 효과 보기 버튼
-------------------------------------
function UI_RuneForgePresetTab:click_setBtn()
    local vars = self.vars

    vars['memoMenu']:setVisible(false)
    vars['memoBtn']:setVisible(true)
end

-------------------------------------
-- function apply_runesSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_RuneForgePresetTab:apply_runesSort()
    self.m_sortManagerRune:sortExecution(self.m_tableViewTD.m_itemList)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function refreshRunesCount
-- @brief 룬 개수 갱신
-------------------------------------
function UI_RuneForgePresetTab:refreshRunesCount()
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
function UI_RuneForgePresetTab:getNewRuneSlotTable()
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
function UI_RuneForgePresetTab:getFilteredRuneList(slot_idx)
    local unequipped = not self.m_bIncludeEquipped
    local slot = slot_idx
    local set_id = self.m_setID
    local l_mopt_list = self.m_lMoptList
    local l_sopt_list = self.m_lSoptList

    -- 리스트가 아닌 map의 형태임을 주의하자
    local l_rune_obj = g_runesData:getFilteredRuneList(unequipped, slot, set_id, l_mopt_list, l_sopt_list)
    return l_rune_obj
end
