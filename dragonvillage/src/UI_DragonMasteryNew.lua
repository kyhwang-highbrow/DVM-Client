local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonMasteryNew
-------------------------------------
UI_DragonMasteryNew = class(PARENT,{
        m_masteryBoardUI = 'UI_DragonMasteryBoardNew',

        -- 재료
        m_selectedMtrl = '',
        m_selectedUI = '',
    })

UI_DragonMasteryNew.TAB_LVUP = 'mastery' -- 특성 레벨업
UI_DragonMasteryNew.TAB_SKILL = 'skill' -- 특성 스킬

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonMasteryNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonMasteryNew'
    self.m_bVisible = true or false
    self.m_titleStr = Str('특성')
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryNew:init(doid)
    local vars = self:load('dragon_mastery_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonMasteryNew')

    self:sceneFadeInAction()

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    self:init_dragonSortMgr()
    
    -- 특성 재료를 우선 순위 배치하는 정렬함수를 PreSortType로 추가
    self.m_mtrlDragonSortManager = SortManager_Dragon()
    self.m_mtrlDragonSortManager:addPreSortType('mastery_material', true, function(a, b, ascending) return self.m_mtrlDragonSortManager:sort_with_material(a, b, ascending) end)
	
    self:init_mtrDragonSortMgr(false)

    -- 선택한 드래곤에 포커싱
    self:focusSelectedDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryNew:initUI()
    local vars = self.vars
    self:init_dragonTableView()
    self:initStatusUI()

    do -- 아모르의 서
        local table_item = TableItem()
        local item_id = ITEM_ID_AMOR
        do -- 아이템 이름
            local name = Str(table_item:getValue(item_id, 't_name'))
            vars['amorNameLabel']:setString(name)
        end

        do -- 아모르의 서 아이콘
            vars['amorItemNode']:removeAllChildren()
            local item_icon = IconHelper:getItemIcon(item_id)
            vars['amorItemNode']:addChild(item_icon)
        end
    end


    -- 특성 보드 생성
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    self.m_masteryBoardUI = UI_DragonMasteryBoardNew(self.vars, dragon_obj)
    self.m_masteryBoardUI:setMasterySkillPlusBtnCB(function(...) self:click_skillEnhanceBtn(...) end)
    
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_DragonMasteryNew:initTab()
    local vars = self.vars
    self:addTabAuto(UI_DragonMasteryNew.TAB_LVUP, vars, vars['masteryLvUpMenu'], vars['masteryLvUpRightMenu'])
    self:addTabAuto(UI_DragonMasteryNew.TAB_SKILL, vars, vars['masterySkillMenu'], vars['masterySkillViewNode'])
    self:setTab(UI_DragonMasteryNew.TAB_SKILL)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_DragonMasteryNew:onChangeTab(tab, first)
    local vars = self.vars
	
	-- 특성 레벨업 탭 진입 시 조건에 충족하면 구매 촉진 팝업
	if (tab == UI_DragonMasteryNew.TAB_LVUP) then
		local amor_cnt = g_userData:get('amor')
		if (amor_cnt < 100) then
			self:showAmorPackagePopup()
            self:setPackageGora(100)
		end
	end
end

-------------------------------------
-- function initStatusUI
-------------------------------------
function UI_DragonMasteryNew:initStatusUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonMasteryNew:initButton()
    local vars = self.vars
    vars['masteryLvUpBtn']:registerScriptTapHandler(function() self:click_masteryLvUpBtn() end)
    vars['amorBtn']:registerScriptTapHandler(function() self:click_amorBtn() end)
    vars['resetBtn']:registerScriptTapHandler(function() self:click_resetBtn() end)

    -- 특성 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'mastery_help')

    -- 만드라고라 버튼
    vars['buyBtn1']:registerScriptTapHandler(function() self:click_promotePackageBtn() end)
    vars['buyBtn1']:setVisible(false)
    vars['buyBtn1']:setLocalZOrder(1)
    cca.pickMePickMe(vars['buyBtn1'], 10)

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryNew:refresh()
    local vars = self.vars
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject

    if (not dragon_obj) then
        return
    end
    
    do -- 재료 중에서 선택된 드래곤 항목들 정리
        if (self.m_selectedMtrl) then
            self.m_selectedMtrl = nil
        end

        if (self.m_selectedUI) then
            self.m_selectedUI:setCheckSpriteVisible(false)
            self.m_selectedUI = nil
        end
    end

    self:refresh_dragonInfo()
    self:refresh_masteryInfo()
    self:refresh_dragonMaterialTableView()
    self:refresh_skillInfo()

    if self.m_masteryBoardUI then
        local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
        self.m_masteryBoardUI:refresh(dragon_obj)
    end

    -- 할인 이벤트
    local only_value = true
    g_hotTimeData:setDiscountEventNode(FEVERTIME_SALE_EVENT.MASTERY_DC, vars, 'masteryEventSprite1', only_value)
    g_hotTimeData:setDiscountEventNode(FEVERTIME_SALE_EVENT.MASTERY_DC, vars, 'masteryEventSprite2', only_value)
