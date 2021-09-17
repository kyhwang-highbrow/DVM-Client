local PARENT = UI_DragonManage_Base


-------------------------------------
-- class UI_DragonGoodbyeSelect
-------------------------------------
UI_DragonGoodbyeSelect = class(PARENT, {
	m_isAutoSelected = 'boolean',
	m_bOptionChanged = 'boolean',

	m_tabList = 'List[string]', -- {'relation', 'mastery', 'exp'}
	m_currTabType = 'string',
	
	m_attributeList = 'List[string]', -- {'fire', 'water', 'earth', 'light', 'dark'}
	m_rarityList = 'List[string]', -- {'legend', 'hero', 'rare', 'common'}

	m_relationList = 'List[did] = sum_of_relation_points', -- 드래곤 최대 인연포인트 계산을 위한 리스트

	m_currFilteredList = 'List[doid] = StructDragonObject', -- 

	m_sellList = 'List[number]', -- doid

	m_selectedNum = 'number',
	m_totalNum = 'number',
})


-------------------------------------
-- function initParentVariable
-- @brief ITopUserInfo_EventListener의 맴버 변수들 설정
-------------------------------------
function UI_DragonGoodbyeSelect:initParentVariable()
    self.m_uiName = 'UI_DragonGoodbyeSelect'
    self.m_bVisible = true
    self.m_titleStr = Str('일괄 작별')
    self.m_bUseExitBtn = true
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelect:init(selectedDragonData)
	local vars = self:load('dragon_goodbye_select_popup_new.ui')

	UIManager:open(self, UIManager.SCENE)

	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelect')

	self:sceneFadeInAction()

	self.m_bOptionChanged = false
	self.m_isAutoSelected = false
	self.m_tabList = {'relation', 'mastery', 'exp'}
	self.m_attributeList = {'fire', 'water', 'earth', 'light', 'dark'}
	self.m_rarityList = {'legend', 'hero', 'rare', 'common'}
	self.m_sellList = {}
	self.m_currFilteredList = {}
	self.m_relationList = {}

    -- 정렬 도우미
	self:init_mtrDragonSortMgr(false) -- slime_first

	self:initUI()
	self:initButton()

	self:click_tabBtn(self.m_tabList[1])

	self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelect:initUI()
	local vars = self.vars

    do -- 배경
        local animator = ResHelper:getUIDragonBG('earth', 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

	self:init_dragonMaterialTableView()
end

-------------------------------------
-- function isContainsInTableview
-------------------------------------
function UI_DragonGoodbyeSelect:isContainsInTableview(struct_dragon)
	-- 잠금 상태인 드래곤 제외
	if struct_dragon:getLock() then
		return false

	-- 리더 드래곤 제외
	elseif struct_dragon:isLeader() then
		return false
		
	-- 스타팅 드래곤인 번고/땅스마트가 5성 이하인 경우 제외 (3성 스타트)
	elseif (struct_dragon:getBirthGrade() > struct_dragon:getGrade()) then
		return false

	-- 신화 드래곤 제외
	elseif (struct_dragon:getRarity() == 'myth') then
		return false

	else
		if (self.m_currTabType == 'exp') then

		elseif (self.m_currTabType == 'relation') then
			local did = struct_dragon:getDid()
			if (not self:checkRelationPoint(did)) then
				return false
			end			
		else--if (self.m_currTabType == 'mastery') then
			if (struct_dragon:getBirthGrade() < 3) then
				return false
			end
	
		end
	end

	local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()
	-- 콜로세움 방어덱 확인
	if struct_user_info then
		local defense_deck = struct_user_info:getDefenseDeck_dragonList(true) -- param : use_doid
		local doid = struct_dragon:getObjectId()
		if table.find(defense_deck, doid) then
			return false
		end
	end

	return true
end

-------------------------------------
-- function getDragonMaterialList
-- brief UI_DragonManage_Base:getDragonMaterialList()
-------------------------------------
function UI_DragonGoodbyeSelect:getDragonMaterialList()
	local dragon_list = g_dragonsData:getDragonsList()

	for doid, struct_dragon in pairs(dragon_list) do
		if (not self:isContainsInTableview(struct_dragon)) then
			dragon_list[doid] = nil
		end
	end

	return self:filterDragonList(dragon_list)
end

-------------------------------------
-- function isFarewellPossible
-------------------------------------
function UI_DragonGoodbyeSelect:isFarewellPossible(struct_dragon)
	local did = struct_dragon:getDid()


	return true
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyeSelect:initButton()
	local vars = self.vars

	for index, key in pairs(self.m_tabList) do
		vars[key .. 'Btn']:registerScriptTapHandler(function() self:click_tabBtn(key) end)
	end
	vars['goodbyeBtn']:registerScriptTapHandler(function() self:click_farewellBtn() end)
	vars['autoSelectBtn']:registerScriptTapHandler(function() self:click_autoSelectBtn() end)
	vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function initFilterButton
-- brief called in UI_DragonGoodbyeSelect:initButton()
-------------------------------------
function UI_DragonGoodbyeSelect:initFilterButton()
    local vars = self.vars

	-- 'farewell', 'selective', 'grade_option'
	-- 'farewell', 'selective', 'attribute_option'
	-- 'farewell', 'selective', 'rarity_option'

	-- local filter_key_list = {'grade', 'attribute', 'rarity'}
	-- local index = 1

	-- local setting_data = g_settingData:get('farewell', 'selective')

	-- while(vars['starBtn' .. index] or vars['attrBtn' .. index] or vars['rarityBtn' .. index]) do

	-- 	for _, key in pairs(filter_key_list) do
	-- 		local button = vars[key .. 'Btn' .. index]
	-- 		if button then
	-- 			local setting_data[key .. '_option']
	-- 		end
	-- 	end

	-- 	index = index + 1
	-- end
	local is_all_checked = true

	local grade_option_list = g_settingData:get('farewell', 'selective', self.m_currTabType, 'grade_option')

    -- 등급 
    for idx = 1, 6 do
		local is_checked = grade_option_list and grade_option_list[idx]
		
		if (is_checked == nil) then
			is_checked = true 
			self.m_bOptionChanged = true
		end

        vars['starBtn'..idx] = UIC_CheckBox(vars['starBtn'..idx].m_node, vars['starSprite'..idx], is_checked)
        vars['starBtn'..idx]:registerScriptTapHandler(function() self:click_filterCheckbox() end)

		if (not is_checked) then is_all_checked = false end
    end

	local attribute_option_list = g_settingData:get('farewell', 'selective', self.m_currTabType, 'attribute_option')

    -- 속성
    for idx = 1, #self.m_attributeList do
		local is_checked = attribute_option_list and attribute_option_list[idx]
		
		if (is_checked == nil) then 
			is_checked = true 
			self.m_bOptionChanged = true
		end

        vars['attrBtn'..idx] = UIC_CheckBox(vars['attrBtn'..idx].m_node, vars['attrSprite'..idx], is_checked)
        vars['attrBtn'..idx]:registerScriptTapHandler(function() self:click_filterCheckbox() end)
		
		if (not is_checked) then is_all_checked = false end
    end

	local rarity_option_list = g_settingData:get('farewell', 'selective', self.m_currTabType, 'rarity_option')

    -- 희귀도
    for idx = 1, #self.m_rarityList do
        local is_checked = rarity_option_list and rarity_option_list[idx]

		if (is_checked == nil) then 
			is_checked = true 
			self.m_bOptionChanged = true
		end

        vars['rarityBtn'..idx] = UIC_CheckBox(vars['rarityBtn'..idx].m_node, vars['raritySprite'..idx], is_checked)
        vars['rarityBtn'..idx]:registerScriptTapHandler(function() self:click_filterCheckbox() end)
		
		if (not is_checked) then is_all_checked = false end
    end


	vars['allCheckBtn'] = UIC_CheckBox(vars['allCheckBtn'].m_node, vars['allCheckSprite'], is_all_checked)
	vars['allCheckBtn']:registerScriptTapHandler(function() self:click_allFilterCheckbox() end)
end

-------------------------------------
-- function filterDragonList
-------------------------------------
function UI_DragonGoodbyeSelect:filterDragonList(dragon_list)
	local vars = self.vars

	-- 등급
	local grade_result = {}

	local index = 1
	local is_grade_all_checked = true
	while(vars['starBtn' .. index]) do
		grade_result[index] = vars['starBtn' .. index]:isChecked()
		is_grade_all = is_grade_all and grade_result[index]

		index = index + 1
	end

	-- 속성
	local attribute_result = {}

	local is_attribute_all_checked = true
	for index, attribute in pairs(self.m_attributeList) do
		attribute_result[attribute] = vars['attrBtn' .. index]:isChecked()
		is_attribute_all_checked = is_attribute_all_checked and attribute_result[attribute]
	end

	-- 희귀도
	local rarity_result = {}
	
	local is_rarity_all_checked = true
	for index, rarity in pairs(self.m_rarityList) do
		rarity_result[rarity] = vars['rarityBtn' .. index]:isChecked()
		is_rarity_all_checked = is_rarity_all_checked and rarity_result[rarity]
	end

	-- 필터 적용
	local table_dragon = TableDragon()
	local result_list = {}

	for doid, struct_dragon in pairs(dragon_list) do
		local did = struct_dragon:getDid()
		local grade = struct_dragon:getGrade()

		local dragon_data = table_dragon:get(did)

		local attribute = dragon_data['attr']
		local rarity = dragon_data['rarity']

		if grade_result[grade] and attribute_result[attribute] and rarity_result[rarity] then
			result_list[doid] = struct_dragon
		end
	end

	return result_list
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelect:refresh()
	local vars = self.vars 

	self.m_sellList = {}
	self.m_isAutoSelected = false

	self.m_currFilteredList = table.MapToList(self:getDragonMaterialList())

	self.m_mtrlDragonSortManager:sortExecution(self.m_currFilteredList)
	self.m_mtrlTableViewTD:setItemList(self.m_currFilteredList, false, 'id')

	self.m_mtrlTableViewTD:relocateContainerDefault(false)
	-- for index, item in pairs(self.m_mtrlTableViewTD.m_itemList) do
	-- 	if item['ui'] then
	-- 		item['ui']:setCheckSpriteVisible(false)
	-- 	end
	-- end

	-- 
	self.m_totalNum = table.count(self.m_currFilteredList)
	self.m_selectedNum = table.count(self.m_sellList)
	vars['selectLabel']:setString(Str('{1}/{2}', self.m_selectedNum, self.m_totalNum))

	vars['infoLabel']:setVisible(self.m_totalNum == 0)
	
end

-------------------------------------
-- function refresh_dragonMaterialTableView
-- brief UI_DragonManage_Base:refresh_dragonMaterialTableView()
-------------------------------------
function UI_DragonGoodbyeSelect:init_dragonMaterialTableView()
	local vars = self.vars
	local tableview_node = vars['materialTableViewNode']
	tableview_node:removeAllChildren()

	local function create_func(ui, data)
		ui.root:setScale(0.54)

		ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(ui, data) end)

		if (not data:isRaisedByUser()) then
			ui:setCheckSpriteVisible(self.m_isAutoSelected)
		end
		
		
		local function press_callback()
			local doid = data['id']
			if doid and (doid ~= '') then
				local ui_popup = UI_SimpleDragonInfoPopup(data)
				ui_popup:setLockPossible(true)
				ui_popup:setBlockRunePopup()

				ui_popup:setCloseCB(function() 
					if ui_popup:isAnyChanges() then
						self:refresh()
					end
				end)
			end
		end
	
		ui.vars['clickBtn']:unregisterScriptPressHandler()
		ui.vars['clickBtn']:registerScriptPressHandler(press_callback)

		-- self:createMtrlDragonCardCB(ui, data)
	end

	-- 
	local tableview = UIC_TableViewTD(tableview_node)
    tableview.m_cellSize = cc.size(86, 86)
    tableview.m_nItemPerCell = 10
    tableview:setCellCreateInterval(0)
	tableview:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    tableview:setCellCreatePerTick(3)
    tableview:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = tableview
