local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonEclvup
-- @brief 초월 UI
-------------------------------------
UI_DragonEclvup = class(PARENT,{
        m_bChangeDragonList = 'boolean',

        m_mtrlTableViewTD = '', -- 재료
        m_mtrlDragonSortManager = 'SortManager_Dragon',

        --- 재료 중에서 선택된 드래곤
        m_lSelectedMtrlList = 'list',
        m_mSelectedMtrMap = 'map',

        m_materialCnt = 'number',
        m_selectedMaterialCnt = 'number',
        m_currSlotIdx = 'number',

        -- 재료 UI 오픈 여부(왼쪽에 테이블 뷰)
        m_bOpenMaterial = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonEclvup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonEclvup'
    self.m_bVisible = true or false
    self.m_titleStr = Str('초월')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEclvup:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false
    self.m_bOpenMaterial = false
    self.m_lSelectedMtrlList = {}
    self.m_mSelectedMtrMap = {}

    local vars = self:load('dragon_management_upgrade_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonEclvup')

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
function UI_DragonEclvup:initUI()
    local vars = self.vars

    vars['leftMenu']:setVisible(false)
    vars['rightMenu']:setPositionX(0)

    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonEclvup:initButton()
    local vars = self.vars
    vars['materialBtn']:registerScriptTapHandler(function() self:click_materialBtn() end)
    vars['transcendBtn']:registerScriptTapHandler(function() self:click_transcendBtn() end)

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
function UI_DragonEclvup:refresh()
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
        vars['termsIconNode']:addChild(dragon_card.root)
    end

    do -- 재료 중에서 선택된 드래곤 항목들 정리
        for i,v in pairs(self.m_lSelectedMtrlList) do
            v.root:removeFromParent()
        end

        self.m_lSelectedMtrlList = {}
        self.m_mSelectedMtrMap = {}
        self.m_materialCnt = 1
        self.m_currSlotIdx = 1
        self.m_selectedMaterialCnt = 0
    end

    do -- 선택된 드래곤별 재료 슬롯 정렬
        local max_slot = 1
        local l_pos = getSortPosList(100, max_slot)
        for i=1, 5 do
            if (i <= max_slot) then
                local x = l_pos[i]
                vars['materialNode' .. i]:setPositionX(x)
                vars['materialNode' .. i]:setVisible(true)
            else
                vars['materialNode' .. i]:setVisible(false)
            end
        end
    end

    -- 재료 리스트 갱신
    if self.m_bOpenMaterial then
        self:refresh_dragonUpgradeMaterialTableView()
    end

    self:refresh_upgrade(table_dragon, t_dragon_data)
    self:refresh_btnState()
end

-------------------------------------
-- function refresh_btnState
-- @brief
-------------------------------------
function UI_DragonEclvup:refresh_btnState()
    local vars = self.vars

    vars['upgradeBtn']:setVisible(false)
    vars['transcendBtn']:setVisible(false)

    if (not self.m_bOpenMaterial) then
        vars['materialBtn']:setVisible(true)
    else
        vars['materialBtn']:setVisible(false)
        vars['transcendBtn']:setVisible(true)
    end
end

-------------------------------------
-- function refresh_upgrade
-------------------------------------
function UI_DragonEclvup:refresh_upgrade(table_dragon, t_dragon_data)
    local vars = self.vars

    local grade = t_dragon_data['grade']
    local eclv = t_dragon_data['eclv']

    -- 등급 테이블
    local table_grade_info = TableGradeInfo()
    local curr_max_lv = TableGradeInfo:getMaxLv(grade, eclv)
    local next_max_lv = TableGradeInfo:getMaxLv(grade, eclv + 1)

    do -- 드래곤 다음 등급 정보 카드
        vars['maxIconNode']:removeAllChildren()
        local t_next_dragon_data = clone(t_dragon_data)
        t_next_dragon_data['eclv'] = (t_next_dragon_data['eclv'] + 1)
        local dragon_card = UI_DragonCard(t_next_dragon_data)
        vars['maxIconNode']:addChild(dragon_card.root)
    end

    do -- 레벨 표시
        vars['maxLvLabel']:setString(Str('최대레벨\n{1} > {2}', curr_max_lv, next_max_lv))
        vars['nextTextLabel']:setString(Str('초월 상승'))
    end

    do -- 설명
        vars['infoLabel']:setString(Str('초월하면 최대레벨이 상승해요'))
        vars['infoLabel1']:setString(Str('원종이 같은 드래곤이 필요합니다.'))
    end

    do -- 초월에 필요한 가격
        local req_gold = TableGradeInfo:getEclvUpgradeReqGold(eclv + 1)
        vars['transcendPriceLabel']:setString(comma_value(req_gold))
    end
end

-------------------------------------
-- function click_materialBtn
-- @brief "재료 선택" 버튼 클릭
--        재료 리스트가 등장하고, 초월 버튼 등장
-------------------------------------
function UI_DragonEclvup:click_materialBtn()
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
-- @brief 드래곤 초월 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonEclvup:refresh_dragonUpgradeMaterialTableView()
    -- 최초로 leftMenu가 등장했을 때 예약된 함수 제거
    cca.stopAction(self.vars['leftMenu'], 100)
    
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:makeDefaultEmptyDescLabel(Str('초월에는 원종이 같은 6성 드래곤이 필요합니다.'))
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    -- 정렬
    self:refresh_sortUI()
end

-------------------------------------
-- function getDragonUpgradeMaterialList
-- @brief 드래곤 초월 재료(다른 드래곤) 리스트
-------------------------------------
function UI_DragonEclvup:getDragonUpgradeMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용
    local table_dragon = TableDragon()

    -- 자기 자신 드래곤 제외
    l_dragon_list[doid] = nil

    for i,v in pairs(l_dragon_list) do
        -- 등급 체크
        if (v['grade'] < t_dragon_data['grade']) then
            l_dragon_list[i] = nil

        -- 드래곤 원종 체크
        elseif (not table_dragon:isSameDragonType(t_dragon_data['did'], v['did'])) then
            l_dragon_list[i] = nil
        end
    end

    return l_dragon_list
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_DragonEclvup:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_DragonEclvup:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_DragonEclvup:click_sortBtn(sort_type)
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_DragonEclvup:refresh_sortUI()
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
-- function click_dragonUpgradeMaterial
-------------------------------------
function UI_DragonEclvup:click_dragonUpgradeMaterial(data)
    local vars = self.vars

    local doid = data['id']

    local list_item = self.m_mtrlTableViewTD:getItem(doid)
    local list_item_ui = list_item['ui']
    
    if self.m_mSelectedMtrMap[doid] then
        local ui = self.m_mSelectedMtrMap[doid]
        self.m_mSelectedMtrMap[doid] = nil
        self.m_lSelectedMtrlList[ui.m_tag] = nil

        ui.root:removeFromParent()

        list_item_ui:setShadowSpriteVisible(false)
        self.m_selectedMaterialCnt = (self.m_selectedMaterialCnt - 1)
    else
        if self.m_currSlotIdx then
            local ui = UI_DragonCard(data)
            ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(data) end)
            ui.m_tag = self.m_currSlotIdx

            self.m_mSelectedMtrMap[doid] = ui

            self.m_lSelectedMtrlList[self.m_currSlotIdx] = ui
        
            vars['materialNode' .. self.m_currSlotIdx]:addChild(ui.root)

            list_item_ui:setShadowSpriteVisible(true)
            self.m_selectedMaterialCnt = (self.m_selectedMaterialCnt + 1)
        end
    end

    self.m_currSlotIdx = nil
    for i=1, self.m_materialCnt do
        if (not self.m_lSelectedMtrlList[i] ) then
            self.m_currSlotIdx = i
            break
        end
    end
end

-------------------------------------
-- function click_transcendBtn
-------------------------------------
function UI_DragonEclvup:click_transcendBtn()
    if (self.m_selectedMaterialCnt < 1) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요.'))
        return
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    do
        for _,v in pairs(self.m_lSelectedMtrlList) do
            local _doid = v.m_dragonData['id']
            if (src_doids == '') then
                src_doids = tostring(_doid)
            else
                src_doids = src_doids .. ',' .. tostring(_doid)
            end
        end
    end

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
    ui_network:setUrl('/dragons/exceed')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function upgradeDirecting
-- @brief 강화 연출
-------------------------------------
function UI_DragonEclvup:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 에니메이션 연출
    directing_animation = function()
        local vars = self.vars

        self.vars['upgradeVisual']:setVisible(true)
        self.vars['upgradeVisual']:setVisual('group', 'idle')
        self.vars['upgradeVisual']:setRepeat(false)
        self.vars['upgradeVisual']:addAniHandler(directing_result)
        SoundMgr:playEffect('EFFECT', 'exp_gauge')
    end

    -- 결과 연출
    directing_result = function()
        block_ui:close()
        
        UI_DragonManageUpgradeResult(t_next_dragon_data, t_prev_dragon_data)

        -- UI 갱신
        --self:setSelectDragonDataRefresh()
        --self:refresh_dragonIndivisual(doid)
        self:close()
    end

    --directing_animation()
    directing_result()
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonEclvup:getDragonList()
    local l_item_list = g_dragonsData:getDragonsList()


    for i,v in pairs(l_item_list) do
        local doid = v['id']
        local upgradeable, msg = g_dragonsData:checkEclvUpgradeable(doid)
        if (not upgradeable) then
            l_item_list[i] = nil
        end
    end

    return l_item_list
end

--@CHECK
UI:checkCompileError(UI_DragonEclvup)
