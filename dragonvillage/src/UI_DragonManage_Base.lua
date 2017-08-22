local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonManage_Base
-------------------------------------
UI_DragonManage_Base = class(PARENT,{
        m_selectDragonData = 'table',           -- 선택된 드래곤의 유저 데이터
        m_selectDragonOID = 'number',           -- 선택된 드래곤의 dragon object id
        m_bSlimeObject = 'boolean',
        m_dragonSelectFrame = 'sprite',         -- 선택된 드래곤의 카드에 표시
        m_bChangeDragonList = 'boolean',
        
		m_dragonAnimator = 'UIC_DragonAnimator',

		-- 테이블뷰
        m_tableViewExt = 'UIC_TableViewTD',  -- 하단의 드래곤 리스트 테이블 뷰
		m_mtrlTableViewTD = 'UIC_TableViewTD', -- 재료

		-- sort list
        m_uicSortList = 'UIC_SortList',
		m_uicMtrlSortList = 'UIC_SortList',
        
		-- 정렬 도우미
		m_sortManagerDragon = 'SortManager_Dragon',
        m_mtrlDragonSortManager = 'SortManager_Dragon',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManage_Base:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManage_Base'
    self.m_bVisible = true
    self.m_titleStr = Str('드래곤 관리')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-- @brief 상속받아서 쓰는 용도
--        하위 클래스에서 init을 해야함
-------------------------------------
function UI_DragonManage_Base:init()
    self.m_bChangeDragonList = false

    -- 드래곤들의 덱설정 여부 데이터 갱신
    g_deckData:resetDragonDeckInfo()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManage_Base:initUI()
    self:init_dragonTableView()
    self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManage_Base:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManage_Base:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManage_Base:click_exitBtn()
    self:close()
end

-------------------------------------
-- function close
-------------------------------------
function UI_DragonManage_Base:close()
    if self.m_dragonSelectFrame then
        self.m_dragonSelectFrame:release()
        self.m_dragonSelectFrame = nil
    end

    PARENT.close(self)
end

-------------------------------------
-- function setSelectDragonDataRefresh
-- @brief 선택된 드래곤의 데이터를 최신으로 갱신
-------------------------------------
function UI_DragonManage_Base:setSelectDragonDataRefresh()
    local object_id = self.m_selectDragonOID

    if self.m_bSlimeObject then
        self.m_selectDragonData = g_slimesData:getSlimeObject(object_id)
    else
        self.m_selectDragonData = g_dragonsData:getDragonDataFromUid(object_id)
    end
end

-------------------------------------
-- function setSelectDragonData
-- @brief 선택된 드래곤 설정
-------------------------------------
function UI_DragonManage_Base:setSelectDragonData(object_id, b_force)
    if (not b_force) and (self.m_selectDragonOID == object_id) then
        return
    end

    local object_data = g_dragonsData:getDragonDataFromUid(object_id)
    if (not object_data) then
        object_data = g_slimesData:getSlimeObject(object_id)
    end

    if (not object_data) then
        return self:setDefaultSelectDragon()
    end

    if (not self:checkDragonSelect(object_id)) then
        return
    end

    -- 선택된 드래곤의 데이터를 최신으로 갱신
    self.m_selectDragonOID = object_id
    self.m_selectDragonData = object_data
    self.m_bSlimeObject = (object_data.m_objectType == 'slime')

    -- 선택된 드래곤 카드에 프레임 표시
    self:changeDragonSelectFrame()

    -- 선택된 드래곤이 변경되면 refresh함수를 호출
    self:refresh()

    -- 신규 드래곤이면 삭제
    g_highlightData:removeNewDoid(object_id)
end

-------------------------------------
-- function changeDragonSelectFrame
-- @brief 선택된 드래곤 카드에 프레임 표시
-------------------------------------
function UI_DragonManage_Base:changeDragonSelectFrame(ui)
    -- 없으면 새로 생성
    if (not self.m_dragonSelectFrame) then
        self.m_dragonSelectFrame = cc.Sprite:create('res/ui/frames/temp/dragon_select_frame.png')
        self.m_dragonSelectFrame:setDockPoint(cc.p(0.5, 0.5))
        self.m_dragonSelectFrame:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_dragonSelectFrame:retain()
    else
    -- 있으면 부모에게서 떼어냄
        self.m_dragonSelectFrame:removeFromParent()
    end

    -- 테이블뷰에서 선택된 드래곤의 카드를 가져옴
    local dragon_object_id = self.m_selectDragonOID
    local t_item = self.m_tableViewExt.m_itemMap[dragon_object_id]
    local ui = ui or (t_item and t_item['ui'])

    -- addChild 후 액션 실행(깜빡임)
    if ui then
        ui.root:addChild(self.m_dragonSelectFrame)
        self.m_dragonSelectFrame:stopAllActions()
        self.m_dragonSelectFrame:setOpacity(255)
        self.m_dragonSelectFrame:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255))))
        return
    end
