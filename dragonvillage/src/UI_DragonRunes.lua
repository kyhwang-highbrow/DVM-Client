
local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunes
-------------------------------------
UI_DragonRunes = class(PARENT,{
        m_listFilterSetID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManagerRune = 'SortManager_Rune', -- 룬 정렬
        m_equippedRuneObject = 'StructRuneObject',
        m_selectedRuneObject = 'StructRuneObject',

        m_mEquippedRuneObjects = 'map',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonRunes:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonRunes'
    self.m_bVisible = true or false
    self.m_titleStr = Str('')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_invenType = 'rune' 
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunes:init(doid, slot_idx)
    self.m_selectDragonOID = doid
    self.m_listFilterSetID = 0
    self.m_mEquippedRuneObjects = {}

    local vars = self:load('dragon_rune.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunes')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 룬 Tab 설정
    self:initUI_runeTab(slot_idx)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunes:initUI()
    self:init_tableViewTD()

    if (IS_TEST_MODE()) then
        self.vars['selectDevBtn']:setVisible(true)
        self.vars['selectDevBtn']:registerScriptTapHandler(function() self:click_selectDevBtn() end)
        self.vars['useDevBtn']:setVisible(true)
        self.vars['useDevBtn']:registerScriptTapHandler(function() self:click_useDevBtn() end)
    else
        self.vars['selectDevBtn']:setVisible(false)
        self.vars['useDevBtn']:setVisible(false)
    end

    self:setEquipedRuneObject(nil)
    self:setSelectedRuneObject(nil)

    self:init_dragonTableView()

    -- 룬 정렬 최초 전체 선택
    self:refresh_runeSetFilter(0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunes:initButton()
    local vars = self.vars

    -- 장착된 룬
    vars['useEnhanceBtn']:registerScriptTapHandler(function() self:click_useEnhanceBtn() end)
    vars['useLockBtn']:registerScriptTapHandler(function() self:click_useLockBtn() end)
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)    

    -- 선택된 룬 판매
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
    vars['selectLockBtn']:registerScriptTapHandler(function() self:click_selectLockBtn() end)
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
    vars['selectEnhanceBtn']:registerScriptTapHandler(function() self:click_selectEnhance() end)

    -- 룬 정렬
    vars['setSortBtn']:registerScriptTapHandler(function() self:click_setSortBtn() end)
    
    -- 모험 떠나기
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)

	-- 룬 정보
	vars['runeInfoBtn']:registerScriptTapHandler(function() self:click_runeInfoBtn() end)
    vars['runeInfoBtn2']:registerScriptTapHandler(function() self:click_runeInfoBtn() end)

    -- 룬 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'rune_help')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunes:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    local did = t_dragon_data['did']

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end    

	-- 할인 이벤트
	local l_dc_event = g_hotTimeData:getDiscountEventList()
    for i, dc_target in ipairs(l_dc_event) do
        local only_value = true
        if (dc_target == HOTTIME_SALE_EVENT.RUNE_RELEASE) then
            g_hotTimeData:setDiscountEventNode(dc_target, vars, 'removeEventSprite', only_value)

        elseif (dc_target == HOTTIME_SALE_EVENT.RUNE_ENHANCE) then
            g_hotTimeData:setDiscountEventNode(dc_target, vars, 'useEnhanceEventSprite', only_value)
            g_hotTimeData:setDiscountEventNode(dc_target, vars, 'selectEnhanceEventSprite', only_value)
        end
    end

	-- 추천 룬
	self:refreshRecommendRune()

	-- refresh tableview
    self:refreshTableViewList()
end

-------------------------------------
-- function refreshRecommendRune
-------------------------------------
function UI_DragonRunes:refreshRecommendRune()
	local vars = self.vars
	local t_dragon_data = self.m_selectDragonData

	-- 드래곤이 없는 경우
    if (not t_dragon_data) then
		vars['runeInfoNode']:setVisible(false)
		vars['runeInfoLabel']:setString('')
        return
    end

	local did = t_dragon_data:getDid()
	local t_rune = TableDragon:getRecommendRuneInfo(did)
	
	-- 추천 룬 정보가 없는 경우
	if (not t_rune) then
		vars['runeInfoNode']:setVisible(false)
		vars['runeInfoLabel']:setString('')
		return
	end

	-- 초기화
	vars['runeInfoNode']:setVisible(true)
	vars['runeInfoNode']:removeAllChildren(true)
	
	-- 아이콘
	local res = t_rune['res']
	local icon = IconHelper:getIcon(res)
	vars['runeInfoNode']:addChild(icon)

	-- 텍스트
	local stat = t_rune['stat']
	local rich_color = string.format('r_set_%s', t_rune['color'])
	local gora_text = Str('이 드래곤이 좋아하는 능력치는 {@{1}}{2}{@SKILL_DESC_MOD}인 것 같다고라!', rich_color, stat)
	vars['runeInfoLabel']:setString(gora_text)
