-------------------------------------
-- class CameraTouchHandler
-- @brief 카메라의 터치를 관리하는 클래스
-------------------------------------
CameraTouchHandler = class({
        m_camera = 'Camera',

        -- 더블 탭 관련 변수
        m_tapInterval = 'number',   -- 탭과 탭 사이의 간격
        m_dobleTapDelay = 'number', -- 더블 탭 직후 0.5초간 터치 입력 제한
        m_prevTapPos = '{x, y}',    -- 직전 탭의 위치

        -- 핀치(줌) 관련 변수
        m_bDoingPinch = 'boolean',
        m_pinchTempPos = '{x, y}',
        m_pinchDistance = 'number',
        m_pinchCenterPos = '{x, y}',
        m_pinchStartPos = '{x, y}',
        m_pinchStartZoom = 'number',

        -- 키보드 관련 변수
        m_tPressedKey = 'table',

        m_onTouchBegan = '',
        m_onTouchMoved = '',
        m_onTouchEnded = '',
        m_onDoubleTap = '',
        m_onMoveStop = '',

        m_onTouchTap = '',

        m_tapTimer = '',

        m_useZoom = '',

        -- 자동 이동
        m_velocityX = '',
        m_velocityY = '',
        m_velocityTimer = '',
        m_dt = '',
        m_accelX = '',
        m_accelY = '',
    })

-------------------------------------
-- function init
-------------------------------------
function CameraTouchHandler:init(camera, target_node)
    self.m_camera = camera

    -- 더블탭
    self.m_tapInterval = 0
    self.m_dobleTapDelay = 0
    self.m_prevTapPos = {x=0, y=0}

    -- 핀치
    self.m_bDoingPinch = false
    self.m_pinchTempPos = nil
    self.m_pinchDistance = 0
    self.m_pinchCenterPos = nil
    self.m_pinchStartPos = nil
    self.m_pinchStartZoom = nil

    -- 키보드
    self.m_tPressedKey = {}

    self:makeTouchLayer(target_node)
    self:makeKeypad(target_node)
    self:makeScheduleUpdate(target_node)

    self.m_useZoom = true
    self.m_velocityTimer = 0
end

