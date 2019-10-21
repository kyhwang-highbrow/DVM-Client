local PARENT = UIC_ExtendList

-------------------------------------
-- class UIC_ExtendList_Image
-------------------------------------
UIC_ExtendList_Image = class(PARENT, {
		m_tIsExtend = 'table', -- {[key1] = 0, [key2] = 1}
		m_cbClick = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ExtendList_Image:init()
	self.m_tIsExtend = {}
end

-------------------------------------
-- function create
-------------------------------------
function UIC_ExtendList_Image:create(node, focus_key)
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
function UIC_ExtendList_Image:makeItemUI(ui_class, data)
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
function UIC_ExtendList_Image:setFocus(focus_key)
	local l_main = self.m_lMainBtn
	-- focus_key가 없으면 다 접는다.
	if (not focus_key) then
		self:setFoldAll()
		return
	end
	
	if (self.m_tIsExtend[focus_key] ~= nil) then
		-- Toggle
		if (self.m_tIsExtend[focus_key] == true) then
			self.m_tIsExtend[focus_key] = false
		else
			self.m_tIsExtend[focus_key] = true
		end
	end

	-- 1.포커싱 된 메뉴만 서브 메뉴 생성
	for idx, t_main in ipairs(l_main) do

		if (t_main['key'] == focus_key) then
			local is_extend = self.m_tIsExtend[focus_key]
			self:setExtend(t_main['key'], is_extend)
		end
	end

	-- 2.펼쳐짐에 따라 다른 버튼들 이동
	self:moveMainBtn()
end

-------------------------------------
-- function moveMainBtn
-------------------------------------
function UIC_ExtendList_Image:moveMainBtn()
	local l_main = self.m_lMainBtn
	local l_move_y = {}
	-- 펼쳐졌을 때 늘어난 y 위치
	local base_y = 0

	for idx, t_main in ipairs(l_main) do
		local ui = t_main['created_ui']
		local content_height = self.m_mainBtnHeight
		local pos_y = (-content_height * (idx-1)) - base_y
		table.insert(l_move_y, pos_y)

		local key = t_main['key']
		if (self.m_tIsExtend[key]) then
			base_y = base_y + self.m_extendHeight
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
-- function clickMainBtn
-------------------------------------
function UIC_ExtendList_Image:clickMainBtn(key)
	if (self.m_cbClick) then
		self.m_cbClick()
	end
	self:setFocus(key)
end

-------------------------------------
-- function setExtend
-------------------------------------
function UIC_ExtendList_Image:setExtend(focus_key, is_extend)
	local l_main = self.m_lMainBtn
	local extend_size = 0
	if (is_extend) then
		extend_size = self.m_extendHeight
	end

	for idx, t_main in ipairs(l_main) do
		if (t_main['key'] == focus_key) then
			local clipping_node = t_main['clipping_node']
			clipping_node:stopAllActions()
			local func = function(value)
			    clipping_node:setNormalSize(800, value)
			end
			
			local height = self.m_mainBtnHeight
			local tween = cc.ActionTweenForLua:create(0.3, height, extend_size, func)
			local action = cc.EaseInOut:create(tween, 2)
			cca.runAction(clipping_node.m_node, action, TAG_CELL_WIDTH_TO)
		end
	end
end

-------------------------------------
-- function setFoldAll
-------------------------------------
function UIC_ExtendList_Image:setFoldAll()
	local l_main = self.m_lMainBtn

	for idx, t_main in ipairs(l_main) do
		local clipping_node = t_main['clipping_node']
		clipping_node:setNormalSize(800, 0)
	end
end

-------------------------------------
-- function addMainBtn
-------------------------------------
function UIC_ExtendList_Image:addMainBtn(key, ui, data)
	local t_ui = {['key'] = key, ['ui_class'] = ui, ['data'] = data, ['clipping_node'] = nil}
	table.insert(self.m_lMainBtn, t_ui)
	
	self.m_tIsExtend[key] = false
end

-------------------------------------
-- function getAllHeight
-------------------------------------
function UIC_ExtendList_Image:getAllHeight()
	local l_main = self.m_lMainBtn
	local l_move_y = {}
	-- 펼쳐졌을 때 늘어난 y 위치
	local base_y = 0
	local pos_y = 0

	local extend_cnt = 0
	for idx, t_main in ipairs(l_main) do
		local key = t_main['key']
		if (self.m_tIsExtend[key]) then
			extend_cnt = extend_cnt + 1
		end
	end

	return (extend_cnt * self.m_extendHeight) + (#l_main * self.m_mainBtnHeight)
end

-------------------------------------
-- function setClickFunc
-------------------------------------
function UIC_ExtendList_Image:setClickFunc(cb_func)
	self.m_cbClick = cb_func
end