end

-------------------------------------
-- function refresh_dragonInfo
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonMasteryNew:refresh_dragonInfo()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars
    local attr = dragon_obj:getAttr()
    local role_type = dragon_obj:getRole()
    local rarity_type = nil
    local t_info = DragonInfoIconHelper.makeInfoParamTable(attr, role_type, rarity_type)

    -- 배경
    local attr = dragon_obj:getAttr()
    if self:checkVarsKey('bgNode', attr) then    
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(dragon_obj:getDragonNameWithEclv())
    end

    do -- 드래곤 속성
        vars['attrNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonAttrBtn(attr, vars['attrNode'], vars['attrLabel'], t_info)
    end

    do -- 드래곤 역할(role)
        vars['typeNode']:removeAllChildren()
        DragonInfoIconHelper.setDragonRoleBtn(role_type, vars['typeNode'], vars['typeLabel'], t_info)
    end

    do -- 드래곤 현재 정보 카드
        vars['dragonIconNode1']:removeAllChildren()
        local dragon_card = UI_DragonCard(dragon_obj)
        vars['dragonIconNode1']:addChild(dragon_card.root)
    end
end

-------------------------------------
-- function refresh_masteryInfo
-- @brief 특성 정보
-------------------------------------
function UI_DragonMasteryNew:refresh_masteryInfo()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    local mastery_level = dragon_obj:getMasteryLevel()
    local mastery_point = dragon_obj:getMasteryPoint()

    local vars = self.vars
    vars['mstrLvUp_masteryLabel']:setString(Str('특성 레벨 {1}', mastery_level))
    vars['mstrLvUp_spLabel']:setString(Str('스킬 포인트: {1}', mastery_point))

    -- 아모르의 서
    local rarity_str = dragon_obj:getRarity()
    local req_count, req_gold = TableMastery:getRequiredAmorQuantity(rarity_str, mastery_level + 1)
    local own_count = g_userData:get('amor') or 0
    local str = Str('{1} / {2}', comma_value(own_count), comma_value(req_count))
    if (req_count <= own_count) then
        str = '{@possible}' .. str
    else
        str = '{@impossible}' .. str
    end
    vars['amorNumberLabel']:setString(str)

    -- 필요 골드
    vars['masteryLvUp_priceLabel']:setString(comma_value(req_gold))

    -- 최대 레벨 확인
    local is_max_level = (mastery_level == 10)
    vars['lockSprite']:setVisible(is_max_level)
    vars['masteryLvUpBtn']:setEnabled(not is_max_level)

    -- 마스터리 할인 피버타임(핫타임) 적용
    if (g_fevertimeData:isActiveFevertime_masteryDc()) then
        vars['masteryEventSprite1']:setVisible(true)
        vars['masteryEventSprite2']:setVisible(true)
        local _, value = g_fevertimeData:isActiveFevertimeByType('mastery_dc')
        local str = Str('{1}% 할인', value * 100)
        vars['masteryEventLabel']:setString(str)
        vars['masteryLvUp_priceLabel']:setString(comma_value(req_gold * value))
    end
end

-------------------------------------
-- function refresh_skillInfo
-- @brief 특성 스킬 정보 (오른쪽 탭)
-------------------------------------
function UI_DragonMasteryNew:refresh_skillInfo(tier, index)
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local mastery_level = dragon_obj:getMasteryLevel()
    local mastery_point = dragon_obj:getMasteryPoint()

    local vars = self.vars
    vars['masteryLabel']:setString(Str('특성 레벨 {1}', mastery_level))
    vars['spLabel']:setString(Str('스킬 포인트: {1}', mastery_point))


    -- 초기화 가능한지 체크
    if MasteryHelper:possibleMasteryReset(dragon_obj) then
        vars['resetBtn']:setEnabled(true)
    else
        vars['resetBtn']:setEnabled(false)
    end    
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-- @override
-------------------------------------
function UI_DragonMasteryNew:getDragonList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 특성 조건이 되지 않는 드래곤 제거 (6성 60레벨)
    for oid, v in pairs(dragon_dic) do
        if (self:isMasteryDragon(v) == false) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function isMasteryDragon
-- @brief 선택된 드래곤이 특성 레벨업 가능한 지 확인
-- @return boolean true면 가능
-------------------------------------
function UI_DragonMasteryNew:isMasteryDragon(dragon_object)
    if (not dragon_object) then
        return false
    end

    -- 드래곤이 아닌 경우
    if (dragon_object:getObjectType() ~= 'dragon') then
        return false
    end

    -- 최대 등급, 최대 레벨이 아닌 경우
    if (dragon_object:isMaxGradeAndLv() == false) then
        return false
    end

    return true
end

-------------------------------------
-- function checkSelectedDragonCondition
-- @brief 선택된 드래곤이 조건이 가능한지 체크
-- @return boolean true면 선택이 가능
-------------------------------------
function UI_DragonMasteryNew:checkSelectedDragonCondition(dragon_object)
    if (not dragon_object) then
        return false
    end

    -- 드래곤이 아닌 경우
    if (dragon_object:getObjectType() ~= 'dragon') then
        local msg = Str('슬라임은 선택할 수 없습니다.')
        UIManager:toastNotificationRed(msg)
        return false
    end

    -- 최대 등급, 최대 레벨이 아닌 경우
    if (dragon_object:isMaxGradeAndLv() == false) then
        local msg = Str('최대 등급, 최대 레벨이 아닙니다.')
        UIManager:toastNotificationRed(msg)
        return false
    end

    return true
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 레벨업
-- @override
-------------------------------------
function UI_DragonMasteryNew:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonsList()

    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid) -- StructDragonObject

    -- 자기 자신 드래곤 제외
    dragon_dic[doid] = nil

    -- 특성 조건이 되지 않는 드래곤 제거 (희귀도, 속성)
    for oid, v in pairs(dragon_dic) do

        -- 희귀도가 다르면 제거
        if (dragon_obj:getRarity() ~= v:getRarity()) then
            dragon_dic[oid] = nil

        -- 속성이 다르면 제거
        elseif (dragon_obj:getAttr() ~= v:getAttr()) then
            dragon_dic[oid] = nil
        end
    end

    -- 속성별 특성 재료
    do
        local material_type = 'mastery_material_' .. dragon_obj:getRarity() .. '_' .. dragon_obj:getAttr()
        local material_id = TableItem:getItemIDFromItemType(material_type)
        local material_cnt = g_userData:getAttrMasteryMaterialCount(material_id) or 0
        
        for i = 1, material_cnt do
            local t_data = {}
            local t_material = {}
            t_material['did'] = 'mastery_material'
            t_material['item_id'] = material_id
            t_material['id'] = 1000 + i -- tableview uniqe id

            dragon_dic[t_material['id']] = t_material
        end
    end

    -- 전속성 특성 재료
    do
        local material_type = 'mastery_material_0' .. (dragon_obj:getBirthGrade() - 1)
        local material_id = TableItem:getItemIDFromItemType(material_type)
        local material_cnt = g_userData:getAttrMasteryMaterialCount(material_id) or 0

       for i = 1, material_cnt do
            local t_data = {}
            local t_material = {}
            t_material['did'] = 'mastery_material'
            t_material['item_id'] = material_id
            t_material['id'] = i -- tableview uniqe id

            dragon_dic[t_material['id']] = t_material
        end  
    end

    return dragon_dic
