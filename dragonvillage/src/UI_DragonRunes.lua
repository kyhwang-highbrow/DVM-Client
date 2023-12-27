
local PARENT = class(UI_DragonManage_Base, ITabUI:getCloneTable())

-------------------------------------
-- class UI_DragonRunes
-------------------------------------
UI_DragonRunes = class(PARENT,{
        m_listFilterSetID = 'number', -- 0번은 전체 1~8은 해당 세트만
        m_lMoptList = 'list', -- 선택된 주옵션 필터
        m_lSoptList = 'list', -- 선택된 보조옵션 필터
        m_bIncludeEquipped = 'boolean', -- 장착 룬 포함 여부 필터 

        m_tableViewTD = 'UIC_TableViewTD',
        m_sortManagerRune = 'SortManager_Rune', -- 룬 정렬
        m_equippedRuneObject = 'StructRuneObject',
        m_selectedRuneObject = 'StructRuneObject',

        m_mEquippedRuneObjects = 'map',
        m_selectOptionLabel = 'ui',
        m_useOptionLabel = 'ui',

        m_useRuneUI = '',
        m_selectRuneUI = '',
        m_lfocusEquippedRuneUIList = 'list',
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
    self.m_lMoptList = nil
    self.m_lSoptList = nil
    self.m_bIncludeEquipped = g_settingData:get('option_rune_filter', 'not_include_equipped_2')
    self.m_mEquippedRuneObjects = {}
    self.m_selectOptionLabel = nil
    self.m_useOptionLabel = nil

    self.m_useRuneUI = nil
    self.m_selectRuneUI = nil
    self.m_lfocusEquippedRuneUIList = {}

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

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)
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
        self.vars['addDevBtn']:setVisible(true)
        self.vars['addDevBtn']:registerScriptTapHandler(function() self:click_addDevBtn() end)

    else
        self.vars['selectDevBtn']:setVisible(false)
        self.vars['useDevBtn']:setVisible(false)
        self.vars['addDevBtn']:setVisible(false)
    end

    self:setEquipedRuneObject(nil)
    self:setSelectedRuneObject(nil)

    self:init_dragonTableView()

    -- 룬 정렬 최초 전체 선택
    self:refresh_runeSetFilter(0)
    self.vars['setSortLabel']:setString(Str('세트'))
    
    self.vars['optSortLabel']:setColor(cc.c4b(240, 215, 159))

    self.vars['runeSortLabel']:setString(Str('정렬'))
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
    --vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtn() end)
    vars['equipBtn']:registerScriptTapHandler(function() self:click_equipBtnNew() end)
    vars['selectEnhanceBtn']:registerScriptTapHandler(function() self:click_selectEnhance() end)

    -- 룬 필터
    vars['setSortBtn']:registerScriptTapHandler(function() self:click_setSortBtn() end)
    vars['optSortBtn']:registerScriptTapHandler(function() self:click_optSortBtn() end)
    
    -- 모험 떠나기
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventureBtn() end)

	-- 룬 정보
	vars['runeInfoBtn']:registerScriptTapHandler(function() self:click_runeInfoBtn() end)
    vars['runeInfoBtn2']:registerScriptTapHandler(function() self:click_runeInfoBtn() end)

    -- 룬 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'rune_help')

    -- 일괄 장착
    vars['equipBtn1']:registerScriptTapHandler(function () self:click_bulkEquipBtn() end)
    vars['equipBtn2']:registerScriptTapHandler(function () self:click_bulkEquipBtn() end)

    -- 세트 효과 보기
    vars['useSetBtn']:registerScriptTapHandler(function() self:click_setBtn('use') end) 
    vars['selectSetBtn']:registerScriptTapHandler(function() self:click_setBtn('select') end)
    
    -- 메모 보기
    vars['useMemoBtn']:registerScriptTapHandler(function() self:click_memoBtn('use') end)
    vars['selectMemoBtn']:registerScriptTapHandler(function() self:click_memoBtn('select') end)

    vars['useMemoEditBtn']:registerScriptTapHandler(function() self:click_memoEditBtn('use') end)
    vars['selectMemoEditBtn']:registerScriptTapHandler(function() self:click_memoEditBtn('select') end)

	-- editBox handler 등록
    local function checkMemoWithType(type) 
        local t_rune_data
        
        if (type == 'select') then
            t_rune_data = self.m_selectedRuneObject
            
        elseif (type == 'use') then
            t_rune_data = self.m_equippedRuneObject
        end

        if (t_rune_data == nil) then
            return
        end

        local roid = t_rune_data['roid']

		-- 키보드 입력이 종료될 때 텍스트 검증을 한다.
        local text = vars[type .. 'MemoEditBox']:getText()
        local context, is_valid = g_runeMemoData:validateMemoText(text)
        if (not is_valid) then
            self:refresh_memoLabel(type)
            return
        end

		local function proceed_func()
            local t_rune_data = self.m_selectedRuneObject
            if (t_rune_data) then
			    g_runeMemoData:modifyMemo(roid, context)
			    g_runeMemoData:saveRuneMemoMap()
                self:refresh_memoLabel(type)
            end
        end

		local function cancel_func()
            self:refresh_memoLabel(type)
		end
			
		-- 비속어 필터링
        CheckBlockStr(context, proceed_func, cancel_func)
    end

	local function useEditBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            checkMemoWithType('use')       
        end
    end
    vars['useMemoEditBox']:registerScriptEditBoxHandler(useEditBoxTextEventHandle)
    vars['useMemoEditBox']:setMaxLength(RUNE_MEMO_MAX_LENGTH)

    local function selectEditBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            checkMemoWithType('select')       
        end
    end

    vars['selectMemoEditBox']:registerScriptEditBoxHandler(selectEditBoxTextEventHandle)
    vars['selectMemoEditBox']:setMaxLength(RUNE_MEMO_MAX_LENGTH)

    do
        local user_level = g_userData:get('lv')
        local free_level = g_constant:get('INGAME', 'FREE_RUNE_UNEQUIP_USER_LV')
        if user_level <= free_level then
            local text = Str('{@yellow}75레벨 이하 룬 해제 비용 없음{@}')
            local node = self:getBubbleText(text)

            node:setPositionX(0)
            node:setPositionY(40)

            vars['removeBtn']:addChild(node)
        end
    end