end

-------------------------------------
-- function click_tabBtn
-------------------------------------
function UI_DragonGoodbyeSelect:click_tabBtn(tab_type)
	local vars = self.vars

	if (self.m_currTabType == tab_type) then
		return
	end
	

	if (self.m_currTabType) then
	-- 이전 탭 버튼 활성화
		vars[self.m_currTabType .. 'Btn']:setEnabled(true)
		vars[self.m_currTabType .. 'Label']:setColor(COLOR['white'])
	end
	
	self:saveOptions()

	self.m_currTabType = tab_type

	-- 현재 탭 버튼 비활성화
	vars[self.m_currTabType .. 'Btn']:setEnabled(false)
	vars[self.m_currTabType .. 'Label']:setColor(COLOR['black'])

	self:initFilterButton()

	self:refresh()
end


-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_DragonGoodbyeSelect:click_infoBtn()
	require('UI_DragonGoodbyeSelectInfoPopup')
	local type = self.m_currTabType
	UI_DragonGoodbyeSelectInfoPopup(type)
end


-------------------------------------
-- function click_filterCheckbox
-------------------------------------
function UI_DragonGoodbyeSelect:click_filterCheckbox()
	local vars = self.vars 

	self.m_bOptionChanged = true

	local is_all_checked = true

    -- 등급 
    for idx = 1, 6 do
        if (not vars['starBtn'..idx]:isChecked()) then
			is_all_checked = false
		end
    end

    -- 속성
    for idx = 1, #self.m_attributeList do
        if (not vars['attrBtn'..idx]:isChecked()) then
			is_all_checked = false
		end
    end

    -- 희귀도
    for idx = 1, #self.m_rarityList do
        if (not vars['rarityBtn'..idx]:isChecked()) then
			is_all_checked = false
		end
    end

	vars['allCheckBtn']:setChecked(is_all_checked)

	self:refresh()
