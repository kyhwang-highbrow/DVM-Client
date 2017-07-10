Z_ORDER_NORMAL = 101
Z_ORDER_TOOL_TIP = 300
Z_ORDER_TOAST_MSG = 400
Z_ORDER_LOADING = 500


-------------------------------------
-- class UIManager
-------------------------------------
UIManager = {
    SCENE = 0,
    NORMAL = 1,
    POPUP = 2,
    TOOLTIP = 3,
    LOADING = 4,

    m_uiLayer = 'cc.Node',
    m_uiList = {},
    m_scene = 'cc.Scene',

    m_toastNotiList = 'table',
    m_toastNotiTime = 'number',
    m_toastNotiLayer = 'cc.Node',

	m_tutorialNode = nil,
    m_lTutorialBtnList = 'list<button>',

    m_topUserInfo = nil,

	m_debugUI = nil, --'UI_GameDebug_RealTime',
    m_cbUIOpen = nil,
}

-------------------------------------
-- function init
-------------------------------------
function UIManager:init(perple_scene)
    local scene = perple_scene.m_scene

    if self.m_scene then
        self:cleanUp()
    end

    self.m_scene = scene
    self.m_uiLayer = cc.Node:create()
    self.m_scene:addChild(self.m_uiLayer, 20)
    self.m_uiList = {}
    self:invalidateUI()

    -- toast notification 관련 변수 초기화
    self.m_toastNotiLayer = cc.Node:create()
    self.m_toastNotiLayer:setDockPoint(cc.p(0.5, 0.5))
    self.m_toastNotiLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_toastNotiLayer:setPositionY(220)
    --self.m_uiLayer:addChild(self.m_toastNotiLayer, Z_ORDER_TOAST_MSG)
    self.m_scene:addChild(self.m_toastNotiLayer, 21)
    self.m_toastNotiList = {}
    self.m_toastNotiTime = nil

    -- TopUserInfo를 사용하는 Scene일 경우 초기화
    if perple_scene.m_bShowTopUserInfo then
        self:makeTopUserInfo()
    end
    
    -- 이전 Scene에서 사용됐을 수 있으므로 정리
    if self.m_topUserInfo then
        self.m_topUserInfo:clearOwnerUI()
    end

	g_currScene:addKeyKeyListener(self)
end

-------------------------------------
-- function makeTopUserInfo
-------------------------------------
function UIManager:makeTopUserInfo()
    if (not self.m_topUserInfo) then
        self.m_topUserInfo = UI_TopUserInfo()
        self.m_topUserInfo.root:retain()

        g_topUserInfo = self.m_topUserInfo
    end
end

-------------------------------------
-- function cleanUp
-------------------------------------
function UIManager:cleanUp()
    for i = #self.m_uiList, 1, -1 do
        local ui = self.m_uiList[i]
        ui:onDestroyUI()
        ui.closed = true
        self.m_uiLayer:removeChild(ui.root, true)
    end
    self.m_uiList = {}

	self:removeDebugUI()

	self:releaseTutorial()
end

-------------------------------------
-- function invalidateUI
-------------------------------------
function UIManager:invalidateUI()
    local scrSize = cc.Director:getInstance():getWinSize()
    self.viewSize = cc.size(scrSize.width, scrSize.height)
    self.m_uiLayer:setContentSize(self.viewSize)

    -- cclog("ui layer size = %d,%d", self.viewSize.width, self.viewSize.height)
end

