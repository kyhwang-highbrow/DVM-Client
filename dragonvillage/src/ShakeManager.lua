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
-- function getStandardShake
-- @brief 표준 쉐이크를 반환
-------------------------------------
function ShakeManager:getStandardShake(duration, level, repeat_time)
	local interval = 0.2
	local rand_x = math_random(level-10, level)
	local rand_y = math_random(level-10, level)

	local sequence_action = cc.Sequence:create(
		cc.EaseIn:create(cc.MoveTo:create(duration, cc.p(rand_x, rand_y)), interval), 
		cc.EaseOut:create(cc.MoveTo:create(duration, cc.p(-rand_x, -rand_y)), interval)
	)

	return cc.Repeat:create(sequence_action, repeat_time)
end

-------------------------------------
-- function doShakeRandomAngle
-- @brief 화면 떨림 연출
-------------------------------------
function ShakeManager:doShakeRandomAngle(distance, duration, is_repeat, interval)
    local distance = (distance or 40)
    local angle = math_random(1, 360)
    local x = distance * math_cos(angle)
    local y = distance * math_sin(angle)
    self:doShake(x, y, duration, is_repeat, interval)
end

-------------------------------------
-- function doShake
-- @brief 화면 떨림 연출
-------------------------------------
function ShakeManager:doShake(x, y, duration, is_repeat, interval)
	-- 1. 변수 설정
    local timeScale = cc.Director:getInstance():getScheduler():getTimeScale()
    local duration = (duration or g_constant:get('INGAME', 'SHAKE_DURATION')) * timeScale
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
-- function doShakeUpDown
-- @param duration 지속시간
-- @param level 강도
-------------------------------------
function ShakeManager:doShakeUpDown(duration, level)
	local level = level or 1
	local duration = duration or 0.5

	self:stopShake()

	local shake_action = cc.RepeatForever:create(cc.Sequence:create(
		cc.MoveTo:create( 0.1, cc.p(0, -level) ),
		cc.MoveTo:create( 0.1, cc.p(0, level) )
	))

	local time_action = cc.Sequence:create(
		cc.DelayTime:create(duration),
		cc.CallFunc:create(function()
			self:stopShake()
			self.m_shakeLayer:setRotation(0)
		end)
	)

	self.m_shakeLayer:runAction(shake_action)
	self.m_shakeLayer:runAction(time_action)
end

-------------------------------------
-- function doShakeGrowling
-- @param duration 지속시간
-- @param level_low  강도
-------------------------------------
function ShakeManager:doShakeGrowling(duration, level_low, level_high, repeat_time)
	local duration = duration or 0.2
	local repeat_time = repeat_time or 4

	-- Stop Shake
	self:stopShake()
	
	-- 고 중 저 순으로 쉐이크
	local sequence_action = cc.Sequence:create(
		self:getStandardShake(duration, level_high, repeat_time*2), 
		self:getStandardShake(duration, (level_low + level_high)/2, repeat_time), 
		self:getStandardShake(duration, level_low, repeat_time*2)
	)

	-- Run Shake
	self.m_shakeLayer:runAction(sequence_action)
end

-------------------------------------
-- function stopShake
-- @brief 화면 떨림 연출 중지
-------------------------------------
function ShakeManager:stopShake()
	self.m_shakeLayer:stopAllActions()
    self.m_shakeLayer:setPosition(0, 0)
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
function ShakeManager:doShakeForScript(repeat_time)
	-- Stop Shake
	self:stopShake()
	
	local shake_custom_min_pos = g_constant:get('INGAME', 'SHAKE_CUSTOM_MIN_POS')
	local shake_custom_max_pos = g_constant:get('INGAME', 'SHAKE_CUSTOM_MAX_POS')

	local rand = math_random(shake_custom_min_pos, shake_custom_max_pos)
	local duration = 0.05
	local repeat_time = repeat_time or 0.2
	local repeat_cnt = repeat_time/duration
	
	local shake_action = self:getStandardShake(duration, rand, repeat_cnt)

	-- Run Shake
	self.m_shakeLayer:runAction(shake_action)
end
