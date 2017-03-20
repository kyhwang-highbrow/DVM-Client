local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonSkillLevelUp
-- @brief 스킬 강화 UI
-------------------------------------
UI_DragonSkillLevelUp = class(PARENT,{
        m_bChangeDragonList = 'boolean',

        m_mtrlTableViewTD = '', -- 재료
        m_mtrlDragonSortManager = 'SortManager_Dragon',

        m_selectedMaterial = '',
        m_selectedMaterialUI = '',

        -- 재료 UI 오픈 여부(왼쪽에 테이블 뷰)
        m_bOpenMaterial = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSkillLevelUp:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSkillLevelUp'
    self.m_bVisible = true or false
    self.m_titleStr = Str('스킬 강화')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkillLevelUp:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false
    self.m_bOpenMaterial = false

    local vars = self:load('dragon_management_skill_levelup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonSkillLevelUp')

    -- 정렬 매니저
    self.m_mtrlDragonSortManager = SortManager_Dragon()

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr(b_ascending_sort, sort_type)

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkillLevelUp:initUI()
    local vars = self.vars

    vars['leftMenu']:setVisible(false)
    vars['rightMenu']:setPositionX(0)
    vars['priceLabel']:setString('0')

    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSkillLevelUp:initButton()
    local vars = self.vars

    vars['materialBtn']:registerScriptTapHandler(function() self:click_materialBtn() end)
    vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)

    do -- 정렬 관련 버튼들
        vars['sortSelectOrderBtn']:registerScriptTapHandler(function() self:clcik_sortSelectOrderBtn() end)

        vars['sortSelectBtn']:registerScriptTapHandler(function() self:click_sortSelectBtn() end)
        vars['sortSelectHpBtn']:registerScriptTapHandler(function() self:click_sortBtn('hp') end)
        vars['sortSelectDefBtn']:registerScriptTapHandler(function() self:click_sortBtn('def') end)
        vars['sortSelectAtkBtn']:registerScriptTapHandler(function() self:click_sortBtn('atk') end)
        vars['sortSelectAttrBtn']:registerScriptTapHandler(function() self:click_sortBtn('attr') end)
        vars['sortSelectLvBtn']:registerScriptTapHandler(function() self:click_sortBtn('lv') end)
        vars['sortSelectGradeBtn']:registerScriptTapHandler(function() self:click_sortBtn('grade') end)
        vars['sortSelectRarityBtn']:registerScriptTapHandler(function() self:click_sortBtn('rarity') end)
        vars['sortSelectFriendshipBtn']:registerScriptTapHandler(function() self:click_sortBtn('friendship') end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkillLevelUp:refresh()
    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 이름
        vars['nameLabel']:setString(Str(t_dragon['t_name']))
    end

    do -- 드래곤 현재 정보 카드
        vars['termsIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        cca.uiReactionSlow(dragon_card.root)
        vars['termsIconNode']:addChild(dragon_card.root)
    end

    do -- 스킬 아이콘 생성
        local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
        local l_skill_icon = skill_mgr:getDragonSkillIconList()
        for i=0, MAX_DRAGON_EVOLUTION do
            if l_skill_icon[i] then
                vars['skillNode' .. i]:removeAllChildren()
                vars['skillNode' .. i]:addChild(l_skill_icon[i].root)
                cca.uiReactionSlow(l_skill_icon[i].root)
            end
        end
    end

    -- 재료 리스트 갱신
    if self.m_bOpenMaterial then
        self:refresh_dragonUpgradeMaterialTableView()
    end

    do -- 선택된 재료가 있으면 nil처리
        if self.m_selectedMaterialUI then
            self.m_selectedMaterialUI.root:removeFromParent()
            self.m_selectedMaterialUI = nil
        end

        if self.m_selectedMaterial then
            self.m_selectedMaterial = nil
        end
    end

    self:refresh_btnState()
end

-------------------------------------
-- function refresh_btnState
-- @brief
-------------------------------------
function UI_DragonSkillLevelUp:refresh_btnState()
    local vars = self.vars

    vars['levelupBtn']:setVisible(false)

    if (not self.m_bOpenMaterial) then
        vars['materialBtn']:setVisible(true)
    else
        vars['materialBtn']:setVisible(false)
        vars['levelupBtn']:setVisible(true)
    end
end

-------------------------------------
-- function click_materialBtn
-- @brief "재료 선택" 버튼 클릭
--        재료 리스트가 등장하고, 강화 버튼 등장
-------------------------------------
function UI_DragonSkillLevelUp:click_materialBtn()
    if (self.m_bOpenMaterial == true) then
        return
    end

    self.m_bOpenMaterial = true
    self:refresh_btnState()

    local vars = self.vars
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local pos_x, pos_y = vars['leftMenu']:getPosition()
    vars['leftMenu']:setPositionX(pos_x - visibleSize['width'])
    local action = cc.EaseInOut:create(cc.MoveTo:create(0.5, cc.p(pos_x, pos_y)), 2)
    cca.runAction(vars['leftMenu'], action)

    cca.reserveFuncWithTag(vars['leftMenu'], 0.5, function() self:refresh_dragonUpgradeMaterialTableView() end, 100)

    vars['leftMenu']:setVisible(true)
    vars['rightMenu']:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.5, cc.p(320, 69)), 2))
end