end

-------------------------------------
-- function click_dragonMaterial
-- @override 재료 클릭 시,
-------------------------------------
function UI_DragonMasteryNew:click_dragonMaterial(data)
    local material_id = data['id']
    
    -- 1.재료로 사용할 수 있는지 확인
    -- 2.선택된 재료가 있는 경우 체크 해제 처리
    -- 3.(사용 전)재료 확인 팝업 (드래곤 정보 팝업/특성 재료 정보 팝업)
    -- 4.체크 or 체크x

    -- 1.재료로 사용할 수 있는지 확인
    if (data['did'] ~= 'mastery_material' and not self:checkMaterialDragonCondition(material_id)) then
        return    
    end

    -- 2.선택된 재료가 있는 경우, 해제 처리
    if self.m_selectedMtrl then
        -- 해제 처리
		self.m_selectedUI:setCheckSpriteVisible(false)
        self.m_selectedUI = nil

        -- 선택한 것을 또 선택 했다면 해제하고 탈출
        if (self.m_selectedMtrl['id'] == data['id']) then
            self.m_selectedMtrl = nil
            return
        end
        self.m_selectedMtrl = nil
	end

	-- 체크 표시 func
    local check_ui = function()
        self.m_selectedMtrl = data
        local list_item = self.m_mtrlTableViewTD:getItem(self.m_selectedMtrl['id'])
        local list_item_ui = list_item['ui']
        self.m_selectedUI = list_item_ui
        list_item_ui:setCheckSpriteVisible(true)
    end

    -- 체크 해제 func
    local un_check_ui = function()
        if self.m_selectedMtrl then
            -- 해제 처리
		    self.m_selectedUI:setCheckSpriteVisible(false)
            self.m_selectedUI = nil
            self.m_selectedMtrl = nil
        end
    end

    -- 특성재료일 경우 해당 특성재료 아이템 아이디로 material_id을 변경
    if (self:isMasteryMaterial(data['did'])) then
        local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
        material_id = data['item_id']
    end

    UI_DragonMasteryConfirmPopup(material_id, check_ui, un_check_ui) -- 드래곤의 경우 오브젝트 아이디/아이템의 경우 아이템 아이디
