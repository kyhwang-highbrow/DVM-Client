local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())
local MAX_DRAGON_GOODBYE_MATERIAL_MAX = 30 -- 한 번에 작별 가능한 드래곤 수

-------------------------------------
-- class UI_DragonGoodbye
-------------------------------------
UI_DragonGoodbye = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_tableViewExtMaterial = 'TableViewExtension', -- 재료
        m_addLactea = 'number', -- 추가될 라테아 수
        m_dragonSortMgr = 'DragonSortManager',

        m_excludedDragons = '',


        m_selectedMaterialMap = 'map',
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

    self:sceneFadeInAction()

    self.m_bChangeDragonList = false
    self.m_addLactea = 0

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()
end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_DragonGoodbye:init_dragonSortMgr()
    self.m_dragonSortMgr = DragonSortManagerUpgradeMaterial(self.vars, self.m_tableViewExtMaterial, b_ascending_sort, sort_type)
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
    local vars = self.vars
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbye:refresh()
    self:init_dragonMaterialTableView()
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
        ui.root:setScale(item_scale)
        
        -- 드래곤 클릭 콜백 함수
        local function click_dragon_item()
            self:click_dragonCard(doid)
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
    local l_item_list = self:makeMaterialList()
    table_view_td:setItemList(l_item_list)

    self.m_tableViewExtMaterial = table_view_td
end

-------------------------------------
-- function makeMaterialList
-- @brief
-------------------------------------
function UI_DragonGoodbye:makeMaterialList()
    local l_item_list = g_dragonsData:getDragonsList()

    for i,v in pairs(l_item_list) do
        local doid = i
        if self.m_excludedDragons[doid] then
            l_item_list[i] = nil
        end
    end

    return l_item_list
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_DragonGoodbye:click_dragonCard(doid)
    -- 재료 해제
    if self.m_selectedMaterialMap[doid] then
        self:delMaterial(doid)
    -- 재료 추가
    else
        self:addMaterial(doid)
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
    for _doid,_ in pairs(self.m_selectedMaterialMap) do
        if (not src_doids) then
            src_doids = tostring(_doid)
        else
            src_doids = src_doids .. ',' .. tostring(_doid)
        end
    end

    self:goodbyeNetworkRequest(uid, src_doids)
end

-------------------------------------
-- function goodbyeNetworkRequest
-------------------------------------
function UI_DragonGoodbye:goodbyeNetworkRequest(uid, src_doids)
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
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function goodbyeNetworkResponse
-------------------------------------
function UI_DragonGoodbye:goodbyeNetworkResponse(ret)
    -- 재료로 사용된 드래곤 삭제
    if ret['deleted_dragons_oid'] then
        for _,odid in pairs(ret['deleted_dragons_oid']) do
            g_dragonsData:delDragonData(odid)

            -- 드래곤 리스트 갱신
            self.m_tableViewExtMaterial:delItem(odid)
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
function UI_DragonGoodbye:addMaterial(doid)

    if (g_dragonsData:isLeaderDragon(doid) == true) then
        UIManager:toastNotificationRed(Str('리더로 설정된 드래곤은 작별할 수 없습니다.'))
        return
    end

    local item_cnt = table.count(self.m_selectedMaterialMap)
    if (item_cnt >= MAX_DRAGON_GOODBYE_MATERIAL_MAX) then
        UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리만 작별할 수 있습니다.', MAX_DRAGON_GOODBYE_MATERIAL_MAX))
        return
    end

    self.m_selectedMaterialMap[doid] = true

    self:onChangeSelectedDragons(doid)
end

-------------------------------------
-- function delMaterial
-------------------------------------
function UI_DragonGoodbye:delMaterial(doid)
    -- 재료 해제
    self.m_selectedMaterialMap[doid] = nil
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

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']
    local lactea = TableLactea:getGoodbyeLacteaCnt(grade, evolution)

    local is_selected = (self.m_selectedMaterialMap[doid] ~= nil)

    if (is_selected) then
        self.m_addLactea = (self.m_addLactea + lactea)
    else
        self.m_addLactea = (self.m_addLactea - lactea)
    end

    local vars = self.vars
    vars['lacreaLabel2']:setString(Str('+{1}', comma_value(self.m_addLactea)))
    local selected_dragon_cnt = table.count(self.m_selectedMaterialMap)
    vars['selectLabel']:setString(Str('{1} / {2}', selected_dragon_cnt, MAX_DRAGON_GOODBYE_MATERIAL_MAX))
end

-------------------------------------
-- function goodbyeDirecting
-------------------------------------
function UI_DragonGoodbye:goodbyeDirecting(cb)
    -- 하위 UI의 터치를 막기 위해 사용
    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 에니메이션 연출
    directing_animation = function()
        local animator = self.vars['lacteaVisual']

        local function ani_handler()
            animator:changeAni2('lectea_on_after', 'lectea_idle', false)
            directing_result()
        end
        
        animator:changeAni('lectea_on', false)
        animator:addAniHandler(ani_handler)
        SoundMgr:playEffect('EFFECT', 'exp_gauge')
    end

    -- 결과 연출
    directing_result = function()
        block_ui:close()
        cb()
    end

    directing_animation()
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbye)
