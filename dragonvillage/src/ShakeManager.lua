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
function ShakeManager:doShake(x, y, duration, is_repeat)
	-- 1. 변수 설정
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    local duration = duration or SHAKE_DURATION * timeScale
	local is_repeat = is_repeat or false

	-- 2. 기존에 있던 액션 중지
    self:stopShake()

	-- 3. 새로운 액션 설정 
    local start_action = cc.MoveTo:create(0, cc.p(x, y))
    local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(duration, cc.p(0, 0)), 0.2)
	local sequence_action = cc.Sequence:create(start_action, end_action)

	-- 4. 실행
	if is_repeat then 
		self.m_shakeLayer:runAction(cc.RepeatForever:create(sequence_action))
	else
		self.m_shakeLayer:runAction(sequence_action)
	end
end

-------------------------------------
-- function doShake
-- @brief 화면 떨림 연출 중지
-------------------------------------
function ShakeManager:stopShake()
	self.m_shakeLayer:stopAllActions()
end

-------------------------------------
-- function ShakeByDistance
-- @brief 거리 기반 
-------------------------------------
function ShakeManager:ShakeByDistance(dir, distance)
    local pos = getPointFromAngleAndDistance(dir, distance)
    self:doShake(pos['x'], pos['y'])
end

-------------------------------------
-- function ShakeBySpeed
-- @brief 속도 기반
-------------------------------------
function ShakeManager:ShakeBySpeed(dir, speed)
    local distance = math_clamp(speed / 20, 5, 50)
    self:ShakeByDistance(dir, distance)
end