end

-------------------------------------
-- function checkMaterialDragonCondition
-- @override
-------------------------------------
function UI_DragonMasteryNew:checkMaterialDragonCondition(doid)
    -- 선택된 드래곤이 특성 레벨업이 가능한지
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    local possible, noti_str = g_dragonsData:possibleDragonMasteryLevelUp(dragon_obj['id'])
    
    if (not possible) then
        UIManager:toastNotificationRed(noti_str)
        return false
    end
    
    -- 재료로 사용 가능한 드래곤 검증
    local possible, noti_str = g_dragonsData:possibleMaterialDragon(doid)
    
    if (not possible) then
        UIManager:toastNotificationRed(noti_str)
        return false
    end

    return true
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonMasteryNew:refresh_materialDragonIndivisual(doid)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonMasteryNew:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_stats
-- @brief 능력치
-------------------------------------
function UI_DragonMasteryNew:refresh_stats(t_dragon_data, lv)
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonMasteryNew:createDragonCardCB(ui, data)
end

-------------------------------------
-- function refresh_dragonMaterialTableView
-- @brief 특성 재료 테이블 뷰 갱신
-------------------------------------
function UI_DragonMasteryNew:refresh_dragonMaterialTableView()
    local vars = self.vars   
    local list_table_node = vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end
    
    local function make_func(object)
        if (self:isMasteryMaterial(object['did'])) then
            return UI_ItemCard(object['item_id'], object['item_count'])
        else
            return UI_DragonCard(object)
        end
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(make_func, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 특성 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonMaterialList(self.m_selectDragonOID)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list)

    -- 리스트가 비었을 때
    local msg = Str('도와줄 드래곤이 없다고라') 
    table_view_td:makeDefaultEmptyMandragora(msg)

	self:apply_mtrlDragonSort()
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-------------------------------------
function UI_DragonMasteryNew:createMtrlDragonCardCB(ui, data)
    if (not ui) then
        return
    end

    -- 특성 재료는 모두 재료로 사용 가능
    if (self:isMasteryMaterial(data['did'])) then
        return
    end

    -- 재료 드래곤이 재료 가능한지 판별
    doid = data['id']
    local is_shadow = false
    if (data:getObjectType() == 'dragon') then
        if (not g_dragonsData:possibleMaterialDragon(doid)) then
            is_shadow = true
        else
            is_shadow = false
        end
    
    elseif (data:getObjectType() == 'slime') then
        if (not g_slimesData:possibleMaterialSlime(doid, 'skill')) then
            is_shadow = true
        else
            is_shadow = false
        end
    end
    ui:setShadowSpriteVisible(is_shadow)

    -- 프레스 함수 세팅
    local press_card_cb = function()
        local doid = data['id']
        if doid and (doid ~= '') then
            local ui = UI_SimpleDragonInfoPopup(data)
            local selected_id = self.m_selectedMtrl and self.m_selectedMtrl['id']
			local is_selected = (selected_id == doid)
            ui:setLockPossible(true, is_selected)
            ui:setRefreshFunc(function()
                self:refresh_dragonIndivisual(doid)          -- 하단의 드래곤 tableview
                self:refresh_dragonIndivisual_material(doid) -- 특성 재료 tableview
                
                -- 특성 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
                self.m_bChangeDragonList = true
            end)
        end
    end
        
    ui.vars['clickBtn']:registerScriptPressHandler(press_card_cb)