end


-------------------------------------
-- function refresh_runeSetFilter
-------------------------------------
function UI_DragonRunes:refresh_runeSetFilter(set_id)
    local vars = self.vars
    local table_rune_set = TableRuneSet()
    local text = (set_id == 0) and Str('전체') or table_rune_set:makeRuneSetNameRichText(set_id)
    vars['setSortLabel']:setString(text)

    self.m_listFilterSetID = set_id
    self:refreshTableViewList()

    -- 룬 개수 갱신
    self:refreshRunesCount()
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonRunes:getDragonList()
    return g_dragonsData:getDragonsListRef()
end

-------------------------------------
-- function initUI_runeTab
-- @brief 룰 슬롯 버튼 처리
-------------------------------------
function UI_DragonRunes:initUI_runeTab(slot_idx)
    local vars = self.vars
    slot_idx = slot_idx or 1
    self:addTab(1, vars['runeSlotBtn1'], vars['selectSprite1']) --, vars[l_rune_slot_name[1] .. 'TableViewNode'])
    self:addTab(2, vars['runeSlotBtn2'], vars['selectSprite2']) --, vars[l_rune_slot_name[2] .. 'TableViewNode'])
    self:addTab(3, vars['runeSlotBtn3'], vars['selectSprite3']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(4, vars['runeSlotBtn4'], vars['selectSprite4']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(5, vars['runeSlotBtn5'], vars['selectSprite5']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:addTab(6, vars['runeSlotBtn6'], vars['selectSprite6']) --, vars[l_rune_slot_name[3] .. 'TableViewNode'])
    self:setTab(slot_idx)
end

-------------------------------------
-- function init_tableViewTD
-- @brief
-------------------------------------
function UI_DragonRunes:init_tableViewTD()
    local vars = self.vars
    local node = self.vars['runeTableViewNode']
    node:removeAllChildren()

    local l_item_list = {}

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)

        local rune_obj = data
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectedRuneObject(rune_obj) end)
		
		-- 선택된 룬 하이라이트
		if (self.m_selectedRuneObject['roid'] == rune_obj['roid']) then
			ui:setHighlightSpriteVisible(true)
		end

		-- 새로 획득한 룬 뱃지
        local is_new = data:isNewRune()
        ui:setNewSpriteVisible(is_new)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_RuneCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(Str('조건에 맞는 룬이 없습니다.\n다양한 전투를 통해 룬을 획득해보세요!'))

    -- 정렬
    local sort_manager = SortManager_Rune()
    self.m_sortManagerRune = sort_manager

    self.m_tableViewTD = table_view_td


    do -- 정렬 UI 생성
        local uic_sort_list = MakeUICSortList_runeManage(vars['runeSortBtn'], vars['runeSortLabel'])

        -- 버튼을 통해 정렬이 변경되었을 경우
        local function sort_change_cb(sort_type)
            sort_manager:pushSortOrder(sort_type)
            self:apply_runesSort()
        
        end
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
-- function apply_runesSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonRunes:apply_runesSort()
    self.m_sortManagerRune:sortExecution(self.m_tableViewTD.m_itemList)
    self.m_tableViewTD:setDirtyItemList()
end

-------------------------------------
-- function onChangeTab
-- @brief 룬 슬롯 탭이 변경되었을 때
-------------------------------------
function UI_DragonRunes:onChangeTab(tab, first)
    self:refreshTableViewList()

    -- 슬롯 타입이 변경되었을 때
    local slot_idx = tab
    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)
    local roid = dragon_obj['runes'][tostring(slot_idx)]
    if (roid == '') then
        roid = nil
    end
    if roid then
        local rune_obj = g_runesData:getRuneObject(roid)
        self:setEquipedRuneObject(rune_obj)
    else
        self:setEquipedRuneObject(nil)
    end
end

