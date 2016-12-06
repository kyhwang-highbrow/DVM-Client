local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())
local MAX_DRAGON_GOODBYE_MATERIAL_MAX = 30 -- 한 번에 작별 가능한 드래곤 수

-------------------------------------
-- class UI_DragonGoodbye
-------------------------------------
UI_DragonGoodbye = class(PARENT,{
        m_tableViewExtMaterial = 'TableViewExtension', -- 재료
        m_tableViewExtSelectMaterial = 'TableViewExtension', -- 선택된 재료
        m_tableDragonTrainInfo = 'TableDragonTrainInfo',
        m_addLactea = 'number', -- 추가될 라테아 수
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonGoodbye:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonGoodbye'
    self.m_bVisible = true or false
    self.m_titleStr = Str('타이틀') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbye:init()
    local vars = self:load('dragon_manage_sell.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbye')

    self:sceneFadeInAction()

    self.m_tableDragonTrainInfo = TableDragonTrainInfo()
    self.m_addLactea = 0

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbye:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbye:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbye:refresh()
    self:init_dragonMaterialTableView()
    self:init_dragonUMaterialSelectTableView()
    self:refresh_lactea()
end

-------------------------------------
-- function refresh_lactea
-------------------------------------
function UI_DragonGoodbye:refresh_lactea()
    local vars = self.vars
    vars['infoLabel']:setString(Str('드래곤과 작별하여 라테아를 획득합니다.'))
    local lactea = g_userData:get('lactea')
    vars['lacreaLabel1']:setString(comma_value(lactea))

    self.m_addLactea = 0
    vars['lacreaLabel2']:setString(Str('+{1}', comma_value(self.m_addLactea)))
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
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    local item_size = 150
    local item_scale = 0.71

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(item_scale)

        self:refresh_materialDragonIndivisual(item['unique_id'])
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        self:click_dragonCard(item)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    do -- 아이콘 크기 지정
        local item_adjust_size = (item_size * item_scale)
        local nItemPerCell = 5
        local cell_width = (item_adjust_size * nItemPerCell)
        local cell_height = item_adjust_size
        local item_width = item_adjust_size
        local item_height = item_adjust_size
        table_view_ext:setCellInfo2(nItemPerCell, cell_width, cell_height, item_width, item_height)
    end    
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    
    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = g_dragonsData:getDragonsList()--self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    table_view_ext:setItemInfo(l_dragon_list)

    table_view_ext:update()

    self.m_tableViewExtMaterial = table_view_ext

    --[[
    do -- 정렬 도우미 도입
        local b_ascending_sort = nil
        local sort_type = nil

        if self.m_materialSortMgr then
            b_ascending_sort = self.m_materialSortMgr.m_bAscendingSort
            sort_type = self.m_materialSortMgr.m_currSortType
        end
        
        self.m_materialSortMgr = DragonSortManagerUpgradeMaterial(self.vars, table_view_ext, self.m_tableViewExtSelectMaterial, b_ascending_sort, sort_type)
        self.m_materialSortMgr:changeSort()
    end
    --]]
end

-------------------------------------
-- function init_dragonMaterialSelectTableView
-- @brief 선택된 드래곤 작별 재료 리스트 테이블 뷰
-------------------------------------
function UI_DragonGoodbye:init_dragonUMaterialSelectTableView()
    local list_table_node = self.vars['materialNode']
    list_table_node:removeAllChildren()

    local item_size = 150
    local item_scale = 0.5
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(item_scale)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        self:click_dragonCard(item)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.HORIZONTAL)
    table_view_ext:setCellInfo(item_adjust_size, item_adjust_size)  
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo({})
    table_view_ext:update()

    self.m_tableViewExtSelectMaterial = table_view_ext
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_DragonGoodbye:click_dragonCard(item)
    local data = item['data']
    local doid = data['id']

    local selected_material_item = self.m_tableViewExtSelectMaterial:getItem(doid)

    -- 재료 해제
    if selected_material_item then
        self:delMaterial(doid)
    -- 재료 추가
    else
        self:addMaterial(doid)
    end
end

-------------------------------------
-- function addMaterial
-------------------------------------
function UI_DragonGoodbye:addMaterial(doid)
    local item_cnt = self.m_tableViewExtSelectMaterial:getItemCount()
    if (item_cnt >= MAX_DRAGON_GOODBYE_MATERIAL_MAX) then
        UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리만 작별할 수 있습니다.', MAX_DRAGON_GOODBYE_MATERIAL_MAX))
        return
    end

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    -- 재료 추가
    self.m_tableViewExtSelectMaterial:addItem(doid, t_dragon_data)
    self.m_tableViewExtSelectMaterial:update()

    self:onChangeSelectedDragons(doid)
end

-------------------------------------
-- function delMaterial
-------------------------------------
function UI_DragonGoodbye:delMaterial(doid)
    -- 재료 해제
    self.m_tableViewExtSelectMaterial:delItem(doid)
    self.m_tableViewExtSelectMaterial:update()

    self:onChangeSelectedDragons(doid)
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonGoodbye:refresh_materialDragonIndivisual(odid)
    if (not self.m_tableViewExtMaterial) then
        return
    end

    if (not self.m_tableViewExtSelectMaterial) then
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

    local is_selected = (self.m_tableViewExtSelectMaterial:getItem(odid) ~= nil)
    ui:setShadowSpriteVisible(is_selected)
end

-------------------------------------
-- function onChangeSelectedDragons
-- @brief
-------------------------------------
function UI_DragonGoodbye:onChangeSelectedDragons(doid)

    -- 드래곤 재료 리스트에서 선택된 드래곤 표시
    self:refresh_materialDragonIndivisual(doid)

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']
    local lactea = self.m_tableDragonTrainInfo:getGoodbyeLacteaCnt(grade, evolution)

    local is_selected = (self.m_tableViewExtSelectMaterial:getItem(doid) ~= nil)

    if (is_selected) then
        self.m_addLactea = (self.m_addLactea + lactea)
    else
        self.m_addLactea = (self.m_addLactea - lactea)
    end

    local vars = self.vars
    vars['lacreaLabel2']:setString(Str('+{1}', comma_value(self.m_addLactea)))
    local selected_dragon_cnt = self.m_tableViewExtSelectMaterial and self.m_tableViewExtSelectMaterial:getItemCount() or 0
    vars['selectLabel']:setString(Str('{1} / {2}', selected_dragon_cnt, MAX_DRAGON_GOODBYE_MATERIAL_MAX))
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbye)
