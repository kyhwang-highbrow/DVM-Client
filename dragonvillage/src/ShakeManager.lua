-------------------------------------
-- class ShakeManager
-------------------------------------
ShakeManager = class({
        m_world = 'GameWorld',
		m_shakeLayer = 'layer',
    })

-------------------------------------
-- function init
-------------------------------------
function ShakeManager:init(world, shake_layer)
    self.m_world = world
	self.m_shakeLayer = shake_layer
end

-------------------------------------
-- function doShake
-- @brief 화면 떨림 연출
-------------------------------------
function ShakeManager:doShake(x, y, duration, is_repeat, interval)
	-- 1. 변수 설정
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    local duration = (duration or SHAKE_DURATION) * timeScale
	local is_repeat = is_repeat or false
    local interval =  interval or 0.2

	-- 2. 기존에 있던 액션 중지
    self:stopShake()

	-- 3. 새로운 액션 설정 
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), interval)
	local sequence_action = cc.Sequence:create(start_action, end_action)

	-- 4. 실행
	if is_repeat then 
		self.m_shakeLayer:runAction(cc.RepeatForever:create(sequence_action))
	else
		self.m_shakeLayer:runAction(sequence_action)
	end
end

-------------------------------------
-- function doShake2
-- @brief 화면 떨림 연출
-------------------------------------
function ShakeManager:doShake2(duration, level)
	local level = level or 1
	local duration = duration or 0.5

	self.m_shakeLayer:stopAllActions()

	local shake_action = cc.RepeatForever:create(cc.Sequence:create(
		cc.MoveTo:create( 0.1, cc.p(0, -level) ),
		cc.MoveTo:create( 0.1, cc.p(0, level) )
	))

	local time_action = cc.Sequence:create(
		cc.DelayTime:create(duration),
		cc.CallFunc:create(function()
			self.m_shakeLayer:stopAllActions()
			self.m_shakeLayer:setRotation(0)
		end)
	)

	self.m_shakeLayer:runAction(shake_action)
	self.m_shakeLayer:runAction(time_action)

end

-------------------------------------
-- function stopShake
-- @brief 화면 떨림 연출 중지
-------------------------------------
function ShakeManager:stopShake()
	self.m_shakeLayer:stopAllActions()
end

-------------------------------------
-- function shakeByDistance
-- @brief 거리 기반 
-------------------------------------
function ShakeManager:shakeByDistance(dir, distance)
    local pos = getPointFromAngleAndDistance(dir, distance)
    self:doShake(pos['x'], pos['y'])
end

-------------------------------------
-- function shakeBySpeed
-- @brief 속도 기반
-------------------------------------
function ShakeManager:shakeBySpeed(dir, speed)
    local distance = math_clamp(speed / 20, 5, 50)
    self:shakeByDistance(dir, distance)
end

-------------------------------------
-- function doShakeForScript
-- @brief script missile 용 shake
-------------------------------------
function ShakeManager:doShakeForScript()
	local random1 = math_random(SHAKE_CUSTOM_MIN_POS, SHAKE_CUSTOM_MAX_POS)
	local random2 = math_random(SHAKE_CUSTOM_MIN_POS, SHAKE_CUSTOM_MAX_POS)
	self:doShake(random1, random2, SHAKE_CUSTOM_DURATION, true)
end