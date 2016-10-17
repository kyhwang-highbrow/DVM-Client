
Z_ORDER_SCENE = 100
Z_ORDER_NORMAL = 101
Z_ORDER_SCENE_TOP_USER_INFO = 110
Z_ORDER_POPUP = 200
Z_ORDER_POPUP_TOP_USER_INFO = 210
Z_ORDER_TOOL_TIP = 300
Z_ORDER_TOAST_MSG = 400


-------------------------------------
-- class UIManager
-------------------------------------
UIManager = {
    SCENE = 0,
    NORMAL = 1,
    POPUP = 2,
    TOOLTIP = 3,

    m_uiLayer = 'CCNode',
    m_uiList = {},
    m_scene = 'CCScene',

    m_toastNotiList = 'table',
    m_toastNotiTime = 'number',
    m_toastNotiLayer = 'cc.Node',

    m_topUserInfo = nil,
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
    self.m_uiLayer:addChild(self.m_toastNotiLayer, Z_ORDER_TOAST_MSG)
    self.m_toastNotiList = {}
    self.m_toastNotiTime = nil

    self:makeTopUserInfo()

    if perple_scene.m_bShowTopUserInfo and self.m_topUserInfo then
        self.m_uiLayer:addChild(self.m_topUserInfo.root, Z_ORDER_POPUP_TOP_USER_INFO)
        self.m_topUserInfo:refreshData()
        self.m_topUserInfo:clearOwnerUI()
    end

	g_currScene:addKeyKeyListener(self)
end

-------------------------------------
-- function makeTopUserInfo
-------------------------------------
function UIManager:makeTopUserInfo()
    if (not self.m_topUserInfo) and g_userData then
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
        self.m_uiList[i]:close()
    end
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

    if not isInstanceOf(ui, UI) then
        error('not a UI')
    end

    local list = self.m_uiList

    if table.find(list, ui) then
        error('attempt to open twice')
    end

    table.insert(list, ui)


    

    local mode = mode or UIManager.NORMAL

    if (mode == UIManager.SCENE) then
        self.m_uiLayer:addChild(ui.root, Z_ORDER_SCENE)

    elseif (mode == UIManager.NORMAL) then
        self.m_uiLayer:addChild(ui.root, Z_ORDER_NORMAL)

    elseif (mode == UIManager.POPUP) then
        self.m_uiLayer:addChild(ui.root, Z_ORDER_POPUP)

    elseif (mode == UIManager.TOOLTIP) then
        self.m_uiLayer:addChild(ui.root, Z_ORDER_TOOL_TIP)
    end

    -- 임시 터치 블록 영역 생성
    if (mode == UIManager.POPUP) then
        local visibleSize = cc.Director:getInstance():getVisibleSize()

        --[[
        -- 하위 UI가 클릭되지 않도록 버튼 생성
        local img = EMPTY_PNG
        local touchBlock = cc.MenuItemImage:create(img, img, img, 0)
        touchBlock:setDockPoint(cc.p(0, 0))
        touchBlock:setAnchorPoint(0, 0)
        --touchBlock:setContentSize(visibleSize.width, visibleSize.height)
        touchBlock:setRelativeSizeAndType(cc.size(0, 0), 3, false)
        ui.root:addChild(touchBlock, -100)
        --]]

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
            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_MOVED)
            listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_ENDED)
            listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_CANCELLED)

            local eventDispatcher = layer:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
        end

        -- 배경을 어둡게
        if (not ui.vars['bgLayerColor']) then
            local layerColor = cc.LayerColor:create( cc.c4b(0,0,0,150) )
            --[[
            layerColor:setDockPoint(cc.p(0, 0))
            layerColor:setAnchorPoint(0, 0)
            layerColor:setRelativeSizeAndType(cc.size(0, 0), 3, false)
            --]]

            layerColor:setDockPoint(cc.p(0.5, 0.5))
            layerColor:setAnchorPoint(cc.p(0.5, 0.5))
            layerColor:setRelativeSizeAndType(cc.size(1280, 810), 1, false)

            ui.root:addChild(layerColor, -100)
            ui.vars['bgLayerColor'] = layerColor

            -- 엑션에 추가
            ui:addAction(layerColor, UI_ACTION_TYPE_OPACITY, 0, 0.1)
        end

        if bNotBlendBGLayer then
            ui.vars['bgLayerColor']:setVisible(false)
        end
    end
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

    self.m_uiLayer:removeChild(ui.root, true)
    table.remove(list, idx)
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
-- function onKeyReleased
-------------------------------------
function UIManager:onKeyReleased(keyCode, event)
	if (keyCode == KEY_U) then
		local last_ui = table.getLast(self.m_uiList)
		local class_name = getClassName(last_ui) or last_ui.m_uiName
		self:toastNotificationGreen('## UI CLASS NAME : ' .. last_ui.m_uiName)
	elseif (keyCode == KEY_I) then
		local last_ui = table.getLast(self.m_uiList)
		self:toastNotificationGreen('## UI FILE : ' .. last_ui.m_resName)
	end
end