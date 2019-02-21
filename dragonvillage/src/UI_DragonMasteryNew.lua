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
	
    self:init_mtrDragonSortMgr(false) -- slime_first

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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryNew:refresh()
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
        local attr = dragon_obj:getAttr()
        vars['attrNode']:removeAllChildren()
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode']:addChild(icon)
    end

    do -- 드래곤 역할(role)
        local role_type = dragon_obj:getRole()
        vars['typeLabel']:setString(dragonRoleTypeName(role_type))
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
        if (self:checkSelectedDragonCondition(v) == false) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
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
        return false
    end

    -- 최대 등급, 최대 레벨이 아닌 경우
    if (dragon_object:isMaxGradeAndLv() == false) then
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

    local material_name = 'mastery_material_0' .. (dragon_obj:getBirthGrade() - 1) -- 해당 희귀도의 특성재료 
    local mastery_material_cnt = g_userData:get(material_name)
    local material_id = TableItem:getItemIDFromItemType(material_name)

    do
        -- 특성 재료 보유 갯수 만큼 리스트에 추가
        for i = 1, mastery_material_cnt do
            local t_data = {}
            local t_material = {}
            t_material['did'] = 999 -- 드래곤과 구별을 위해 임의로 특성재료 did를 999로 설정
            t_material['item_id'] = material_id
            t_material['idx'] = i
            dragon_dic['mastery_material' .. i] = t_material
        end        
    end

    return dragon_dic
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonMasteryNew:click_dragonMaterial(data)
    local doid = data['id']

    if (data['did'] ~= 999) then
        doid = data['id']
        -- 선택된 드래곤이 특성 레벨업이 가능한지
        local dragon_obj = self:getSelectDragonObj() -- StructDragonObject
        local possible, noti_str = g_dragonsData:possibleDragonMasteryLevelUp(dragon_obj['id'])
        if (not possible) then
            UIManager:toastNotificationRed(noti_str)
            return
        end

        -- 재료로 사용 가능한 드래곤 검증
        local possible, noti_str = g_dragonsData:possibleMaterialDragon(doid)
        if (not possible) then
            UIManager:toastNotificationRed(noti_str)
            return
        end
    else
        doid = data['idx'] -- 드래곤은 id/ 특성 재료의 경우 idx를 고유하게 가짐
    end

    local function set_ui()
        if (data['did'] ~= 999) then
		    -- 재료 경고
            g_dragonsData:dragonMaterialWarning(doid, function()
		    	if (self.m_selectedUI) then
		    		self.m_selectedUI:setCheckSpriteVisible(false)
		    	end

                local list_item = self.m_mtrlTableViewTD:getItem(data['id'])
                local list_item_ui = list_item['ui']
		    	self.m_selectedMtrl = data['id']
		    	self.m_selectedUI = list_item_ui
		    	list_item_ui:setCheckSpriteVisible(true)
                
		    end)
        else
            self.m_selectedMtrl = data['idx'] -- 드래곤은 id/ 특성 재료의 경우 idx를 고유하게 가짐
            local list_item = self.m_mtrlTableViewTD:getItem('mastery_material' .. data['idx'])
            local list_item_ui = list_item['ui']
            self.m_selectedUI = list_item_ui
            list_item_ui:setCheckSpriteVisible(true)
        end
    end


    -- 선택된 재료가 있는 경우, 해제 처리
    if self.m_selectedMtrl then
        -- 해제 처리
		self.m_selectedUI:setCheckSpriteVisible(false)
        self.m_selectedMtrl = nil
        self.m_selectedUI = nil
	end
		
    -- 클릭한 UI, 선택 처리    
    set_ui()
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
-- function UI_DragonMasteryNew
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
        if (object['did'] == 999) then
            return UI_ItemCard(object['item_id'])
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
    if (data['did'] == 999) then
        return
    end

    -- 재료 드래곤이 재료 가능한지 판별
    doid = data['id']
    if (data:getObjectType() == 'dragon') then
        if (not g_dragonsData:possibleMaterialDragon(doid)) then
            ui:setShadowSpriteVisible(true)
            return
        end
    
    elseif (data:getObjectType() == 'slime') then
        if (not g_slimesData:possibleMaterialSlime(doid, 'skill')) then
            ui:setShadowSpriteVisible(true)
            return
        end
    end
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
    local src_doid = self.m_selectedMtrl

    local function cb_func(ret)
        self:refresh_dragonIndivisual(doid)
        
        -- 결과 팝업
        UI_DragonMasteryLevelUp_Result(self:getSelectDragonObj())
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


--@CHECK
UI:checkCompileError(UI_DragonMasteryNew)
