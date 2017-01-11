local PARENT = UI_DragonManage_Base
local MAX_DRAGON_UPGRADE_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonManageUpgrade
-------------------------------------
UI_DragonManageUpgrade = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_tableViewExtMaterial = 'TableViewExtension', -- 재료
        m_tableViewExtSelectMaterial = 'TableViewExtension', -- 선택된 재료

        m_materialSortMgr = 'DragonSortManagerUpgradeMaterial',

        m_bOpenMaterial = 'boolean',
        m_upgradeMode = 'string',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageUpgrade:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageUpgrade'
    self.m_bVisible = true or false
    self.m_titleStr = -1
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
    self.m_bOpenMaterial = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageUpgrade:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false

    local vars = self:load('dragon_management_upgrade.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageUpgrade')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

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
function UI_DragonManageUpgrade:initUI()
    local vars = self.vars
    vars['upgradeGauge']:setPercentage(0)
    vars['leftMenu']:setVisible(false)
    vars['rightMenu']:setPositionX(0)

    self:init_dragonTableView()
    self:init_dragonUpgradeMaterialSelectTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageUpgrade:initButton()
    local vars = self.vars
    vars['materialBtn']:registerScriptTapHandler(function() self:click_materialBtn() end)
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
    vars['skillUpgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
    vars['transcendBtn']:registerScriptTapHandler(function() self:click_transcendBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageUpgrade:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    -- 승급 상태
    self.m_upgradeMode = g_dragonsData:getUpgradeMode(t_dragon_data['id'])

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

    -- 드래곤 다음 등급 정보 카드
    vars['maxIconNode']:removeAllChildren()
    
    -- 등급 업이 될 때 표시 스프라이트
    vars['gradeUpSprite']:setVisible(false)

    -- 스킬 업이 될 때 표시 스프라이트
    vars['skillUpSprite']:setVisible(false)
     
    -- 업그레이드 모드 별 refresh
    if (self.m_upgradeMode == 'upgrade') then
        self:refresh_upgrade(table_dragon, t_dragon_data)

    elseif (self.m_upgradeMode == 'skill_lv_up') then
        self:refresh_skill_lv_up(table_dragon, t_dragon_data)

    elseif (self.m_upgradeMode == 'eclv_up') then
        self:refresh_eclv_up(table_dragon, t_dragon_data)
    end

    -- 재료 리스트 갱신
    if self.m_bOpenMaterial then
        self:refresh_dragonUpgradeMaterialTableView()
    end

    -- 선택된 재료 리스트 갱신
    self.m_tableViewExtSelectMaterial:clearItemList()

    self:refresh_btnState()
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_upgrade
-------------------------------------
function UI_DragonManageUpgrade:refresh_upgrade(table_dragon, t_dragon_data)
    local vars = self.vars

    g_topUserInfo:setTitleString(Str('승급'))

    -- 등급 테이블
    local table_grade_info = TABLE:get('grade_info')
    local t_grade_info = table_grade_info[t_dragon_data['grade']]
    local t_next_grade_info = table_grade_info[t_dragon_data['grade'] + 1]

    do -- 드래곤 다음 등급 정보 카드
        vars['maxIconNode']:removeAllChildren()
        local t_next_dragon_data = clone(t_dragon_data)
        t_next_dragon_data['grade'] = (t_next_dragon_data['grade'] + 1)
        local dragon_card = UI_DragonCard(t_next_dragon_data)
        vars['maxIconNode']:addChild(dragon_card.root)
    end

    do -- 승급 경험치 UI
        vars['upgradeGauge']:setVisible(true)
        vars['upgradeGauge1']:setVisible(true)
        vars['upgradeGauge2']:setVisible(true)
        vars['upgradeExpLabel']:setVisible(true)
    end

    do -- 승급 경험치
        local req_exp = t_grade_info['req_exp']
        local curr_exp = t_dragon_data['gexp']
        local percentage = (curr_exp / req_exp) * 100

        vars['upgradeExpLabel']:setString(Str('승급 경험치 {1}%', math_floor(percentage)))
        vars['upgradeGauge']:stopAllActions()
        vars['upgradeGauge']:runAction(cc.ProgressTo:create(0.3, percentage)) 
    end

    do -- 레벨 표시
        local max_lv = t_grade_info['max_lv']
        local next_max_lv = t_next_grade_info['max_lv']
        vars['maxLvLabel']:setString(Str('최대레벨\n{1} > {2}', max_lv, next_max_lv))

        vars['nextTextLabel']:setString(Str('등급 상승'))
    end

    do -- 설명
        vars['infoLabel']:setString(Str('승급하면 등급과 최대레벨이 상승해요'))
        vars['infoLabel2']:setString(Str('동일 드래곤을 재료로 사용하면 스킬이 레벨업 됩니다'))
    end

    vars['selectLabel']:setVisible(true)
    vars['selectLabel']:setString(Str('선택재료 {1} / {2}', 0, MAX_DRAGON_UPGRADE_MATERIAL_MAX))
end

-------------------------------------
-- function refresh_skill_lv_up
-------------------------------------
function UI_DragonManageUpgrade:refresh_skill_lv_up(table_dragon, t_dragon_data)
    local vars = self.vars

    g_topUserInfo:setTitleString(Str('스킬 레벨업'))

    do -- 승급 경험치 UI
        vars['upgradeGauge']:setVisible(false)
        vars['upgradeGauge1']:setVisible(false)
        vars['upgradeGauge2']:setVisible(false)
        vars['upgradeExpLabel']:setVisible(false)
    end

    -- 레벨 표시
    vars['maxLvLabel']:setString(Str(''))

    do -- 설명
        vars['infoLabel']:setString(Str('스킬 레벨업을 하면 스킬의 효과가 상승해요'))
        vars['infoLabel2']:setString(Str('동일 드래곤을 재료로 사용하면 스킬이 레벨업 됩니다'))
    end

    vars['nextTextLabel']:setString(Str('스킬 레벨업'))

    vars['selectLabel']:setVisible(true)
    vars['selectLabel']:setString(Str('선택재료 {1} / {2}', 0, MAX_DRAGON_UPGRADE_MATERIAL_MAX))
end

-------------------------------------
-- function refresh_eclv_up
-------------------------------------
function UI_DragonManageUpgrade:refresh_eclv_up(table_dragon, t_dragon_data)
    local vars = self.vars

    g_topUserInfo:setTitleString(Str('초월'))

    do -- 드래곤 다음 초월 정보 카드
        vars['maxIconNode']:removeAllChildren()
        local t_next_dragon_data = clone(t_dragon_data)
        t_next_dragon_data['eclv'] = (t_next_dragon_data['eclv'] + 1)
        local dragon_card = UI_DragonCard(t_next_dragon_data)
        vars['maxIconNode']:addChild(dragon_card.root)
    end

    do -- 승급 경험치 UI
        vars['upgradeGauge']:setVisible(false)
        vars['upgradeGauge1']:setVisible(false)
        vars['upgradeGauge2']:setVisible(false)
        vars['upgradeExpLabel']:setVisible(false)
    end

    do -- 레벨 표시
        local max_lv = 70 + (t_dragon_data['eclv'] * 2)
        vars['maxLvLabel']:setString(Str('최대레벨\n{1} > {2}', max_lv, max_lv + 2))
    end
    
    do -- 설명
        vars['infoLabel']:setString(Str('초월할 때마다 최대 레벨이 2씩 상승해요'))
        vars['infoLabel2']:setString(Str('초월에는 동일 드래곤이 필요합니다'))
    end

    vars['nextTextLabel']:setString(Str('초월'))

    vars['selectLabel']:setVisible(false)
end

-------------------------------------
-- function init_dragonUpgradeMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonManageUpgrade:init_dragonUpgradeMaterialTableView()

    -- 최초로 leftMenu가 등장했을 때 예약된 함수 제거
    cca.stopAction(self.vars['leftMenu'], 100)
    
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)

        -- 승급, 스킬 레벨업 모드에서는 skill icon 표시
        if isExistValue(self.m_upgradeMode, 'upgrade', 'skill_lv_up') then
            local doid = data['id']
            if g_dragonsData:isSameTypeDragon(self.m_selectDragonOID, doid) then
                ui:setSkillSpriteVisible(true)
            end
        end

        self:refresh_materialDragonIndivisual(doid)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(ui, data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_tableViewExtMaterial = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    self.m_tableViewExtMaterial:setItemList(l_dragon_list, true)

    do -- 정렬 도우미 도입
        local b_ascending_sort = nil
        local sort_type = nil

        if self.m_materialSortMgr then
            b_ascending_sort = self.m_materialSortMgr.m_bAscendingSort
            sort_type = self.m_materialSortMgr.m_currSortType
        end
        
        self.m_materialSortMgr = DragonSortManagerUpgradeMaterial(self.vars, table_view_td, self.m_tableViewExtSelectMaterial, b_ascending_sort, sort_type)
        self.m_materialSortMgr:changeSort()

        -- 정렬
        self.m_materialSortMgr:changeSort()  
    end
end

-------------------------------------
-- function refresh_dragonUpgradeMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonManageUpgrade:refresh_dragonUpgradeMaterialTableView()
    self:init_dragonUpgradeMaterialTableView()
end

-------------------------------------
-- function getDragonUpgradeMaterialList
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트
-------------------------------------
function UI_DragonManageUpgrade:getDragonUpgradeMaterialList(doid)
    if (not doid) then
        return
    end

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    if (not t_dragon_data) then
        return
    end

    local upgrade_mode = g_dragonsData:getUpgradeMode(doid)

    -- 승급, 진화, 스킬 레벨업, 초월이 모두 끝난지 체크
    if (upgrade_mode == 'max') then
        return {}
    end

    -- 2. 자기 자신 드래곤 제외
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용
    l_dragon_list[doid] = nil

    -- 3. 원종이 다른 드래곤 제외
    if (upgrade_mode == 'skill_lv_up') or (upgrade_mode == 'eclv_up') then
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[t_dragon_data['did']]
        local dragon_type = t_dragon['type']
        for _doid, _t_data in pairs(l_dragon_list) do
            local did = _t_data['did']
            local _t_dragon = table_dragon[did]

            if (_t_dragon['type'] ~= dragon_type) then
                l_dragon_list[_doid] = nil
            end 
        end
    end

    return l_dragon_list
end

-------------------------------------
-- function init_dragonUpgradeMaterialSelectTableView
-- @brief 선택된 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonManageUpgrade:init_dragonUpgradeMaterialSelectTableView()
    local list_table_node = self.vars['materialNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)

        -- 승급, 스킬 레벨업 모드에서는 skill icon 표시
        if isExistValue(self.m_upgradeMode, 'upgrade', 'skill_lv_up') then
            local doid = data['id']
            if g_dragonsData:isSameTypeDragon(self.m_selectDragonOID, doid) then
                ui:setSkillSpriteVisible(true)
            end
        end

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonUpgradeMaterial(ui, data) end)
    end

    -- 테이블뷰 생성
    local table_view = UIC_TableView(list_table_node)
    table_view.m_defaultCellSize = cc.size(90, 90)
    table_view:setCellUIClass(UI_DragonCard, create_func)
    table_view:setItemList({})
    self.m_tableViewExtSelectMaterial = table_view
end

-------------------------------------
-- function click_dragonUpgradeMaterial
-------------------------------------
function UI_DragonManageUpgrade:click_dragonUpgradeMaterial(ui, data)
    local doid = data['id']

    local selected_material_item = self.m_tableViewExtSelectMaterial:getItem(doid)

    -- 재료 해제
    if selected_material_item then
        self.m_tableViewExtSelectMaterial:delItem(doid)
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
        self.m_materialSortMgr:changeSort2()
        return

    -- 재료 추가
    else
        local material_count = self.m_tableViewExtSelectMaterial:getItemCount()
        
        -- 초월 시 1마리 초과 선택 확인
        if (self.m_upgradeMode == 'eclv_up') then
            if (material_count >= 1) then
                UIManager:toastNotificationRed(Str('초월은 한 번에 1마리만 가능합니다.'))
                return
            end

        -- 최대 재료 갯수 체크
        elseif (material_count >= MAX_DRAGON_UPGRADE_MATERIAL_MAX) then
            UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_DRAGON_UPGRADE_MATERIAL_MAX))
            return
        end

        -- 리더 설정 여부 확인
        if (g_dragonsData:isLeaderDragon(doid)) then
            UIManager:toastNotificationRed(Str('리더로 설정된 드래곤은 재료로 사용될 수 없습니다.'))
            return
        end

        self.m_tableViewExtSelectMaterial:addItem(doid, data)
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
        self.m_materialSortMgr:changeSort2()
        return
    end
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonManageUpgrade:refresh_materialDragonIndivisual(odid)
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
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonManageUpgrade:refresh_selectedMaterial()
    
    local vars = self.vars

    -- 재료 분석 (가격 총 경험치 등)
    local t_analyze
    do 
        local doid = self.m_selectDragonOID
        local l_item = self.m_tableViewExtSelectMaterial.m_itemList
        t_analyze = self:analyzeSelectedMaterial(doid, l_item)
    end

    if isExistValue(self.m_upgradeMode, 'upgrade', 'skill_lv_up') then
        -- 재료 갯수 출력
        vars['selectLabel']:setString(Str('선택재료 {1} / {2}', t_analyze['count'], MAX_DRAGON_UPGRADE_MATERIAL_MAX))

        -- 가격 출력
        local price_str = comma_value(t_analyze['total_price'])

        if (self.m_upgradeMode == 'upgrade') then
            vars['priceLabel']:setString(price_str)
        elseif (self.m_upgradeMode == 'skill_lv_up') then
            vars['skillUpPriceLabel']:setString(price_str)
        end

        -- 선택된 재료로 인한 경험치 상승
        self:refresh_selectedMaterialExp(t_analyze['total_exp'])

    elseif (self.m_upgradeMode == 'eclv_up') then
        -- 가격 출력
        local price_str = comma_value(t_analyze['total_price_eclv'])
        vars['transcendPriceLabel']:setString(price_str)
    end
   

    -- 갯수에 따라 설명 출력
    local material_count = self.m_tableViewExtSelectMaterial:getItemCount()
    if (material_count <= 0) then
        vars['infoLabel1']:setVisible(true)
        vars['infoLabel2']:setVisible(true)
    else
        vars['infoLabel1']:setVisible(false)
        vars['infoLabel2']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_selectedMaterialExp