-------------------------------------
-- function open
-------------------------------------
function UIManager:open(ui, mode, bNotBlendBGLayer)
    local bNotBlendBGLayer = bNotBlendBGLayer or false

	-- UI 인지 검사
    if not isInstanceOf(ui, UI) then
        error('not a UI')
    end

    local list = self.m_uiList

	-- 이미 등록되어있는지 검사
    if table.find(list, ui) then
        error('attempt to open twice')
    end

	-- UI 등록
    table.insert(list, ui)

	-- mode 별 z_order
    local z_order
    if (mode == UIManager.SCENE) then
        z_order = Z_ORDER_NORMAL

    elseif (mode == UIManager.NORMAL) then
        z_order = Z_ORDER_NORMAL

    elseif (mode == UIManager.POPUP) then
        z_order = Z_ORDER_NORMAL

    elseif (mode == UIManager.TOOLTIP) then
        z_order = Z_ORDER_TOOL_TIP

    elseif (mode == UIManager.LOADING) then
        z_order = Z_ORDER_NORMAL
        
    end

    -- SCENE mode인 경우 하위 UI를 전부 끄고 pause를 건다
    if (mode == UIManager.SCENE) then
		local function f_pause(node)
			node:pause()
		end

        local childs = self.m_uiLayer:getChildren()
        for _,child in ipairs(childs) do
            if child:isVisible() then
                child:setVisible(false)
                doAllChildren(child, f_pause)
                table.insert(ui.m_lHideUIList, child)
            end
        end
    end
    
	-- mode가 있을 경우에만 addChild
	if (mode) then
		self.m_uiLayer:addChild(ui.root, z_order)
	end

    -- 임시 터치 블록 영역 생성
    if (mode == UIManager.POPUP) or (mode == UIManager.LOADING) then
		self:makeTouchBlock(ui, bNotBlendBGLayer)
    end

    if self.m_cbUIOpen then
        self.m_cbUIOpen(ui)
    end
end

-------------------------------------
-- function makeTouchBlock
-------------------------------------
function UIManager:makeTouchBlock(ui, bNotBlendBGLayer)
    -- 하위 UI가 클릭되지 않도록 레이어 생성
    do
        local layer = cc.Layer:create()
        ui.root:addChild(layer, -100)

        local function onTouch(touch, event)
            if ui.root:isVisible() and layer:isVisible() then
                ui.root:resume()
                event:stopPropagation()
                return true
            else
                return false
            end
        end

		self:setLayerToEventListener(layer, onTouch)
    end

    -- 배경을 어둡게
    if (not ui.vars['bgLayerColor']) then
        local layerColor = self:makeMaskingLayer()

        ui.root:addChild(layerColor, -100)
        ui.vars['bgLayerColor'] = layerColor

        -- 엑션에 추가
        local t_action_data = ui:addAction(layerColor, UI_ACTION_TYPE_OPACITY, 0, 0.5)
        ui:doActionReset_(t_action_data)
        ui:doAction_Indivisual(t_action_data)
    end

    if bNotBlendBGLayer then
        ui.vars['bgLayerColor']:setVisible(false)
    end
end

-------------------------------------
-- function 가제
-------------------------------------
function UIManager:tutorial()
    -- 하위 UI가 클릭되지 않도록 레이어 생성
	local block_layer = cc.Layer:create()
	local function onTouch(touch, event)
		if block_layer:isVisible() then
			event:stopPropagation()
			return true
		else
			return false
		end
	end
	self:setLayerToEventListener(block_layer, onTouch)

    -- 배경을 어둡게
	local color_layer = self:makeMaskingLayer()
    color_layer:setDockPoint(CENTER_POINT)
    color_layer:setAnchorPoint(CENTER_POINT)

    -- tutorial node 생성
	local visible_size = cc.Director:getInstance():getVisibleSize()
	local tutorial_node = cc.Menu:create()
    tutorial_node:setDockPoint(CENTER_POINT)
    tutorial_node:setAnchorPoint(CENTER_POINT)
	tutorial_node:setNormalSize(visible_size['width'], visible_size['height'])
	tutorial_node:addChild(block_layer, -1)
	block_layer:addChild(color_layer, -1)

	self.m_uiLayer:addChild(tutorial_node, 128)

    self.m_tutorialNode = tutorial_node
    self.m_lTutorialBtnInfoList = {}
end

-------------------------------------
-- function 가제
-------------------------------------
function UIManager:releaseTutorial()
	if (self.m_tutorialNode) then 
		self.m_tutorialNode:removeFromParent(true)
		self.m_tutorialNode = nil
	end
end

-------------------------------------
-- function 가제
-------------------------------------
function UIManager:getTutorialNode()
	return self.m_tutorialNode
end