-------------------------------------
-- function refreshTableViewList
-- @brief
-------------------------------------
function UI_DragonRunes:refreshTableViewList()
    local vars = self.vars

    local unequipped = true
    local slot = self.m_currTab
    local set_id = self.m_listFilterSetID

    local l_item_list = g_runesData:getFilteredRuneList(unequipped, slot, set_id)

    local function refresh_func(item, new_data)
        local old_data = item['data']

        if (old_data['updated_at'] ~= new_data['updated_at']) then
            local roid = new_data['roid']
            self.m_tableViewTD:replaceItemUI(roid, new_data)
        end
    end

    self.m_tableViewTD:mergeItemList(l_item_list, refresh_func)

    -- 정렬
    self:apply_runesSort()

    -- 선택된 룬 refresh
    if (self.m_selectedRuneObject) then
        local roid = self.m_selectedRuneObject['roid']
        local rune_obj = l_item_list[roid]

        if (not rune_obj) then
            self:setSelectedRuneObject(nil)
        elseif (self.m_selectedRuneObject['updated_at'] ~= rune_obj['updated_at']) then
            self:setSelectedRuneObject(rune_obj)
        end
    end

    -- 리스트에서 첫 룬 자동 선택
    if (not self.m_selectedRuneObject) then
        local first_item = self.m_tableViewTD.m_itemList[1]
        if first_item and first_item['data'] then
            self:setSelectedRuneObject(first_item['data'])
        end
    end

    -- 조건에 맞는 룬이 없을 경우
    vars['runeEmptyMenu']:setVisible(not self.m_selectedRuneObject)

    -- 드래곤이 장착 중인 6개의 룬 정보 갱신
    self:refreshEquippedRunes()

    do -- 슬롯별 룬이 있는지 없는지 여부
        local unequipped = true
        local set_id = 0
        for slot=1, 6 do
            local l_item_list = g_runesData:getFilteredRuneList(unequipped, slot, set_id)
            local count = table.count(l_item_list)

            local is_empty = (count <= 0)
            vars['emptySlot' .. slot]:setVisible(is_empty)
        end
    end

    -- 룬 개수 갱신
    self:refreshRunesCount()
end

-------------------------------------
-- function refreshRunesCount
-- @brief 룬 개수 갱신
-------------------------------------
function UI_DragonRunes:refreshRunesCount()
    if (not self.m_listFilterSetID) then
        return
    end

    local vars = self.vars
    local unequipped = true
    local set_id = self.m_listFilterSetID
    for slot= 1, 6 do
        local l_item_list = g_runesData:getFilteredRuneList(unequipped, slot, set_id)
        local count = table.count(l_item_list)
        vars['runeNumLabel'..slot]:setString(Str('{1}개', comma_value(count)))
    end
end

-------------------------------------
-- function refreshEquippedRunes
-- @brief 장착된 룬 리스트(탭에 붙어 있음)
-------------------------------------
function UI_DragonRunes:refreshEquippedRunes()
    local vars = self.vars
    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)
    local rune_set_obj = dragon_obj:getStructRuneSetObject()
    local active_set_list = rune_set_obj:getActiveRuneSetList()

    -- 애니 재생 가능한 룬 갯수 설정 (2세트 5개 착용시 처음 슬롯부터 4개까지만)
    local function get_need_equip(set_id)
        local need_equip = 0
        for _, v in ipairs(active_set_list) do
            if (v == set_id) then
                need_equip = need_equip + TableRuneSet:getRuneSetNeedEquip(set_id)
            end
        end

        return need_equip
    end

    -- 해당룬 세트 효과 활성화 되있다면 애니 재생
    local t_equip = {}
    local function show_set_effect(slot_id, set_id)
        for _, v in ipairs(active_set_list) do
            local visual = vars['runeVisual'..slot_id]
            if (v == set_id) then
                if (t_equip[set_id]) then
                    t_equip[set_id] = t_equip[set_id] + 1
                else
                    t_equip[set_id] = 1
                end

                local need_equip = get_need_equip(set_id)
                if (t_equip[set_id] <= need_equip) then
                    local ani_name = TableRuneSet:getRuneSetVisualName(slot_id, set_id)
                    visual:setVisible(true)
                    visual:changeAni(ani_name, true)
                end
                break
            end
        end
    end

    local slot_idx = self.m_currTab

    for i=1, 6 do
        vars['runeVisual'..i]:setVisible(false)

        local equipeed_roid = dragon_obj['runes'][tostring(i)]
        if (equipeed_roid == '') then
            equipeed_roid = nil
        end
        local rune_slot = vars['runeSlot' .. i]

        -- 장착이 되지 않았고 변경도 없을 경우
        if ((not self.m_mEquippedRuneObjects[i]) and (not equipeed_roid)) then

        -- 장착이 해제가 된 경우
        elseif (self.m_mEquippedRuneObjects[i] and (not equipeed_roid)) then
            rune_slot:removeAllChildren()
            self.m_mEquippedRuneObjects[i] = nil

            if (slot_idx == i) then
                self:setEquipedRuneObject(nil)
            end

        -- 새롭게 장착이 된 경우
        elseif ((not self.m_mEquippedRuneObjects[i]) and equipeed_roid) then
            local rune_obj = g_runesData:getRuneObject(equipeed_roid)
            self.m_mEquippedRuneObjects[i] = rune_obj
            local card = UI_RuneCard(rune_obj)
			card:setBtnEnabled(false)
            rune_slot:addChild(card.root)

            if (slot_idx == i) then
                self:setEquipedRuneObject(rune_obj)
            end

            local set_id = rune_obj['set_id']
            show_set_effect(i, set_id)

        -- 둘 다 있을 경우
        else
            local before_rune_obj = self.m_mEquippedRuneObjects[i]
            local rune_obj = g_runesData:getRuneObject(equipeed_roid)
            if (before_rune_obj['updated_at'] ~= rune_obj['updated_at']) then
                self.m_mEquippedRuneObjects[i] = rune_obj
                rune_slot:removeAllChildren()
                local card = UI_RuneCard(rune_obj)
				card:setBtnEnabled(false)
                rune_slot:addChild(card.root)

                if (slot_idx == i) then
                    self:setEquipedRuneObject(rune_obj)
                end
            end

            local set_id = rune_obj['set_id']
            show_set_effect(i, set_id)
        end
        
    end
    
