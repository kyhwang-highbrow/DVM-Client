local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_Forest_ChangePopup
-------------------------------------
UI_Forest_ChangePopup = class(PARENT,{
        m_maxCnt = 'number',
        m_changeCB = 'function',

        m_currSlotIdx = 'number',
        m_focusDeckSlotEffect = 'cc.Sprite',
        m_mSlotMap = 'Map<idx, Node>',

        m_tSelectDragon = '<doid, structDragon>',
        m_selectedDragonMap = 'Map<doid, idx>',
        m_selectedDragonList = '<idx, doid>',
        m_bDirty = 'boolean',

        m_forestExtensionUI = 'UI_Forest_ExtensionBoard',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Forest_ChangePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Forest_ChangePopup'
    self.m_bVisible = true
    self.m_titleStr = Str('드래곤 배치')
end

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_ChangePopup:init()
    local vars = self:load('dragon_forest_change_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Forest_ChangePopup')

    self:sceneFadeInAction()
	
	self.m_tSelectDragon = clone(ServerData_Forest:getInstance():getMyDragons())
    self.m_maxCnt = ServerData_Forest:getInstance():getMaxDragon()
    self.m_currSlotIdx = 0

    self.m_mSlotMap = {}
    self.m_selectedDragonMap = {}
    self.m_selectedDragonList = {}
    self.m_bDirty = false

    -- 최초 등록
    local cnt = 0
    for doid, _ in pairs(self.m_tSelectDragon) do
        self.m_selectedDragonMap[doid] = cnt
        self.m_selectedDragonList[cnt] = doid
        cnt = cnt + 1
    end

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
	local is_slime_fisrt = false
	self:init_mtrDragonSortMgr(is_slime_fisrt)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_ChangePopup:initUI()
	local vars = self.vars
    self:makeSlotUI()
    self:makeSlotEffect()

    -- 슬롯 이펙트 예외처리
    if (self.m_currSlotIdx >= self.m_maxCnt) then
        self.m_focusDeckSlotEffect:setVisible(false)
        self.m_currSlotIdx = -1
    end

    do -- 드래곤의 숲 확장 레벨 UI
        local ui = UI_Forest_ExtensionBoard()
        local vars = self.vars
        vars['forestLvNode']:addChild(ui.root)

        local function cb_forest_lv_change()
            self:refreshForestDragonCnt()
        end
        ui:setForestLvChange(cb_forest_lv_change)
        self.m_forestExtensionUI = ui
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_Forest_ChangePopup:initButton()
    local vars = self.vars
    vars['emptyBtn']:registerScriptTapHandler(function() self:click_emptyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_ChangePopup:refresh()
	self:refresh_dragonMaterialTableView()
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function setChangeCB
-- @brief closeCB과 유사하지만 의도한 곳에서 사용
-------------------------------------
function UI_Forest_ChangePopup:setChangeCB(cb_func)
    self.m_changeCB = cb_func
end

-------------------------------------
-- function makeSlotUI
-- @brief slot을 만든다.
-------------------------------------
function UI_Forest_ChangePopup:makeSlotUI()
    local max_cnt = ServerData_Forest:getInstance():getMaxDragon()
    local slot_node = self.vars['slotNode']

    local frame_res = 'res/ui/frames/base_frame_0201.png'
    local lock_res = 'res/ui/icons/skill/skill_empty.png'

    local frame, slot, pos_x, pos_y
    local icon
    for i = 0, 19 do
        frame = cc.Scale9Sprite:create(frame_res)
        frame:setContentSize(cc.size(80, 80))
        frame:setDockPoint(CENTER_POINT)
	    frame:setAnchorPoint(CENTER_POINT)

        pos_x = ((100 * (i % 4)) - 150)
        pos_y = (200 - (100 * math_floor(i/4)))
        frame:setPosition(pos_x, pos_y)
        slot_node:addChild(frame)

        slot = cc.Node:create()
        slot:setDockPoint(CENTER_POINT)
	    slot:setAnchorPoint(CENTER_POINT)
        frame:addChild(slot)

        -- dragon card 등록
        local set_doid
        for doid, idx in pairs(self.m_selectedDragonMap) do
            if (idx == i) then
                set_doid = doid
            end
        end

        if (set_doid) then
            local struct_dragon_object = self.m_tSelectDragon[set_doid]
            local ui = UI_DragonCard(struct_dragon_object)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(struct_dragon_object) end)
            ui:setCheckSpriteVisible(false)
            ui.root:setScale(80/150)
            slot:addChild(ui.root)

            -- 다음 인덱스 지시 
            self.m_currSlotIdx = i + 1
        end

        -- lock
        if (i >= max_cnt) then
            icon = IconHelper:getIcon(lock_res)
            icon:setScale(0.7)
            slot:addChild(icon)
        end

        self.m_mSlotMap[i] = slot
    end
end

-------------------------------------
-- function makeSlotEffect
-------------------------------------
function UI_Forest_ChangePopup:makeSlotEffect()
    self.m_focusDeckSlotEffect = cc.Sprite:create('res/ui/frames/temp/dragon_select_frame.png')
    self.m_focusDeckSlotEffect:setDockPoint(CENTER_POINT)
    self.m_focusDeckSlotEffect:setAnchorPoint(CENTER_POINT)
    self.vars['slotNode']:addChild(self.m_focusDeckSlotEffect, 2)

    self.m_focusDeckSlotEffect:setScale(0.6)
    self.m_focusDeckSlotEffect:setVisible(true)
    self.m_focusDeckSlotEffect:setPosition(self.m_mSlotMap[self.m_currSlotIdx]:getParent():getPosition())

    self.m_focusDeckSlotEffect:stopAllActions()
    self.m_focusDeckSlotEffect:setOpacity(255)
    self.m_focusDeckSlotEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
end








-------------------------------------
-- function refresh_dragonMaterialTableView
-- @brief 재료 테이블 뷰 갱신
-- @override
-------------------------------------
function UI_Forest_ChangePopup:refresh_dragonMaterialTableView()   
    local list_table_node = self.vars['listNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local item_scale = 0.66
    local function create_func(ui, data)
        ui.root:setScale(item_scale)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(150 * item_scale, 150 * item_scale)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)
	
	self:apply_mtrlDragonSort()
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트이지만 제한없이 사용
-- @override
-------------------------------------
function UI_Forest_ChangePopup:getDragonMaterialList()
    local dragon_dic = g_dragonsData:getDragonsList()

    local table_dragon = TableDragon()

    local t_ret = {}
    for i,v in pairs(dragon_dic) do
        t_ret[i] = v

        -- 최초 기획상에서 몬스터 드래곤(자코)는 리스트에서 제거하기로 했었음 2017-09-25 sgkim (구영환, 조수용이 자코도 포함하는 것으로 결정함)
        --local did = v['did']
        --if table_dragon:isUnderling(did) then
        --    t_ret[i] = nil
        --end
    end

    return t_ret
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-- @override
-------------------------------------
function UI_Forest_ChangePopup:createMtrlDragonCardCB(ui, data)
    local doid = data['id']
    if (self.m_tSelectDragon[doid]) then
        ui:setCheckSpriteVisible(true)
    end
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_Forest_ChangePopup:click_dragonMaterial(t_dragon_data)
    local doid = t_dragon_data['id']

	-- 가격 처리 및 테이블리스트 갱신

	-- 제외
	if (self.m_tSelectDragon[doid]) then
		self.m_tSelectDragon[doid] = nil

        local slot_idx = self.m_selectedDragonMap[doid]
        if (slot_idx) then
            self.m_mSlotMap[slot_idx]:removeAllChildren()
            self.m_selectedDragonMap[doid] = nil
            self.m_selectedDragonList[slot_idx] = nil
        end

	-- 추가
	else
		-- 갯수 체크
		local sell_cnt = table.count(self.m_tSelectDragon)
		if (sell_cnt >= self.m_maxCnt) then
            self:materialMaxGuid()
			return
		end

		self.m_tSelectDragon[doid] = t_dragon_data
        self.m_selectedDragonMap[doid] = self.m_currSlotIdx
        self.m_selectedDragonList[self.m_currSlotIdx] = doid

        local ui = UI_DragonCard(t_dragon_data)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(t_dragon_data) end)
        ui:setCheckSpriteVisible(false)
        ui.root:setScale(80/150)
        self.m_mSlotMap[self.m_currSlotIdx]:addChild(ui.root)
	end

        -- 다음 slot_idx 지정
    if (self.m_maxCnt <= table.count(self.m_selectedDragonMap)) then
        self.m_currSlotIdx = -1

        self.m_focusDeckSlotEffect:setVisible(false)
    else
        for i = 0, self.m_maxCnt - 1 do
            if (not self.m_selectedDragonList[i]) then
                self.m_currSlotIdx = i
                break
            end
        end

        self.m_focusDeckSlotEffect:setVisible(true)
        self.m_focusDeckSlotEffect:setPosition(self.m_mSlotMap[self.m_currSlotIdx]:getParent():getPosition())

        self.m_focusDeckSlotEffect:stopAllActions()
        self.m_focusDeckSlotEffect:setOpacity(255)
        self.m_focusDeckSlotEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
    end

	-- 갱신
    self:refresh_materialDragonIndivisual(doid)
    self.m_bDirty = true

    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_Forest_ChangePopup:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

	local is_select = self.m_tSelectDragon[doid] and true or false
    ui:setCheckSpriteVisible(is_select)
end

-------------------------------------
-- function refreshForestDragonCnt
-- @brief 드래곤의 숲 레벨이 변경됨에 따라 늘어난 드래곤 슬롯 수 처리
-------------------------------------
function UI_Forest_ChangePopup:refreshForestDragonCnt()
    local new_max_cnt = ServerData_Forest:getInstance():getMaxDragon()

    -- lock sprite 제거
    for i = self.m_maxCnt, new_max_cnt - 1 do
        self.m_mSlotMap[i]:removeAllChildren(true)
    end

    self.m_maxCnt = new_max_cnt
    self:refresh_selectedMaterial()
end


-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_Forest_ChangePopup:refresh_selectedMaterial()
    local vars = self.vars

    -- 드래곤 수
    local curr_cnt = table.count(self.m_tSelectDragon)
    vars['dragonLabel']:setString(string.format('%d', curr_cnt))

    -- 드래곤 최대
    local max_cnt = ServerData_Forest:getInstance():getMaxDragon()
    vars['invenLabel']:setString(string.format('/%d', max_cnt))
end

-------------------------------------
-- function makeCommaOIDStr
-- @brief
-------------------------------------
function UI_Forest_ChangePopup:makeCommaOIDStr(t_oid)
	local doids = ''
	for oid, t_dragon_data in pairs(t_oid) do
		if (t_dragon_data.m_objectType == 'dragon') then
			if (doids == '') then
                doids = tostring(oid)
            else
                doids = doids .. ',' .. tostring(oid)
            end
		end
	end
    return doids
end












-------------------------------------
-- function init_mtrDragonSortMgr
-- @brief 정렬 도우미 - 저장 및 최초 정렬 순서 때문에 재정의
-------------------------------------
function UI_Forest_ChangePopup:init_mtrDragonSortMgr(slime_first)
	local is_slime_first = (slime_first == nil) and true or false

    -- 정렬 매니저 생성
    self.m_mtrlDragonSortManager = SortManager_Dragon()
	self.m_mtrlDragonSortManager.m_mPreSortType['object_type']['ascending'] = is_slime_first -- 슬라임이 앞쪽으로 정렬되도록 변경

	local sort_mgr = self.m_mtrlDragonSortManager
    
	-- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicMtrlSortList = uic_sort_list
    
    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        sort_mgr:pushSortOrder(sort_type)
		self:apply_mtrlDragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
        local ascending = (not sort_mgr.m_defaultSortAscending)
        sort_mgr:setAllAscending(ascending)
		self:apply_mtrlDragonSort()
        self:save_dragonSortInfo()

		local order_spr = vars['sortSelectOrderSprite']
        order_spr:stopAllActions()
        if ascending then
            order_spr:runAction(cc.RotateTo:create(0.15, 180))
        else
            order_spr:runAction(cc.RotateTo:create(0.15, 0))
        end
    end)

	-- 기본값으로 정렬 적용
	self:apply_mtrlDragonSort_saveData()
