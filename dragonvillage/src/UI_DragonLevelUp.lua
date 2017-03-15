local PARENT = UI_DragonManage_Base
local MAX_DRAGON_LEVELUP_MATERIAL_MAX = 30 -- 한 번에 사용 가능한 재료 수

-------------------------------------
-- class UI_DragonLevelUp
-------------------------------------
UI_DragonLevelUp = class(PARENT,{
        m_bChangeDragonList = 'boolean',

        m_mtrlTableViewTD = '', -- 재료
        m_mtrlDragonSortManager = 'SortManager_Dragon',
        m_selectedMtrlTableView = '',

        -- 재료 UI 오픈 여부(왼쪽에 테이블 뷰)
        m_bOpenMaterial = 'boolean',

        m_dragonLevelUpUIHelper = 'UI_DragonLevelUpHelper',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonLevelUp:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonLevelUp'
    self.m_bVisible = true or false
    self.m_titleStr = Str('드래곤 레벨업')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelUp:init(doid, b_ascending_sort, sort_type)
    self.m_bOpenMaterial = false

    local vars = self:load('dragon_management_levelup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonLevelUp')

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
function UI_DragonLevelUp:initUI()
    local vars = self.vars

    vars['leftMenu']:setVisible(false)
    vars['rightMenu']:setPositionX(0)

    self:init_dragonTableView()
    self:init_selectedMaterialTableView()
end

-------------------------------------
-- function init_selectedMaterialTableView
-- @brief 선택된 드래곤 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonLevelUp:init_selectedMaterialTableView()
    local list_table_node = self.vars['materialNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view = UIC_TableView(list_table_node)
    table_view.m_defaultCellSize = cc.size(90, 90)
    table_view:setCellUIClass(UI_DragonCard, create_func)
    table_view:setItemList({})
    self.m_selectedMtrlTableView = table_view
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonLevelUp:initButton()
    local vars = self.vars
    vars['materialBtn']:registerScriptTapHandler(function() self:click_materialBtn() end)

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
function UI_DragonLevelUp:refresh()
    if self.m_selectDragonOID then
        self.m_dragonLevelUpUIHelper = UI_DragonLevelUpHelper(self.m_selectDragonOID, MAX_DRAGON_LEVELUP_MATERIAL_MAX)
    end
    self:refresh_dragonInfo()

    -- 재료 리스트 갱신
    if self.m_bOpenMaterial then
        self:refresh_dragonLevelupMaterialTableView()
    end

    self:init_selectedMaterialTableView()

    self:refresh_btnState()
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_dragonInfo
-------------------------------------
function UI_DragonLevelUp:refresh_dragonInfo()
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

    do -- 레벨 표시
        local grade = t_dragon_data['grade']
        local lv = t_dragon_data['lv']
        local max_lv = TableGradeInfo():getValue(grade, 'max_lv')
        vars['levelLabel']:setString(Str('레벨{1}/{2}', lv, max_lv))
    end

    do -- 경혐치 exp
        local grade = (t_dragon_data['grade'] or 1)
        local lv = (t_dragon_data['lv'] or 1)
        local exp = (t_dragon_data['exp'] or 0)
        local table_exp = TableDragonExp()
        local max_exp = table_exp:getDragonMaxExp(grade, lv)

        local percentage = (exp / max_exp) * 100
        vars['expGauge1']:setVisible(true)
        vars['expGauge1']:setPercentage(percentage)

        vars['expLabel']:setString(Str('{1}/{2}', exp, max_exp))
    end

    do
        local doid = t_dragon_data['id']

        -- 현재 레벨의 능력치 계산기
        local status_calc = MakeOwnDragonStatusCalculator(doid)

        -- 현재 레벨의 능력치
        local curr_atk = status_calc:getFinalStat('atk')
        local curr_def = status_calc:getFinalStat('def')
        local curr_hp = status_calc:getFinalStat('hp')
        local curr_cp = status_calc:getCombatPower()

        -- 변경된 레벨의 능력치 계산기
        local chaged_dragon_data = {}
        chaged_dragon_data['lv'] = (t_dragon_data['lv'] + 1)
        local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

        -- 변경된 레벨의 능력치
        local changed_atk = changed_status_calc:getFinalStat('atk')
        local changed_def = changed_status_calc:getFinalStat('def')
        local changed_hp = changed_status_calc:getFinalStat('hp')
        local changed_cp = changed_status_calc:getCombatPower()

        -- 현재 레벨의 능력치 표시
        vars['atk_p_label']:setString(comma_value(math_floor(curr_atk)))
        vars['def_p_label']:setString(comma_value(math_floor(curr_def)))
        vars['hp_label']:setString(comma_value(math_floor(curr_hp)))
        vars['cp_label']:setString(comma_value(math_floor(curr_cp)))

        -- 상승되는 능력치 표시
        vars['atk_p_label2']:setString(Str('+{1}', comma_value(math_floor(changed_atk - curr_atk))))
        vars['def_p_label2']:setString(Str('+{1}', comma_value(math_floor(changed_def - curr_def))))
        vars['hp_label2']:setString(Str('+{1}', comma_value(math_floor(changed_hp - curr_hp))))
        vars['cp_label2']:setString(Str('+{1}', comma_value(math_floor(changed_cp - curr_cp))))
    end

    -- 선택 재료 갯수
    vars['selectLabel']:setString(Str('선택재료 {1} / {2}', 0, MAX_DRAGON_LEVELUP_MATERIAL_MAX))
end

-------------------------------------
-- function refresh_btnState
-- @brief
-------------------------------------
function UI_DragonLevelUp:refresh_btnState()
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
--        재료 리스트가 등장하고, 승급(or 초월) 버튼 등장
-------------------------------------
function UI_DragonLevelUp:click_materialBtn()
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

    cca.reserveFuncWithTag(vars['leftMenu'], 0.5, function() self:refresh_dragonLevelupMaterialTableView() end, 100)

    vars['leftMenu']:setVisible(true)
    vars['rightMenu']:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.5, cc.p(320, 69)), 2))
