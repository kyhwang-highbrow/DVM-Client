local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyePopup
-------------------------------------
UI_DragonGoodbyePopup = class(PARENT,{
		m_dragonOid = 'string',
		m_tDragonData = 'table',
        m_msg = 'string',
		m_okBtn_cb = 'function',

		m_bIsMythDragon = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyePopup:init(dragon_oid, dragon_data, msg, okBtn_cb)
    self.m_dragonOid = dragon_oid
	self.m_tDragonData = dragon_data
	self.m_bIsMythDragon = (dragon_data:getRarity() == 'myth')
	self.m_msg = msg
	self.m_okBtn_cb = okBtn_cb

    self.m_uiName = 'UI_DragonGoodbyePopup'
    local vars = self:load('goodbye_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyePopup')

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
function UI_DragonGoodbyePopup:initUI()
	local vars = self.vars

	local msg = self.m_msg
	vars['infoLabel']:setString(msg)

	-- 각 아이템 세팅
	local dragon_exp_table = TableDragonExp()
	local dragon_table = TableDragon()
	local item_table = TableItem()
	local dragon_data = self.m_tDragonData
	local oid = self.m_dragonOid
	local did = dragon_data['did']
	local grade = dragon_data['grade']
	local lv = dragon_data['lv']
	local attr = dragon_table:getValue(did, 'attr')
	local rarity = dragon_table:getValue(did, 'rarity')

	-- 인연 포인트
	do
        if (g_dragonsData:possibleGoodbye(oid)) and (not self.m_bIsMythDragon) then -- 인연포인트로 변경 가능할 때
		    local item_id = 760000 + (did % 10000) -- 인연포인트 코드
		    local count = dragon_table:getRelationPoint(did)
	
		    local relation_item = {}
		    relation_item['item_id'] = item_id
		    relation_item['count'] = count 		

		    local ui = UI_ItemCard(relation_item['item_id'], relation_item['count'])
            ui:setEnabledClickBtn(false)
		    vars['itemNode1']:addChild(ui.root)
	    else
		    vars['checkBtn1']:setVisible(false)
		    vars['checkBtn1']:setEnabled(false)
	    end
    end
	-- 특성 재료
    do
	    if (g_dragonsData:possibleConversion(oid)) then -- 특성 재료로 변경 가능할 때
		    local material_name = 'mastery_material_' .. rarity  .. '_' .. attr
		    local item_id = item_table:getItemIDFromItemType(material_name) -- 특성 재료 아이디
		    local count = 1

		    local material_item = {}
		    material_item['item_id'] = item_id
		    material_item['count'] = count 		
	
		    local ui = UI_ItemCard(material_item['item_id'], material_item['count'])
            ui:setEnabledClickBtn(false)
		    vars['itemNode2']:addChild(ui.root)
		elseif (self.m_bIsMythDragon) then

	    else
		    vars['checkBtn2']:setVisible(false)
		    vars['checkBtn2']:setEnabled(false)
	    end
    end
	-- 경험치 아이템
	do
		if (not self.m_bIsMythDragon) then
			local exp = dragon_exp_table:getDragonGivingExp(grade, lv, self.m_bIsMythDragon)	

			local dragon_exp_item = {}
			dragon_exp_item['item_id'] = 700017 -- 드래곤 경험치 아이템 코드
			dragon_exp_item['count'] = exp 	
			
			local ui = UI_ItemCard(dragon_exp_item['item_id'], dragon_exp_item['count'])
			ui:setEnabledClickBtn(false)
			vars['itemNode3']:addChild(ui.root)
		else
		    vars['checkBtn3']:setVisible(false)
		    vars['checkBtn3']:setEnabled(false)
		end
	end		
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGoodbyePopup:initButton()
    local vars = self.vars

	local enable_button_count = 0
	for idx = 1, 3 do
		vars['checkBtn'..idx] = UIC_CheckBox(vars['checkBtn'..idx].m_node, vars['checkSprite'..idx], false)
		if (vars['checkBtn'..idx]:isEnabled()) then
			vars['checkBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox(idx) end)
			enable_button_count = enable_button_count + 1
		end
	end

	-- 켜져 있는 버튼들에 대해 정렬하기
	-- 경험치 버튼은 어떤 드래곤이든 존재하지만
	-- 인연 포인트랑 특성 재료는 없을 수 있음
    local interval = vars['checkBtn1']:getParent():getPositionX() - vars['checkBtn2']:getParent():getPositionX() -- 각 버튼의 간격은 ui 설정에 따름
	local l_pos = getSortPosList(interval, enable_button_count)
	local l_pos_count = 1
	for idx = 1, 3 do
		if (vars['checkBtn'..idx]:isEnabled()) then
			vars['checkBtn'..idx]:getParent():setPositionX(l_pos[l_pos_count]) -- 체크 버튼의 부모인 메뉴 노드를 옮김
			l_pos_count = l_pos_count + 1
		end
	end

    vars['goodbyeBtn']:registerScriptTapHandler(function() self:click_goodbyeBtn() end)
	vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGoodbyePopup:refresh()
    self:refresh_info()
end

-------------------------------------
-- function click_checkBox
-------------------------------------
function UI_DragonGoodbyePopup:click_checkBox(idx)
	local vars = self.vars

    if (vars['checkBtn' .. idx]:isChecked()) then
        for i = 1, 3 do -- 무언가 선택하면 나머지는 꺼짐
		    if (i == idx) then
			    vars['checkBtn' .. idx]:setChecked(true)
		    else
			    vars['checkBtn' .. i]:setChecked(false)
		    end
	    end
    end

    self:refresh_info()
end

-------------------------------------
-- function refresh_info
-------------------------------------
function UI_DragonGoodbyePopup:refresh_info()
    local vars = self.vars

    local item_id = nil
    local item_name = ''
    local item_desc = ''

    local dragon_table = TableDragon()
    local item_table = TableItem()
    local dragon_data = self.m_tDragonData
	local did = dragon_data['did']
	local attr = dragon_table:getValue(did, 'attr')
	local rarity = dragon_table:getValue(did, 'rarity') 

	if (vars['checkBtn1']:isChecked()) then
	    item_id = 760000 + (did % 10000) -- 인연포인트 코드
    elseif (vars['checkBtn2']:isChecked()) then
        local material_name = 'mastery_material_' .. rarity  .. '_' .. attr
		item_id = item_table:getItemIDFromItemType(material_name) -- 특성 재료 아이디
	elseif (vars['checkBtn3']:isChecked()) then
        item_id = 700017 -- 드래곤 경험치 아이템 코드
    end
    
    vars['itemNameLabel']:setVisible(false)
    vars['itemInfoLabel']:setVisible(false)
    vars['selectInfoLabel']:setVisible(false)
    
    if (item_id ~= nil) then
        item_name = item_table:getItemName(item_id)
        item_desc = item_table:getValue(item_id, 't_desc')
        vars['itemNameLabel']:setString(Str(item_name))
        vars['itemInfoLabel']:setString(Str(item_desc))
        vars['itemNameLabel']:setVisible(true)
        vars['itemInfoLabel']:setVisible(true)
        

        local l_ui_list = {vars['itemNameLabel'], vars['itemInfoLabel']}
        AlignUIPos(l_ui_list, 'VERTICAL', 'CENTER', 10) -- ui list, direction, align, offset
        -- self:alignInfoText()

    else
        vars['selectInfoLabel']:setVisible(true)
    end
end

-------------------------------------
-- function refresh_info
-- @brief 아이템 설명이 몇 줄인지에 따라
-- 적절한 아이템 제목 위치 설정
-------------------------------------
function UI_DragonGoodbyePopup:alignInfoText()
    local vars = self.vars

    if (vars['itemNameLabel'] == nil) then
        return
    end

    if (vars['itemInfoLabel'] == nil) then
        return
    end

    local interval_y = 7
    
    -- 아이템 제목 높이 계산
    local item_name_height = 0
    do
        local string_height = vars['itemNameLabel']:getStringHeight()
        local scale_y = vars['itemNameLabel']:getScaleY()
        item_name_height = (string_height * scale_y)
    end

    -- 아이템 설명 높이 계산
    local item_info_height = 0
    local item_info_y = 0
    do
        local string_height = vars['itemInfoLabel']:getStringHeight()
        local scale_y = vars['itemInfoLabel']:getScaleY()
        item_info_height = (string_height * scale_y)
        item_info_y = vars['itemInfoLabel']:getPositionY()
    end

    -- node 위치 조정
    vars['itemNameLabel']:setPositionY(item_info_y + interval_y + (item_info_height/2) + (item_name_height / 2))
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonGoodbyePopup:click_goodbyeBtn()
	local vars = self.vars
	local target = nil
	
	if (vars['checkBtn1']:isChecked()) then
		target = 'relation'		
	elseif (vars['checkBtn2']:isChecked()) then
		if (not self.m_bIsMythDragon) then
			target = 'mastery'
		else
			target = 'test'
		end
	elseif (vars['checkBtn3']:isChecked()) then
		target = 'exp'  
	end

	if (target == nil) then
		UIManager:toastNotificationRed(Str('선택된 아이템이 없습니다.'))	
		return
	end

	self:request_goodbye(target)
end

-------------------------------------
-- function request_goodbye
-------------------------------------
function UI_DragonGoodbyePopup:request_goodbye(target)
	local uid = g_userData:get('uid')
	local oid = self.m_dragonOid
	local doids = tostring(oid)

	local function success_cb(ret)
		self:response_goodbye(ret)
    end
	
    g_dragonsData:request_goodbye(target, doids, success_cb)

    self:close()
end

-------------------------------------
-- function response_goodbye
-------------------------------------
function UI_DragonGoodbyePopup:response_goodbye(ret)
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

	if (self.m_okBtn_cb) then
		self.m_okBtn_cb(ret)
	end
end

--@CHECK
UI:checkCompileError(UI_DragonGoodbyePopup)