end

-------------------------------------
-- function click_masteryLvUpBtn
-- @brief 특성 레벨업 버튼
-------------------------------------
function UI_DragonMasteryNew:click_masteryLvUpBtn()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    local rarity_str = dragon_obj:getRarity()
    local mastery_level = dragon_obj:getMasteryLevel()
    local req_amor, req_gold = TableMastery:getRequiredAmorQuantity(rarity_str, mastery_level + 1)

    -- 마스터리 할인 피버타임(핫타임) 적용
    if (g_fevertimeData:isActiveFevertime_masteryDc()) then
        local _, value = g_fevertimeData:isActiveFevertimeByType('mastery_dc')
        req_gold = (req_gold * value) -- 50% 할인일 경우 value는 0.5의 값으로 넘어온다.
    end

    -- 최대 특성 레벨 달성
    if (dragon_obj:getMasteryLevel() >= 10) then
        local msg = Str('이미 최대 특성 레벨을 달성하였습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end
    
    -- 재료 드래곤을 선택하지 않았을 때
    if (not self.m_selectedMtrl) then
        local msg = Str('재료 드래곤을 선택해주세요!')
        UIManager:toastNotificationRed(msg)
        cca.uiImpossibleAction(self.vars['masteryLvUpRightMenu'])
        return
    end

    -- 아모르의 서 수량 확인
    local amor = g_userData:get('amor') or 0
    if (amor < req_amor) then
        local msg = Str('아모르의 서가 부족합니다.')
        UIManager:toastNotificationRed(msg)
        cca.uiImpossibleAction(self.vars['amorBtn'])
        return
    end
    

    -- 골드 충족 여부
    if (not ConfirmPrice('gold', req_gold)) then
        cca.uiImpossibleAction(self.vars['masteryLvUpBtn'])
        return
	end

    local doid = dragon_obj['id']
    local src_doid

    -- 특성재료일 경우, 특성 재료 아이템 아이디를 넣어줌
    if (self:isMasteryMaterial(self.m_selectedMtrl['did'])) then
        src_doid = self.m_selectedMtrl['item_id']
    else
        src_doid = self.m_selectedMtrl['id']
    end

    local function cb_func(ret)
        self:refresh_dragonIndivisual(doid)
        
        -- 결과 팝업
        local ui_result = UI_DragonMasteryLevelUp_Result(self:getSelectDragonObj())
		
		-- 특성 레벨업 이후 조건에 충족하면 구매 촉진 팝업
		ui_result:setCloseCB(function() 
			local amor_cnt = g_userData:get('amor')
			if (amor_cnt < 50) then
				self:showAmorPackagePopup()
                self:setPackageGora(50)
			end
		end)
	end
    
    local function fail_cb()
    end

    self:request_mastery_lvup(doid, src_doid, cb_func, fail_cb)
end

-------------------------------------
-- function click_amorBtn
-- @brief 특성 레벨업 버튼
-------------------------------------
function UI_DragonMasteryNew:click_amorBtn()
    UI_ItemInfoPopup(ITEM_ID_AMOR)
end

-------------------------------------
-- function click_skillEnhanceBtn
-- @brief 특성 스킬 강화
-------------------------------------
function UI_DragonMasteryNew:click_skillEnhanceBtn(tier, num)
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local vars = self.vars

    -- 스킬 포인트가 있는지 확인
    local mastery_point = dragon_obj:getMasteryPoint()
    if (mastery_point <= 0) then
        UIManager:toastNotificationRed(Str('스킬 포인트가 부족합니다.'))
        cca.uiImpossibleAction(vars['masteryTabBtn'])
        return
    end
    
    local ui = UI_DragonMasterySkillLevelUpPopup(dragon_obj, tier, num)

    local function close_cb()
        if ui:isChanged() then
            local doid = dragon_obj['id']
            self:refresh_dragonIndivisual(doid)
            
            -- 특성 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
            self.m_bChangeDragonList = true
        end
    end
    
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function getCurrMasterySkillID
-- @brief
-------------------------------------
function UI_DragonMasteryNew:getCurrMasterySkillID()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local tier, index = self.m_masteryBoardUI:getSelectedTierAndIndex()
    local rarity_str = dragon_obj:getRarity()
    local role_str = dragon_obj:getRole()
    local mastery_skill_id = TableMasterySkill:makeMasterySkillID(rarity_str, role_str, tier, index)

    return mastery_skill_id
end

-------------------------------------
-- function click_resetBtn
-- @brief 특성 초기화 버튼 (망각의 서를 사용하여 특성 스킬을 모두 초기화하고 사용한 스킬 포인트를 돌려받는 기능)
-------------------------------------
function UI_DragonMasteryNew:click_resetBtn()
    local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
    
    if (not dragon_obj) then
        return
    end

    local ui = UI_DragonMasteryResetPopup(dragon_obj)

    local function close_cb()
        if ui:isChanged() then
            local doid = dragon_obj['id']
            self:refresh_dragonIndivisual(doid)
            
            -- 특성 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
            self.m_bChangeDragonList = true
        end
    end
    
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function request_mastery_lvup
-- @brief 특성 레벨업
-------------------------------------
function UI_DragonMasteryNew:request_mastery_lvup(doid, src_doid, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    --[[
    -- 에러코드 처리
    local function response_status_cb(ret)
        return true
    end

    -- 통신실패 처리
    local function response_fail_cb(ret)
    end
    --]]

    local function success_cb(ret)

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)

                -- 드래곤 리스트 갱신
                self.m_tableViewExt:delItem(doid)
            end
        end

		-- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['modified_dragon'])

		-- 재화 갱신
		g_serverData:networkCommonRespone(ret)

        if (self.m_selectedMtrl) then
			self.m_selectedMtrl = nil
		end

        if (self.m_selectedUI) then
            self.m_selectedUI:setCheckSpriteVisible(false)
            self.m_selectedUI = nil
        end

        -- 특성 UI 뒤의 드래곤관리UI를 갱신하도록 한다.
        self.m_bChangeDragonList = true

		if (cb_func) then
			cb_func()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/mastery_lvup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('src_doid', src_doid)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    --ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    --ui_network:setFailCB(response_fail_cb)
    ui_network:request()