-------------------------------------
-- function 가제
-------------------------------------
function UIManager:attachToTutorialNode(button)
	local node = button.m_node

	local transform = node:getNodeToWorldTransform();
	local world_x = transform[12 + 1]
	local world_y = transform[13 + 1]
	local node_space = convertToNodeSpace(self.m_tutorialNode, cc.p(world_x, world_y), node:getDockPoint())

    local world_pos = convertToWorldSpace(node)

    -- 돌아갈 정보 저장
    local parent = button.m_node:getParent()
    local pos = {node:getPosition()}
    table.insert(self.m_lTutorialBtnInfoList, {parent = parent, node = node, pos = pos})

    -- tutorialNode에 붙여버린다.
	node:retain()
	node:removeFromParent()
	self.m_tutorialNode:addChild(node, 2)
	node:release()

    cclog('###########################')
    ccdump({world_x = world_x, world_y = world_y})
    ccdump(pos)
    ccdump(node_space)
    ccdump(world_pos)
    cclog('---------------------------')
    --button:setPosition(world_pos['x'], world_pos['y'])
end


-------------------------------------
-- function setLayerToEventListener
-- @brief 해당 레이어에 event_listener 등록
-------------------------------------
function UIManager:setLayerToEventListener(layer, touch_func)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_CANCELLED)

    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
end

-------------------------------------
-- function makeMaskingLayer
-- @brief 연한 검정색 layer_color 생성
-------------------------------------
function UIManager:makeMaskingLayer()
    local layer_color = cc.LayerColor:create( cc.c4b(0,0,0,150) )
    layer_color:setDockPoint(CENTER_POINT)
    layer_color:setAnchorPoint(CENTER_POINT)

    local visible_size = cc.Director:getInstance():getVisibleSize()
    layer_color:setNormalSize(visible_size['width'], visible_size['height'])

	return layer_color
end

-------------------------------------
-- function close
-------------------------------------
function UIManager:close(ui)
    if not ui.closed then
        error('DO NOT close UI manually! Do this with UI:close()')
    end

    local list = self.m_uiList

    local idx = table.find(list, ui)
    if idx == nil then
        error('attemp to close not opened ui')
    end

    --TODO: 팝업 처리
    --CCDialogHelper:onClose(ui.root)

    ui:onDestroyUI()

    self.m_uiLayer:removeChild(ui.root, true)
    table.remove(list, idx)

    local function f_resume(node)
        node:resume()
    end

    -- 숨김처리된 UI 다시 살림
    local childs = self.m_uiLayer:getChildren()
    for _,child in ipairs(ui.m_lHideUIList) do
        for _,child_ in ipairs(childs) do
            if (child == child_) then
                doAllChildren(child, f_resume)
                child:setVisible(true)
            end
        end
    end
end

-------------------------------------
-- function pause
-------------------------------------
function UIManager:pause()
    local function f_pause(node)
        node:pause()
    end
    if self.m_uiLayer then
        doAllChildren(self.m_uiLayer, f_pause)
    end
end

-------------------------------------
-- function resume
-------------------------------------
function UIManager:resume()
    local function f_resume(node)
        node:resume()
    end
    if self.m_uiLayer then
        doAllChildren(self.m_uiLayer, f_resume)
    end
end

-------------------------------------
-- function setEnable
-------------------------------------
function UIManager:setEnable(b)
    for i = #self.m_uiList, 1, -1 do
        self.m_uiList[i].enable = b
    end
end

-------------------------------------
-- function toastNotificationRed
-- @brief 
-------------------------------------
function UIManager:toastNotificationRed(msg)
    self:toastNotification(msg, cc.c3b(255,0,0))
end

-------------------------------------
-- function toastNotificationGreen
-- @brief 
-------------------------------------
function UIManager:toastNotificationGreen(msg)
    self:toastNotification(msg, cc.c3b(0,255,0))
end