-------------------------------------
-- function refresh_dragonUpgradeMaterialTableView
-- @brief 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonSkillLevelUp:refresh_dragonUpgradeMaterialTableView()
    -- 최초로 leftMenu가 등장했을 때 예약된 함수 제거
    cca.stopAction(self.vars['leftMenu'], 100)
    
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_skillUpgradeMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:makeDefaultEmptyDescLabel(Str('스킬 강화에는 원종이 같은 드래곤이 필요합니다.'))
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    -- 정렬
    self:refresh_sortUI()
end

-------------------------------------
-- function getDragonUpgradeMaterialList
-- @brief 드래곤 재료(다른 드래곤) 리스트
-------------------------------------
function UI_DragonSkillLevelUp:getDragonUpgradeMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용
    local table_dragon = TableDragon()

    -- 자기 자신 드래곤 제외
    l_dragon_list[doid] = nil

    for i,v in pairs(l_dragon_list) do
        -- 원종이 다른 항목 제거
        if (not table_dragon:isSameDragonType(t_dragon_data['did'], v['did'])) then
            l_dragon_list[i] = nil
        end
    end

    return l_dragon_list
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_DragonSkillLevelUp:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_DragonSkillLevelUp:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_DragonSkillLevelUp:click_sortBtn(sort_type)
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_DragonSkillLevelUp:refresh_sortUI()
    local vars = self.vars

    local sort_manager = self.m_mtrlDragonSortManager

    -- 테이블 뷰 정렬
    local table_view = self.m_mtrlTableViewTD
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()

    -- 선택된 정렬 이름
    local sort_type = sort_manager:getTopSortingType()
    local sort_name = sort_manager:getSortName(sort_type)
    vars['sortSelectLabel']:setString(sort_name)

    -- 오름차순일경우
    if sort_manager.m_defaultSortAscending then
        vars['sortSelectOrderSprite']:setScaleY(-1)
    -- 내림차순일경우
    else
        vars['sortSelectOrderSprite']:setScaleY(1)
    end
end

-------------------------------------
-- function click_skillUpgradeMaterial
-------------------------------------
function UI_DragonSkillLevelUp:click_skillUpgradeMaterial(data)
    local vars = self.vars
    local doid = data['id']

    -- 선택되어있는 재료가 있으면 해제
    if self.m_selectedMaterial then
        local item = self.m_mtrlTableViewTD:getItem(self.m_selectedMaterial)
        local ui = item['ui']
        if ui then
            ui:setShadowSpriteVisible(false)
        end
        
        if self.m_selectedMaterialUI then
            self.m_selectedMaterialUI.root:removeFromParent()
            self.m_selectedMaterialUI = nil
        end

        if (self.m_selectedMaterial == doid) then
            self.m_selectedMaterial = nil
            return
        end
    end

    -- 선택된 재료 UI 생성
    local ui = UI_DragonCard(data)
    cca.uiReactionSlow(ui.root)
    self.m_selectedMaterialUI = ui
    ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_skillUpgradeMaterial(data) end)
    vars['materialNode']:addChild(ui.root)
    local item = self.m_mtrlTableViewTD:getItem(doid)
    local ui = item['ui']
    ui:setShadowSpriteVisible(true)
    self.m_selectedMaterial = doid
end

-------------------------------------
-- function click_levelupBtn
-------------------------------------
function UI_DragonSkillLevelUp:click_levelupBtn()
    if (not self.m_selectedMaterial) then
        UIManager:toastNotificationRed(Str('스킬 강화에는 원종이 같은 드래곤이 필요합니다.'))
        return
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = self.m_selectedMaterial

    local function success_cb(ret)
        local t_prev_dragon_data = self.m_selectDragonData

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(doid)
            end
        end

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 골드 갱신
        if ret['gold'] then
            g_serverData:applyServerData(ret['gold'], 'user', 'gold')
            g_topUserInfo:refreshData()
        end

        self.m_bChangeDragonList = true

        local t_next_dragon_data = g_dragonsData:getDragonDataFromUid(self.m_selectDragonOID)

        -- 연출 시작
        self:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/skillup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonSkillLevelUp:getDragonList()
    local l_item_list = g_dragonsData:getDragonsList()


    for i,v in pairs(l_item_list) do
        local doid = v['id']
        local upgradeable, msg = g_dragonsData:checkSkillUpgradeable(doid)
        if (not upgradeable) then
            l_item_list[i] = nil
        end
    end

    return l_item_list
end

-------------------------------------
-- function upgradeDirecting
-- @brief 연출
-------------------------------------
function UI_DragonSkillLevelUp:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        -- 연출
        co:work()
        self.vars['levelupVisual']:setVisible(true)
        self.vars['levelupVisual']:setVisual('group', 'slot_fx_01')
        self.vars['levelupVisual']:setRepeat(false)
        self.vars['levelupVisual']:addAniHandler(function() self.vars['levelupVisual']:setVisible(false) co.NEXT() end)
        if co:waitWork() then return end

        -- 최대 초월 단계일 경우
        local upgradeable, msg = g_dragonsData:checkSkillUpgradeable(doid)
        if upgradeable then
            self:setSelectDragonDataRefresh()
            self:refresh_dragonIndivisual(doid)
        else
            self:close()
        end

        -- 결과 팝업 생성
        local ui = UI_DragonSkillLevelUpResult:checkSkillLevelUp(t_prev_dragon_data, t_next_dragon_data)

        co:close()
    end

    Coroutine(coroutine_function)
end

--@CHECK
UI:checkCompileError(UI_DragonSkillLevelUp)