end

-------------------------------------
-- function setEquipedRuneObject
-- @brief
-------------------------------------
function UI_DragonRunes:setEquipedRuneObject(rune_obj)
    local vars = self.vars
    self.m_equippedRuneObject = rune_obj

    -- 룬 아이콘 삭제
    vars['useRuneNode']:removeAllChildren()
    vars['useRuneNameLabel']:setString('')
    vars['useMainOptionLabel']:setString('')
    vars['useSubOptionLabel']:setString('')
    vars['useRuneSetLabel']:setString('')

    if (not rune_obj) then
        vars['useMenu']:setVisible(false)
        vars['useEmptyMenu']:setVisible(true)
        cca.uiReactionSlow(vars['useEmptyMenu'], 1, 1, 0.95)
        return
    else
        vars['useMenu']:setVisible(true)
        vars['useEmptyMenu']:setVisible(false)
        cca.uiReactionSlow(vars['useMenu'], 1, 1, 0.95)
    end

    -- 룬 명칭
    vars['useRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['useRuneNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['useMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['useSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['useRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

    do -- 레어도
        local color = rune_obj:getRarityColor()
        vars['useRuneNameLabel']:setColor(color)
        vars['useRarityNode']:setColor(color)

        local name = rune_obj:getRarityName()
        vars['useRarityLabel']:setString(name)
    end

    -- 잠금 정보 추가
    vars['useLockSprite']:setVisible(self.m_equippedRuneObject['lock'])
end

-------------------------------------
-- function setSelectedRuneObject
-- @brief
-------------------------------------
function UI_DragonRunes:setSelectedRuneObject(rune_obj)
    local vars = self.vars

    -- 하일라이트 삭제
    if self.m_selectedRuneObject then
        local roid = self.m_selectedRuneObject['roid']
        self:setTableViewItemHighlight(roid, false)
    end

    self.m_selectedRuneObject = rune_obj

    -- 룬 아이콘 삭제
    vars['selectRuneNode']:removeAllChildren()
    vars['selectRuneNameLabel']:setString('')
    vars['selectMainOptionLabel']:setString('')
    vars['selectSubOptionLabel']:setString('')
    vars['selectRuneSetLabel']:setString('')

    if (not rune_obj) then
        vars['selectMenu']:setVisible(false)
        return
    else
        vars['selectMenu']:setVisible(true)
        cca.uiReactionSlow(vars['selectMenu'], 1, 1, 0.95)
    end

	-- 신규 룬 표시 삭제
	local roid = rune_obj['roid']
    g_highlightData:removeNewRoid(roid)

    -- 룬 명칭
    vars['selectRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['selectRuneNode']:addChild(rune_icon.root)

    -- 메인, 유니크 옵션
    vars['selectMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 서브 옵션
    vars['selectSubOptionLabel']:setString('')

    -- 세트 옵션
    vars['selectRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

    do -- 레어도
        local color = rune_obj:getRarityColor()
        vars['selectRuneNameLabel']:setColor(color)
        vars['selectRarityNode']:setColor(color)

        local name = rune_obj:getRarityName()
        vars['selectRarityLabel']:setString(name)
    end

    -- 하일라이트 추가
    if self.m_selectedRuneObject then
        local roid = self.m_selectedRuneObject['roid']
        self:setTableViewItemHighlight(roid, true)
    end

    -- 잠금 정보 추가
    vars['selectLockSprite']:setVisible(self.m_selectedRuneObject['lock'])
end

-------------------------------------
-- function setTableViewItemHighlight
-- @brief
-------------------------------------
function UI_DragonRunes:setTableViewItemHighlight(roid, visible)
    local item = self.m_tableViewTD:getItem(roid)
    if (not item) then
        return
    end

    local ui = item['ui']
    if (not ui) then
        return
    end

    ui:setHighlightSpriteVisible(visible)
end

-------------------------------------
-- function click_selectDevBtn
-- @brief (임시로 룬 개발 API 팝업 호출)
-------------------------------------
function UI_DragonRunes:click_selectDevBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local ui = UI_RuneDevApiPopup(self.m_selectedRuneObject.roid)
    
    local function close_cb()
        local t_rune_data = g_runesData:getRuneObject(ui.m_runeObjectID)

        if (self.m_selectedRuneObject['updated_at'] ~= t_rune_data['updated_at']) then
            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_useDevBtn
-- @brief (임시로 룬 개발 API 팝업 호출)
-------------------------------------
function UI_DragonRunes:click_useDevBtn()
    if (not self.m_equippedRuneObject) then
        return
    end

    local ui = UI_RuneDevApiPopup(self.m_equippedRuneObject.roid)

    local function close_cb()
        local t_rune_data = g_runesData:getRuneObject(ui.m_runeObjectID)

        if (self.m_equippedRuneObject['updated_at'] ~= t_rune_data['updated_at']) then
            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_sellBtn
-- @brief 룬 판매 버튼
-------------------------------------
function UI_DragonRunes:click_sellBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local rune_obj = self.m_selectedRuneObject
    local roid = rune_obj['roid']
    
    if (rune_obj['lock'] == true) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('잠금 상태입니다.'))
        return
    end

    -- 판매 요청 (서버에)
    local function request_item_sell()
        local function finish_cb(ret)
            -- 판매된 룬을 리스트에서 제거하기 위해 refresh
            self:refreshTableViewList()
        end

        g_runesData:request_runeSell(roid, finish_cb)
    end

    -- 확인 팝업
    local item_name = rune_obj['name']
    local item_price = TableItem():getValue(rune_obj['rid'], 'sale_price')
    local msg = Str('[{1}](을)를 {2}골드에 판매하시겠습니까?', item_name, comma_value(item_price))
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_item_sell)
end

-------------------------------------
-- function click_selectLockBtn
-- @brief 룬 잠금 버튼
-------------------------------------
function UI_DragonRunes:click_selectLockBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local roid = self.m_selectedRuneObject['roid']
    local owner_doid = self.m_selectedRuneObject['owner_doid']

    local function finish_cb()
        local new_data = g_runesData:getRuneObject(roid)
        if (self.m_selectedRuneObject['updated_at'] ~= new_data['updated_at']) then
            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end
    end

    g_runesData:request_runesLock_toggle(roid, owner_doid, finish_cb)
end

-------------------------------------
-- function getSelectDragonAttr
-- @brief
-------------------------------------
function UI_DragonRunes:getSelectDragonAttr()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return nil
    end

    local did = t_dragon_data['did']
    local attr = TableDragon:getDragonAttr(did)
    return attr
end

-------------------------------------
-- function click_useEnhanceBtn
-- @brief 룬 강화 버튼
-------------------------------------
function UI_DragonRunes:click_useEnhanceBtn()
    if (not self.m_equippedRuneObject) then
        return
    end

    local ui = UI_DragonRunesEnhance(self.m_equippedRuneObject, self:getSelectDragonAttr())

    local function close_cb()
        if (self.m_equippedRuneObject['updated_at'] ~= ui.m_runeObject['updated_at']) then
            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_useLockBtn
-- @brief 룬 잠금 버튼
-------------------------------------
function UI_DragonRunes:click_useLockBtn()
    if (not self.m_equippedRuneObject) then
        return
    end

    local roid = self.m_equippedRuneObject['roid']
    local owner_doid = self.m_equippedRuneObject['owner_doid']

    local function finish_cb()
        local new_data = g_runesData:getRuneObject(roid)
        if (self.m_equippedRuneObject['updated_at'] ~= new_data['updated_at']) then
            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end
    end

    g_runesData:request_runesLock_toggle(roid, owner_doid, finish_cb)
end

-------------------------------------
-- function click_removeBtn
-- @brief 룬 해제 버튼
-------------------------------------
function UI_DragonRunes:click_removeBtn()
    if (not self.m_equippedRuneObject) then
        return
    end

    local rune_obj = self.m_equippedRuneObject
    local slot = rune_obj['slot']
    local doid = self.m_selectDragonOID

    local grade = rune_obj['grade']
    local price = TableRuneGrade:getUnequipPrice(grade)

	-- 룬 할인 이벤트
	local dc_value = g_hotTimeData:getDiscountEventValue('rune')
	if (dc_value) then
		price = price * (1 - (dc_value / 100))
	end

    local function ok_btn_cb()
        local function finish_cb(ret)

            -- 해제한 룬을 선택하게 함
            if (not self.m_selectedRuneObject) then 
                self:setSelectedRuneObject(rune_obj)
            end

            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end

        g_runesData:request_runesUnequip(doid, slot, finish_cb, fail_cb)
    end

    MakeSimplePopup_Confirm('gold', price, Str('룬을 해제하시겠습니까?'), ok_btn_cb)
end



-------------------------------------
-- function click_selectEnhance
-- @brief 룬 강화 버튼
-------------------------------------
function UI_DragonRunes:click_selectEnhance()
    if (not self.m_selectedRuneObject) then
        return
    end

    local ui = UI_DragonRunesEnhance(self.m_selectedRuneObject, self:getSelectDragonAttr())

    local function close_cb()
        if (self.m_selectedRuneObject['updated_at'] ~= ui.m_runeObject['updated_at']) then
            self:refreshTableViewList()
            self.m_bChangeDragonList = true
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_setSortBtn
-- @brief 룬 정렬 버튼
-------------------------------------
function UI_DragonRunes:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    ui:setCloseCB(function(set_id)
        self:refresh_runeSetFilter(set_id)
    end)
end

-------------------------------------
-- function click_adventureBtn
-- @brief "모험 떠나기"
-------------------------------------
function UI_DragonRunes:click_adventureBtn()
    local stage_id = g_settingData:get('adventure_focus_stage')
    UINavigator:goTo('adventure', stage_id)
end

-------------------------------------
-- function click_runeInfoBtn
-- @brief 룬 도움말
-------------------------------------
function UI_DragonRunes:click_runeInfoBtn()
	--UI_Help('rune')
    UI_GuidePopup_Rune()
    -- sgkim 2018.08.22 텍스트로만 되어있는 도움말에서 별도의 룬 관련 도움말 UI로 변경
end

-------------------------------------
-- function click_equipBtn
-- @brief 룬 장착 버튼
-------------------------------------
function UI_DragonRunes:click_equipBtn()
    if (not self.m_selectedRuneObject) then
        return
    end

    local rune_obj = self.m_selectedRuneObject
    local roid = rune_obj['roid']
    local doid = self.m_selectDragonOID


    local slot_idx = rune_obj['slot']
    if self.m_mEquippedRuneObjects[slot_idx] then

        -- 잠금 확인
        local rune_obj = self.m_mEquippedRuneObjects[slot_idx]
        if (rune_obj['lock'] == true) then
            MakeSimplePopup2(POPUP_TYPE.OK, Str('기존에 장착된 룬이 있으며 룬이 잠금 상태입니다.'), Str('(장착된 룬은 골드를 사용하여 "해제"할 수 있습니다)'))
            return
        end

        local function ok_btn_cb()
            self:request_runeEquip(doid, roid)
        end
        MakeSimplePopup2(POPUP_TYPE.YES_NO, Str('기존에 장착된 룬은 파괴됩니다.\n장착하시겠습니까?'), Str('(장착된 룬은 골드를 사용하여 "해제"할 수 있습니다)'), ok_btn_cb)
    else
        self:request_runeEquip(doid, roid)
    end
end

-------------------------------------
-- function request_runeEquip
-- @brief 룬 장착
-------------------------------------
function UI_DragonRunes:request_runeEquip(doid, roid)
    local function finish_cb(ret)
        self:refreshTableViewList()
        self.m_bChangeDragonList = true
    end

    g_runesData:request_runesEquip(doid, roid, finish_cb)
end