-------------------------------------
-- function toastNotification
-- @brief 
-------------------------------------
function UIManager:toastNotification(msg, color)

    -- 2초 안에 같은 메세지가 들어올 경우 skip
    --[[
    if self.m_toastNotiList[1] then
        if self.m_toastNotiList[1].m_msg == msg then
            local time = os.time()
            if (time - self.m_toastNotiTime) <= 2 then
                return
            end
        end
    end
    --]]

    -- 노티피케이션 생성
    local notification = Notification(msg, color)

    -- 리스트에 추가
    table.insert(self.m_toastNotiList, 1, notification)
    UIManager.m_toastNotiLayer:addChild(notification.m_root)

    local function cb()
        self:removeToastNoti(notification)
    end

    -- 등장 액션 지정
    notification.m_root:setOpacity(0)
    notification.m_label:setOpacity(0)
    notification.m_root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(4), cc.FadeTo:create(0.5, 0), cc.CallFunc:create(cb)))
    notification.m_label:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(4), cc.FadeTo:create(0.5, 0)))

    -- 정렬
    self:sortToastNoti()

    -- 노스트 메세지가 생성된 시간 저장(동일 메세지를 2초 이내에는 skip하기 위해 저장)
    self.m_toastNotiTime = os.time()
end

-------------------------------------
-- function removeToastNoti
-- @brief 재생이 완료된 메세지를 삭제
-------------------------------------
function UIManager:removeToastNoti(notification)
    
    -- 삭제 처리
    for i,v in ipairs(self.m_toastNotiList) do
        if (v == notification) then
            notification.m_root:removeFromParent(true)
            table.remove(self.m_toastNotiList, i)
            break
        end
    end
    
end

-------------------------------------
-- function sortToastNoti
-- @brief 메세지들의 위치를 정렬
-------------------------------------
function UIManager:sortToastNoti()
    for i,v in ipairs(self.m_toastNotiList) do
        -- 기존에 move액션 삭제(tag 1)
        v.m_root:stopActionByTag(1)

        -- 새로운 move액션 실행
        local action = cc.MoveTo:create(0.3, cc.p(0, (i-1)*40))
        action:setTag(1)
        v.m_root:runAction(action)
    end
end

-------------------------------------
-- function updateDebugUI
-- @brief
-------------------------------------
function UIManager:updateDebugUI(dt)
	if (not self.m_debugUI) then
		self.m_debugUI = UI_GameDebug_RealTime(self.m_scene)
	end
	self.m_debugUI:update(dt)
end

-------------------------------------
-- function removeDebugUI
-- @brief debug 영역을 cleanUp() 호출 시 같이 내려준다.
-------------------------------------
function UIManager:removeDebugUI()
	if (self.m_debugUI) then
		self.m_debugUI.m_debugLayer:removeFromParent(true)
		self.m_debugUI = nil
	end
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function UIManager:onKeyReleased(keyCode, event)
	-- UI 클래스 이름 출력
	if (keyCode == KEY_U) then
		local last_ui = table.getLast(self.m_uiList)
		local class_name = last_ui.m_uiName or 'Class 이름이 정의되지 않았습니다.'
		self:toastNotificationGreen('## UI CLASS NAME : ' .. class_name)

	-- ui 파일 이름 출력
	elseif (keyCode == KEY_I) then
		local last_ui = table.getLast(self.m_uiList)
		local ui_name = last_ui.m_resName or 'ui 파일이 없습니다'
		self:toastNotificationGreen('## UI FILE : ' .. ui_name)

	-- 등록된 UI 리스트 출력
	elseif (keyCode == KEY_A) then
		cclog('----------------opened ui list----------------------')
		for i, v in pairs(self.m_uiList) do
			cclog(v.m_resName, v.m_uiName)
		end

	-- 
	elseif (keyCode == KEY_Q) then
		self:releaseTutorial()

	-- debug 영역 활성화/비활성화
	elseif (keyCode == KEY_G) then
		local set_data = not g_constant:get('DEBUG', 'DISPLAY_DEBUG_INFO')
	    g_constant:set(set_data, 'DEBUG', 'DISPLAY_DEBUG_INFO')

		if self.m_debugUI then
			self.m_debugUI.m_debugLayer:setVisible(g_constant:get('DEBUG', 'DISPLAY_DEBUG_INFO'))
		end
		PrintMemory()

	-- currScene에 반복 액션으로 테스트 중인 경우 해제를 위해서 등록
	elseif (keyCode == KEY_D) then
		g_currScene.m_scene:stopAllActions()

	end
end