-- @brief 선택된 재료로 인한 경험치 상승
-------------------------------------
function UI_DragonManageUpgrade:refresh_selectedMaterialExp(total_exp)
    local vars = self.vars
    
    local t_dragon_data = self.m_selectDragonData

    -- 최대 등급인지 여부
    local is_max_grade = (t_dragon_data['grade'] >= MAX_DRAGON_GRADE)

    -- 등급 테이블
    local table_grade_info = TABLE:get('grade_info')
    local t_grade_info = table_grade_info[t_dragon_data['grade']]

    if is_max_grade then
        return
    end

    local req_exp = t_grade_info['req_exp']
    local curr_exp = (t_dragon_data['gexp'] + total_exp)

    local percentage = (curr_exp / req_exp) * 100
    percentage = math_clamp(percentage, 0, 100)

    vars['upgradeExpLabel']:setString(Str('승급 경험치 {1}%', math_floor(percentage)))

    vars['upgradeGauge1']:stopAllActions()
    vars['upgradeGauge1']:runAction(cc.ProgressTo:create(0.3, percentage))
end

-------------------------------------
-- function analyzeSelectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonManageUpgrade:analyzeSelectedMaterial(doid, l_item)
    --local l_item = self.m_tableViewExtSelectMaterial.m_itemList

    local t_ret = {}

    local t_dragon_Data = g_dragonsData:getDragonDataFromUid(doid)
    local table_grade_info = TABLE:get('grade_info')
    local table_dragon = TABLE:get('dragon')

    -- 최대 등급까지 필요한 경험치 총 량 계산
    local total_remain_exp = 0
    for grade=t_dragon_Data['grade'], MAX_DRAGON_GRADE do
        local t_grade_info = table_grade_info[grade]
        if (grade == t_dragon_Data['grade']) then
            total_remain_exp = total_remain_exp + (t_grade_info['req_exp'] - t_dragon_Data['gexp'])
        else
            total_remain_exp = total_remain_exp + t_grade_info['req_exp']
        end
    end
    t_ret['total_remain_exp'] = total_remain_exp

    -- 재료들을 모두 사용하여 승급할 때 필요한 골드
    local total_price = 0
    local total_price_eclv = 0
    for i,v in pairs(l_item) do
        local data = v['data']
        local grade = data['grade']
        local req_gold = table_grade_info[grade]['req_gold']
        total_price = (total_price + req_gold)

        local eclv_req_gold = table_grade_info[grade]['eclv_req_gold']
        total_price_eclv = (total_price_eclv + eclv_req_gold)
    end
    t_ret['total_price'] = total_price
    t_ret['total_price_eclv'] = total_price

    -- 스킬들의 레벨업 가능한 갯수
    local num_of_remin_skill_level = g_dragonsData:getNumberOfRemainingSkillLevel(doid)
    t_ret['num_of_remin_skill_level'] = num_of_remin_skill_level

    -- 스킬들의 레벨업 수
    local num_of_skill_level = 0
    for i,v in pairs(l_item) do
        local data = v['data']
        local doid2 = data['id']
        if g_dragonsData:isSameTypeDragon(doid, doid2) then
            num_of_skill_level = (num_of_skill_level + 1)
        end
    end
    t_ret['num_of_skill_level'] = num_of_skill_level

    -- 현재 갯수
    local count = table.count(l_item)
    t_ret['count'] = count

    -- 경험치 체크
    local total_exp = 0
    for i,v in pairs(l_item) do
        local data = v['data']
        local grade = data['grade']
        local evolution = data['evolution']
        local evolution_str
        if (evolution == 1) then
            evolution_str = 'hatch_exp'
        elseif (evolution == 2) then
            evolution_str = 'hatchling_exp'
        elseif (evolution == 3) then
            evolution_str = 'adult_exp'
        end
        local exp = table_grade_info[grade][evolution_str]
        total_exp = (total_exp + exp)
    end
    t_ret['total_exp'] = total_exp


    return t_ret