end

-------------------------------------
-- function isMasteryMaterial
-------------------------------------
function UI_DragonMasteryNew:isMasteryMaterial(did)
    return did == 'mastery_material'
end

-------------------------------------
-- function refresh_dragonIndivisual_material
-------------------------------------
function UI_DragonMasteryNew:refresh_dragonIndivisual_material(doid)
    local item = self.m_mtrlTableViewTD.m_itemMap[doid]

    local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

    -- 테이블뷰 리스트의 데이터 갱신
    item['data'] = t_dragon_data

    -- UI card 버튼이 있을 경우 데이터 갱신
    if item and item['ui'] then
        local ui = item['ui']
        ui.m_dragonData = t_dragon_data
        ui:refreshDragonInfo()
        self:createMtrlDragonCardCB(ui, t_dragon_data)
    end

    -- 갱신된 드래곤이 선택된 드래곤일 경우
    if (doid == self.m_selectDragonOID) then
        self:setSelectDragonData(doid, true)
    end
end

-------------------------------------
-- function showAmorPackagePopup
-- @brief 아모르의 서 패키지를  유저에게 보여줘서 상품 구매를 유도
-------------------------------------
function UI_DragonMasteryNew:showAmorPackagePopup()
	
	-- 1.아모르의 서 패키지를 구매 가능한가
	do
		local is_buyable = g_shopDataNew:isBuyablePackage({110251})
		if (not is_buyable) then
			return 
		end
	end

    -- 2.쿨타임 7일 지났는지
    do
        local expired_time = g_settingData:getPromoteExpired('package_amor')
        local cur_time = Timer:getServerTime()
        if (cur_time < expired_time) then
            return
        end

        -- 아모르의 서 판매 촉진하는 팝업 쿨타임 7일
        local next_cool_time = cur_time + datetime.dayToSecond(7)
        -- 쿨 타임 만료시간 갱신
        g_settingData:setPromoteCoolTime('package_amor', next_cool_time)
    end

	self:click_promotePackageBtn()
