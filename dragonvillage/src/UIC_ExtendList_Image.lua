local PARENT = UIC_ExtendList

-------------------------------------
-- class UIC_ExtendList_Image
-------------------------------------
UIC_ExtendList_Image = class(PARENT, {
		m_tIsExtend = 'table', -- {[key1] = 0, [key2] = 1}
		m_cbClick = 'function',
        m_group = 'number',
		m_node = 'cc.Node',

		-- 순차적으로 생성하는 데 필요한 변수
		m_isCreateDone = 'boolean',
		m_makeTimer = 'number',
		m_createIdx = 'number'
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ExtendList_Image:init()
	self.m_tIsExtend = {}
    self.m_group = nil
	self.m_isCreateDone = false
	self.m_makeTimer = 0
	self.m_createIdx = 1
end

-------------------------------------
-- function create
-------------------------------------
function UIC_ExtendList_Image:create(node, focus_key, use_scroll)
	local l_main = self.m_lMainBtn

	self.m_node = node
	self.m_node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UIC_ExtendList_Image:update(dt)
	local l_main = self.m_lMainBtn
	if (self.m_isCreateDone) then
		return
	end
	self.m_makeTimer = (self.m_makeTimer - dt)
	if (self.m_makeTimer <= 0) then
		if (self.m_createIdx > #l_main) then
			self:setFocus()
			self.m_isCreateDone = true
			self.m_createIdx = 1
			return
		end
		self:createItemUI()
		self.m_makeTimer = 0.02
	end
end

-------------------------------------
-- function createItemUI
-------------------------------------
function UIC_ExtendList_Image:createItemUI()
	local node = self.m_node
	local l_main = self.m_lMainBtn
	local create_idx = self.m_createIdx

	local t_main = l_main[create_idx]
	if (not t_main) then
		return
	end

	local ui_main = self:makeItemUI(t_main['ui_class'], t_main['data'])
	ui_main.vars['openBtn']:registerScriptTapHandler(function() self:clickMainBtn(t_main['key']) end)
	t_main['clipping_node'] = ui_main.vars['extendNode']
	t_main['clipping_menu'] = ui_main.vars['extendMenu']
	-- 처음에는 접어둠
	t_main['clipping_node']:setNormalSize(800, 0)
	
	if (ui_main) then
		node:addChild(ui_main.root)
		t_main['created_ui'] = ui_main
		
		local scale = ui_main.root:getScale()
        ui_main.root:setScale(scale * 0.2)
        local scale_to = cc.ScaleTo:create(0.25, scale)
        local action = cc.EaseInOut:create(scale_to, 2)
        ui_main.root:runAction(action)
	end

	local ui = t_main['created_ui']
	local content_height = self:getDefaultHeightByIdx(create_idx)
	ui.root:setPositionY(content_height)

	self.m_createIdx = create_idx + 1
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

	-- focus_key가 없으면 다 접는다.
	if (not focus_key) then
		self:setFoldAll()
		self:moveMainBtn(true) -- no action
		return
	end

	-- 2.펼쳐짐에 따라 다른 버튼들 이동
	self:moveMainBtn()
end

-------------------------------------
-- function moveMainBtn
-------------------------------------
function UIC_ExtendList_Image:moveMainBtn(no_action)
	local l_main = self.m_lMainBtn
	local l_move_y = {}
	-- 펼쳐졌을 때 늘어난 y 위치
	local base_y = 0

    local total_pos_y = 0
	for idx, t_main in ipairs(l_main) do
		local ui = t_main['created_ui']
		local content_height = 0
        if (self.m_group) then
            if (idx - 1) % self.m_group == 0 then
                content_height = self.m_mainBtnHeight + 50
            else
                content_height = self.m_mainBtnHeight
            end
        else
            content_height = self.m_mainBtnHeight
        end

        if (idx == 1) then
            content_height = 0
        end

		total_pos_y = total_pos_y + (-content_height) - base_y
		table.insert(l_move_y, total_pos_y)

		local key = t_main['key']
		if (self.m_tIsExtend[key]) then
			base_y = self.m_extendHeight
		else
            base_y = 0
        end
	end

	for idx, t_main in ipairs(l_main) do
		local ui = t_main['created_ui']
		if (ui) then
			if (no_action) then
				ui.root:setPositionY(l_move_y[idx])
			else
				local move_to = cc.MoveTo:create(0.2, cc.p(0, l_move_y[idx]))
				cca.runAction(ui.root, cc.EaseInOut:create(move_to, 2))
			end
		end
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
		if (clipping_node) then
			clipping_node:setNormalSize(800, 0)
		end
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

-------------------------------------
-- function setGroup
-------------------------------------
function UIC_ExtendList_Image:setGroup(group)
	self.m_group = group
end

-------------------------------------
-- function initScroll
-------------------------------------
function UIC_ExtendList_Image.initScroll(scroll_node, scroll_menu)
	local scroll_node = scroll_node
	scroll_node:setScale(1,-1)

	local scroll_menu = scroll_menu

	-- ScrollView 사이즈 설정 (ScrollNode 사이즈)
	local size = scroll_node:getContentSize()
	local scroll_view = cc.ScrollView:create()
	scroll_view:setNormalSize(size)
	scroll_node:setSwallowTouch(false)
	scroll_node:addChild(scroll_view)

	-- ScrollView 에 달아놓을 컨텐츠 사이즈(ScrollMenu)
	local target_size = scroll_menu:getContentSize()
	scroll_view:setDockPoint(cc.p(0.5, 0.5))
	scroll_view:setAnchorPoint(cc.p(0.5, 0.5))

	scroll_view:setContentSize(target_size)
	scroll_view:setPosition(ZERO_POINT)
	scroll_view:setTouchEnabled(true)

	-- ScrollMenu를 부모에서 분리하여 ScrollView에 연결
	-- 분리할 부모가 없을 때 에러 없음
    scroll_menu:retain()
	scroll_menu:removeFromParent()


	scroll_view:addChild(scroll_menu)
    scroll_menu:release()

	scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	
	local node = cc.Node:create()
	local reverse_node = cc.Node:create()
	node:setScale(1,-1)
	scroll_view:addChild(reverse_node)
	reverse_node:addChild(node)
	
	return node, scroll_view
end


-------------------------------------
-- function getDefaultHeightByIdx
-------------------------------------
function UIC_ExtendList_Image:getDefaultHeightByIdx(idx)
	local content_height = 0
	if (self.m_group) then
        content_height = self.m_mainBtnHeight * (idx - 1) + 50 * math.floor((idx - 1)/self.m_group)
    else
        content_height = self.m_mainBtnHeight * (idx - 1)
    end

	return content_height * (-1)
end