end

-------------------------------------
-- function refresh_dragonLevelupMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonLevelUp:refresh_dragonLevelupMaterialTableView()
    -- 최초로 leftMenu가 등장했을 때 예약된 함수 제거
    cca.stopAction(self.vars['leftMenu'], 100)
    
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.7)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(105, 105)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonLevelupMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    -- 정렬
    self:refresh_sortUI()
end

-------------------------------------
-- function getDragonLevelupMaterialList
-- @brief 드래곤 레벨업 재료
-------------------------------------
function UI_DragonLevelUp:getDragonLevelupMaterialList(doid)
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용
    -- 자기 자신 드래곤 제외
    l_dragon_list[doid] = nil
    return l_dragon_list
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_DragonLevelUp:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_DragonLevelUp:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_DragonLevelUp:click_sortBtn(sort_type)
    local sort_manager = self.m_mtrlDragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_DragonLevelUp:refresh_sortUI()
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
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonLevelUp:createDragonCardCB(ui, data)
    local doid = data['id']

    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)
    if (not possible) then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-------------------------------------
function UI_DragonLevelUp:checkDragonSelect(doid)
    local possible, msg = g_dragonsData:possibleDragonLevelUp(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_dragonMaterial
-------------------------------------
function UI_DragonLevelUp:click_dragonMaterial(data)
    local doid = data['id']

    local selected_material_item = self.m_selectedMtrlTableView:getItem(doid)

    -- 재료 해제
    if selected_material_item then
        self.m_selectedMtrlTableView:delItem(doid)
        --self:refresh_materialDragonIndivisual(doid)
        --self:refresh_selectedMaterial()
        --self.m_materialSortMgr:changeSort2()

    -- 재료 추가
    else
        local material_count = self.m_selectedMtrlTableView:getItemCount()

        -- 최대 재료 갯수 체크
        if (material_count >= MAX_DRAGON_LEVELUP_MATERIAL_MAX) then
            UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_DRAGON_LEVELUP_MATERIAL_MAX))
            return
        end

        -- 리더 설정 여부 확인
        local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
        if (not possible) then
            UIManager:toastNotificationRed(msg)
            return
        end

        self.m_selectedMtrlTableView:addItem(doid, data)
    end

    self.m_dragonLevelUpUIHelper:modifyMaterial(doid)
    self:refresh_materialDragonIndivisual(doid)
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonLevelUp:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    if (not self.m_selectedMtrlTableView) then
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

    local is_selected = (self.m_selectedMtrlTableView:getItem(doid) ~= nil)
    ui:setShadowSpriteVisible(is_selected)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonLevelUp:refresh_selectedMaterial()
    local vars = self.vars
    
    local helper = self.m_dragonLevelUpUIHelper
    if (not helper) then
        return
    end

    vars['selectLabel']:setString(helper:getMaterialCountString())
    vars['priceLabel']:setString(comma_value(helper.m_price))
    vars['expGauge1']:setPercentage(helper.m_expPercentage)
    
    vars['levelLabel']:setString(Str('레벨{1}/{2}', helper.m_changedLevel, helper.m_maxLevel))

    if helper.m_changedMaxExp then
        vars['expLabel']:setString(Str('{1}/{2}', helper.m_changedExp, helper.m_changedMaxExp))
    else
        vars['expLabel']:setString('')
    end

    do
        local t_dragon_data = self.m_selectDragonData
        local doid = t_dragon_data['id']

        -- 현재 레벨의 능력치 계산기
        local status_calc = MakeOwnDragonStatusCalculator(doid)

        -- 현재 레벨의 능력치
        local curr_atk = status_calc:getFinalStat('atk')
        local curr_def = status_calc:getFinalStat('def')
        local curr_hp = status_calc:getFinalStat('hp')
        local curr_cp = status_calc:getCombatPower()

        -- 변경된 레벨의 능력치 계산기
        local chaged_dragon_data = {}
        chaged_dragon_data['lv'] = math_max((t_dragon_data['lv'] + 1), helper.m_changedLevel)
        local changed_status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)

        -- 변경된 레벨의 능력치
        local changed_atk = changed_status_calc:getFinalStat('atk')
        local changed_def = changed_status_calc:getFinalStat('def')
        local changed_hp = changed_status_calc:getFinalStat('hp')
        local changed_cp = changed_status_calc:getCombatPower()

        -- 현재 레벨의 능력치 표시
        vars['atk_p_label']:setString(comma_value(math_floor(curr_atk)))
        vars['def_p_label']:setString(comma_value(math_floor(curr_def)))
        vars['hp_label']:setString(comma_value(math_floor(curr_hp)))
        vars['cp_label']:setString(comma_value(math_floor(curr_cp)))

        -- 상승되는 능력치 표시
        vars['atk_p_label2']:setString(Str('+{1}', comma_value(math_floor(changed_atk - curr_atk))))
        vars['def_p_label2']:setString(Str('+{1}', comma_value(math_floor(changed_def - curr_def))))
        vars['hp_label2']:setString(Str('+{1}', comma_value(math_floor(changed_hp - curr_hp))))
        vars['cp_label2']:setString(Str('+{1}', comma_value(math_floor(changed_cp - curr_cp))))
    end
end


--@CHECK
UI:checkCompileError(UI_DragonLevelUp)
