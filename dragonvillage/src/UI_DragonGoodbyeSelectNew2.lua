local PARENT = UI_DragonManage_Base
local MAX_SELL_CNT = 100

-------------------------------------
-- class UI_DragonGoodbyeSelectNew2
-- @brief 이미 UI_DragonGoodbyeSelectNew가 존재해서
-- 일단 2 붙임. 나중에 수정할 것
-------------------------------------
UI_DragonGoodbyeSelectNew2 = class(PARENT,{
        m_selectType = 'string',
        m_tSellTable = 'list',

		m_expSum = 'number', 
        m_tRelationSum = 'table', -- 현재까지 선택된 인연포인트 합 저장(드래곤 선택 가능한지 판단할 때 사용)

        m_bselectAllBtn = 'boolean',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonGoodbyeSelectNew2:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonGoodbyeSelectNew2'
    self.m_bVisible = true
    self.m_titleStr = Str('')
    self.m_bUseExitBtn = true
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyeSelectNew2:init()
    local vars = self:load('dragon_goodbye_select_popup_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyeSelectNew2')

    self:sceneFadeInAction()
	
	self.m_tSellTable = {}
	self.m_expSum = 0
    self.m_tRelationSum = {}
    
    -- 정렬 도우미
	self:init_mtrDragonSortMgr(false) -- slime_first

    self:initUI()
    self:initButton()
    self:refresh()

    self:click_typeBtn('relation')

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGoodbyeSelectNew2:initUI()
	local vars = self.vars

	self:init_bg()
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonGoodbyeSelectNew2:initButton()
    local vars = self.vars

    vars['relationBtn']:registerScriptTapHandler(function() self:click_typeBtn('relation') end)
    vars['masteryBtn']:registerScriptTapHandler(function() self:click_typeBtn('mastery') end)
    vars['expBtn']:registerScriptTapHandler(function() self:click_typeBtn('exp') end)

    vars['goodbyeSellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
    vars['goodbyeBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)

    vars['autoSelectBtn']:registerScriptTapHandler(function() self:click_selectAllBtn() end)

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyeSelectNew2:refresh()
    self:refresh_selectedMaterial()
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function init_bg
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonGoodbyeSelectNew2:init_bg()
    local vars = self.vars

    -- 배경
    local animator = ResHelper:getUIDragonBG('earth', 'idle')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function refresh_dragonMaterialTableView
-- @brief 재료 테이블 뷰 갱신
-- @override
-------------------------------------
function UI_DragonGoodbyeSelectNew2:refresh_dragonMaterialTableView()   
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonMaterial(data) end)

		self:createMtrlDragonCardCB(ui, data)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(102, 102)
    table_view_td.m_nItemPerCell = 10
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    self.m_mtrlTableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('판매할 드래곤이 없어요.'))

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonMaterialList()

    
    l_dragon_list = table.MapToList(l_dragon_list)
    
    
    self.m_mtrlDragonSortManager:sortExecution(l_dragon_list)
    self.m_mtrlTableViewTD:setItemList(l_dragon_list, true, 'id')

    --self:apply_mtrlDragonSort()
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 판매 - 잠금/ 리더 제외한 모두
-- @override
-------------------------------------
function UI_DragonGoodbyeSelectNew2:getDragonMaterialList()
    local dragon_dic = g_dragonsData:getDragonsList()

    -- 재료로 사용 불가능한 드래곤 제외
    for oid,v in pairs(dragon_dic) do
        if (self.m_selectType == 'exp') then
            if (not g_dragonsData:possibleMaterialDragon(oid)) then
                dragon_dic[oid] = nil
            end
        elseif (self.m_selectType == 'relation') then 
            if (not g_dragonsData:possibleGoodbye(oid)) then
                dragon_dic[oid] = nil
            end
        elseif (self.m_selectType == 'mastery' ) then
            if (not g_dragonsData:possibleConversion(oid)) then
                dragon_dic[oid] = nil
            end
        end
    end

    -- 슬라임은 작별의 대상이 아님. 코드 참고용을 위해 남겨둠.
	-- 슬라임 추가
    --[[
	local slime_dic = g_slimesData:getSlimeList()
	for oid, v in pairs(slime_dic) do
        if (not v['lock']) then
		    dragon_dic[oid] = v
        end
	end
    --]]

    return dragon_dic
end

-------------------------------------
-- function createMtrlDragonCardCB
-- @brief 재료 카드 만든 후..
-- @override
-------------------------------------
function UI_DragonGoodbyeSelectNew2:createMtrlDragonCardCB(ui, data)
    -- nothing to do
end


-------------------------------------
-- function click_selectAllBtn
-- @brief 
-------------------------------------
function UI_DragonGoodbyeSelectNew2:click_selectAllBtn()
    local is_skipped_warning_popup = self:checkSkipWarningPopup()

    if (not is_skipped_warning_popup) and (not self.m_bselectAllBtn) then 
        local ui = MakeSimplePopup2(POPUP_TYPE.YES_NO, '4성 이하 모든 드래곤', '작별하시겠습니까?', function() self:test_func() end)

        if ui then
            ui:setCheckBoxCallback(function() g_settingData:setSkipInfoForFarewellWarningPopup(curr_date) end)
        end

        return
    end


    self:test_func()
end

-------------------------------------
-- function click_selectAllBtn
-- @brief 
-------------------------------------
function UI_DragonGoodbyeSelectNew2:test_func()
    local vars = self.vars

    self.m_bselectAllBtn = (not self.m_bselectAllBtn)
    -- 다시 초기화
	self.m_expSum = 0
    self.m_tRelationSum = {}
	self.m_tSellTable = {}
	self:refresh_dragonMaterialTableView()
    self:refresh_selectedMaterial()

    if self.m_bselectAllBtn then
        vars['selectAllLabel']:setString(Str('선택 해제'))
    else
        vars['selectAllLabel']:setString(Str('자동 선택'))
        return
    end

    local dragon_exp_table = TableDragonExp()

     -- 재료로 사용 가능한 리스트를 얻어옴
     local item_list = self.m_mtrlTableViewTD.m_itemList
     local dragon_list = self:getDragonMaterialList()

     for oid, item in pairs(item_list) do
        local data = item['data']
        local sell_count = table.count(self.m_tSellTable)
        
        -- 최대 100마리
        if (sell_count >= MAX_SELL_CNT) then 
            break
        end

        local doid = data['id']
        local grade = data['grade']
        local is_rune_empty = (#data:getRuneObjectList() < 1)

        if (grade < 5) and is_rune_empty then
            local level = data['lv']
            local is_myth_dragon = (data:getRarity() == 'myth')
            local exp = dragon_exp_table:getDragonGivingExp(grade, level, is_myth_dragon)
            
            local is_possible = false

            if (self.m_selectType == 'exp') then -- 경험치
                self.m_expSum = self.m_expSum + exp
                is_possible = true

            elseif (self.m_selectType == 'relation') then -- 인연포인트
                local relation_table = self.m_tRelationSum
                local did = data['did']

                if (relation_table[did] == nil) then
                    relation_table[did] = 0
                end

                local curr_relation = g_bookData:getBookData(did):getRelation()
                local add_relation_count = TableDragon:getRelationPoint(did)
                local sum = curr_relation + relation_table[did] + add_relation_count -- 기존 인연포인트 + 현재 선택되있던 인연포인트 + 새로 선택하는 인연포인트
                local max_relation = TableDragonReinforce:getTotalExp()

                if (sum <= max_relation) then -- 인연포인트 한도 체크
                    relation_table[did] = relation_table[did] + add_relation_count
                    is_possible = true
                end
            else -- 특성 재료
                is_possible = true
            end

            if is_possible then
                self.m_tSellTable[doid] = data

                -- 갱신
                self:refresh_materialDragonIndivisual(doid)
                self:refresh_selectedMaterial()
            end
        end
     end
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonGoodbyeSelectNew2:click_dragonMaterial(t_dragon_data)
    local function next_func()
        local doid = t_dragon_data['id']

	    -- 가격 처리 및 테이블리스트 갱신
        local dragon_exp_table = TableDragonExp()
		local grade = t_dragon_data['grade']
		local lv = t_dragon_data['lv']
        local is_myth_dragon = t_dragon_data:getRarity() == 'myth'
        local dragon_exp = dragon_exp_table:getDragonGivingExp(grade, lv, is_myth_dragon)	

		--local price = TableDragonExp():getDragonSellGold(t_dragon_data['grade'], t_dragon_data['lv'])
        local price = dragon_exp

		-- 제외
		if (self.m_tSellTable[doid]) then
			self.m_tSellTable[doid] = nil

            if (self.m_selectType == 'exp') then
			    self.m_expSum = self.m_expSum - price

            elseif (self.m_selectType == 'relation') then
                local relation_table = self.m_tRelationSum
                local did = t_dragon_data['did']
			    local relation_count = TableDragon:getRelationPoint(did)

                relation_table[did] = relation_table[did] - relation_count
            end
		
		-- 추가
		else
			-- 갯수 체크
			local sell_cnt = table.count(self.m_tSellTable)
			if (sell_cnt >= MAX_SELL_CNT) then
				UIManager:toastNotificationRed(Str('한 번에 최대 {1}마리까지 가능합니다.', MAX_SELL_CNT))
				return
			end
			
            if (self.m_selectType == 'exp') then
                self.m_expSum = self.m_expSum + price

            elseif (self.m_selectType == 'relation') then
                local relation_table = self.m_tRelationSum
                local did = t_dragon_data['did']
                
                if (relation_table[did] == nil) then
                    relation_table[did] = 0
                end

                local curr_relation = g_bookData:getBookData(did):getRelation()
			    local add_relation_count = TableDragon:getRelationPoint(did)
                local sum = curr_relation + relation_table[did] + add_relation_count -- 기존 인연포인트 + 현재 선택되있던 인연포인트 + 새로 선택하는 인연포인트
                local max_relation = TableDragonReinforce:getTotalExp()

                if (sum > max_relation) then -- 인연포인트 한도 초과
                    UIManager:toastNotificationRed(Str('인연포인트 보유 한도를 초과해 선택할 수 없습니다.'))
                    return
                else 
                    relation_table[did] = relation_table[did] + add_relation_count
                end
            end

            self.m_tSellTable[doid] = t_dragon_data
		end

        -- 갱신
        self:refresh_materialDragonIndivisual(doid)
        self:refresh_selectedMaterial()
    end
	

    local doid = t_dragon_data['id']
    
    if (not self.m_tSellTable[doid]) then
        -- 재료 경고
        local oid = t_dragon_data['id']
        local t_warning = {}
        t_warning['pass_comb'] = true -- 조합 재료는 skip

        -- 오늘 하루 보지 않기 기능이 활성화 되어있는지
        local is_skipped_warning_popup, curr_date = self:checkSkipWarningPopup()
        -- 5성 드래곤보다 등급이 낮은지
        local is_grade_under_five = (t_dragon_data:getGrade() < 5)
        -- 장착하고 있는 룬이 있는지
        local is_rune_empty = (#t_dragon_data:getRuneObjectList() < 1)

        -- 위에 boolean 세가지 중 하나라도 해당 되지 않는 것이 있으면 경고 팝업을 띄운다.
        if (not (is_skipped_warning_popup and is_grade_under_five and is_rune_empty)) then
            local ui_popup = g_dragonsData:dragonMaterialWarning(oid, next_func, t_warning, '작별하시겠습니까?') -- param : oid, next_func, t_warning, warning_msg

            -- dragonMaterialWarning에서 UI_SimplePopup2 팝업을 띄우지 않거나, 
            -- 5성 드래곤이상의 드래곤 혹은 장착하고 있는 룬이 있는 경우에 스킵 체크박스를 보여주지 않는다.
            if ui_popup and is_grade_under_five and is_rune_empty then
                ui_popup:setCheckBoxCallback(function() g_settingData:setSkipInfoForFarewellWarningPopup(curr_date) end)
            end

            -- 팝업을 띄우는 경우에는 리턴, 띄우는 않는 경우에는 다음 스텝을 진행한다.
            return    
        end
    end
    
    -- 해제할 경우
    next_func()
end

-------------------------------------
-- function checkSkipWarningPopup
-- brief 선택 작별 팝업에서 오늘 하루 보지 않기 기능이 활성화 되어 있는지 확인 (00시 기준)
-- return boolean 오늘 하루 보지 않기 기능이 활성화 되어있으면 true 아니면 false
-------------------------------------
function UI_DragonGoodbyeSelectNew2:checkSkipWarningPopup()
    local skip_date = g_settingData:getSkipInfoForFarewellWarningPopup()

    local curr_time_info = os.date('*t', Timer:getServerTime())
    local curr_date = string.format('%d%02d%02d', curr_time_info['year'], curr_time_info['month'], curr_time_info['day'])

    -- 팝업 띄움
    return (skip_date == curr_date), curr_date
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonGoodbyeSelectNew2:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
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

	local is_select = self.m_tSellTable[doid] and true or false
    ui:setCheckSpriteVisible(is_select)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonGoodbyeSelectNew2:refresh_selectedMaterial()
	local vars = self.vars

	-- 판매 갯수
	local sell_cnt = table.count(self.m_tSellTable)
	vars['selectLabel']:setString(string.format('%d / %d', sell_cnt, MAX_SELL_CNT))

	-- 가격
    if (self.m_selectType == 'exp') then
        vars['priceLabel']:setString(comma_value(self.m_expSum))
    end
end


-------------------------------------
-- function click_typeBtn
-- @brief
-------------------------------------
function UI_DragonGoodbyeSelectNew2:click_typeBtn(type)
    local vars = self.vars

    if (self.m_selectType == type) then
        return
    end

     -- 이전에 눌려있던 버튼 끄기
	if (self.m_selectType ~= nil) then
        local past_btn_name = self.m_selectType .. 'Btn'
        local past_label_name = self.m_selectType .. 'Label'
        vars[past_btn_name]:setEnabled(true)
		vars[past_label_name]:setColor(COLOR['white'])
	end

    self.m_selectType = type;
    local curr_btn_name = self.m_selectType .. 'Btn'
    local curr_label_name = self.m_selectType .. 'Label'
	vars[curr_btn_name]:setEnabled(false) -- 버튼 누르기
	vars[curr_label_name]:setColor(COLOR['black'])
    

    -- 다시 초기화
    self.m_bselectAllBtn = false

	self.m_expSum = 0
    self.m_tRelationSum = {}
	self.m_tSellTable = {}
	self:refresh_dragonMaterialTableView()
    self:refresh_selectedMaterial()

    local show_exp_sell_btn = (type == 'exp')
    vars['goodbyeBtn']:setVisible(not show_exp_sell_btn)
    vars['goodbyeSellBtn']:setVisible(show_exp_sell_btn)
end

-------------------------------------
-- function click_sellBtn
-- @brief
-------------------------------------
function UI_DragonGoodbyeSelectNew2:click_sellBtn()
    -- 갯수 체크
	local sell_cnt = table.count(self.m_tSellTable)
	if (sell_cnt <= 0) then
		UIManager:toastNotificationGreen(Str('재료 드래곤을 선택해주세요!'))
		return
	end

	local function ok_btn_cb()
		self:request_goodbye()
	end

    require('UI_DragonGoodbyeSelectConfirmPopup')
	local item_list = self:makeItemList()
	local msg = Str(self:getGoodbyeMsg(), sell_cnt)
	local function ok_btn_cb()
		self:request_goodbye()
	end
	local ui = UI_DragonGoodbyeSelectConfirmPopup(item_list, msg, ok_btn_cb)
end

-------------------------------------
-- function click_infoBtn
-- @brief
-------------------------------------
function UI_DragonGoodbyeSelectNew2:click_infoBtn()
    require('UI_DragonGoodbyeSelectInfoPopup')
    local type = self.m_selectType
	local ui = UI_DragonGoodbyeSelectInfoPopup(type)
end

-------------------------------------
-- function getGoodbyeMsg
-- @brief 드래곤 작별시키기
-------------------------------------
function UI_DragonGoodbyeSelectNew2:getGoodbyeMsg()
	if (self.m_selectType == 'exp') then
		return '{1} 마리의 드래곤이 드래곤 경험치로 변경됩니다.'
	elseif (self.m_selectType == 'relation') then
		return '{1} 마리의 드래곤이 인연포인트로 변경됩니다.'
	elseif (self.m_selectType == 'mastery') then
		return '{1} 마리의 드래곤이 특성 재료로 변경됩니다.'
	else 
		return '{1}' -- error
	end
end

-------------------------------------
-- function makeItemList
-- @brief 현재 선택된 드래곤들을 변환한 아이템 리스트
-------------------------------------
function UI_DragonGoodbyeSelectNew2:makeItemList()
	local item_list = {}
	if (self.m_selectType == 'exp') then
		local dragon_exp_item = {}
		dragon_exp_item['item_id'] = 700017 -- 경험치 아이템 코드
		dragon_exp_item['count'] = self.m_expSum 		
				
		table.insert(item_list, dragon_exp_item)

	elseif (self.m_selectType == 'relation') then
		local temp_table = {}
		for oid, v in pairs(self.m_tSellTable) do
			local did = v['did']
			local item_id = 760000 + (did % 10000) -- 인연포인트 코드
			local count = TableDragon:getRelationPoint(did)
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

	elseif (self.m_selectType == 'mastery') then
		local temp_table = {}
		local item_table = TableItem()
		for oid, v in pairs(self.m_tSellTable) do
			local did = v['did']
			local attr = TableDragon:getValue(did, 'attr')
			local rarity = TableDragon:getValue(did, 'rarity')
			
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
function UI_DragonGoodbyeSelectNew2:request_goodbye()
	local uid = g_userData:get('uid')
	local target = self.m_selectType

	local doids = ''

    for oid, t_dragon_data in pairs(self.m_tSellTable) do
		if (t_dragon_data.m_objectType == 'dragon') then
			if (doids == '') then
                doids = tostring(oid)
            else
                doids = doids .. ',' .. tostring(oid)
            end

        -- 슬라임은 작별의 대상이 아님. 코드 참고용을 위해 남겨둠.
		elseif (t_dragon_data.m_objectType == 'slime') then
			if (soids == '') then
                soids = tostring(oid)
            else
                soids = soids .. ',' .. tostring(oid)
            end

		end
	end

	local function success_cb(ret)
        -- 다시 초기화
		self.m_expSum = 0
		self.m_tRelationSum = {}
        self.m_tSellTable = {}
		self:refresh_dragonMaterialTableView()
        self:refresh_selectedMaterial()

		-- 외부에 변화 여부 전달
		self.m_bChangeDragonList = true

        local l_result_item_list = ret['items_list']
        if l_result_item_list then
            UI_ObtainPopup(l_result_item_list, nil, nil, true) -- params : l_item, msg, ok_btn_cb, is_merge_all_item)
        end
    end
	
    g_dragonsData:request_goodbye(target, doids, success_cb)
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyeSelectNew2)
