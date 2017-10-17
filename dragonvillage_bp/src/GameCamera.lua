local MAX_SCALE = 1.5
local MIN_SCALE = 0.6

-------------------------------------
-- class GameCamera
-------------------------------------
GameCamera = class(IEventDispatcher:getCloneClass(), {
	m_world = 'GameWorld',
	m_node = 'cc.Node',
	m_cbActionEnd = 'function',

	m_bEnable = 'boolean',

	m_target = 'Unit',

    m_homeScale = 'number',
    m_homePosX = 'number',
    m_homePosY = 'number',

    m_prevHomePosX = 'number',
    m_prevHomePosY = 'number',

    -- 액션 사용시에는 액션이 끝났을때의 결과값을 가짐(액션 중간의 실시간 정보가 아님)
    m_curScale = 'number',
    m_curPosX = 'number',
    m_curPosY = 'number',

    m_range = 'table',  -- 카메라 이동 제한 범위(nil값인 경우 무제한)
})

-------------------------------------
-- function init
-------------------------------------
function GameCamera:init(world, node)
	self.m_world = world
	self.m_node = node
	
	self.m_bEnable = true

	self.m_target = nil

    self.m_homeScale = 1
    self.m_homePosX = 0
    self.m_homePosY = 0
    self.m_prevHomePosX = 0
    self.m_prevHomePosY = 0

    self.m_curScale = 1
    self.m_curPosX = 0
    self.m_curPosY = 0

    self:setRange(nil)

	self:reset()

    -- glnode 생성
    --[[
    do
        -- draw 함수 구현
        local function primitivesDraw(transform, transformUpdated)
            self:drawLine(transform, transformUpdated)
        end

        -- glNode 생성
        local glNode = cc.GLNode:create()
        glNode:registerScriptDrawHandler(primitivesDraw)

        local container = cc.Sprite:create(EMPTY_PNG)
        self.m_node:addChild(container, 100)

        container:addChild(glNode)
    end
    ]]--
end

-------------------------------------
-- function update
-------------------------------------
function GameCamera:update(dt)
	if not self.m_bEnable then return end

	local scale = self.m_node:getScale()
	local x, y = self.m_node:getPosition()

	if self.m_target then
		x = (-self.m_target.pos.x + (CRITERIA_RESOLUTION_X / 2)) * scale
		y = -self.m_target.pos.y * scale + 80
	end

	x, y = self:adjustPos(x, y, scale)

	self.m_node:setPosition(x, y)
end

-------------------------------------
-- function setHomeInfo
-------------------------------------
function GameCamera:setHomeInfo(tParam)
    local homeScale = tParam['scale'] or self.m_homeScale
    local homePosX = tParam['pos_x'] or self.m_homePosX
    local homePosY = tParam['pos_y'] or self.m_homePosY

    self.m_prevHomePosX = self.m_homePosX
    self.m_prevHomePosY = self.m_homePosY

    self.m_homeScale = self:adjustScale(homeScale)
    self.m_homePosX, self.m_homePosY = self:adjustPos(homePosX, homePosY)
    
    self:dispatch('camera_set_home', {}, self.m_homePosX, self.m_homePosY)
end

-------------------------------------
-- function getHomePos
-------------------------------------
function GameCamera:getHomePos()
    return self.m_homePosX, self.m_homePosY
end

-------------------------------------
-- function getPrevHomePos
-------------------------------------
function GameCamera:getPrevHomePos()
    return self.m_prevHomePosX, self.m_prevHomePosY
end

-------------------------------------
-- function getIntermissionOffset
-------------------------------------
function GameCamera:getIntermissionOffset()
    local gap_x = (self.m_homePosX - self.m_prevHomePosX)
    local gap_y = (self.m_homePosY - self.m_prevHomePosY)
    return gap_x, gap_y
end

-------------------------------------
-- function getHomeScale
-------------------------------------
function GameCamera:getHomeScale()
    return self.m_homeScale
end

-------------------------------------
-- function getPosition
-------------------------------------
function GameCamera:getPosition(bReal)
    if bReal then
        local x, y = self.m_node:getPosition()
        return -x, -y
    else
        return self.m_curPosX, self.m_curPosY
    end
end

-------------------------------------
-- function getScale
-------------------------------------
function GameCamera:getScale()
    return self.m_curScale
end