end

-------------------------------------
-- function setPackageGora
-- @brief 아모르의 서 패키지를  유저에게 보여줘서 상품 구매를 유도
-------------------------------------
function UI_DragonMasteryNew:setPackageGora(cnt)
    local vars = self.vars

    local amor_cnt = g_userData:get('amor')
	if (amor_cnt >= cnt) then
        return
    end
    
    local is_buyable = g_shopDataNew:isBuyablePackage({110251})
	if (not is_buyable) then
		return 
	end

    vars['buyBtn1']:setVisible(is_buyable)
end

-------------------------------------
-- function click_promotePackageBtn
-------------------------------------
function UI_DragonMasteryNew:click_promotePackageBtn()
    local ui = UI_Package_Bundle('package_amor', true) -- is_popup

    -- @UI_ACTION(룬 연마 풀팝업 scale 액션)
    ui:doActionReset()
    ui:doAction(nil, false)

	ui:setBuyCB(function() 
		UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOODS_WITH_CLOSE_CB, function()
			self:refresh_masteryInfo()
            self.vars['buyBtn1']:setVisible(false)
            ui:close()		
		end)
	end)
end
















local PARENT = UI

-------------------------------------
-- class UI_DragonMasteryConfirmPopup
-------------------------------------
UI_DragonMasteryConfirmPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryConfirmPopup:init(id, ok_cb, cancel_cb) -- 드래곤의 경우 드래곤 오브젝트 아이디/ 아이템의 경우 아이템 아이디
    local vars = self:load('dragon_mastery_material_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() cancel_cb() self:close() end, 'UI_DragonMasteryConfirmPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(id, ok_cb, cancel_cb)
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryConfirmPopup:initUI(id, ok_cb, cancel_cb)
    local vars = self.vars
    local card_ui = nil
    local item_name = ''

    -- 드래곤/특성 재료 아이템일 경우 아이템 카드/이름 생성
    local dragon_obj = g_dragonsData:getDragonDataFromUid(id)
    if (dragon_obj) then
        card_ui = UI_DragonCard(dragon_obj)
        item_name = TableDragon:getDragonName(dragon_obj:getDid())
    else
        card_ui = UI_ItemCard(id)
        item_name = TableItem:getItemName(id)    
    end
    
    vars['okBtn']:registerScriptTapHandler(function() ok_cb() self:close() end)
    vars['cancelBtn']:registerScriptTapHandler(function() cancel_cb() self:close() end)
    vars['closeBtn']:registerScriptTapHandler(function() cancel_cb() self:close() end)
    vars['itemDscLabel']:setString(item_name)
    if (card_ui) then
        card_ui.root:setScale(0.8)
        vars['iconNode']:addChild(card_ui.root)
    end
end


--@CHECK
UI:checkCompileError(UI_DragonMasteryNew)
