local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())
local MAX_DRAGON_GOODBYE_MATERIAL_MAX = 30 -- 한 번에 작별 가능한 드래곤 수

-------------------------------------
-- class UI_DragonGoodbye
-------------------------------------
UI_DragonGoodbye = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_tableViewExtMaterial = 'TableViewExtension', -- 재료
        m_addLactea = 'number', -- 추가될 라테아 수
        m_excludedDragons = '',
        m_selectedMaterialMap = 'map',

        -- 정렬
        m_sortManagerDragon = '',
        m_uicSortList = '',

		-- 연출
		m_directingUI = '',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonGoodbye:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonGoodbye'
    self.m_bVisible = true or false
    self.m_titleStr = Str('라테아 획득') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_subCurrency = 'lactea'
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbye:init(excluded_dragons)
    self.m_excludedDragons = (excluded_dragons or {})
    self.m_selectedMaterialMap = {}

    local vars = self:load('dragon_lactea.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbye')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self.m_bChangeDragonList = false
    self.m_addLactea = 0

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbye:initUI()
	self.m_directingUI = UI_Directing_DragonGoodBye()
	self.root:addChild(self.m_directingUI.root, -1)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbye:initButton()
    local vars = self.vars
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbye:refresh()
    self:init_dragonMaterialTableView()
    self:init_dragonSortMgr()
    self:refresh_lactea()
end

-------------------------------------
-- function refresh_lactea
-------------------------------------
function UI_DragonGoodbye:refresh_lactea()
    local vars = self.vars
    vars['infoLabel']:setString(Str('드래곤과 작별하여 라테아를 획득합니다.'))
    local lactea = g_userData:get('lactea')

    self.m_addLactea = 0
    vars['lacreaLabel']:setString(Str('+{1}', comma_value(self.m_addLactea)))
    vars['selectLabel']:setString(Str('{1} / {2}', 0, MAX_DRAGON_GOODBYE_MATERIAL_MAX))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonGoodbye:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init_dragonMaterialTableView
-- @brief 드래곤 작별 재료 리스트 테이블 뷰
-------------------------------------
function UI_DragonGoodbye:init_dragonMaterialTableView()
    -- 기존에 노드들 삭제
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    -- cell_size 지정
    local item_size = 150
    local item_scale = 0.66
    local cell_size = cc.size(item_size*item_scale, item_size*item_scale)

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        local doid = data['id']
        local is_slime = (data.m_objectType == 'slime')
        ui.root:setScale(item_scale)
        
        -- 드래곤 클릭 콜백 함수
        local function click_dragon_item()
            self:click_dragonCard(doid, is_slime)
        end

        if self.m_selectedMaterialMap[doid] then
            ui:setShadowSpriteVisible(true)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_dragon_item)
    end

    -- 2차원 테이블 뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)

    -- 리스트 설정
    local l_item_list = self:getDragonMaterialList()
    table_view_td:setItemList(l_item_list)

    self.m_tableViewExtMaterial = table_view_td
