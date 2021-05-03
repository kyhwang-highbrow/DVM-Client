--[[
Z_ORDER_NORMAL = 101
Z_ORDER_TOOL_TIP = 300
Z_ORDER_TOAST_MSG = 400
Z_ORDER_LOADING = 500
]]

SCENE_ZORDER = {
    UI = 16,
    TOAST = 32,
    TUTORIAL = 64,
    TUTORIAL_DLG = 128,
}

UI_ZORDER = {
    NORMAL = 8,
    TOOL_TIP = 32,
    TOAST_MSG = 32,
    TUTORIAL = 64,
    LOADING = 256,
    ERROR_POPUP = 256,
    TOP_POPUP = 512,
}

IGNORE_LOGGING_UI_RES_NAME = {}
IGNORE_LOGGING_UI_RES_NAME['empty.ui'] = true
IGNORE_LOGGING_UI_RES_NAME['network_loading.ui'] = true

-------------------------------------
-- class UIManager
-------------------------------------
UIManager = {
    SCENE = 0,
    NORMAL = 1,
    POPUP = 2,
    TOOLTIP = 3,
    LOADING = 4,
    ERROR_POPUP = 5,
    TOP_POPUP = 6, -- 모든걸 뚫는 창

    m_uiLayer = 'cc.Node',
    m_uiList = {}, -- list -> 1부터 시작하는 index를 사용
    m_scene = 'cc.Scene',
    m_perpleScene = 'PerpleScene',

    m_toastNotiList = 'table',
    m_toastNotiTime = 'number',
    m_toastNotiLayer = 'cc.Node',

    m_toastBroadcastLayer = 'cc.Node',

    --m_toastPopup = 'UI_ToastPopup',

    m_topUserInfo = nil,

    m_cbUIOpen = nil,

    m_keyListenerList = 'list',
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
    self.m_perpleScene = perple_scene
    self.m_uiLayer = cc.Node:create()
    self.m_scene:addChild(self.m_uiLayer, SCENE_ZORDER.UI)
    self.m_uiList = {}
    self:invalidateUI()

    -- toast notification 관련 변수 초기화
    self.m_toastNotiLayer = cc.Node:create()
    self.m_toastNotiLayer:setDockPoint(cc.p(0.5, 0.5))
    self.m_toastNotiLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_toastNotiLayer:setPositionY(220)
    self.m_scene:addChild(self.m_toastNotiLayer, SCENE_ZORDER.TOAST)
    self.m_toastNotiList = {}
    self.m_toastNotiTime = nil

    -- broadcast notification 관련 변수 초기화
    self.m_toastBroadcastLayer = cc.Node:create()
    self.m_toastBroadcastLayer:setDockPoint(cc.p(0.5, 0.5))
    self.m_toastBroadcastLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_scene:addChild(self.m_toastBroadcastLayer, SCENE_ZORDER.TOAST)

    -- TopUserInfo를 사용하는 Scene일 경우 초기화
    if perple_scene.m_bShowTopUserInfo then
        self:makeTopUserInfo()
    end
    
    -- 이전 Scene에서 사용됐을 수 있으므로 정리
    if self.m_topUserInfo then
        self.m_topUserInfo:clearOwnerUI()
    end

    self.m_keyListenerList = {}

    -- toast popup 중복 제어용
    --self.m_toastPopup = nil

	g_currScene:addKeyKeyListener(self)
end

-------------------------------------
-- function makeTopUserInfo
-------------------------------------
function UIManager:makeTopUserInfo()
    --cclog('## UIManager:makeTopUserInfo() - 함수 시작')
    -- @sgkim 2020.09.29 탑바가 터치가 안되는 현상이 있어서 추측으로 수정 중
    if (self.m_topUserInfo ~= nil) then
        if self.m_topUserInfo.root then
            if self.m_topUserInfo.root:isExist() then
                --cclog('## UIManager:makeTopUserInfo() - 기존 탑바 삭제')
                self.m_topUserInfo.root:release()
            end
        end
        self.m_topUserInfo = nil
    end

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
end

-------------------------------------
-- function invalidateUI
-------------------------------------
function UIManager:invalidateUI()
    local scrSize = cc.Director:getInstance():getWinSize()
    self.viewSize = cc.size(scrSize.width, scrSize.height)
    self.m_uiLayer:setContentSize(self.viewSize)
end

-------------------------------------
-- function open
-------------------------------------
function UIManager:open(ui, mode, bNotBlendBGLayer, ignore_add)
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
    if (not ignore_add) then
        table.insert(list, ui)
    end

	-- mode 별 z_order
    local z_order
    if (mode == UIManager.SCENE) then
        z_order = UI_ZORDER.NORMAL

    elseif (mode == UIManager.NORMAL) then
        z_order = UI_ZORDER.NORMAL

    elseif (mode == UIManager.POPUP) then
        z_order = UI_ZORDER.NORMAL

    elseif (mode == UIManager.TOOLTIP) then
        z_order = UI_ZORDER.TOOL_TIP
        
    elseif (mode == UIManager.LOADING) then
        z_order = UI_ZORDER.LOADING

    elseif (mode == UIManager.TOP_POPUP) then
        z_order = UI_ZORDER.TOP_POPUP

    elseif (mode == UIManager.ERROR_POPUP) then
        z_order = UI_ZORDER.ERROR_POPUP
        
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
    if (mode == UIManager.POPUP) or (mode == UIManager.LOADING) or (mode == UIManager.ERROR_POPUP) then
		self:makeTouchBlock(ui, bNotBlendBGLayer)
    end

    if self.m_cbUIOpen then
        self.m_cbUIOpen(ui)
    end

    -- Firebase Crashlytics에 UI 기록 로그 추가
    if (IGNORE_LOGGING_UI_RES_NAME[tostring(ui.m_resName)] ~= true) then
        local ui_str = 'UI : ' .. tostring(ui.m_uiName) .. ' / ' .. tostring(ui.m_resName)
        --ccdisplay(ui_str)
        PerpleSdkManager.getCrashlytics():setLog(ui_str)
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
-- function makeSkipAndMaskingLayer
-------------------------------------
function UIManager:makeSkipAndMaskingLayer(ui, touch_func)
    -- skip layer
    do
        local layer = cc.Layer:create()
        ui.root:addChild(layer, -100)

        local function onTouch(touch, event)
            if (touch_func) then
				touch_func(touch, event)
			end
        end
        self:setLayerToEventListener(layer, onTouch)
    end

    -- masking layer
    do
        local layerColor = self:makeMaskingLayer()
        
        ui.root:addChild(layerColor, -100)

        -- 엑션에 추가
        local t_action_data = ui:addAction(layerColor, UI_ACTION_TYPE_OPACITY, 0, 0.5)
        ui:doActionReset_(t_action_data)
        ui:doAction_Indivisual(t_action_data)
    end
end
 
-------------------------------------
-- function makeSkipLayer
-------------------------------------
function UIManager:makeSkipLayer(ui, touch_func)
    -- skip layer
    local layer = cc.Layer:create()
    ui.root:addChild(layer, -100)

    local function onTouch(touch, event)
        if (touch_func) then
			touch_func(touch, event)
		end
		event:stopPropagation()
    end
    self:setLayerToEventListener(layer, onTouch)
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
-- function toastBroadcast
-- @brief 
-------------------------------------
function UIManager:toastBroadcast(msg)

    local notification = NotificationBroadcast(msg, cc.c3b(255,255,0))
    UIManager.m_toastBroadcastLayer:addChild(notification.m_root)

    local function cb()
        self:removeToastNoti(notification)
    end

    -- 등장 액션 지정
    notification.m_root:setOpacity(0)
    notification.m_label:setOpacity(0)
    notification.m_root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(4), cc.FadeTo:create(0.5, 0), cc.CallFunc:create(cb)))
    notification.m_label:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(4), cc.FadeTo:create(0.5, 0)))
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
-- function blockBackKey
-------------------------------------
function UIManager:blockBackKey(b)
    if (self.m_perpleScene) then
        self.m_perpleScene:blockBackkey(b)
    end
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function UIManager:onKeyReleased(keyCode, event)

    -- 테스트 모드에서만 동작하도록 설정
    if (not IS_TEST_MODE()) then
        return
    end

    -- 인게임에서 동작하지 않도록 설정
    if (g_gameScene or DV_SCENE_ACTIVE) then
        return
    end

	-- UI 클래스 이름 출력 및 클립보드 복사
	if (keyCode == KEY_U) then
		local last_ui = table.getLast(self.m_uiList)
		local class_name = last_ui.m_uiName or 'Class 이름이 정의되지 않았습니다.'
		self:toastNotificationGreen('## UI CLASS NAME : ' .. class_name)

        SDKManager:copyOntoClipBoard(class_name)

	-- ui 파일 이름 출력 및 클립보드 복사
	elseif (keyCode == KEY_I) then
		local last_ui = table.getLast(self.m_uiList)
		local ui_name = last_ui.m_resName or 'ui 파일이 없습니다'
		self:toastNotificationGreen('## UI FILE : ' .. ui_name)

        SDKManager:copyOntoClipBoard(ui_name)

	-- 등록된 UI 리스트 출력
	elseif (keyCode == KEY_A) then
		cclog('----------------opened ui list----------------------')
		for i, v in pairs(table.reverse(self.m_uiList)) do
			cclog(v.m_resName, v.m_uiName)
		end

	-- 등록된 UI 리스트 출력
	elseif (keyCode == KEY_N) then
		cclog('----------------network list----------------------')
		cclog('\n' .. g_errorTracker:getAPIStack())

	-- memory 출력
	elseif (keyCode == KEY_G) then
		PrintMemory()

    -- 방송 비활성화
    elseif (keyCode == KEY_B) then
        local b = g_broadcastManager:isEnable()
        if (b == true) then
            g_topUserInfo:clearBroadcast()
            self:toastNotificationGreen('방송 비활성화')
        else
            self:toastNotificationGreen('방송 활성화')
        end
        g_broadcastManager:setEnable(not b)

	-- 로비 낮/밤 전환
    elseif (keyCode == KEY_D) then
        SKIP_CHECK_DAY_OR_NIGHT = true
		USE_NIGHT = not USE_NIGHT
		SceneLobby(true):runScene()

	-- 튜토리얼 강제 종료
    elseif (keyCode == KEY_X) then
		TutorialManager.getInstance():forcedClose()

	end

    -- 개발용 키 리스너 유연성 제고
    for i, v in ipairs(self.m_keyListenerList) do
        v(keyCode, event)
    end
end

-------------------------------------
-- function registerKeyListener
-------------------------------------
function UIManager:registerKeyListener(listener)
    table.insert(self.m_keyListenerList, listener)

    cclog('registered listeners.. ' .. #self.m_keyListenerList)
end


-------------------------------------
-- function removeKeyListener
-------------------------------------
function UIManager:removeKeyListener(listener)
    table.remove(self.m_keyListenerList, listener)
end