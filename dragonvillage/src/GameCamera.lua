local MAX_SCALE = 4

-------------------------------------
-- class GameCamera
-------------------------------------
GameCamera = class({
	m_world = 'GameWorld',
	m_node = 'cc.Node',
	m_cbActionEnd = 'function',

	m_bEnable = 'boolean',

	m_target = 'Unit',

    m_homeScale = 'number',
    m_homePosX = 'number',
    m_homePosY = 'number',
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

	self:reset()
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
		--y = -self.m_target.pos.y * scale
        y = -self.m_target.pos.y * scale + 80
	end

	x, y = self:adjustPos(x, y, scale)

	self.m_node:setPosition(x, y)
end

-------------------------------------
-- function setHomeInfo
-------------------------------------
function GameCamera:setHomeInfo(tParam)
    self.m_homeScale = tParam['scale'] or self.m_homeScale
    self.m_homePosX = tParam['pos_x'] or self.m_homePosX
    self.m_homePosY = tParam['pos_y'] or self.m_homePosY
end

-------------------------------------
-- function getHomePos
-------------------------------------
function GameCamera:getHomePos()
    return self.m_homePosX, self.m_homePosY
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
		end
	else
		scale = prevScale
	end
	
	-- pos
	local prevX, prevY = self.m_node:getPosition()
	if x and y then
		local x = -x * scale
		local y = -y * scale
		x, y = self:adjustPos(x, y, scale)
		
		if x ~= prevX or y ~= prevY then
			move_action = cc.MoveTo:create(time, cc.p(x, y))
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

	-- 타겟이 설정된 경우 카메라 위치는 update에서 처리됨
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
	--scale = math_max(scale, 1)

	return scale
end

-------------------------------------
-- function adjustPos
-- @brief 게임 화면 안으로 들어오도록 위치 조절
-------------------------------------
function GameCamera:adjustPos(x, y, scale)
    --[[
	local scale = scale or self.m_node:setScale()

	local maxX = CRITERIA_RESOLUTION_X / 2 * (scale - 1)
	local minX = -maxX
	local maxY = CRITERIA_RESOLUTION_Y / 2 * (scale - 1)
	local minY = -maxY

	x = math_min(x, maxX)
	x = math_max(x, minX)
	y = math_min(y, maxY)
	y = math_max(y, minY)
    ]]--
	return x, y, scale
end