end

-------------------------------------
-- function getBubbleText
-------------------------------------
function UI_DragonRunes:getBubbleText(txt_str)
	-- 베이스 노드
	local node = cc.Node:create()
	node:setDockPoint(cc.p(0.0, 0.5))
	node:setAnchorPoint(cc.p(0.0, 0.5))

	-- 말풍선 프레임
	local frame = cc.Scale9Sprite:create('res/ui/frames/event_0202.png')
	frame:setDockPoint(cc.p(1.0, 0.5))
	frame:setAnchorPoint(cc.p(1.0, 0.5))
    frame:setScaleX(-1)


	-- 텍스트 (rich_label)
	local rich_label = UIC_RichLabel()
    rich_label:setString(txt_str)
    rich_label:setFontSize(18)
    rich_label:setDimension(500, 70)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:setDockPoint(cc.p(0.5, 0.5))
    rich_label:setAnchorPoint(cc.p(0.5, 0.5))
	rich_label:setPosition(0, 5)
    rich_label.m_node:setScaleX(-1)

	-- label 사이즈로 프레임 조정
	local width = math_max(226, rich_label:getStringWidth() + 50)
	local size = frame:getContentSize()
	frame:setNormalSize(width, size['height'] + 10)

	-- addChild
	frame:addChild(rich_label.m_node)
	node:addChild(frame)

	-- fade out을 위해 설정
	doAllChildren(node, function(node) node:setCascadeOpacityEnabled(true) end)

	return node
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
            g_hotTimeData:setDiscountEventNode(dc_target, vars, 'equipEventSprite1', only_value)
            g_hotTimeData:setDiscountEventNode(dc_target, vars, 'equipEventSprite2', only_value)

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

    self.m_listFilterSetID = set_id
    self:refreshTableViewList()

    -- 룬 개수 갱신
    self:refreshRunesCount()
end

