-------------------------------------
-- class UIC_ExtendList
-------------------------------------
UIC_ExtendList = class({
		m_lMainBtn = 'list',
		m_lSubBtn = 'list',

		m_focusKey = 'string',

		m_subBtnHeight = 'number',
		m_mainBtnHeight = 'number',

		m_duration = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ExtendList:init()
	self.m_lMainBtn = {}
	self.m_lSubBtn = {}
	self.m_duration = 0.5
end

-------------------------------------
-- function addMainBtn
-------------------------------------
function UIC_ExtendList:addMainBtn(key, ui, data)
	local t_ui = {['key'] = key, ['ui_class'] = ui, ['data'] = data, ['clipping_node'] = nil}
	table.insert(self.m_lMainBtn, t_ui)
end

-------------------------------------
-- function addSubBtn
-------------------------------------
function UIC_ExtendList:addSubBtn(key, ui, l_data)
	local t_ui = {['key'] = key, ['ui_class'] = ui, ['l_data'] = l_data, ['l_created_ui'] = {}}
	table.insert(self.m_lSubBtn, t_ui)
end


-------------------------------------
-- function create
-------------------------------------
function UIC_ExtendList:create(node, focus_key)
	local l_main = self.m_lMainBtn
	for _, t_main in ipairs(l_main) do
		local ui_main = self:makeItemUI(t_main['ui_class'], t_main['data'])
		ui_main.vars['openBtn']:registerScriptTapHandler(function() self:clickMainBtn(t_main['key']) end)
		t_main['clipping_node'] = ui_main.vars['extendNode']
		t_main['clipping_menu'] = ui_main.vars['extendMenu']
		if (ui_main) then
			node:addChild(ui_main.root)
			t_main['created_ui'] = ui_main
		end
	end

	for idx, t_main in ipairs(l_main) do
		local ui = t_main['created_ui']
		local content_height = self.m_mainBtnHeight
		ui.root:setPositionY(-content_height * (idx-1))
	end

	self:setFocus(focus_key)
end

-------------------------------------
-- function makeItemUI
-------------------------------------
function UIC_ExtendList:makeItemUI(ui_class, data)
	if (not ui_class) then
		return nil
	end

	if (not data) then
		return nil
	end
	
    local ui = ui_class(data)
	return ui
end

-------------------------------------
-- function setFocus
-------------------------------------
function UIC_ExtendList:setFocus(focus_key)
	local l_main = self.m_lMainBtn

	self.m_focusKey = focus_key

	-- 1.포커싱 된 메뉴만 서브 메뉴 생성
	for idx, t_main in ipairs(l_main) do
		if (t_main['key'] == focus_key) then
			self:makeSubBtn(t_main['clipping_menu'], focus_key)
			self:setExtendSubBtn(t_main['key'], true)
		else
			self:setExtendSubBtn(t_main['key'], false)
		end
	end

	-- 2.펼쳐짐에 따라 다른 버튼들 이동
	self:moveMainBtn(focus_key)
end

-------------------------------------
-- function moveMainBtn
-------------------------------------
function UIC_ExtendList:moveMainBtn(focus_key)
	local l_main = self.m_lMainBtn
	local l_move_y = {}
	-- 펼쳐졌을 때 늘어난 y 위치
	local base_y = 0

	for idx, t_main in ipairs(l_main) do
		local ui = t_main['created_ui']
		local content_height = self.m_mainBtnHeight
		local pos_y = (-content_height * (idx-1)) - base_y
		table.insert(l_move_y, pos_y)

		if (t_main['key'] == focus_key) then
			base_y = self:getLastContentsEndPositionY(focus_key)
		end
	end

	for idx, t_main in ipairs(l_main) do
		local ui = t_main['created_ui']
		ui.root:stopAllActions()
		local move_to = cc.MoveTo:create(0.2, cc.p(0, l_move_y[idx]))
        cca.runAction(ui.root, cc.EaseInOut:create(move_to, 2))
	end
end

-------------------------------------
-- function makeSubBtn
-------------------------------------
function UIC_ExtendList:makeSubBtn(node, key)
	local l_sub = self.m_lSubBtn
	for idx, t_sub in ipairs(l_sub) do
		if (t_sub['key'] == key) then
			-- 이미 ui들이 있다면 생성하지 않고 visible만 켜준다.
			if (#t_sub['l_created_ui'] > 0) then
				self:setExtendSubBtn(key, true)
				return
			end

			for i, data in ipairs(t_sub['l_data']) do
				local ui_sub = self:makeItemUI(t_sub['ui_class'], data)
				if (ui_sub) then
					node:addChild(ui_sub.root)
					local height = self.m_subBtnHeight
					ui_sub.root:setPositionY(-height/2 - height * (i-1))
					table.insert(t_sub['l_created_ui'], ui_sub)
				end
			end
			break
		end
	end
end

-------------------------------------
-- function getLastContentsEndPositionY
-------------------------------------
function UIC_ExtendList:getLastContentsEndPositionY(key)
	local l_sub = self.m_lSubBtn
	for idx, t_sub in ipairs(l_sub) do
		if (t_sub['key'] == key) then
			local ui_cnt = #t_sub['l_created_ui']
			local height = self.m_subBtnHeight
			return height * ui_cnt + 5
		end
	end

	return 0		
end

-------------------------------------
-- function clickMainBtn
-------------------------------------
function UIC_ExtendList:clickMainBtn(key)
	-- 같은 키를 눌렀다면 다 닫아줌
	if (key == self.m_focusKey) then
		key = nil
	end
	self:setFocus(key)
end

-------------------------------------
-- function setExtendSubBtn
-------------------------------------
function UIC_ExtendList:setExtendSubBtn(key, is_extend)
	local l_main = self.m_lMainBtn
	local extend_size = 0
	if (is_extend) then
		extend_size = self:getLastContentsEndPositionY(key)
	end
	
	for idx, t_main in ipairs(l_main) do
		if (t_main['key'] == key) then
			local clipping_node = t_main['clipping_node']
			clipping_node:stopAllActions()
			local func = function(value)
			    clipping_node:setNormalSize(800, value)
			end
			
			local height = self.m_mainBtnHeight
			local tween = cc.ActionTweenForLua:create(0.3, height, extend_size, func)
			local action = cc.EaseInOut:create(tween, 2)
			cca.runAction(clipping_node.m_node, action, TAG_CELL_WIDTH_TO)
			return
		end
	end
end

-------------------------------------
-- function setMainBtnHeight
-------------------------------------
function UIC_ExtendList:setMainBtnHeight(height)
	self.m_mainBtnHeight = height
end

-------------------------------------
-- function setSubBtnHeight
-------------------------------------
function UIC_ExtendList:setSubBtnHeight(height)
	self.m_subBtnHeight = height
end

-------------------------------------
-- function setDuration
-------------------------------------
function UIC_ExtendList:setDuration(duration)
	self.m_duration = duration
end