end

-------------------------------------
-- function setDefaultSelectDragon
-- @brief 지정된 드래곤이 없을 경우 기본 드래곤을 설정
-------------------------------------
function UI_DragonManage_Base:setDefaultSelectDragon(doid)
    if doid then
        local b_force = true
        self:setSelectDragonData(doid, b_force)
        return
    end

    local item = self.m_tableViewExt.m_itemList[1]

    if (item) then
        local dragon_object_id = item['data']['id']
        local b_force = true
        self:setSelectDragonData(dragon_object_id, b_force)
    end
end

-------------------------------------
-- function refresh_dragonIndivisual
-- @brief 특정 드래곤의 object_id로 갱신
-------------------------------------
function UI_DragonManage_Base:refresh_dragonIndivisual(dragon_object_id)
    local item = self.m_tableViewExt.m_itemMap[dragon_object_id]

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(dragon_object_id)

    -- 테이블뷰 리스트의 데이터 갱신
    item['data'] = t_dragon_data

    -- UI card 버튼이 있을 경우 데이터 갱신
    if item and item['ui'] then
        local ui = item['ui']
        ui.m_dragonData = t_dragon_data
        ui:refreshDragonInfo()
    end

    -- 갱신된 드래곤이 선택된 드래곤일 경우
    if (dragon_object_id == self.m_selectDragonOID) then
        self:setSelectDragonData(dragon_object_id, true)
    end
end

-------------------------------------
-- function init_dragonTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonManage_Base:init_dragonTableView()

    if (not self.m_tableViewExt) then
        local list_table_node = self.vars['listTableNode']

        local function make_func(object)
            return UI_DragonCard(object)
        end

        local function create_func(ui, data)
            self:createDragonCardCB(ui, data)
            ui.root:setScale(0.66)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:setSelectDragonData(data['id']) end)

            if (data['id'] == self.m_selectDragonOID) then
                self:changeDragonSelectFrame(ui)
            end
        end

        local table_view = UIC_TableView(list_table_node)
        table_view.m_defaultCellSize = cc.size(100, 100)
        table_view:setCellUIClass(make_func, create_func)
        self.m_tableViewExt = table_view
    end

    local l_item_list = self:getDragonList()
    self.m_tableViewExt:setItemList(l_item_list)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonManage_Base:getDragonList()
    local l_item_list = g_dragonsData:getDragonsList()

    local l_slime_list = g_slimesData:getSlimeList()

    local ret = {}
    for key,value in pairs(l_item_list) do
        ret[key] = value
    end

    for key,value in pairs(l_slime_list) do
        ret[key] = value
    end

    return ret
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonManage_Base:createDragonCardCB(ui, data)
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-- @return boolean false를 리턴하면 해당 드래곤을 선택할 수 없음
-------------------------------------
function UI_DragonManage_Base:checkDragonSelect(doid)
    return true
end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_DragonManage_Base:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

	local sort_mgr = self.m_sortManagerDragon
	local table_view = self.m_tableViewExt

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'])
    self.m_uicSortList = uic_sort_list
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        sort_mgr:pushSortOrder(sort_type)
        self:apply_dragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not sort_mgr.m_defaultSortAscending)
            sort_mgr:setAllAscending(ascending)
            self:apply_dragonSort()
            self:save_dragonSortInfo()

			local order_spr = vars['sortOrderSprite']
            order_spr:stopAllActions()
            if ascending then
                order_spr:runAction(cc.RotateTo:create(0.15, 180))
            else
                order_spr:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 세이브데이터에 있는 정렬 값을 적용
    self:apply_dragonSort_saveData()