end

-------------------------------------
-- function refresh_btnState
-- @brief
-------------------------------------
function UI_DragonManageUpgrade:refresh_btnState()
    local vars = self.vars

    vars['upgradeBtn']:setVisible(false)
    vars['skillUpgradeBtn']:setVisible(false)
    vars['transcendBtn']:setVisible(false)

    if (not self.m_bOpenMaterial) then
        vars['materialBtn']:setVisible(true)
    else
        vars['materialBtn']:setVisible(false)

        if (self.m_upgradeMode == 'upgrade') then
            vars['upgradeBtn']:setVisible(true)

        elseif (self.m_upgradeMode == 'skill_lv_up') then
            vars['skillUpgradeBtn']:setVisible(true)

        elseif (self.m_upgradeMode == 'eclv_up') then
            vars['transcendBtn']:setVisible(true)

        end
    end
end

-------------------------------------
-- function click_materialBtn
-- @brief "재료 선택" 버튼 클릭
--        재료 리스트가 등장하고, 승급(or 초월) 버튼 등장
-------------------------------------
function UI_DragonManageUpgrade:click_materialBtn()
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
-- function click_upgradeBtn
-------------------------------------
function UI_DragonManageUpgrade:click_upgradeBtn()
    local material_count = self.m_tableViewExtSelectMaterial:getItemCount()

    if (material_count <= 0) then
        UIManager:toastNotificationRed(Str('재료 드래곤을 선택해주세요!'))
        return
    end

    local uid = g_userData:get('uid')
    local doid = self.m_selectDragonOID
    local src_doids = ''
    do
        for _doid,_ in pairs(self.m_tableViewExtSelectMaterial.m_itemMap) do
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

            self.m_tableViewExt:expandTemp(0.5)
        end

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragon'] then
            local doid = ret['deleted_dragon']['id']
            g_dragonsData:delDragonData(doid)

            -- 드래곤 리스트 갱신
            self.m_tableViewExt:delItem(doid)
            self.m_tableViewExt:expandTemp(0.5)
        end

        -- 승급(or 초월)된 드래곤 갱신
        if ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

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

    -- 승급(스킬 레벨업)
    if isExistValue(self.m_upgradeMode, 'upgrade', 'skill_lv_up') then
        local ui_network = UI_Network()
        ui_network:setUrl('/dragons/upgrade')
        ui_network:setParam('uid', uid)
        ui_network:setParam('doid', doid)
        ui_network:setParam('src_doids', src_doids)
        ui_network:setRevocable(true)
        ui_network:setSuccessCB(function(ret) success_cb(ret) end)
        ui_network:request()

    -- 초월
    elseif (self.m_upgradeMode == 'eclv_up') then
        local ui_network = UI_Network()
        ui_network:setUrl('/dragons/exceed')
        ui_network:setParam('uid', uid)
        ui_network:setParam('doid', doid)
        ui_network:setParam('src_doid', src_doids)
        ui_network:setRevocable(true)
        ui_network:setSuccessCB(function(ret) success_cb(ret) end)
        ui_network:request()
    end
