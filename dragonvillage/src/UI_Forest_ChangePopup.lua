local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_Forest_ChangePopup
-------------------------------------
UI_Forest_ChangePopup = class(PARENT,{
        m_tSelectDragon = 'list',
        m_maxCnt = 'number',
        m_changeCB = 'function',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Forest_ChangePopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Forest_ChangePopup'
    self.m_bVisible = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_ChangePopup:init()
    local vars = self:load('dragon_forest_change_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Forest_ChangePopup')

    self:sceneFadeInAction()
	
	self.m_tSelectDragon = ServerData_Forest:getInstance():getMyDragons()
    self.m_maxCnt = ServerData_Forest:getInstance():getMaxDragon()

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
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_Forest_ChangePopup:initButton()
    local vars = self.vars
    vars['changeBtn']:registerScriptTapHandler(function() self:click_changeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_ChangePopup:refresh()
    self:refresh_selectedMaterial()
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function setChangeCB
-------------------------------------
function UI_Forest_ChangePopup:setChangeCB(cb_func)
    self.m_changeCB = cb_func
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
    local function create_func(ui, data)
        ui.root:setScale(0.80)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(124.4, 124.4)
    table_view_td.m_nItemPerCell = 10
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
    return dragon_dic
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

	-- 추가
	else
		-- 갯수 체크
		local sell_cnt = table.count(self.m_tSelectDragon)
		if (sell_cnt >= self.m_maxCnt) then
			UIManager:toastNotificationRed(Str('최대 {1}마리까지 가능합니다.', self.m_maxCnt))
			return
		end

		self.m_tSelectDragon[doid] = t_dragon_data
	end

	-- 갱신
    self:refresh_materialDragonIndivisual(doid)
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
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_Forest_ChangePopup:refresh_selectedMaterial()
	-- 선택한 갯수
    local dragon_count = table.count(self.m_tSelectDragon)
    local max_count = ServerData_Forest:getInstance():getMaxDragon()
    self.vars['inventoryLabel']:setString(string.format('%d / %d', dragon_count, max_count))
end

-------------------------------------
-- function click_changeBtn
-- @brief
-------------------------------------
function UI_Forest_ChangePopup:click_changeBtn()
	-- 갯수 체크
	local sell_cnt = table.count(self.m_tSelectDragon)
	if (sell_cnt <= 0) then
		UIManager:toastNotificationGreen(Str('배치할 드래곤을 선택해주세요'))
		return
	end

    -- 콤마 스트링 생성
    local doids = self:makeCommaOIDStr(self.m_tSelectDragon)

	local function cb_func()
        if (self.m_changeCB) then
            self.m_changeCB()
        end
		self:close()
	end

	ServerData_Forest:getInstance():request_setDragons(doids, cb_func)
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

--@CHECK
UI:checkCompileError(UI_Forest_ChangePopup)