end

-------------------------------------
-- function apply_dragonSort_saveData
-- @brief 세이브데이터에 있는 정렬 순서 적용
-------------------------------------
function UI_DragonManage_Base:apply_dragonSort_saveData()
    local l_order = g_localData:get('dragon_sort', 'order')
    local ascending = g_localData:get('dragon_sort', 'ascending')

    local sort_type
    for i=#l_order, 1, -1 do
        sort_type = l_order[i]
        self.m_sortManagerDragon:pushSortOrder(sort_type)
    end
    self.m_sortManagerDragon:setAllAscending(ascending)

    self.m_uicSortList:setSelectSortType(sort_type)


    do -- 오름차순, 내림차순 아이콘
        local vars = self.vars
        vars['sortOrderSprite']:stopAllActions()
        if ascending then
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonManage_Base:apply_dragonSort()
    local list = self.m_tableViewExt.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableViewExt:setDirtyItemList()
end

-------------------------------------
-- function save_dragonSortInfo
-- @brief 새로운 정렬 설정을 세이브 데이터에 적용
-------------------------------------
function UI_DragonManage_Base:save_dragonSortInfo()
    g_localData:lockSaveData()

    -- 정렬 순서 저장
    local sort_order = self.m_sortManagerDragon.m_lSortOrder
    g_localData:applyLocalData(sort_order, 'dragon_sort', 'order')

    -- 오름차순, 내림차순 저장
    local ascending = self.m_sortManagerDragon.m_defaultSortAscending
    g_localData:applyLocalData(ascending, 'dragon_sort', 'ascending')

    g_localData:unlockSaveData()
end

-------------------------------------
-- function refresh_dragonMaterialTableView
-- @brief 재료 테이블 뷰 갱신
-------------------------------------
function UI_DragonManage_Base:refresh_dragonMaterialTableView()   
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('도와줄 드래곤이 없어요 ㅠㅠ'))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)
	
	self:apply_mtrlDragonSort()
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonManage_Base:createMtrlDragonCardCB(ui, data)
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료 리스트를 반환
-------------------------------------
function UI_DragonManage_Base:getDragonMaterialList(doid)
	error('미정의된 함수 getDragonMaterialList')
end

-------------------------------------
-- function click_dragonUpgradeMaterial
-------------------------------------
function UI_DragonManage_Base:click_dragonMaterial(data)
	error('미정의된 함수 click_dragonMaterial')
end

-------------------------------------
-- function init_mtrDragonSortMgr
-- @brief 정렬 도우미 - 재료드래곤
-- @commnet 재료드래곤 테이블은 로컬에 정렬 방식을 저장하지 않는다
-------------------------------------
function UI_DragonManage_Base:init_mtrDragonSortMgr(slime_first)
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
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
        local ascending = (not sort_mgr.m_defaultSortAscending)
        sort_mgr:setAllAscending(ascending)
		self:apply_mtrlDragonSort()

		local order_spr = vars['sortSelectOrderSprite']
        order_spr:stopAllActions()
        if ascending then
            order_spr:runAction(cc.RotateTo:create(0.15, 180))
        else
            order_spr:runAction(cc.RotateTo:create(0.15, 0))
        end
    end)

    -- 재료드래곤 정렬은 등급 역순이 기본
    sort_mgr:setAllAscending(true)
    uic_sort_list:setSelectSortType('grade')

	-- 기본값으로 정렬 적용
	self:apply_mtrlDragonSort()
end

-------------------------------------
-- function apply_mtrlDragonSort
-- @brief 재료 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonManage_Base:apply_mtrlDragonSort()
	-- 최초 refresh 할 때에는 sortManager가 생성되기 전이므로 예외처리
	if (not self.m_mtrlDragonSortManager) then
		return
	end

	local sort_mgr = self.m_mtrlDragonSortManager
	local table_view = self.m_mtrlTableViewTD

	local list = table_view.m_itemList
	sort_mgr:sortExecution(list)
	table_view:setDirtyItemList()
end

--@CHECK
UI:checkCompileError(UI_DragonManage_Base)