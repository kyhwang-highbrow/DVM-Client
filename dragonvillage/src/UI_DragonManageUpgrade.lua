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
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonManageUpgrade:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonManageUpgrade'
    self.m_bVisible = true or false
    self.m_titleStr = Str('승급') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
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

    self:init_dragonTableView()
    --self:setDefaultSelectDragon()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageUpgrade:initButton()
    local vars = self.vars
    vars['upgradeBtn']:registerScriptTapHandler(function() self:click_upgradeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageUpgrade:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars

    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    -- 등급 테이블
    local table_grade_info = TABLE:get('grade_info')
    local t_grade_info = table_grade_info[t_dragon_data['grade']]
    local t_next_grade_info = table_grade_info[t_dragon_data['grade'] + 1]

    -- 최대 등급인지 여부
    local is_max_grade = (t_dragon_data['grade'] >= MAX_DRAGON_GRADE)

    do -- 드래곤 이름
        vars['nameLabel']:setString(Str(t_dragon['t_name']))
    end

    do -- 드래곤 현재 정보 카드
        vars['termsIconNode']:removeAllChildren()
        local dragon_card = UI_DragonCard(t_dragon_data)
        vars['termsIconNode']:addChild(dragon_card.root)
    end

    do -- 드래곤 다음 등급 정보 카드
        vars['maxIconNode']:removeAllChildren()

        if is_max_grade then
            
        else
            local t_next_dragon_data = clone(t_dragon_data)
            t_next_dragon_data['grade'] = (t_next_dragon_data['grade'] + 1)
            local dragon_card = UI_DragonCard(t_next_dragon_data)
            vars['maxIconNode']:addChild(dragon_card.root)
        end
    end
    
    -- 등급 업이 될 때 표시 스프라이트
    vars['gradeUpSprite']:setVisible(false)

    -- 스킬 업이 될 때 표시 스프라이트
    vars['skillUpSprite']:setVisible(false)
    
    do -- 승급 경험치
        if is_max_grade then
            vars['upgradeExpLabel']:setString(Str('승급 경험치 MAX'))
            vars['upgradeGauge']:stopAllActions()
            vars['upgradeGauge']:runAction(cc.ProgressTo:create(0.3, 100)) 
        else
            local req_exp = t_grade_info['req_exp']
            local curr_exp = t_dragon_data['gexp']
            local percentage = (curr_exp / req_exp) * 100

            vars['upgradeExpLabel']:setString(Str('승급 경험치 {1}%', math_floor(percentage)))
            vars['upgradeGauge']:stopAllActions()
            vars['upgradeGauge']:runAction(cc.ProgressTo:create(0.3, percentage)) 
        end
    end

    -- 레벨 표시
    do
        local curr_lv = t_dragon_data['lv']
        local max_lv = t_grade_info['max_lv']
        vars['termsLvLabel']:setString(Str('조건레벨 {1}/{2}', curr_lv, max_lv))

        if is_max_grade then
            vars['maxLvLabel']:setVisible(false)
        else
            vars['maxLvLabel']:setVisible(true)
            local next_max_lv = t_next_grade_info['max_lv']
            vars['maxLvLabel']:setString(Str('최대레벨 {1} > {2}', max_lv, next_max_lv))
        end
    end

    vars['selectLabel']:setString(Str('선택재료 {1} / 30', 0))

    -- 선택된 재료 리스트 갱신
    self:init_dragonUpgradeMaterialSelectTableView()

    -- 재료 리스트 갱신
    self:init_dragonUpgradeMaterialTableView()

    self:refresh_selectedMaterial()
end

-------------------------------------
-- function init_dragonUpgradeMaterialTableView
-- @brief 드래곤 승급 재료(다른 드래곤) 리스트 테이블 뷰
-------------------------------------
function UI_DragonManageUpgrade:init_dragonUpgradeMaterialTableView()
    local list_table_node = self.vars['selectListNode']
    list_table_node:removeAllChildren()

    local item_size = 150
    local item_scale = 0.75

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(item_scale)

        local data = item['data']
        local doid = data['id']
        if g_dragonsData:isSameTypeDragon(self.m_selectDragonOID, doid) then
            ui:setSkillSpriteVisible(true)
        end

        self:refresh_materialDragonIndivisual(item['unique_id'])
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        self:click_dragonUpgradeMaterial(item)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    do -- 아이콘 크기 지정
        local item_adjust_size = (item_size * item_scale)
        local nItemPerCell = 4
        local cell_width = (item_adjust_size * nItemPerCell)
        local cell_height = item_adjust_size
        local item_width = item_adjust_size
        local item_height = item_adjust_size
        table_view_ext:setCellInfo2(nItemPerCell, cell_width, cell_height, item_width, item_height)
    end    
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    
    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonUpgradeMaterialList(self.m_selectDragonOID)
    table_view_ext:setItemInfo(l_dragon_list)

    table_view_ext:update()

    self.m_tableViewExtMaterial = table_view_ext

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

    -- 최대 등급인지 확인
    local is_max_grade = (t_dragon_data['grade'] >= MAX_DRAGON_GRADE)

    -- 남은 드래곤 스킬 레벨 갯수
    local num_of_remin_skill_level = g_dragonsData:getNumberOfRemainingSkillLevel(doid)

    -- 1. 최대 등급, 최대 스킬 레벨일 경우 모든 드래곤 제외
    if (is_max_grade and num_of_remin_skill_level) then
        return {}
    end

    -- 2. 자기 자신 드래곤 제외
    local l_dragon_list = g_dragonsData:getDragonsList()-- clone된 데이터를 사용
    l_dragon_list[doid] = nil

    -- 3. 최대 등급일 경우 원종이 다른 드래곤 제외
    if is_max_grade then
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

    local item_size = 150
    local item_scale = 0.5
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(item_scale)

        local data = item['data']
        local doid = data['id']
        if g_dragonsData:isSameTypeDragon(self.m_selectDragonOID, doid) then
            ui:setSkillSpriteVisible(true)
        end
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        self:click_dragonUpgradeMaterial(item)
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
-- function click_dragonUpgradeMaterial
-------------------------------------
function UI_DragonManageUpgrade:click_dragonUpgradeMaterial(item)
    local data = item['data']
    local unique_id = data['id']

    local selected_material_item = self.m_tableViewExtSelectMaterial:getItem(unique_id)

    -- 재료 해제
    if selected_material_item then
        self.m_tableViewExtSelectMaterial:delItem(unique_id)
        self.m_tableViewExtSelectMaterial:update()
        self:refresh_materialDragonIndivisual(unique_id)
        self:refresh_selectedMaterial()
        self.m_materialSortMgr:changeSort2()
        return

    -- 재료 추가
    else
        self.m_tableViewExtSelectMaterial:addItem(unique_id, data)
        self.m_tableViewExtSelectMaterial:update()
        self:refresh_materialDragonIndivisual(unique_id)
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

    if item then
        local is_selected = (self.m_tableViewExtSelectMaterial:getItem(odid) ~= nil)
        local ui = item['ui']
        if ui then
            ui:setShadowSpriteVisible(is_selected)
        end
    end
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonManageUpgrade:refresh_selectedMaterial()
    
    local vars = self.vars

    local t_analyze

    do -- 재료 분석 (가격 총 경험치 등)
        local doid = self.m_selectDragonOID
        local l_item = self.m_tableViewExtSelectMaterial.m_lItem
        t_analyze = self:analyzeSelectedMaterial(doid, l_item)
    end

    -- 재료 갯수 출력
    vars['selectLabel']:setString(Str('선택재료 {1} / {2}', t_analyze['count'], MAX_DRAGON_UPGRADE_MATERIAL_MAX))

    -- 가격 출력
    vars['priceLabel']:setString(comma_value(t_analyze['total_price']))

    -- 선택된 재료로 인한 경험치 상승
    self:refresh_selectedMaterialExp(t_analyze['total_exp'])
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
    --local l_item = self.m_tableViewExtSelectMaterial.m_lItem

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
    for i,v in pairs(l_item) do
        local data = v['data']
        local grade = data['grade']
        local req_gold = table_grade_info[grade]['req_gold']
        total_price = (total_price + req_gold)
    end
    t_ret['total_price'] = total_price

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
        for _doid,_ in pairs(self.m_tableViewExtSelectMaterial.m_mapItem) do
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
            for _,odid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(odid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(odid)
            end

            self.m_tableViewExt:update()
        end

        -- 승급된 드래곤 갱신
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

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/upgrade')
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

        -- 결과 팝업
        if (t_prev_dragon_data['grade'] < t_next_dragon_data['grade']) then
            UI_DragonManageUpgradeResult(t_next_dragon_data)

            -- 최대 승급을 달성했을 경우(스킬까지 모두 다)
            if (not g_dragonsData:canUpgrade(doid)) then
                self:close()
                return
            end
        end

        -- UI 갱신
        self:refresh_dragonIndivisual(doid)
    end

    directing_animation()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonManageUpgrade:click_exitBtn()
    self:close()
end

-------------------------------------
-- function reateDragonCardCB
-- @brief 드래곤 생성 콜백
-------------------------------------
function UI_DragonManageUpgrade:reateDragonCardCB(item)
    local ui = item['ui']
    local data = item['data']
    local doid = data['id']

    if (not g_dragonsData:canUpgrade(doid)) then
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
    if (not g_dragonsData:canUpgrade(doid)) then
        UIManager:toastNotificationGreen(Str('최대 승급단계의 드래곤입니다.'))
        return false
    end
    return true
end

--@CHECK
UI:checkCompileError(UI_DragonManageUpgrade)