-------------------------------------
-- function refresh_runeOptionFilter
-------------------------------------
function UI_DragonRunes:refresh_runeOptionFilter(l_mopt_list, l_sopt_list, b_include_equipped)
    local vars = self.vars

    self.m_lMoptList = l_mopt_list
    self.m_lSoptList = l_sopt_list
    self.m_bIncludeEquipped = b_include_equipped

    self:refreshTableViewList(true)

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
        ui.root:setScale(0.55)

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
    table_view_td.m_cellSize = cc.size(86, 106)
    table_view_td.m_nItemPerCell = 6
    table_view_td.m_marginFinish = 15
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_RuneCardOption, create_func)
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
    self.m_tableViewTD:relocateContainerDefault()

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
function UI_DragonRunes:refreshTableViewList(is_force_refresh)
    local vars = self.vars    

    local slot = self.m_currTab
    local l_item_list = self:getFilteredRuneList(slot)

    local function refresh_func(item, new_data)
        local old_data = item['data']
        if is_force_refresh == true or (old_data['updated_at'] ~= new_data['updated_at']) then
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
        for slot=1, 6 do
            local l_item_list = self:getFilteredRuneList(slot)
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

    for slot= 1, 6 do
        local l_item_list = self:getFilteredRuneList(slot)
        local count = table.count(l_item_list)
        vars['runeNumLabel'..slot]:setString(Str('{1}개', comma_value(count)))
    end
end

-------------------------------------
-- function getFilteredRuneList
-- @brief 룬 리스트 받기
-------------------------------------
function UI_DragonRunes:getFilteredRuneList(slot_idx)
    local set_id = self.m_listFilterSetID
    local l_mopt_list = self.m_lMoptList
    local l_sopt_list = self.m_lSoptList
    local unequipped = not self.m_bIncludeEquipped

    local l_item_list = g_runesData:getFilteredRuneList(unequipped, slot_idx, set_id, l_mopt_list, l_sopt_list)

    -- TODO : 자신이 장착한 거 빼기
    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)

    local equip_roid = dragon_obj['runes'] and dragon_obj['runes'][tostring(slot_idx)] or nil
    if (equip_roid ~= nil) then
        l_item_list[equip_roid] = nil
    end
    
    return l_item_list
end