end

-------------------------------------
-- function click_transcendBtn
-------------------------------------
function UI_DragonManageUpgrade:click_transcendBtn()
    self:click_upgradeBtn()
end


-------------------------------------
-- function upgradeDirecting
-- @brief 강화 연출
-------------------------------------
function UI_DragonManageUpgrade:upgradeDirecting(doid, t_prev_dragon_data, t_next_dragon_data)
    local block_ui = UI_BlockPopup()

    local directing_animation
    local directing_result

    -- 에니메이션 연출
    directing_animation = function()
        local vars = self.vars

        self.vars['upgradeVisual']:setVisible(true)
        self.vars['upgradeVisual']:setVisual('res', 'material_frame_fx')
        self.vars['upgradeVisual']:setRepeat(false)
        self.vars['upgradeVisual']:addAniHandler(directing_result)
        SoundMgr:playEffect('EFFECT', 'exp_gauge')
    end

    -- 결과 연출
    directing_result = function()
        block_ui:close()

        -- 결과 팝업 (승급)
        if (t_prev_dragon_data['grade'] < t_next_dragon_data['grade']) then
            UI_DragonManageUpgradeResult(t_next_dragon_data)

        -- 결과 팝업 (초월)
        elseif (t_prev_dragon_data['eclv'] < t_next_dragon_data['eclv']) then
            local ui = UI_DragonManageUpgradeResult(t_next_dragon_data)
            if (t_next_dragon_data['eclv'] >= MAX_DRAGON_ECLV) then
                local function close_cb()
                    self:close()
                end
                ui:setCloseCB(close_cb)
            end
        end

        -- UI 갱신
        self:refresh_dragonIndivisual(doid)
    end

    -- 초월의 경우 즉시 연출 시작
    if (self.m_upgradeMode == 'eclv_up') then
        directing_result()
    else
        directing_animation()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageUpgrade:click_exitBtn()
    self:close()
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonManageUpgrade:createDragonCardCB(ui, data)
    local doid = data['id']

    if (g_dragonsData:getUpgradeMode(doid) == 'max') then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-------------------------------------
function UI_DragonManageUpgrade:checkDragonSelect(doid)
    local upgrade_mode = g_dragonsData:getUpgradeMode(doid)

    if (upgrade_mode == 'max') then
        UIManager:toastNotificationGreen(Str('최대 초월단계의 드래곤입니다.'))
        return false
    else
        return true
    end
end

--@CHECK
UI:checkCompileError(UI_DragonManageUpgrade)