-------------------------------------
-- function getDistance
-------------------------------------
function CameraTouchHandler:getDistance(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
	return math_sqrt(dx*dx + dy*dy)
end

-------------------------------------
-- function makeTouchLayer
-- @brief 터치 레이어 생성
-------------------------------------
function CameraTouchHandler:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(touches, event) return self:onTouchBegan(touches, event) end, cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(function(touches, event) return self:onTouchMoved(touches, event) end, cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(function(touches, event) return self:onTouchEnded(touches, event) end, cc.Handler.EVENT_TOUCHES_ENDED)
    listener:registerScriptHandler(function(touches, event) return self:onTouchEnded(touches, event) end, cc.Handler.EVENT_TOUCHES_CANCELLED)

    local eventDispatcher = target_node:getEventDispatcher()
    --eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function CameraTouchHandler:onTouchBegan(touches, event)
    --cclog('CameraTouchHandler:onTouchBegan')
    self.m_tapTimer = 0

    if self.m_dobleTapDelay > 0 then
        return
    end

    local camera = self.m_camera

    -- 액션 중 터치 입력 시 액션 정지
    if camera.m_bDoingAction then
        camera:stopAction()
    end

    if (#touches == 1) and (touches[1]) then

        if (self.m_tapInterval <= 0.5) then
            local location = touches[1]:getLocation()
            local distance = self:getDistance(location['x'], location['y'], self.m_prevTapPos['x'], self.m_prevTapPos['y'])

            if distance <= 50 then
                self:onDoubleTap(touches, event)
            end
        end
    end

    self.m_tapInterval = 0
    self.m_prevTapPos = touches[1]:getLocation()

    if self.m_onTouchBegan then
        self.m_onTouchBegan(touches, event)
    end

    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function CameraTouchHandler:onTouchMoved(touches, event)
    --cclog('CameraTouchHandler:onTouchMoved')
    if self.m_dobleTapDelay > 0 then
        return
    end

    local camera = self.m_camera

    -- 액션 중 터치 입력 시 액션 정지
    if camera.m_bDoingAction then
        camera:stopAction()
    end

    if self.m_onTouchMoved then
        if (self.m_onTouchMoved(touches, event) == true) then
            return
        end
    end

    -- 멀티 터치 zoom
    if self.m_useZoom and (self.m_tPressedKey[12] or (#touches >= 2)) then

        local location1 = nil
        local location2 = nil

        -- keyCode 12 == 'shift key'
        if self.m_tPressedKey[12] then
            location1 = touches[1]:getLocation()

            if self.m_pinchTempPos then
                location2 = self.m_pinchTempPos
            else
                location2 = touches[1]:getLocation()
                location2['x'] = location2['x'] - 0
                location2['y'] = location2['y'] - 400

                self.m_pinchTempPos = {}
                self.m_pinchTempPos['x'] = location2['x']
                self.m_pinchTempPos['y'] = location2['y']
            end
        else
            location1 = touches[1]:getLocation()
            location2 = touches[2]:getLocation()
        end

        if (not self.m_bDoingPinch) then
            -- 투 지점의 거리 저장
            self.m_pinchDistance = self:getDistance(location1['x'], location1['y'], location2['x'], location2['y'])

            -- 터치한 두 지점의 가운데 위치 저장
            self.m_pinchCenterPos = {}
            self.m_pinchCenterPos['x'] = (location1['x'] + location2['x']) / 2
            self.m_pinchCenterPos['y'] = (location1['y'] + location2['y']) / 2
            self.m_pinchCenterPos = camera.m_stdNode:convertToNodeSpace(self.m_pinchCenterPos)

            -- 시작시 위치
            self.m_pinchStartPos = {}
            self.m_pinchStartPos['x'] = camera.m_posX
            self.m_pinchStartPos['y'] = camera.m_posY

            -- 시작시 줌
            self.m_pinchStartZoom = camera.m_zoom

            self.m_bDoingPinch = true
        else
            local new_dist = self:getDistance(location1['x'], location1['y'], location2['x'], location2['y'])

            local diff = new_dist - self.m_pinchDistance
            self.m_pinchDistance = new_dist
            diff = diff * 0.002

            local zoom = camera.m_zoom + diff
            camera:setZoom(zoom, true)

            -- 센터를 기준으로 줌
            local x = self.m_pinchStartPos['x'] - ((camera.m_zoom - self.m_pinchStartZoom) * (self.m_pinchCenterPos['x']))
            local y = self.m_pinchStartPos['y'] - ((camera.m_zoom - self.m_pinchStartZoom) * (self.m_pinchCenterPos['y']))
            camera:setPosition(x, y, true)
        end

    -- 싱글 터치(화면 이동)
    elseif (#touches == 1) then
        local touch = touches[1]
        local diff = touch:getDelta()
        local x, y = camera:adjustPos(camera.m_posX + diff.x, camera.m_posY + diff.y, camera.m_zoom)
        camera:setPosition(x, y, true)

        self.m_velocityX = diff['x'] / self.m_dt
        self.m_velocityY = diff['y'] / self.m_dt

        -- 0.5초만에 속도가 0이 되도록
        self.m_accelX = math_abs(self.m_velocityX) * 2
        self.m_accelY = math_abs(self.m_velocityY) * 2
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function CameraTouchHandler:onTouchEnded(touches, event)
    --cclog('CameraTouchHandler:onTouchEnded')
    local doing_pinch = self.m_bDoingPinch

    self.m_bDoingPinch = false
    self.m_pinchTempPos = nil

    if self.m_onTouchTap then
        self.m_onTouchTap(self.m_tapTimer, touches)
    end
    self.m_tapTimer = nil


    -- 이동하다 정지
    if (doing_pinch == false) then
        if (self.m_velocityY == nil) and (self.m_velocityX == nil) then
            if self.m_onMoveStop then
                self.m_onMoveStop()
            end
        end
    end

    if self.m_onTouchEnded then
        if self.m_onTouchEnded(touches, event) then
            return
        end
    end
end

-------------------------------------
-- function onDoubleTap
-------------------------------------
function CameraTouchHandler:onDoubleTap(touches, event)
    if self.m_onDoubleTap then
        if self.m_onDoubleTap(touches, event) then
            return
        end
    end

    -- 더블탭 기능 off
    if true then
        return
    end

    local camera = self.m_camera

    local pos = camera.m_stdNode:convertTouchToNodeSpace(touches[1])
    local zoom = 1.5

    camera:actionMoveAndZoom(0.5, -pos['x'], -pos['y'], zoom)
    self.m_dobleTapDelay = 0.5
end


-------------------------------------
-- function makeKeypad
-- @brief 키패드 생성 (윈도우에서 멀티터치 대용으로 사용)
-------------------------------------
function CameraTouchHandler:makeKeypad(target_node)
    local listener = cc.EventListenerKeyboard:create()

    listener:registerScriptHandler(function(keyCode, event) return self:onKeyPressed(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(function(keyCode, event) return self:onKeyReleased(keyCode, event) end, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onKeyPressed
-------------------------------------
function CameraTouchHandler:onKeyPressed(keyCode, event)
    self.m_tPressedKey[keyCode] = true
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function CameraTouchHandler:onKeyReleased(keyCode, event)
    self.m_tPressedKey[keyCode] = false
end

-------------------------------------
-- function makeScheduleUpdate
-------------------------------------
function CameraTouchHandler:makeScheduleUpdate(target_node)
    target_node:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function CameraTouchHandler:update(dt)
    self.m_tapInterval = self.m_tapInterval + dt

    if self.m_dobleTapDelay > 0 then
        self.m_dobleTapDelay = math_max(self.m_dobleTapDelay - dt, 0)
    end

    if self.m_tapTimer then
        self.m_tapTimer = self.m_tapTimer + dt
    end

    -- 터치 후에도 이동하도록 수정
    if (self.m_camera.m_bDoingAction == false) and (self.m_tapTimer == nil) then
        local camera = self.m_camera

        if self.m_velocityX or self.m_velocityY then

            local speed_x = 0
            local speed_y = 0

            -- x축 연선
            if self.m_velocityX then
                local sign = 1
                if (self.m_velocityX < 0) then
                    sign = -1
                end
                speed_x = math_abs(self.m_velocityX)
                speed_x = math_max(speed_x - (dt * self.m_accelX), 0) * sign

                if speed_x == 0 then
                    self.m_velocityX = nil
                else
                    self.m_velocityX = speed_x
                end
            end

            -- y축 연선
            if self.m_velocityY then
                local sign = 1
                if (self.m_velocityY < 0) then
                    sign = -1
                end
                speed_y = math_abs(self.m_velocityY)
                speed_y = math_max(speed_y - (dt * self.m_accelY), 0) * sign

                if speed_y == 0 then
                    self.m_velocityY = nil
                else
                    self.m_velocityY = speed_y
                end
            end

            -- 카메라 이동
            local x, y, adjusted_x, adjusted_y = camera:adjustPos(camera.m_posX + (speed_x * dt), camera.m_posY + (speed_y * dt), camera.m_zoom)
            camera:setPosition(x, y, true)

            if adjusted_x then
                self.m_velocityX = nil
            end

            if adjusted_y then
                self.m_velocityY = nil
            end

            -- 이동하다 정지
            if (self.m_velocityY == nil) and (self.m_velocityX == nil) then
                if self.m_onMoveStop then
                    self.m_onMoveStop()
                end
            end
        end
    elseif self.m_tapTimer then
        self.m_velocityTimer = self.m_velocityTimer + dt
        if self.m_velocityTimer >= 0.1 then
            self.m_velocityX = nil
            self.m_velocityY = nil
            self.m_velocityTimer = 0
        end
    end

    -- 한프레임에 이동하는 속도를 계산하기 위해 delta time을 저장
    self.m_dt = dt
end