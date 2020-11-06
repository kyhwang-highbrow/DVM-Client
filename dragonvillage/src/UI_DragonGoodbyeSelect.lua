local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonGoodbyeBatch
-------------------------------------

PRESENT_TYPE = {}
PRESENT_TYPE.EXP = 1
PRESENT_TYPE.RELATION = 2
PRESENT_TYPE.MASTERY = 3

UI_DragonGoodbyeSelect = class(PARENT,{
		m_tableView = 'UIC_TableViewTD', -- 드래곤 정렬 리스트뷰
		m_sortManagerDragon = "SortManager_Dragon", -- 드래곤 정렬 매니저
		m_tFilterDragonList = 'table',
		m_selectPresentType = 'PRESENT_TYPE', -- 작별로 받을 아이템 종류
		m_bOptionChanged = 'boolean', -- 옵션이 바뀌었는지

		m_bChangeDragonList = 'boolean' -- 드래곤 변동사항이 있는지
	})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonGoodbyeSelect:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonGoodbyeSelect'
    self.m_bVisible = true
    self.m_titleStr = Str('일괄 작별')
    self.m_bUseExitBtn = true
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelect:init(doid)
    local vars = self:load('goodbye_select_popup_01.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelect')

    self:sceneFadeInAction()
		
	self.m_bOptionChanged = false
	self.m_bChangeDragonList = false

    self:initUI()
    self:initButton()
	self:initTableView()

	self:changePresentType(PRESENT_TYPE.EXP)

    -- 정렬 도우미
	--self:init_mtrDragonSortMgr(false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelect:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DragonGoodbyeSelect:initTableView()
	local vars = self.vars

	local node = self.vars['listViewNode']

    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        -- 새로 획득한 드래곤 뱃지
        local is_new_dragon = data:isNewDragon()
        ui:setNewSpriteVisible(is_new_dragon)

        ui.root:setScale(0.74)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(116, 116)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    self.m_tableView = table_view_td

    -- 리스트를 얻어옴
    local l_dragon_list = self:getFilterDragonList()
    self.m_tableView:setItemList(l_dragon_list)

	local sort_manager = SortManager_Dragon()
    sort_manager:pushSortOrder('grade')
    sort_manager:pushSortOrder('lv')
    sort_manager:pushSortOrder('rarity')
   
    self.m_sortManagerDragon = sort_manager
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonGoodbyeSelect:initButton()
    local vars = self.vars

	vars['expBtn']:registerScriptTapHandler(function() self:changePresentType(PRESENT_TYPE.EXP) end)
	vars['relationshipBtn']:registerScriptTapHandler(function() self:changePresentType(PRESENT_TYPE.RELATION) end)
	vars['masteryBtn']:registerScriptTapHandler(function() self:changePresentType(PRESENT_TYPE.MASTERY) end)

    vars['goodbyeBtn']:registerScriptTapHandler(function() self:click_goodbyeBtn() end)
	vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)

	-- 전체 선택
	vars['allCheckBtn'] = UIC_CheckBox(vars['allCheckBtn'].m_node, vars['allCheckSprite'], false)
	vars['allCheckBtn']:registerScriptTapHandler(function() self:click_allCheckBtn() end)

	-- 등급 
    for idx = 1, 6 do
        local active = g_settingData:get('option_dragon_select', 'grade_'..idx)
        vars['starBtn'..idx] = UIC_CheckBox(vars['starBtn'..idx].m_node, vars['starSprite'..idx], active)
        vars['starBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end
    -- 속성
    for idx = 1, 5 do
        local active = g_settingData:get('option_dragon_select', 'attr_'..idx)
        vars['attrBtn'..idx] = UIC_CheckBox(vars['attrBtn'..idx].m_node, vars['attrSprite'..idx], active)
        vars['attrBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end
    -- 희귀도
    for idx = 1, 4 do
        local active = g_settingData:get('option_dragon_select', 'rarity_'..idx)
        vars['rarityBtn'..idx] = UIC_CheckBox(vars['rarityBtn'..idx].m_node, vars['raritySprite'..idx], active)
        vars['rarityBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end
    -- 역할
    for idx = 1, 4 do
        local active = g_settingData:get('option_dragon_select', 'type_'..idx)
        vars['typeBtn'..idx] = UIC_CheckBox(vars['typeBtn'..idx].m_node, vars['typeSprite'..idx], active)
        vars['typeBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end
end

-------------------------------------
-- function click_allCheckBtn
-- @brief 전체 선택, 전체 해제 토글
-------------------------------------
function UI_DragonGoodbyeSelect:click_allCheckBtn()
	local vars = self.vars
	local is_active = vars['allCheckBtn']:isChecked()

	-- 등급 
    for idx = 1, 6 do
        vars['starBtn'..idx]:setChecked(is_active)
    end
    -- 속성
    for idx = 1, 5 do
        vars['attrBtn'..idx]:setChecked(is_active)
    end
    -- 희귀도
    for idx = 1, 4 do
        vars['rarityBtn'..idx]:setChecked(is_active)
    end
    -- 역할
    for idx = 1, 4 do
        vars['typeBtn'..idx]:setChecked(is_active)
    end

	self:refresh()
end

-------------------------------------
-- function changePresentType
-- @brief 작별 선물 타입 변경
-- @param type = {exp, relation, mastery} 중 1개
-------------------------------------
function UI_DragonGoodbyeSelect:changePresentType(type)
	local vars = self.vars

	if type == nil then -- 방어적 프로그래밍
		return
	end
	
	-- 변경할 필요 없는 경우
	if self.m_selectPresentType == type then
		return
	end
	
	-- 변경하는 경우
	if self.m_selectPresentType ~= nil then
		self:getTypeBtn(self.m_selectPresentType):setEnabled(true) -- 이전에 눌려있던 버튼 끄기
	end
	self:getTypeBtn(type):setEnabled(false) -- 버튼 누르기
	
	self.m_selectPresentType = type

	-- 드래곤 리스트 가져와서 정렬하기
	self:refresh()
end

function UI_DragonGoodbyeSelect:getTypeBtn(type)
	local vars = self.vars
	if type == PRESENT_TYPE.EXP then
		return vars['expBtn']
	elseif type == PRESENT_TYPE.RELATION then
		return vars['relationshipBtn']
	elseif type == PRESENT_TYPE.MASTERY then
		return vars['masteryBtn']
	end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelect:refresh()
	local vars = self.vars
	
	-- 리스트를 얻어옴
	local l_all_dragon_list = g_dragonsData:getDragonsList() 
    local l_filter_dragon_list = self:getFilterDragonList()
    self.m_tableView:setItemList(l_filter_dragon_list)
	self.m_sortManagerDragon:sortExecution(self.m_tableView.m_itemList)

	-- 필터링된 드래곤 숫자 표시
	local len_all = table.count(l_all_dragon_list)
	local len_filter = table.count(l_filter_dragon_list)
	vars['countLabel']:setString(Str('{1}/{2}', len_filter, len_all))

	-- 드래곤이 없을 시 라벨 표시
	if len_filter == 0 then
		vars['listViewLabel']:setVisible(true)
	else
		vars['listViewLabel']:setVisible(false)
	end

	self.m_tFilterDragonList = l_filter_dragon_list
end

-------------------------------------
-- function getFilterDragonList
-- @ breif 필터, 선물 타입에 추가로
-- 대표 드래곤, 잠금 드래곤 제외 
-------------------------------------
function UI_DragonGoodbyeSelect:getFilterDragonList()
    local vars = self.vars

    local l_dragon = g_dragonsData:getDragonsList()
    local l_ret_list = {}
    -- 등급
    local l_stars = {}
	local b_all_stars = true
    for index = 1, 6 do
		l_stars[index] = vars['starBtn' .. index]:isChecked()
		if (l_stars[index]) then
			b_all_stars = false
		end
	end
	
    -- 속성
    local l_attr = {}
	local b_all_attr = false
    l_attr['fire'] = vars['attrBtn1']:isChecked()
    l_attr['water'] = vars['attrBtn2']:isChecked()
    l_attr['earth'] = vars['attrBtn3']:isChecked()
    l_attr['light'] = vars['attrBtn4']:isChecked()
    l_attr['dark'] = vars['attrBtn5']:isChecked()
	if ((not l_attr['fire']) and (not l_attr['water']) and (not l_attr['earth']) and (not l_attr['light']) and (not l_attr['dark'])) then
		b_all_attr = true
	end
    -- 희귀도
    local l_rarity = {}
	local b_all_rarity = false
    l_rarity['legend'] = vars['rarityBtn1']:isChecked()
    l_rarity['hero'] = vars['rarityBtn2']:isChecked()
    l_rarity['rare'] = vars['rarityBtn3']:isChecked()
    l_rarity['common'] = vars['rarityBtn4']:isChecked()
	if ((not  l_rarity['legend']) and (not l_rarity['hero']) and (not l_rarity['rare']) and (not l_rarity['common'])) then
		b_all_rarity = true
	end
    -- 역할
    local l_role = {}
	local b_all_role = false
    l_role['tanker'] = vars['typeBtn1']:isChecked()
    l_role['dealer'] = vars['typeBtn2']:isChecked()
    l_role['supporter'] = vars['typeBtn3']:isChecked()
    l_role['healer'] = vars['typeBtn4']:isChecked()
	if ((not l_role['tanker']) and (not l_role['dealer']) and (not l_role['supporter']) and (not l_role['healer'])) then
		b_all_role = true
	end

    local table_dragon = TableDragon()
    for oid,v in pairs(l_dragon) do
        local did = v['did']
        local grade = v['grade']
        local attr = table_dragon:getValue(did, 'attr')
        local rarity = table_dragon:getValue(did, 'rarity')
        local role = table_dragon:getValue(did, 'role')

        if ((l_stars[grade] or b_all_stars) and (l_attr[attr] or b_all_attr) and 
		(l_role[role] or b_all_role) and (l_rarity[rarity] or b_all_rarity)) then
			if self:checkGoodbyeAvailable(oid) then
				l_ret_list[oid] = v
			end
        end
    end

    return l_ret_list
end

-------------------------------------
-- function checkGoodbyeAvailable
-- @brief 현재 선택한 선물 타입으로
-- 바꿀 수 있는 드래곤인지 검사
-- @return 바꿀 수 있을 때 true 반환
-------------------------------------
function UI_DragonGoodbyeSelect:checkGoodbyeAvailable(oid)
	-- exp 일 땐 잠금이나 리더만 확인
	if (self.m_selectPresentType == PRESENT_TYPE.EXP) and (g_dragonsData:possibleMaterialDragon(oid)) then 
		return true
	elseif (self.m_selectPresentType == PRESENT_TYPE.RELATION) and (g_dragonsData:possibleGoodbye(oid)) then
		return true
	elseif (self.m_selectPresentType == PRESENT_TYPE.MASTERY) and (g_dragonsData:possibleConversion(oid)) then
		return true
	else
		return false
	end
end

-------------------------------------
-- function click_goodbyeBtn
-- @brief 드래곤 작별시키기
-------------------------------------
function UI_DragonGoodbyeSelect:click_goodbyeBtn()
	local len_dragon_list = table.count(self.m_tFilterDragonList)
	
	if (len_dragon_list == 0) then -- 0마리인 경우 무시
		UIManager:toastNotificationRed('조건에 해당하는 드래곤이 없습니다.')
		return
	end
		
	require('UI_DragonGoodbyeSelectPopup')
	local item_list = self:makeItemList()
	local msg = Str(self:getGoodbyeMsg(), len_dragon_list)
	local function ok_btn_cb()
		self:request_goodbye()
	end
	local ui = UI_DragonGoodbyeSelectPopup(item_list, msg, ok_btn_cb)
end

function UI_DragonGoodbyeSelect:getGoodbyeMsg()
	if (self.m_selectPresentType == PRESENT_TYPE.EXP) then
		return '{1} 마리의 드래곤이 드래곤 경험치로 변경됩니다.'
	elseif (self.m_selectPresentType == PRESENT_TYPE.RELATION) then
		return '{1} 마리의 드래곤이 인연포인트로 변경됩니다.'
	elseif (self.m_selectPresentType == PRESENT_TYPE.MASTERY) then
		return '{1} 마리의 드래곤이 특성 재료로 변경됩니다.'
	else 
		return '{1}' -- error
	end
end

-------------------------------------
-- function makeItemList
-- @brief 현재 선택된 드래곤들을 변환한 아이템 리스트
-------------------------------------
function UI_DragonGoodbyeSelect:makeItemList()
	local item_list = {}
	if (self.m_selectPresentType == PRESENT_TYPE.EXP) then
		local sum = 0
		local dragon_exp_table = TableDragonExp()
		for oid, v in pairs(self.m_tFilterDragonList) do -- 드래곤 경험치 합 구하기
			local grade = v['grade']
			local lv = v['lv']
			sum = sum + dragon_exp_table:getDragonGivingExp(grade, lv)	
		end
		
		local dragon_exp_item = {}
		dragon_exp_item['item_id'] = 700017 -- 경험치 아이템 코드
		dragon_exp_item['count'] = sum 		
				
		table.insert(item_list, dragon_exp_item)

	elseif (self.m_selectPresentType == PRESENT_TYPE.RELATION) then
		local temp_table = {}
		local dragon_table = TableDragon()
		for oid, v in pairs(self.m_tFilterDragonList) do
			local did = v['did']
			local item_id = 760000 + (did % 10000) -- 인연포인트 코드
			local count = dragon_table:getRelationPoint(did)
			if (not temp_table[item_id]) then
				temp_table[item_id] = 0
			end
			temp_table[item_id] = temp_table[item_id] + count
		end

		for k, v in pairs(temp_table) do
			local item = {}
			item['item_id'] = k
			item['count'] = v
			table.insert(item_list, item)
		end

	elseif (self.m_selectPresentType == PRESENT_TYPE.MASTERY) then
		local temp_table = {}
		local dragon_table = TableDragon()
		local item_table = TableItem()
		for oid, v in pairs(self.m_tFilterDragonList) do
			local did = v['did']
			local attr = dragon_table:getValue(did, 'attr')
			local rarity = dragon_table:getValue(did, 'rarity')
			
			local material_name = 'mastery_material_' .. rarity  .. '_' .. attr
			local item_id = item_table:getItemIDFromItemType(material_name) -- 특성 재료 아이디
			
			if (not temp_table[item_id]) then
				temp_table[item_id] = 0
			end
			temp_table[item_id] = temp_table[item_id] + 1
		end

		for k, v in pairs(temp_table) do
			local item = {}
			item['item_id'] = k
			item['count'] = v
			table.insert(item_list, item)
		end

	end
	
	return item_list
end

-------------------------------------
-- function request_goodbye
-------------------------------------
function UI_DragonGoodbyeSelect:request_goodbye()
	local uid = g_userData:get('uid')
	local target = self:getTypeStr()

	local doids = ''

	for oid, _ in pairs(self.m_tFilterDragonList) do
		if (doids == '') then
            doids = tostring(oid)
        else
            doids = doids .. ',' .. tostring(oid)
        end
	end

	local function success_cb(ret)
        -- @analytics TODO
        -- Analytics:trackUseGoodsWithRet(ret, '드래곤 작별?')

		self:response_goodbye(ret)
    end
	
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/goodbye_new')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
	ui_network:setParam('target', target)
	ui_network:hideLoading()
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
	ui_network:request()
end

-------------------------------------
-- function response_goodbye
-------------------------------------
function UI_DragonGoodbyeSelect:response_goodbye(ret)
	-- 인연포인트 (전체 갱신)
	if (ret['relation']) then
		g_bookData:applyRelationPoints(ret['relation'])
	end

	-- 작별한 드래곤 삭제
	if ret['deleted_dragons_oid'] then
		for _, doid in pairs(ret['deleted_dragons_oid']) do
			g_dragonsData:delDragonData(doid)
		end
	end

    g_serverData:networkCommonRespone(ret)

	-- 획득 팝업
	UI_ObtainPopup(ret['items_list'], nil, nil, true)

	self.m_bChangeDragonList = true

	self:refresh()
end

-------------------------------------
-- function click_checkBox
-- @brief 현재 선택된 타입을 문자열로 바꿈
-------------------------------------
function UI_DragonGoodbyeSelect:getTypeStr()
	if self.m_selectPresentType == PRESENT_TYPE.EXP then
		return 'exp'
	elseif self.m_selectPresentType == PRESENT_TYPE.RELATION then
		return 'relation'
	elseif self.m_selectPresentType == PRESENT_TYPE.MASTERY then
		return 'mastery'
	else
		return nil
	end
end

-------------------------------------
-- function click_checkBox
-------------------------------------
function UI_DragonGoodbyeSelect:click_checkBox()
    self.m_bOptionChanged = true
    self:refresh()
end

-------------------------------------
-- function onClose
-- @brief 닫을 떄 만약 필터 옵션 변경했다면 저장
-------------------------------------
function UI_DragonGoodbyeSelect:onClose()
	if (self.m_bOptionChanged == true) then
		local vars = self.vars

		g_settingData:lockSaveData()
		-- 등급 
		for idx = 1, 6 do
			g_settingData:applySettingData(vars['starBtn'..idx]:isChecked(), 'option_dragon_select', 'grade_'..idx)
		end
		-- 속성
		for idx = 1, 5 do
			g_settingData:applySettingData(vars['attrBtn'..idx]:isChecked(), 'option_dragon_select', 'attr_'..idx)
		end
		-- 희귀도
		for idx = 1, 4 do
			g_settingData:applySettingData(vars['rarityBtn'..idx]:isChecked(), 'option_dragon_select', 'rarity_'..idx)
		end
		-- 역할
		for idx = 1, 4 do
			g_settingData:applySettingData(vars['typeBtn'..idx]:isChecked(), 'option_dragon_select', 'type_'..idx)
		end
		g_settingData:unlockSaveData()
		self.m_bOptionChanged = false
	end

	PARENT.onClose(self)
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelect)