end

-------------------------------------
-- function click_allFilterCheckbox
-------------------------------------
function UI_DragonGoodbyeSelect:click_allFilterCheckbox()
	local vars = self.vars 

	local is_checked = vars['allCheckBtn']:isChecked()

    -- 등급 
    for idx = 1, 5 do
        vars['starBtn'..idx]:setChecked(is_checked)
    end

    -- 속성
    for idx = 1, #self.m_attributeList do
        vars['attrBtn'..idx]:setChecked(is_checked)
    end

    -- 희귀도
    for idx = 1, #self.m_rarityList do
        vars['rarityBtn'..idx]:setChecked(is_checked)
    end

	self.m_bOptionChanged = true

	self:refresh()
end

function UI_DragonGoodbyeSelect:checkRelationPoint(did)
	if (self.m_currTabType == 'relation') then
		local curr_relation = g_bookData:getBookData(did):getRelation()
		local target_relation_point = TableDragon:getRelationPoint(did)
		local max_relation_point = TableDragonReinforce:getTotalExp()

		if (self.m_relationList[did] == nil) then
			self.m_relationList[did] = 0
		end

		local sum = curr_relation + self.m_relationList[did] + target_relation_point

		if (max_relation_point < sum) then
			return false
		end
	end

	return true	
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_DragonGoodbyeSelect:click_dragonCard(ui, data)
	local doid = data:getObjectId()
	local did = data:getDid()
	-- 해당 드래곤이 이미 선택된 경우 true
	local is_checked = (self.m_sellList[doid] ~= nil)

	local function click_callback()
		-- 드래곤이 선택되지 않은 상태이고 인연포인트가 초과하는 경우, 경고 출력
		if (not is_checked) and (not self:checkRelationPoint(did)) then
			UIManager:toastNotificationRed(Str('인연포인트 보유 한도를 초과해 선택할 수 없습니다.'))
			return
		end

		-- 선택되어 있는 경우
		if is_checked then
			-- 판매 목록에서 제거 및 선택된 드래곤 숫자 갱신
			self.m_sellList[doid] = nil
			self.m_selectedNum = self.m_selectedNum - 1

		-- 선택 되어 있지 않은 경우
		else
			-- 판매 목록에 추가 및 선택된 드래곤 숫자 갱신
			self.m_sellList[doid] = data
			self.m_selectedNum = self.m_selectedNum + 1
		end

		if (self.m_currTabType == 'relation') then
			local target_relation_point = TableDragon:getRelationPoint(did)
			if is_checked then	
				local relation_point = self.m_relationList[did] - target_relation_point
				if (relation_point >= 0) then
					self.m_relationList[did] = relation_point
				end
			else
				self.m_relationList[did] = self.m_relationList[did] + target_relation_point
			end
		end
		
		self.vars['selectLabel']:setString(Str('{1}/{2}', self.m_selectedNum, self.m_totalNum))

		if (self.m_selectedNum == 0) then
			self.m_isAutoSelected = false
		end

		ui:setCheckSpriteVisible(not is_checked)
	end

	-- 드래곤이 선택되지 않은 상태이고 육성중인 드래곤인 경우, 경고 출력
	if (not is_checked) and data:isRaisedByUser() then
		MakeSimplePopup2(POPUP_TYPE.YES_NO, Str('육성 중인 드래곤입니다.'), Str('작별 하시겠습니까?'), function() click_callback() end)
		return
	end

	click_callback()