-------------------------------------
-- function refreshEquippedRunes
-- @brief 장착된 룬 리스트(탭에 붙어 있음)
-------------------------------------
function UI_DragonRunes:refreshEquippedRunes()
    local vars = self.vars
    local dragon_obj = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)
    if dragon_obj == nil then
        return
    end

    if dragon_obj:getObjectType() ~= 'dragon' then
        return
    end

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
            self.m_lfocusEquippedRuneUIList[i] = nil

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
            self.m_lfocusEquippedRuneUIList[i] = card

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
                self.m_lfocusEquippedRuneUIList[i] = card

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
        -- 룬 옵션 라벨
        self:setOptionLabel(false)
    end

    -- 룬 명칭
    vars['useRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['useRuneNode']:addChild(rune_icon.root)

    self.m_useRuneUI = rune_icon

    -- 세트 옵션
    vars['useRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

    do -- 레어도
        local color = rune_obj:getRarityColor()
        vars['useRuneNameLabel']:setColor(color)
        vars['useRarityNode']:setColor(color)

        local name = rune_obj:getRarityName()
        vars['useRarityLabel']:setString(name)
    end

    -- 룬 메모
    local roid = rune_obj['roid']
    local rune_memo = g_runeMemoData:getMemo(roid)
    -- 메모가 있는 경우 바로 메모 창을 보여주고
    if (rune_memo ~= nil) then
        vars['useMemoBtn']:setVisible(false)
        vars['useMemoMenu']:setVisible(true)
        self:refresh_memoLabel('use')
    -- 없는 경우에는 세트 효과창을 보여준다.
    else
        vars['useMemoBtn']:setVisible(true)
        vars['useMemoMenu']:setVisible(false)
        self:refresh_memoLabel('use')
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
        -- 룬 옵션 라벨
        self:setOptionLabel(true)
    end

	-- 신규 룬 표시 삭제
	local roid = rune_obj['roid']
    g_highlightData:removeNewRoid(roid)

    -- 룬 명칭
    vars['selectRuneNameLabel']:setString(rune_obj['name'])

    -- 룬 아이콘
    local rune_icon = UI_RuneCard(rune_obj)
    vars['selectRuneNode']:addChild(rune_icon.root)

    self.m_selectRuneUI = rune_icon

    -- 세트 옵션
    vars['selectRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

    do -- 레어도
        local color = rune_obj:getRarityColor()
        vars['selectRuneNameLabel']:setColor(color)
        vars['selectRarityNode']:setColor(color)

        local name = rune_obj:getRarityName()
        vars['selectRarityLabel']:setString(name)
    end

    -- 룬 메모
    local rune_memo = g_runeMemoData:getMemo(roid)
    -- 메모가 있는 경우 바로 메모 창을 보여주고
    if (rune_memo ~= nil) then
        vars['selectMemoBtn']:setVisible(false)
        vars['selectMemoMenu']:setVisible(true)
        self:refresh_memoLabel('select')
    -- 없는 경우에는 세트 효과창을 보여준다.
    else
        vars['selectMemoBtn']:setVisible(true)
        vars['selectMemoMenu']:setVisible(false)
        self:refresh_memoLabel('select')
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
-- function setOptionLabel
-- @brief
-------------------------------------
function UI_DragonRunes:setOptionLabel(is_selected)

    if (is_selected) then
        local rune_selected_obj = self.m_selectedRuneObject
        if (not self.m_selectOptionLabel) then
            self.m_selectOptionLabel = rune_selected_obj:getOptionLabel()
            self.vars['selectRuneDscNode']:addChild(self.m_selectOptionLabel.root)
        end
        rune_selected_obj:setOptionLabel(self.m_selectOptionLabel, 'use', nil) -- param : ui, label_format, target_level
    else
        local rune_equipped_obj = self.m_equippedRuneObject
        if (not self.m_useOptionLabel) then      
            self.m_useOptionLabel = rune_equipped_obj:getOptionLabel()
            self.vars['useRuneDscNode']:addChild(self.m_useOptionLabel.root)
        end
        rune_equipped_obj:setOptionLabel(self.m_useOptionLabel, 'use', nil) -- param : ui, label_format, target_level
    end
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

------------------------------------
-- function click_addDevBtn
-- @brief 개발용 룬 획득 API 팝업 호출
-------------------------------------
function UI_DragonRunes:click_addDevBtn()
    require('UI_RuneSelectDevApiPopup')
    local ui = UI_RuneSelectDevApiPopup()

    local function close_cb()
        self:refreshTableViewList()
        self:refreshRunesCount()
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
    local user_level = g_userData:get('lv')
    local free_level = g_constant:get('INGAME', 'FREE_RUNE_UNEQUIP_USER_LV')

	if (dc_value) then
		price = price * (1 - (dc_value / 100))
	end

    if user_level <= free_level then
        price = 0
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
-- @brief 룬 세트 필터 버튼
-------------------------------------
function UI_DragonRunes:click_setSortBtn()
    local ui = UI_RuneSetFilter()
    ui:setCloseCB(function(set_id)
        self:refresh_runeSetFilter(set_id)
    end)
end

-------------------------------------
-- function click_optSortBtn
-- @brief 룬 옵션 필터 버튼
-------------------------------------
function UI_DragonRunes:click_optSortBtn()
    local l_mopt_list = self.m_lMoptList
    local l_sopt_list = self.m_lSoptList
    local b_include_equipped = self.m_bIncludeEquipped

    local ui = UI_RuneOptionFilter(l_mopt_list, l_sopt_list, not b_include_equipped)

    local function close_cb(l_mopt_list, l_sopt_list, b_include_equipped) 
        local b_is_using_filter = (l_mopt_list ~= nil) or (l_sopt_list ~= nil)
        self.vars['optSortLabel']:setColor((b_is_using_filter == false) and cc.c4b(240, 215, 159) or cc.c4b(255, 215, 0))
        self:refresh_runeOptionFilter(l_mopt_list, l_sopt_list, b_include_equipped)
    end

    ui:setCloseCB(close_cb)
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
    UI_HelpRune()
end

-------------------------------------
-- function click_bulkEquipBtn
-- @brief 룬 일괄 장착
-------------------------------------
function UI_DragonRunes:click_bulkEquipBtn()
    local select_doid = self.m_selectDragonOID

    local function close_cb()
        self:refreshTableViewList()
        self.m_bChangeDragonList = true
    end

    local ui = UI_DragonRunesBulkEquip(select_doid)
    ui:setCloseCB(close_cb)
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
-- function click_equipBtnNew
-- @brief 룬 장착 버튼
-------------------------------------
function UI_DragonRunes:click_equipBtnNew()
    if (not self.m_selectedRuneObject) then
        return
    end

    local rune_obj = self.m_selectedRuneObject
    local roid = rune_obj['roid']
    local doid = self.m_selectDragonOID
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    local slot_idx = rune_obj['slot']

    -- 장착한 룬이 있거나 다른 드래곤이 장착한 룬을 장착하려는 경우
    if (self.m_mEquippedRuneObjects[slot_idx]) or (rune_obj['owner_doid']) then
        local total_price = 0
        local before_rune_obj = self.m_mEquippedRuneObjects[slot_idx]
        
        -- 해제 비용 계산
        if (before_rune_obj) then
            local before_rune_grade = before_rune_obj['grade']
            local price = TableRuneGrade:getUnequipPrice(before_rune_grade)
            total_price = total_price + price     
        end        
        
        if (rune_obj['owner_doid']) then
            local after_rune_grade = rune_obj['grade']
            local price = TableRuneGrade:getUnequipPrice(after_rune_grade)
            total_price = total_price + price
        end
            
        -- 룬 할인 이벤트
	    local dc_value = g_hotTimeData:getDiscountEventValue('rune')
        local user_level = g_userData:get('lv')
        local free_level = g_constant:get('INGAME', 'FREE_RUNE_UNEQUIP_USER_LV')

	    if (dc_value) then
		    total_price = total_price * (1 - (dc_value / 100))
	    end

        if user_level <= free_level then
            total_price = 0
        end

        self:request_runeEquipNew(doid, slot_idx, roid, total_price)

    -- 비어있는 슬롯에 다른 드래곤이 장착한 룬을 장착하지 않는 경우 바로 장착
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

-------------------------------------
-- function request_runeEquipNew
-- @brief 21-01-14 룬 편의성 개선 룬 장착 
-------------------------------------
function UI_DragonRunes:request_runeEquipNew(doid, rune_slot, after_roid, need_gold)
    local function finish_cb()
        self:refreshTableViewList()
        self.m_bChangeDragonList = true
    end

    local ui = UI_DragonRunesEquipPopup(doid, rune_slot, after_roid, need_gold, finish_cb)
end


-------------------------------------
-- function click_setBtn
-- @brief 세트 효과 보기 버튼
-------------------------------------
function UI_DragonRunes:click_setBtn(type)
    local vars = self.vars
    local type = type or 'select'

    vars[type .. 'MemoMenu']:setVisible(false)
    vars[type .. 'MemoBtn']:setVisible(true)
end

-------------------------------------
-- function click_memoBtn
-- @brief 메모 보기 버튼
-------------------------------------
function UI_DragonRunes:click_memoBtn(type)
    local vars = self.vars
    local type = type or 'select'

    vars[type .. 'MemoMenu']:setVisible(true)
    vars[type .. 'MemoBtn']:setVisible(false)
end

-------------------------------------
-- function click_memoEditBtn
-- @brief 메모 수정 버튼
-------------------------------------
function UI_DragonRunes:click_memoEditBtn(type)
    local vars = self.vars

    local t_rune_data

    if (type == 'select') then
        t_rune_data = self.m_selectedRuneObject
            
    elseif (type == 'use') then
        t_rune_data = self.m_equippedRuneObject
    end

    if (t_rune_data == nil) then
        return
    end
            
    local roid = t_rune_data['roid']
    local memo = g_runeMemoData:getMemo(roid) or ''
    
    vars[type .. 'MemoEditBox']:setText(memo)    
    vars[type .. 'MemoEditBox']:openKeyboard()
end

-------------------------------------
-- function refresh_memoLabel
-- @brief 메모 라벨 텍스트 refresh
-------------------------------------
function UI_DragonRunes:refresh_memoLabel(type)
    local vars = self.vars

     local t_rune_data

    if (type == 'select') then
        t_rune_data = self.m_selectedRuneObject
            
    elseif (type == 'use') then
        t_rune_data = self.m_equippedRuneObject
    end

    if (t_rune_data == nil) then
        return
    end

    local roid = t_rune_data['roid']
    local str = g_runeMemoData:getMemo(roid)

    if (str ~= nil) then
        vars[type .. 'MemoLabel']:setString(str)
        vars[type .. 'MemoEditBox']:setText('')
    else
        vars[type .. 'MemoLabel']:setString(Str('메모를 입력해주세요. (최대 40자)'))
        vars[type .. 'MemoEditBox']:setText('')
    end

     -- 룬 카드에 메모 아이콘 리프레시
    local rune_card = self['m_' .. type .. 'RuneUI']
    if (rune_card) then
        rune_card:refresh_memo()
    end

    local focus_rune_item = self.m_tableViewTD:getItem(roid)
    if (focus_rune_item) and (focus_rune_item['ui']) then
        local focus_card = focus_rune_item['ui']
        focus_card:refresh_memo()
    end

    local slot_idx = self.m_currTab
    local focus_equipped_rune = self.m_lfocusEquippedRuneUIList[slot_idx]
    if (focus_equipped_rune) then
        focus_equipped_rune:refresh_memo()
    end
end