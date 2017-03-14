local PARENT = UI_DragonManage_Base
local MAX_DRAGON_UPGRADE_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonUpgrade
-------------------------------------
UI_DragonUpgrade = class(PARENT,{
        m_bChangeDragonList = 'boolean',
        m_mtrlTableViewTD = '', -- 재료
        m_bOpenMaterial = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonUpgrade:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonUpgrade'
    self.m_bVisible = true or false
    self.m_titleStr = Str('승급')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgrade:init(doid, b_ascending_sort, sort_type)
    self.m_bChangeDragonList = false
    self.m_bOpenMaterial = false

    local vars = self:load('dragon_management_upgrade_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonUpgrade')

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
function UI_DragonUpgrade:initUI()
    local vars = self.vars

    vars['leftMenu']:setVisible(false)
    vars['rightMenu']:setPositionX(0)

    self:init_dragonTableView()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonUpgrade:initButton()
    local vars = self.vars
    vars['materialBtn']:registerScriptTapHandler(function() self:click_materialBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgrade:refresh()

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
function UI_DragonUpgrade:refresh_btnState()
    local vars = self.vars

    vars['upgradeBtn']:setVisible(false)
    vars['transcendBtn']:setVisible(false)

    if (not self.m_bOpenMaterial) then
        vars['materialBtn']:setVisible(true)
    else
        vars['materialBtn']:setVisible(false)
        vars['upgradeBtn']:setVisible(true)
    end
end

-------------------------------------
-- function refresh_upgrade
-------------------------------------
function UI_DragonUpgrade:refresh_upgrade(table_dragon, t_dragon_data)
    local vars = self.vars

    -- 등급 테이블
    local table_grade_info = TableGradeInfo()
    local t_grade_info = table_grade_info:get(t_dragon_data['grade'])
    local t_next_grade_info = table_grade_info:get(t_dragon_data['grade'] + 1)

    do -- 드래곤 다음 등급 정보 카드
        vars['maxIconNode']:removeAllChildren()
        local t_next_dragon_data = clone(t_dragon_data)
        t_next_dragon_data['grade'] = (t_next_dragon_data['grade'] + 1)
        t_next_dragon_data['lv'] = 1
        local dragon_card = UI_DragonCard(t_next_dragon_data)
        vars['maxIconNode']:addChild(dragon_card.root)
    end

    do -- 레벨 표시
        local max_lv = t_grade_info['max_lv']
        local next_max_lv = t_next_grade_info['max_lv']
        vars['maxLvLabel']:setString(Str('최대레벨\n{1} > {2}', max_lv, next_max_lv))

        vars['nextTextLabel']:setString(Str('등급 상승'))
    end

    do -- 설명
        vars['infoLabel']:setString(Str('승급하면 등급과 최대레벨이 상승해요'))
    end

    do -- 승급에 필요한 가격
        local grade = t_dragon_data['grade']
        local req_gold = table_grade_info:getValue(grade, 'req_gold')
        vars['priceLabel']:setString(comma_value(req_gold))
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-------------------------------------
function UI_DragonUpgrade:checkDragonSelect(doid)
    local upgradeable, msg = g_dragonsData:checkUpgradeable(doid)

    if upgradeable then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_materialBtn
-- @brief "재료 선택" 버튼 클릭
--        재료 리스트가 등장하고, 승급(or 초월) 버튼 등장
-------------------------------------
function UI_DragonUpgrade:click_materialBtn()
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
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonUpgrade:refresh_dragonUpgradeMaterialTableView()
    -- 최초로 leftMenu가 등장했을 때 예약된 함수 제거
    cca.stopAction(self.vars['leftMenu'], 100)
    
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)

        --[[
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
        --]]
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    --[[
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
    --]]
end

-------------------------------------
-- function getDragonUpgradeMaterialList
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트
-------------------------------------
function UI_DragonUpgrade:getDragonUpgradeMaterialList(doid)
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
    
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용

    -- 2. 자기 자신 드래곤 제외
    l_dragon_list[doid] = nil

    for i,v in pairs(l_dragon_list) do
        if (v['grade'] < t_dragon_data['grade']) then
            l_dragon_list[i] = nil
        end
    end

    return l_dragon_list
end

--@CHECK
UI:checkCompileError(UI_DragonUpgrade)
