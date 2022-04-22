local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonUpgradeCombineMaterial
-------------------------------------
UI_DragonUpgradeCombineMaterial = class(PARENT,{
        m_uicSortList = 'UIC_SortList',
        m_sortGrade = 'number',

        m_tableView = 'UIC_TableViewTD',
        m_combineTableView = 'UIC_TableView',
        m_sortManager = 'SortManager',
        m_bDirty = 'boolean',
    
        m_mSelectDragonMap = 'map',
        m_lCombineDataList = 'list',

        m_needGold = 'number',
        m_needExp = 'number',

        m_bDoingAutoBtn = 'boolean',
    })

UI_DragonUpgradeCombineMaterial.CARD_SCALE = 0.6 -- (63, 63)
UI_DragonUpgradeCombineMaterial.CARD_CELL_SIZE = cc.size(93, 93)
UI_DragonUpgradeCombineMaterial.MAX_COMBINE_COUNT = 25 -- 한번에 합성 가능한 최대 갯수

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonUpgradeCombineMaterial:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonUpgradeCombineMaterial'
    self.m_titleStr = nil
    self.m_invenType = 'dragon'
    self.m_bShowInvenBtn = true 
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgradeCombineMaterial:init()
    local vars = self:load('dragon_upgrade_material.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_bDirty = false
    self.m_needGold = 0
    self.m_needExp = 0

    self.m_sortGrade = 3
    self.m_bDoingAutoBtn = false

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_DragonUpgradeCombineMaterial')

    if vars['slimeBtn'] then
        vars['slimeBtn'] = UIC_CheckBox(vars['slimeBtn'].m_node, vars['slimeSprite'], false) 
    end


    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonUpgradeCombineMaterial:initUI()
    local vars = self.vars

    do -- 배경
        local animator = ResHelper:getUIDragonBG('earth', 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    do -- 정렬
        local uic_sort_list =  MakeUICSortList_DragonUpgradeMaterialCombine(vars['sortBtn'], vars['sortLabel'])
        uic_sort_list:setSelectSortType(3)
        self.m_uicSortList = uic_sort_list

        -- 버튼을 통해 정렬이 변경되었을 경우
        local function sort_change_cb(sort_type)
            self.m_sortGrade = sort_type
             
            -- 선택된 드래곤 초기화
            self.m_mSelectDragonMap = {}

            self:initTableView()
            self:initCombineTableView()
            self:refresh()
        end

        uic_sort_list:setSortChangeCB(sort_change_cb)
    end

    -- 선택된 드래곤 초기화
    self.m_mSelectDragonMap = {}
    
    self:initTableView()
    self:initCombineTableView()
end

-------------------------------------
-- function initTableView
-- @brief 왼쪽 재료(슬라임 or 드래곤) 리스트 생성
-------------------------------------
function UI_DragonUpgradeCombineMaterial:initTableView()
    local vars = self.vars
    local node = vars['materialTableViewNode']
    
    -- 기존 테이블뷰 삭제
    node:removeAllChildren()
    
    local function create_func(ui, data)
        -- 새로 획득한 드래곤 뱃지
        local is_new_dragon = data:isNewDragon()
        ui:setNewSpriteVisible(is_new_dragon)

        ui.root:setScale(UI_DragonUpgradeCombineMaterial.CARD_SCALE)

        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = UI_DragonUpgradeCombineMaterial.CARD_CELL_SIZE
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)

    -- 리스트가 비었을 때
    local msg = Str('도와줄 드래곤이 없다고라') 
    table_view_td:makeDefaultEmptyMandragora(msg)

    self.m_tableView = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_grade_dragon_list = self:getMaterialMap()

    self.m_tableView:setItemList(l_grade_dragon_list)

    if (self.m_sortManager == nil) then
        local sort_manager = self:getDefaultSortManager()
        self.m_sortManager = sort_manager

    else
        vars['sortOrderSprite']:setRotation(180)
    end

    self.m_sortManager:sortExecution(self.m_tableView.m_itemList)
end

-------------------------------------
-- function getMaterialMap
-- @brief 왼쪽 재료 맵
-- @return map[oid] = StructDragonObject or StructSlimeObject 
-------------------------------------
function UI_DragonUpgradeCombineMaterial:getMaterialMap(grade)
    local vars = self.vars
    local grade = grade or self.m_sortGrade

    local l_dragon_list 
    if vars['slimeBtn'] and vars['slimeBtn']:isVisible() and vars['slimeBtn']:isChecked() then
        l_dragon_list = g_dragonsData:getDragonsList()
    else
        l_dragon_list = g_dragonsData:getDragonListWithSlime()
    end
    
    local l_material_map = {}

    for k, v in pairs(l_dragon_list) do
        if (v['grade'] == grade) and (v['lock'] == false) then
            if (v:getObjectType() == 'slime') then
                 -- 슬라임 타입이 upgrade가 아니면 제외
                local slime_type = v:getSlimeType()
                if (slime_type == 'upgrade') then
                     l_material_map[k] = v
                end
            
            else
	            local possible, msg = g_dragonsData:possibleMaterialDragon(k)
                local b_is_raised = v:isRaisedByUser() or v:isRuneEquipped()

                if (possible == true) and (b_is_raised == false) then
                    l_material_map[k] = v
                end
            end
        end
    end

    return l_material_map
end

-------------------------------------
-- function getMaterialList
-- @brief 왼쪽 재료 리스트
-- @return map[oid] = StructDragonObject or StructSlimeObject 
-------------------------------------
function UI_DragonUpgradeCombineMaterial:getDefaultSortManager()
    local sort_manager = SortManager_Dragon()
    sort_manager:addPreSortType('object_type', false, function(a, b, ascending) return sort_manager:sort_object_type(a, b, ascending) end)
	sort_manager.m_mPreSortType['object_type']['ascending'] = true -- 슬라임이 앞쪽으로 정렬되도록 변경
    sort_manager:pushSortOrder('underling')
    sort_manager:pushSortOrder('lv')
    sort_manager.m_mSortType['lv']['ascending'] = true -- 레벨이 낮을수록 앞에 정렬되도록 변경

    return sort_manager
end

-------------------------------------
-- function initCombineTableView
-- @brief 오른쪽 합성 테이블뷰 생성
-------------------------------------
function UI_DragonUpgradeCombineMaterial:initCombineTableView()
    local vars = self.vars
    local node = vars['materialUpgradeTableViewNode']
    
    -- 기존 테이블뷰 삭제
    node:removeAllChildren()
    
    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_DragonUpgradeCombineMaterialItem(self, object)
    end

    local function create_func(ui, data)
    end

    -- 테이블뷰 생성
    local l_item_list = {}
    self.m_lCombineDataList = l_item_list
   
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(600, 105)
    table_view:setCellUIClass(make_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	table_view:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view:setItemList(l_item_list)
    self.m_combineTableView = table_view
    
    -- 미리 생성
    local grade = self.m_sortGrade
    for i = 1, UI_DragonUpgradeCombineMaterial.MAX_COMBINE_COUNT do
        local t_upgrade_material_combine_data = StructUpgradeMaterialCombine(grade)
        self.m_lCombineDataList[i] = t_upgrade_material_combine_data
        self.m_combineTableView:addItem(i, t_upgrade_material_combine_data)
    end

    table_view:makeAllItemUINoAction()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonUpgradeCombineMaterial:initButton()
    local vars = self.vars

    vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['combineBtn']:registerScriptTapHandler(function() self:click_combineBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    
    cca.pickMePickMe(vars['buyBtn'], 10)
    if vars['slimeBtn'] then
        vars['slimeBtn']:registerScriptTapHandler(function() self:click_slimeBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradeCombineMaterial:refresh()
    local vars = self.vars

    do -- 현재 선택된 드래곤 갯수 표기
        local all_count = table.count(self.m_tableView.m_itemList)
        local select_count = table.count(self.m_mSelectDragonMap)
        vars['countLabel']:setString(Str('선택된 드래곤') .. ' ' .. Str('{@white}{1}/{2}', select_count, all_count))
    end

    do -- 현재 합성 개수 표기
        local combine_max_count = UI_DragonUpgradeCombineMaterial.MAX_COMBINE_COUNT
        local combine_count = 0
        for i, v in ipairs(self.m_lCombineDataList) do
            if (v:isFull()) then
                combine_count = combine_count + 1
            end
        end
        vars['selectLabel']:setString(Str('{1}/{2}', combine_count, combine_max_count))
    end

    self:refreshCombineItems()
    
    self:refreshPrice()

    do -- 슈퍼 슬라임 군단 패키지 버튼
        local product_id = 121411
        local struct_product = g_shopData:getTargetProduct(product_id)
        local can_buy = false

        -- 현재 판매중인 경우에만 time limit 보여주기
        if (struct_product ~= nil) then
            can_buy = struct_product:isItBuyable()
        end

        if (can_buy) then
            local end_date = struct_product:getEndDateStr()
            vars['timeLabel']:setString(end_date)

        else
            vars['buyBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function refreshPrice
-- @brief 소모 재화 갱신
-------------------------------------
function UI_DragonUpgradeCombineMaterial:refreshPrice()
    local vars = self.vars

    -- 총 경험치 및 가격 표시
    local user_dragon_exp = g_userData:get('dragon_exp')
    local need_dragon_exp = 0
    local need_gold = 0

    for i, combine_data in ipairs(self.m_lCombineDataList) do
        if (combine_data:isFull()) then
            need_dragon_exp = need_dragon_exp + combine_data.m_needExp
            need_gold = need_gold + combine_data.m_needGold
        end
    end

    local exp_str = ''
    if (need_dragon_exp <= user_dragon_exp) then
        exp_str = Str('{1}/{2}', comma_value(user_dragon_exp), comma_value(need_dragon_exp))
    else
        exp_str = Str('{@impossible}{1}{@}/{2}', comma_value(user_dragon_exp), comma_value(need_dragon_exp))
    end

    vars['dragonExpLabel']:setString(exp_str)
    vars['priceLabel']:setString(comma_value(need_gold))

    AlignUIPos({vars['dragonExpIcon'], vars['dragonExpLabel']}, 'HORIZONTAL', 'CENTER', 0)

    self.m_needGold = need_gold
    self.m_needExp = need_dragon_exp
end


-------------------------------------
-- function refreshCombineItems
-- @brief 합성 정보 UI 갱신
-------------------------------------
function UI_DragonUpgradeCombineMaterial:refreshCombineItems()
    self.m_combineTableView:refreshAllItemUI()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_cancelBtn()
    self:close()
end

-------------------------------------
-- function click_dragonCard
-- @brief 드래곤 카드 클릭
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_dragonCard(data)
    local t_dragon_data = data
    local doid = t_dragon_data['id']

    if (self.m_mSelectDragonMap[doid] == nil) then
        self:selectDragon(t_dragon_data)
    else 
        self:deselectDragon(t_dragon_data)
    end

    self:refresh()
end

-------------------------------------
-- function selectDragon
-- @brief 드래곤 선택
-- @param t_dragon_data : 선택된 드래곤 데이터 (StructDragonObject)
-------------------------------------
function UI_DragonUpgradeCombineMaterial:selectDragon(t_dragon_data)
    local doid = t_dragon_data['id']

    if (self.m_mSelectDragonMap[doid]) then return end

    local combine_data_id
    local b_add_dragon = false

    for i, combine_data in ipairs(self.m_lCombineDataList) do
        b_is_full = combine_data:isFull() -- 추가적인 룬 등록이 가능한 상태인가
        if not b_is_full then
            b_add_dragon = true
            combine_data_id = i
            combine_data:addDragonObject(t_dragon_data)
            break
        end
    end

    -- 드래곤이 재료로 등록될 자리가 없는 경우
    if (not b_add_dragon) then
        UIManager:toastNotificationRed(Str('한번에 합성 가능한 슈퍼 슬라임 개수를 초과했습니다.'))
        return
    end

    local data = {}
    data['combine_id'] = combine_data_id
    data['data'] = t_dragon_data
    self.m_mSelectDragonMap[doid] = data

    local dragon_card = self.m_tableView:getCellUI(doid)
    if (dragon_card) then
        dragon_card:setCheckSpriteVisible(true)
    end
end

-------------------------------------
-- function deselectDragon
-- @brief 드래곤 선택 해제
-- @param t_dragon_data : 선택된 드래곤 데이터 (StructDragonObject)
-------------------------------------
function UI_DragonUpgradeCombineMaterial:deselectDragon(t_dragon_data)
    local doid = t_dragon_data['id']
    
    local combine_data_id = self.m_mSelectDragonMap[doid]['combine_id']
    local combine_data = self.m_lCombineDataList[combine_data_id]
    combine_data:removeDragonObject(doid)
    
    self.m_mSelectDragonMap[doid] = nil
    
    local dragon_card = self.m_tableView:getCellUI(doid)
    if (dragon_card) then
        dragon_card:setCheckSpriteVisible(false)
    end
end

-------------------------------------
-- function click_autoBtn
-- @brief 자동 등록
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_autoBtn()
    -- 로직 돌고 있는 동안 또 돌지 않게 
    if (self.m_bDoingAutoBtn == true) then
        return
    end
    self.m_bDoingAutoBtn = true

    -- 유저가 가진 재화 계산해서 되는 만큼만 넣어줌
    local user_dragon_exp = g_userData:get('dragon_exp')
    local user_gold = g_userData:get('gold')
    local total_need_dragon_exp = 0
    local total_need_gold = 0
    
    local grade = self.m_sortGrade
    local lv = 1
    local max_lv = TableGradeInfo():getValue(grade, 'max_lv')

    local need_gold, need_dragon_exp = TableDragonExp():getGoldAndDragonEXPForDragonLevelUp(grade, lv, max_lv)
    need_gold = need_gold +  TableGradeInfo():getValue(grade, 'req_gold')

    local material_item_list = clone(self.m_tableView.m_itemList)

    local b_is_change = false
    local no_change_reason = 'material'

    -- 1. 유저가 등록한 드래곤이 존재하던 합성 재료부터 채운다.
    for combine_data_id, combine_data in ipairs(self.m_lCombineDataList) do
        -- 이미 다 등록된 경우
        if (combine_data:isFull()) then
            total_need_dragon_exp = total_need_dragon_exp + need_dragon_exp
            total_need_gold = total_need_gold + need_gold

        -- 아직 등록되지 않은 재료 드래곤이 있는 경우에
        elseif (not combine_data:isFull()) and (not combine_data:isEmpty()) then
            for i, v in ipairs(material_item_list) do
                local t_dragon_data = v['data']
                local doid = t_dragon_data['id']
                                
                if (self.m_mSelectDragonMap[doid] == nil) then
                    b_is_change = true

                    -- 합성 정보에 드래곤 정보 등록
                    combine_data:addDragonObject(t_dragon_data)

                    -- self에 드래곤 정보 등록
                    local data = {}
                    data['combine_id'] = combine_data_id
                    data['data'] = t_dragon_data
                    self.m_mSelectDragonMap[doid] = data
                    
                    -- 드래곤 카드에 체크 표시 추가
                    local dragon_card = self.m_tableView:getCellUI(doid)
                    
                    if (dragon_card) then
                        dragon_card:setCheckSpriteVisible(true)
                    end

                    -- 현재 합성 정보 빈 칸 다 채웠는지 확인
                    if (combine_data:isFull() == true) then
                        total_need_dragon_exp = total_need_dragon_exp + need_dragon_exp
                        total_need_gold = total_need_gold + need_gold
                        break
                    end
                end
            end
        end
    end

    -- 2. 유저가 아무것도 등록하지 않았던 합성 재료를 '전부' 채우는 게 가능할 때 채운다
    local check_item_idx = 0

    for combine_data_id, combine_data in ipairs(self.m_lCombineDataList) do
        -- 아직 아무것도 들어서지 않았고, 정보가 더 등록되어도 재화가 여유로운 경우
        if (combine_data:isEmpty()) and ((user_dragon_exp - total_need_dragon_exp) - need_dragon_exp >= 0) and ((user_gold - total_need_gold) - need_gold >= 0) then
            local l_doid_list = {}
            local l_dragon_data_list = {}

            -- 나머지 재료 칸에 선택되지 않은 레벨 1 재료만 차례로 넣는다
            for idx, v in ipairs(material_item_list) do
                if (check_item_idx < idx) then
                    check_item_idx = idx

                    local check_dragon_data = v['data']
                    local doid = check_dragon_data['id']

                    -- 아직 선택되지 않은 드래곤이라면
                    if (self.m_mSelectDragonMap[doid] == nil) then
                        table.insert(l_doid_list, doid)
                        table.insert(l_dragon_data_list, check_dragon_data)

                        -- 다 채우는 게 가능한 경우 합성 재료 등록
                        if (table.count(l_doid_list) == combine_data:getRequireCount()) then
                            b_is_change = true
                            
                            total_need_dragon_exp = total_need_dragon_exp + need_dragon_exp
                            total_need_gold = total_need_gold + need_gold

                            for i, doid in ipairs(l_doid_list) do
                                -- 합성 정보에 드래곤 정보 등록
                                local t_dragon_data = l_dragon_data_list[i]
                                combine_data:addDragonObject(t_dragon_data)

                                -- self에 드래곤 정보 등록
                                local data = {}
                                data['combine_id'] = combine_data_id
                                data['data'] = t_dragon_data
                                self.m_mSelectDragonMap[doid] = data
                    
                                -- 드래곤 카드에 체크 표시 추가
                                local dragon_card = self.m_tableView:getCellUI(doid)
                                if (dragon_card) then
                                    dragon_card:setCheckSpriteVisible(true)
                                end
                            end

                            break
                        end
                    end
                end
            end
        
        elseif ((user_gold - total_need_gold) - need_gold < 0) then
            no_change_reason = 'gold'
        elseif ((user_dragon_exp - total_need_dragon_exp) - need_dragon_exp < 0) then
            no_change_reason = 'dragon_exp'
        end
    end
    
    if (b_is_change) then
        self:refresh()
    elseif (no_change_reason == 'gold') then
        UIManager:toastNotificationRed(Str('골드가 부족합니다'))
    elseif (no_change_reason == 'dragon_exp') then
        UIManager:toastNotificationRed(Str('드래곤 경험치가 부족합니다'))
    elseif (no_change_reason == 'material') then
        UIManager:toastNotificationRed(Str('합성에 필요한 재료가 부족합니다.'))
    end

    -- 마구잡이로 해당 버튼을 누르면 렉을 유발하니까 딜레이를 준다.
    local function reserve_func()
        self.m_bDoingAutoBtn = false
    end

    local node = self.root
    cca.reserveFunc(node, 0.3, reserve_func)
end

-------------------------------------
-- function click_combineBtn
-- @brief 합성 
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_combineBtn()
    
    local grade = self.m_sortGrade
    local need_gold = self.m_needGold
    local need_dragon_exp = self.m_needExp

    do -- 재화 검사
        -- 골드가 충분히 있는지 확인
        if (not ConfirmPrice('gold', need_gold)) then -- 골드가 부족한경우 상점이동 유도 팝업이 뜬다. (ConfirmPrice함수 안에서)
		    --UIManager:toastNotificationRed(Str('골드가 부족합니다'))
	        return
        end

	    -- 경험치가 충분히 있는지 확인
        local dragon_exp = g_userData:get('dragon_exp')
	    if (dragon_exp < need_dragon_exp) then
		    UIManager:toastNotificationRed(Str('드래곤 경험치가 부족합니다'))
		    return
	    end
    end
    
    local l_combine_data_list = {}
    for idx, combine_data in ipairs(self.m_lCombineDataList) do
        if (combine_data:isFull()) then
            table.insert(l_combine_data_list, combine_data)
        end
    end

    if (#l_combine_data_list == 0) then
        UIManager:toastNotificationRed(Str('합성에 필요한 재료가 부족합니다.'))
        return
    end

    local function finish_cb(added_slimes)
        -- 스플레시 터뜨리고 리프레시
        self:refreshWithSplash(added_slimes)
    end

    -- 확인 팝업
    local ui = UI_DragonUpgradeCombineMaterialConfirmPopup(grade, l_combine_data_list, finish_cb)
end

-------------------------------------
-- function click_combineBtn
-- @brief 합성 후 이펙트 및 리프레시 
-------------------------------------
function UI_DragonUpgradeCombineMaterial:refreshWithSplash(added_slimes)
    local vars = self.vars

    -- 슈퍼 슬라임 획득 확인 팝업
    local function obtain_popup_cb()
        local l_item = {}
        local slime_grade = self.m_sortGrade + 1
        local slime_count = #added_slimes
        local slime_item_id = 779104 + 10 * slime_grade 
        table.insert(l_item, {['item_id'] = slime_item_id, ['count'] = slime_count})

        local msg = nil
        local ok_btn_cb = nil
        local is_merge_all_item = false

        UI_ObtainPopup(l_item, msg, ok_btn_cb, is_merge_all_item)
    end

    -- 플래시 연출
    local splash_ui = UI_BlockSplashPopup(obtain_popup_cb)

    -- refresh
    -- 선택된 드래곤 초기화
    self.m_mSelectDragonMap = {}

    self:initTableView()
    self:initCombineTableView()
    self:refresh()

    self.m_bDirty = true
end

-------------------------------------
-- function click_infoBtn
-- @brief 도움말 클릭 
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_infoBtn()
    local vars = self.vars
    
    local str = Str('승급에 필요한 드래곤 1마리를 최대 레벨로 만들기 위한 골드와 경험치가 자동으로 계산됩니다.')
    local tool_tip = UI_Tooltip_Skill(70, -145, str)

    -- 자동 위치 지정
    tool_tip:autoPositioning(vars['infoBtn'])
end

-------------------------------------
-- function click_buyBtn
-- @brief 패키지 클릭 
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_buyBtn()
    local vars = self.vars
    
    local package_name = 'package_super_slime_swarm'
    local is_popup = true
    local package_ui = UI_Package_Bundle(package_name, is_popup)
    local before_slime_count = table.count(g_slimesData:getSlimeList())

    local function close_cb()
        -- 슬라임 갯수가 달라졌다면 refresh
        local after_slime_count = table.count(g_slimesData:getSlimeList())
        if (before_slime_count ~= after_slime_count) then
            self:initTableView()
        end

        self:refresh()
    end

    package_ui:setCloseCB(close_cb)
end


-------------------------------------
-- function click_slimeBtn
-------------------------------------
function UI_DragonUpgradeCombineMaterial:click_slimeBtn()
    self.m_mSelectDragonMap = {}
    self:initCombineTableView()
    self:initTableView()

    self:refresh()
end