end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_DragonGoodbye:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortSelectBtn'], vars['sortSelectLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    

    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        --self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortSelectOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
            self.m_sortManagerDragon:setAllAscending(ascending)
            self:apply_dragonSort()
            --self:save_dragonSortInfo()

            vars['sortSelectOrderSprite']:stopAllActions()
            if ascending then
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
            else
                vars['sortSelectOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 세이브데이터에 있는 정렬 값을 적용
    --self:apply_dragonSort_saveData()
    self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonGoodbye:apply_dragonSort()
    local list = self.m_tableViewExtMaterial.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableViewExtMaterial:setDirtyItemList()
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 작별
-------------------------------------
function UI_DragonGoodbye:getDragonMaterialList()
    local l_dragon_list = g_dragonsData:getDragonsList()
    local l_slime_list = g_slimesData:getSlimeList()

    local l_object = {}
    for key,value in pairs(l_dragon_list) do
        l_object[key] = value
    end

    for key,value in pairs(l_slime_list) do
        l_object[key] = value
    end

    for oid,v in pairs(l_object) do
		if (not g_dragonsData:possibleMaterialDragon(oid)) then
            l_object[oid] = nil
        end
    end

    return l_object
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_DragonGoodbye:click_dragonCard(doid, is_slime)
    -- 재료 해제
    if self.m_selectedMaterialMap[doid] then
        self:delMaterial(doid, is_slime)
    -- 재료 추가
    else
        self:addMaterial(doid, is_slime)
    end
end

-------------------------------------
-- function click_sellBtn
-------------------------------------
function UI_DragonGoodbye:click_sellBtn()
    local item_cnt = table.count(self.m_selectedMaterialMap)

    if (item_cnt <= 0) then
        UIManager:toastNotificationRed(Str('작별할 드래곤을 선택해주세요!'))
        return
    end

    local uid = g_userData:get('uid')
    local src_doids = nil
    local src_soids = nil
    for _doid,type in pairs(self.m_selectedMaterialMap) do
        if (type == 'dragon') then
            if (not src_doids) then
                src_doids = tostring(_doid)
            else
                src_doids = src_doids .. ',' .. tostring(_doid)
            end
        elseif (type == 'slime') then
            if (not src_soids) then
                src_soids = tostring(_doid)
            else
                src_soids = src_soids .. ',' .. tostring(_doid)
            end
        end
    end

    self:goodbyeNetworkRequest(uid, src_doids, src_soids)
end

-------------------------------------
-- function goodbyeNetworkRequest
-------------------------------------
function UI_DragonGoodbye:goodbyeNetworkRequest(uid, src_doids, src_soids)
    local function success_cb(ret)
        local function cb()
            self:goodbyeNetworkResponse(ret)
        end
        self:goodbyeDirecting(cb)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/goodbye')
    ui_network:setParam('uid', uid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setParam('src_soids', src_soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function goodbyeNetworkResponse
-------------------------------------
function UI_DragonGoodbye:goodbyeNetworkResponse(ret)
    self.m_selectedMaterialMap = {}

    -- 재료로 사용된 드래곤 삭제
    if ret['deleted_dragons_oid'] then
        for _,odid in pairs(ret['deleted_dragons_oid']) do
            g_dragonsData:delDragonData(odid)

            -- 드래곤 리스트 갱신
            self.m_tableViewExtMaterial:delItem(odid)
        end
    end

    -- 슬라임
    if ret['deleted_slimes_oid'] then
        for _,soid in pairs(ret['deleted_slimes_oid']) do
            g_slimesData:delSlimeObject(soid)

            -- 리스트 갱신
            self.m_tableViewExtMaterial:delItem(soid)
        end
    end

    -- 라테아 갱신
    if ret['lactea'] then
        g_serverData:applyServerData(ret['lactea'], 'user', 'lactea')
        g_topUserInfo:refreshData()
    end

    self:refresh_lactea()

    self.m_bChangeDragonList = true
end

-------------------------------------
-- function addMaterial
-------------------------------------
function UI_DragonGoodbye:addMaterial(doid, is_slime)

    if (g_dragonsData:isLeaderDragon(doid) == true) then
        UIManager:toastNotificationRed(Str('리더로 설정된 드래곤은 작별할 수 없습니다.'))
        return
    end

	if (g_dragonsData:isLockDragon(doid) == true) then
        UIManager:toastNotificationRed(Str('잠금한 드래곤은 작별할 수 없습니다.'))
        return
    end

    local item_cnt = table.count(self.m_selectedMaterialMap)
    if (item_cnt >= MAX_DRAGON_GOODBYE_MATERIAL_MAX) then
        UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리만 작별할 수 있습니다.', MAX_DRAGON_GOODBYE_MATERIAL_MAX))
        return
    end

    self.m_selectedMaterialMap[doid] = is_slime and 'slime' or 'dragon'

    self:onChangeSelectedDragons(doid)

	-- 연출 추가
	self.m_directingUI:addDragonData(doid)
end

-------------------------------------
-- function delMaterial
-------------------------------------
function UI_DragonGoodbye:delMaterial(doid)
    -- 재료 해제
    self.m_selectedMaterialMap[doid] = nil
    self:onChangeSelectedDragons(doid)

	-- 연출 삭제
	self.m_directingUI:delDragonData(doid)
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonGoodbye:refresh_materialDragonIndivisual(odid)
    if (not self.m_tableViewExtMaterial) then
        return
    end

    local item = self.m_tableViewExtMaterial:getItem(odid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

    local is_selected = (self.m_selectedMaterialMap[odid] ~= nil)
    ui:setShadowSpriteVisible(is_selected)
end

-------------------------------------
-- function onChangeSelectedDragons
-- @brief
-------------------------------------
function UI_DragonGoodbye:onChangeSelectedDragons(doid)

    -- 드래곤 재료 리스트에서 선택된 드래곤 표시
    self:refresh_materialDragonIndivisual(doid)

    local object = g_dragonsData:getDragonDataFromUid(doid)
    if (not object) then
        object = g_slimesData:getSlimeObject(doid)
    end

    local grade = object['grade']
    local evolution = object['evolution']
    local lactea = TableLactea:getGoodbyeLacteaCnt(grade, evolution)

    local is_selected = (self.m_selectedMaterialMap[doid] ~= nil)

    if (is_selected) then
        self.m_addLactea = (self.m_addLactea + lactea)
    else
        self.m_addLactea = (self.m_addLactea - lactea)
    end

    local vars = self.vars
    vars['lacreaLabel']:setString(Str('+{1}', comma_value(self.m_addLactea)))
    local selected_dragon_cnt = table.count(self.m_selectedMaterialMap)
    vars['selectLabel']:setString(Str('{1} / {2}', selected_dragon_cnt, MAX_DRAGON_GOODBYE_MATERIAL_MAX))
end

-------------------------------------
-- function goodbyeDirecting
-------------------------------------
function UI_DragonGoodbye:goodbyeDirecting(cb)
	g_topUserInfo:hide()
	self:doActionReverse(function()
		local t_data = {
			type = 'lactea',
			value = self.m_addLactea
		}

		local function cb_func()
			if cb then
				cb()
			end

			self:doAction(nil, false)
			g_topUserInfo:show()
			g_topUserInfo:refreshData()
		end

		self.m_directingUI:doDirectingAction(t_data, cb_func)
	end, 1)
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbye)
