local PARENT = UI

-------------------------------------
-- class UI_DragonGoodbyePopup
-------------------------------------
UI_DragonGoodbyePopup = class(PARENT,{
		m_dragonOid = 'string',
		m_tDragonData = 'table',
        m_msg = 'string',
		m_okBtn_cb = 'function'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGoodbyePopup:init(dragon_oid, dragon_data, msg, okBtn_cb)
    self.m_dragonOid = dragon_oid
	self.m_tDragonData = dragon_data
	self.m_msg = msg
	self.m_okBtn_cb = okBtn_cb

    local vars = self:load('goodbye_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonGoodbyePopup')

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

	-- 경험치 아이템
	do
		local exp = dragon_exp_table:getDragonGivingExp(grade, lv)	

		local dragon_exp_item = {}
		dragon_exp_item['item_id'] = 700017 -- 경험치 아이템 코드
		dragon_exp_item['count'] = exp 	
		
		local ui = UI_ItemCard(dragon_exp_item['item_id'], dragon_exp_item['count'])
        ui:setEnabledClickBtn(false)
		vars['itemNode1']:addChild(ui.root)
	end		
	
	-- 특성 재료
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
	else
		vars['checkBtn2']:setVisible(false)
		vars['checkBtn2']:setEnabled(false)
	end

	-- 인연 포인트
	if (g_dragonsData:possibleGoodbye(oid)) then -- 인연포인트로 변경 가능할 때
		local item_id = 760000 + (did % 10000) -- 인연포인트 코드
		local count = dragon_table:getRelationPoint(did)
	
		local relation_item = {}
		relation_item['item_id'] = item_id
		relation_item['count'] = count 		

		local ui = UI_ItemCard(relation_item['item_id'], relation_item['count'])
        ui:setEnabledClickBtn(false)
		vars['itemNode3']:addChild(ui.root)
	else
		vars['checkBtn3']:setVisible(false)
		vars['checkBtn3']:setEnabled(false)
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
	local l_pos = getSortPosList(210, enable_button_count)
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
end


-------------------------------------
-- function click_checkBox
-------------------------------------
function UI_DragonGoodbyePopup:click_checkBox(idx)
	local vars = self.vars

	if (not vars['checkBtn' .. idx]:isChecked()) then -- 켜져있던 걸 끈 경우
		return
	end

	for i = 1, 3 do -- 무언가 선택하면 나머지는 꺼짐
		if (i == idx) then
			vars['checkBtn' .. idx]:setChecked(true)
		else
			vars['checkBtn' .. i]:setChecked(false)
		end
	end
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonGoodbyePopup:click_goodbyeBtn()
	local vars = self.vars
	local target = nil
	
	if (vars['checkBtn1']:isChecked()) then
		target = 'exp'		
	elseif (vars['checkBtn2']:isChecked()) then
		target = 'mastery'
	elseif (vars['checkBtn3']:isChecked()) then
		target = 'relation'  
	end

	if (target == nil) then
		UIManager:toastNotificationRed('선택된 아이템이 없습니다.')	
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

	cclog(doids)

	local function success_cb(ret)
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