end

-------------------------------------
-- function click_autoSelectBtn
-------------------------------------
function UI_DragonGoodbyeSelect:click_autoSelectBtn()
	self.m_sellList = {}
	self.m_relationList = {}
	self.m_isAutoSelected = (not self.m_isAutoSelected)

	for index, item in pairs(self.m_mtrlTableViewTD.m_itemList) do
		local did = item['data']:getDid()

		if (not item['data']:isRaisedByUser()) and self:checkRelationPoint(did) then
			if item['ui'] then
				item['ui']:setCheckSpriteVisible(self.m_isAutoSelected)
			end
			
			local target_relation_point = TableDragon:getRelationPoint(did)

			if self.m_isAutoSelected then
				self.m_sellList[item['unique_id']] = item['data']
			end

			if (self.m_currTabType == 'relation') then
				if self.m_isAutoSelected then
					self.m_relationList[did] = self.m_relationList[did] + target_relation_point
				else
					local relation_point = self.m_relationList[did] - target_relation_point
					if (relation_point >= 0) then
						self.m_relationList[did] = relation_point
					end
				end
			end
		else
			if item['ui'] then
				item['ui']:setCheckSpriteVisible(false)
			end
		end
	end

	self.m_totalNum = table.count(self.m_currFilteredList)
	self.m_selectedNum = table.count(self.m_sellList)
	self.vars['selectLabel']:setString(Str('{1}/{2}', self.m_selectedNum, self.m_totalNum))