end

-------------------------------------
-- function save_dragonSortInfo
-- @brief 새로운 정렬 설정을 세이브 데이터에 적용
-------------------------------------
function UI_Forest_ChangePopup:save_dragonSortInfo()
    g_localData:lockSaveData()

    -- 정렬 순서 저장
    local sort_order = self.m_mtrlDragonSortManager.m_lSortOrder
    g_localData:applyLocalData(sort_order, 'dragon_sort_forest', 'order')

    -- 오름차순, 내림차순 저장
    local ascending = self.m_mtrlDragonSortManager.m_defaultSortAscending
    g_localData:applyLocalData(ascending, 'dragon_sort_forest', 'ascending')

    g_localData:unlockSaveData()
end

-------------------------------------
-- function apply_mtrlDragonSort_saveData
-- @brief 세이브데이터에 있는 정렬 순서 적용
-------------------------------------
function UI_Forest_ChangePopup:apply_mtrlDragonSort_saveData()
    local l_order = g_localData:get('dragon_sort_forest', 'order') or g_localData:get('dragon_sort_fight', 'order')
    local ascending = g_localData:get('dragon_sort_forest', 'ascending')

    local sort_type
    for i=#l_order, 1, -1 do
        sort_type = l_order[i]
        self.m_mtrlDragonSortManager:pushSortOrder(sort_type)
    end
    self.m_mtrlDragonSortManager:setAllAscending(ascending)

    self.m_uicMtrlSortList:setSelectSortType(sort_type)


    do -- 오름차순, 내림차순 아이콘
        local vars = self.vars
        vars['sortSelectOrderSprite']:stopAllActions()
        if ascending then
            vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest_ChangePopup:click_exitBtn()
    if (not self.m_bDirty) then
        self:close()
        return
    end

    local function cb_func()
        if (self.m_changeCB) then
            self.m_changeCB()
        end
		self:close()
	end

    -- 콤마 스트링 생성
    local doids = self:makeCommaOIDStr(self.m_tSelectDragon)

	ServerData_Forest:getInstance():request_setDragons(doids, cb_func)
end

-------------------------------------
-- function materialMaxGuid
-- @brief
-------------------------------------
function UI_Forest_ChangePopup:materialMaxGuid()
    local lv = ServerData_Forest:getInstance():getExtensionLV()
    local max_lv = ServerData_Forest:getInstance():getExtensionMaxLV()

    if (lv <= max_lv) then
        UIManager:toastNotificationRed(Str('드래곤의 숲 레벨이 부족합니다.'))
        if self.m_forestExtensionUI then
            local node = self.m_forestExtensionUI.vars['lvUpBtn']
            cca.uiReactionSlow(node)
        end
    else
        UIManager:toastNotificationRed(Str('최대 {1}마리까지 가능합니다.', self.m_maxCnt))
    end
end

-------------------------------------
-- function click_emptyBtn
-- @brief
-------------------------------------
function UI_Forest_ChangePopup:click_emptyBtn()
    if self.m_forestExtensionUI then
        self.m_forestExtensionUI:click_lvUpBtn()
        local node = self.m_forestExtensionUI.vars['lvUpBtn']
        cca.uiReactionSlow(node)
    end
end


--@CHECK
UI:checkCompileError(UI_Forest_ChangePopup)