-------------------------------------
-- function setAction
-------------------------------------
function GameCamera:setAction(t_data)
	local scale = t_data['scale']
	local x = t_data['pos_x']
	local y = t_data['pos_y']
	local time = t_data['time'] or 1
	local cb = t_data['cb']

	local zoom_action
	local move_action
	local ease_action

	-- scale
	local prevScale = self.m_node:getScale()
	if scale then
		scale = self:adjustScale(scale)
		
		if scale ~= prevScale then
			zoom_action = cc.ScaleTo:create(time, scale)

            self.m_curScale = scale
		end
	else
		--scale = prevScale
        scale = self.m_curScale
	end
	
	-- pos
	local prevX, prevY = self.m_node:getPosition()
	if x and y then
		local nextX = -x * scale
		local nextY = -y * scale
		nextX, nextY = self:adjustPos(nextX, nextY, scale)
		
		if nextX ~= prevX or nextY ~= prevY then
			move_action = cc.MoveTo:create(time, cc.p(nextX, nextY))

            self.m_curPosX = x
            self.m_curPosY = y
		end
	end

	if zoom_action and move_action then
		local spawn_action = cc.Spawn:create(zoom_action, move_action)
		ease_action = cc.EaseIn:create(spawn_action, 2)

	elseif zoom_action then
		ease_action = cc.EaseIn:create(zoom_action, 2)

	elseif move_action then
		ease_action = cc.EaseIn:create(move_action, 2)

	end

	self.m_node:stopAllActions()

	if ease_action then
		self.m_node:runAction(cc.Sequence:create(
			ease_action,
			cc.CallFunc:create(function()
				if cb then cb() end
			end)
		))
	else
		if cb then cb() end
	end
end

-------------------------------------
-- function setTarget
-- @param target : Entity 오브젝트
-------------------------------------
function GameCamera:setTarget(target, t_data)
	self.m_target = target

	local t_data = t_data or {}
	local time = t_data['time'] or 0.4
	local cb = t_data['cb']

	-- 타겟이 설정된 경우 카메라 위치는 update에서 처리됨(타겟이 이동하는 경우 따라 움직여야하기 때문)
	if self.m_target then
		self:setAction({scale = t_data['scale'] or 1.15, time = time, cb = cb})
	else
		self:setAction({scale = t_data['scale'] or 1, time = time, cb = cb})
	end
end

-------------------------------------
-- function clearTarget
-------------------------------------
function GameCamera:clearTarget()
	self.m_target = nil
end

-------------------------------------
-- function reset
-- 카메라를 초기정보로 리셋
-------------------------------------
function GameCamera:reset(cb)
	self.m_target = nil

    self:setAction({scale = self.m_homeScale, pos_x = self.m_homePosX, pos_y = self.m_homePosY, time = 0.1, cb = cb})
end

-------------------------------------
-- function adjustScale
-------------------------------------
function GameCamera:adjustScale(scale)
	--scale = math_min(scale, MAX_SCALE)
	--scale = math_max(scale, MIN_SCALE)

	return scale
end

-------------------------------------
-- function adjustPos
-- @brief 게임 화면 안으로 들어오도록 위치 조절
-------------------------------------
function GameCamera:adjustPos(x, y, scale)
    
    local scale = scale or self.m_node:getScale()

    local minX = self.m_range['minX']
    local maxX = self.m_range['maxX']
    local minY = self.m_range['minY']
    local maxY = self.m_range['maxY']

    if minX then
        x = math_max(x, minX * scale)
    end
    if maxX then
	    x = math_min(x, maxX * scale)
    end
    if minY then
        y = math_max(y, minY * scale)
    end
    if maxY then
	    y = math_min(y, maxY * scale)
    end
	
	return x, y, scale
end

-------------------------------------
-- function setRange
-------------------------------------
function GameCamera:setRange(t)
    -- 모드에 따라 범위가 다르게 설정되어야함!!!!
    self.m_range = t or {}

    --cclog('GameCamera:setRange range = ' .. luadump(self.m_range))
end

-------------------------------------
-- function drawLine
-------------------------------------
function GameCamera:drawLine(transform)
    local x, y = self.m_node:getPosition()
    local scale = self.m_node:getScale()
    x = -x / scale
    y = -y / scale
        
    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    gl.lineWidth(1)

    cc.DrawPrimitives.drawColor4B(255, 0, 0, 255)
    cc.DrawPrimitives.drawLine(cc.p(x - CRITERIA_RESOLUTION_X, y), cc.p(x + CRITERIA_RESOLUTION_X, y))
    cc.DrawPrimitives.drawLine(cc.p(x, y + CRITERIA_RESOLUTION_Y), cc.p(x, y - CRITERIA_RESOLUTION_Y))
    
    kmGLPopMatrix()
end

-------------------------------------
-- function printInfo
-------------------------------------
function GameCamera:printInfo()
    local scale = self.m_node:getScale()
	local x, y = self.m_node:getPosition()

    cclog('-------------------------------------------------------')
	cclog('CAMARA POS : (' .. x .. ',' .. y .. ')')
    cclog('CAMARA SCALE : ' .. scale)
    cclog('-------------------------------------------------------')
end