end

-------------------------------------
-- function click_farewellBtn
-------------------------------------
function UI_DragonGoodbyeSelect:click_farewellBtn()
	-- 갯수 체크
	local sell_cnt = table.count(self.m_sellList)
	if (sell_cnt <= 0) then
		UIManager:toastNotificationGreen(Str('재료 드래곤을 선택해주세요!'))
		return
	end

	local is_four_grade_included = false
	local is_five_grade_included = false
	local doid_list = ''

	for doid, dragon_data in pairs(self.m_sellList) do
		local grade = dragon_data['grade']

		if (grade == 4) then 
			is_four_grade_included = true
		elseif (grade == 5) then
			is_five_grade_included = true
		end

		if (doid_list == '') then
			doid_list = tostring(doid)
		else
			doid_list = doid_list .. ',' .. tostring(doid)
		end
	end
	
	local function farewell_callback()
		local uid = g_userData:get('uid')
		local target = self.m_currTabType

		local function success_callback(ret)
			self:refresh()
			self.m_bChangeDragonList = true

			if ret['items_list'] then
				-- params : l_item, msg, ok_btn_cb, is_merge_all_item)
				UI_ObtainPopup(ret['items_list'], nil, nil, true)
			end
		end

		g_dragonsData:request_goodbye(target, doid_list, success_callback)
	end

	local function confirm_callback()
		require('UI_DragonGoodbyeSelectConfirmPopup')
		local item_list, msg = self:getExpectItemsAndMsg()

		UI_DragonGoodbyeSelectConfirmPopup(item_list, msg, function() farewell_callback() end)
	end

	local str 
	if is_four_grade_included and is_five_grade_included then
		str = Str('4, 5성')
	elseif is_four_grade_included then
		str = Str('4성')
	elseif is_five_grade_included then
		str = Str('5성')
	end

	if is_four_grade_included or is_five_grade_included then
		MakeSimplePopup2(POPUP_TYPE.YES_NO, str .. Str('드래곤이 포함되어 있습니다.'),
		 '작별하시겠습니까?', function() confirm_callback() end)
		return
	end

	confirm_callback()
end

-------------------------------------
-- function onClose
-- @brief ITopUserInfo_EventListener:onClose()
-------------------------------------
function UI_DragonGoodbyeSelect:onClose()
	self:saveOptions()

	PARENT.onClose(self)
end

-------------------------------------
-- function saveOptions
-------------------------------------
function UI_DragonGoodbyeSelect:saveOptions()
	if self.m_bOptionChanged then
		local vars = self.vars
		
		-- 등급
		local option_list = {}
		local index = 1
		while(vars['starBtn' .. index]) do
			option_list[index] = vars['starBtn' .. index]:isChecked()

			index = index + 1
		end

		g_settingData:applySettingData(option_list, 'farewell', 'selective', self.m_currTabType, 'grade_option')

		-- 속성
		option_list = {}

		for index, _ in pairs(self.m_attributeList) do
			option_list[index] = vars['attrBtn' .. index]:isChecked()
		end

		g_settingData:applySettingData(option_list, 'farewell', 'selective', self.m_currTabType, 'attribute_option')

		-- 희귀도
		option_list = {}
		
		for index, rarity in pairs(self.m_rarityList) do
			option_list[index] = vars['rarityBtn' .. index]:isChecked()
		end

		g_settingData:applySettingData(option_list, 'farewell', 'selective', self.m_currTabType, 'rarity_option')
	end
end

-------------------------------------
-- function getExpectItemsAndMsg
-- @brief 현재 선택된 드래곤들을 변환한 아이템 리스트
-------------------------------------
function UI_DragonGoodbyeSelect:getExpectItemsAndMsg()
	local item_list = {}
	local msg

	local selected_dragon_num = table.count(self.m_sellList)

	if (self.m_currTabType == 'exp') then
		local exp_table = TableDragonExp()
		local total_exp = 0

		for doid, struct_dragon in pairs(self.m_sellList) do
			local exp = exp_table:getDragonGivingExp(struct_dragon:getGrade(), struct_dragon:getLv(), false)
			total_exp = total_exp + exp
		end
		
		table.insert(item_list, {
			['item_id'] = 700017,
			['count'] = total_exp
		})
		msg = Str('{1} 마리의 드래곤이 드래곤 경험치로 변경됩니다.', selected_dragon_num)
	elseif (self.m_currTabType == 'relation') then
		local temp = {}
		local dragon_table = TableDragon()
		for doid, dragon_struct in pairs(self.m_sellList) do
			local did = dragon_struct:getDid()
			local item_id = 760000 + (did % 10000) -- 인연포인트
			
			if (not temp[item_id]) then temp[item_id] = 0 end

			temp[item_id] = temp[item_id] + dragon_table:getRelationPoint(did)
		end

		for item_id, relation_points in pairs(temp) do
			table.insert(item_list, {
				['item_id'] = item_id,
				['count'] = relation_points
			})
		end
		msg = Str('{1} 마리의 드래곤이 인연포인트로 변경됩니다.', selected_dragon_num)
	else--if (self.m_currTabType == 'mastery') then
		local temp = {}
		local item_table = TableItem()
		local dragon_table = TableDragon()

		for doid, dragon_struct in pairs(self.m_sellList) do
			local did = dragon_struct:getDid()
			local attr = dragon_table:getValue(did, 'attr')
			local rarity = dragon_table:getValue(did, 'rarity')

			local mastery_name = 'mastery_material_' .. rarity .. '_' .. attr
			local item_id = item_table:getItemIDFromItemType(mastery_name)

			if (not temp[item_id]) then temp[item_id] = 0 end

			temp[item_id] = temp[item_id] + 1
		end

		for item_id, mastery_num in pairs(temp) do
			table.insert(item_list, {
				['item_id'] = item_id,
				['count'] = mastery_num
			})
		end
		msg = Str('{1} 마리의 드래곤이 특성 재료로 변경됩니다.', selected_dragon_num)
	end
	
	return item_list, msg
end