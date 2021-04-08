local PARENT = Entity

MISSILE_TYPE = {}
MISSILE_TYPE['NORMAL'] = 1
MISSILE_TYPE['normal'] = 1
MISSILE_TYPE['PASS'] = 2
MISSILE_TYPE['pass'] = 2
MISSILE_TYPE['PASS_STRONG'] = 3
MISSILE_TYPE['pass_strong'] = 3
MISSILE_TYPE['PASS_LASER'] = 4
MISSILE_TYPE['pass_laser'] = 4
MISSILE_TYPE['SPLASH'] = 5
MISSILE_TYPE['splash'] = 5

SIZE_UP_SCALE = (10-1)

-------------------------------------
-- class Missile
-------------------------------------
Missile = class(PARENT, {
        m_owner = '',
        m_afterimageMove = '',
        m_bAfterimage = 'boolean',

        -------------------------------------------------------
        -- 드래곤히어로즈 미사일 변수
        m_aiParam = '',

        m_acceleration = '',
        m_resetTimer = '',

        -- 최고, 최저 속도
        m_minSpeed = 'number',
        m_maxSpeed = 'number',

        m_baseScale = '',
        m_baseBodySize = '',

        m_accelDelay = 'number',        -- n초 후에만 accel 적용(n초 동안은 speed만 적용)
		m_accelReverseInterval = 'number',	-- n초마다 accel * -1
		m_accelReverseTimer = 'number',
		m_speedReverseInterval = 'number', -- n초마다 speed * -1
		m_speedReverseTimer = 'number',

        m_deleteTime = 'number',        -- n초 후에 해당 투사체 순식간에 작아지며 소멸
        m_vanishTime = 'number',        -- n초 후에 갑자기 사라짐
        m_explosionTime = 'number',     -- n초 후에 해당 투사체 폭발(반경 50픽셀 데미지)
        m_explosionTime2 = 'number',    -- n초 후에 해당 투사체 폭발(반경 75픽셀 데미지)
        m_explosionTime3 = 'number',    -- n초 후에 해당 투사체 폭발(반경 150픽셀 데미지)
        m_resetTime = 'number',         -- n초마다 충돌 리스트 삭제
        m_resetTimeDelay = 'number',    -- n초마다 충돌 리스트 삭제 시간 지연
        m_sizeUpTime = 'number',        -- n초에 걸쳐 리소스 및 충돌박스가 10배로 커짐
        m_magnetTime = 'number',        -- n초 후에 영웅 방향으로 빨려들어감
        m_tRotateTime = 'table',        -- 특정 시간마다 특정 각도 회전

		m_fadeoutTime = 'number',		-- n초 후에 특정 시간 동안 fade out 으로 소멸
		m_mapShakeTime = 'number',		-- n초까지 map을 shake한다.
		m_collisionCheckTime = 'number',-- n초 후부터 충돌체크, 이전에는 하지 않음

        m_angularVelocity = 'number',   -- 초당 n도씩 회전
        m_tAngularVelocity = 'table',   -- 특정 시간마다 초당 회전각 변경
		m_bNoRotate = 'boolean',		-- 미사일 리소스 회전 여부

        m_passSpeed = 'number',         -- 관통형 미사일이 충돌되었을 때 0.08초간 멈추기 직전의 이동 속도

        m_remainHitCount = 'number',    -- 남은 타격 횟수(nil일 경우 제한 없음)
        -------------------------------------------------------

        m_activityCarrier = '',
        m_bPassType = 'boolean',        -- 관통 타입인지 여부
        m_bNoCheckRange = 'boolean',    -- 범위 체크를 하지 않는지 여부(체크할 경우 일정 범위 밖으로 나가면 자동 삭제됨)
		
		-- 확정 타겟 개념 추가 후 필요한 변수들
		m_target = '',
        m_targetBody = '',
		m_isFadeOut = 'bool',
        m_lFixedTargetCollision = 'table',  -- 확정된 타겟 충돌 정보 리스트


		-- 미사일이 미사일을 쏜다
		m_addScript = 'table',
		m_addScriptStart = '',
		m_addScriptTerm = '',
		m_addScriptMax = '',
		m_addScriptDead = 'bool',			-- add된 탄을 다쏘면 부모 미사일을 죽임.
		m_addScriptRelative = 'bool',		-- 상대 각도
        m_addScriptTargetList = 'table',    -- 부모 미사일 발사시 지정된 타겟 리스트
        m_addScriptTargetIdx = 'table',     -- 부모 미사일의 target_idx
		m_lAddScriptTime = 'list',			-- 탄 발사 시간을 저장해놓아 프레임 저하가 있어도 전부 발사되도록함
		m_fireCnt = '',

     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Missile:init(file_name, body, ...)
    self.m_owner = nil

    -------------------------------------------------------
    -- 드래곤히어로즈 미사일 변수
    self.m_acceleration = 0
    self.m_resetTimer = nil

    self.m_accelDelay = nil

	self.m_accelReverseInterval = nil
	self.m_accelReverseTimer = nil
	self.m_speedReverseInterval = nil
	self.m_speedReverseTimer = nil

    self.m_deleteTime = nil
    self.m_vanishTime = nil
    self.m_explosionTime = nil
    self.m_explosionTime2 = nil
    self.m_explosionTime3 = nil
    self.m_sizeUpTime = nil
    self.m_magnetTime = nil
    self.m_tRotateTime = nil
    self.m_angularVelocity = nil
    self.m_tAngularVelocity = nil
	self.m_bNoRotate = nil
    -------------------------------------------------------

    -- 드래곤빌리지에서 추가
    self.m_afterimageMove = 0
    self.m_bPassType = false
    self.m_bNoCheckRange = false

	self.m_isFadeOut = false
	self.m_fadeoutTime = nil
	self.m_mapShakeTime = nil
	self.m_collisionCheckTime = nil

	self.m_addScript = nil
    self.m_addScriptTargetList = nil
    self.m_addScriptTargetIdx = nil
	self.m_fireCnt  = 0
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Missile:initAnimator(file_name)
    -- Animator 삭제
    if self.m_animator then
        self.m_animator:release()
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)

    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function Missile:initState()
    self:addState('move', Missile.st_move, 'move', true)
    self:addState('delete', Missile.st_delete, nil, true)
    self:addState('explosion', Missile.st_explosion, nil, true)
    self:addState('explosion2', Missile.st_explosion2, nil, true)
    self:addState('explosion3', Missile.st_explosion3, nil, true)
    self:addState('splash', Missile.st_splash, nil, true)
    self:addState('magnet', Missile.st_magnet, nil, true)
    self:addState('hole', Missile.st_hole, nil, true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('move')
end

-------------------------------------
-- function updatePhys
-------------------------------------
function Missile:updatePhys(dt)
    if (not self.apply_movement or self.m_temporaryPause) then return end

    local ogr_speed = self.speed

    -- 목표 대상이 존재하는 경우 대상을 지나치지 않도록 속도를 조절
    if (not self.m_bPassType and self.body.size > 0) then
        if (dt > 0 and self.m_target) then
            local pos_x, pos_y = self:getCenterPos()
            local target_x, target_y

            if (self.m_targetBody) then
                target_x = self.m_target.pos.x + self.m_targetBody['x']
                target_y = self.m_target.pos.y + self.m_targetBody['y']
            else
                target_x, target_y = self.m_target:getCenterPos()
            end

            local distance = getDistance(pos_x, pos_y, target_x, target_y)
            self.speed = math_min(self.speed, distance / dt)
        end
    end
    
    PARENT.updatePhys(self, dt)

    self.speed = ogr_speed
end

-------------------------------------
-- function setPosition
-------------------------------------
function Missile:setPosition(x, y)
    Entity.setPosition(self, x, y)

    if (self.m_world) then
        if (not self.m_bNoCheckRange and self.m_world:checkMissileRange(x, y)) then
            self:changeState('dying')
        end
    end
end

-------------------------------------
-- function getAdjustSpeed
-------------------------------------
function Missile:getAdjustSpeed(speed)
    if self.m_minSpeed and speed < self.m_minSpeed then
        speed = self.m_minSpeed
    end

    if self.m_maxSpeed and speed > self.m_maxSpeed then
        speed = self.m_maxSpeed
    end

    return speed
end

-------------------------------------
-- function st_move
-------------------------------------
function Missile.st_move(owner, dt)
    -- 가속 여부(가속도가 양수이고, 가속 딜레이가 없거나, 가속 딜레이의 시간이 지났을 경우
    local can_accel = (owner.m_acceleration ~= 0) and ((not owner.m_accelDelay) or (owner.m_stateTimer >= owner.m_accelDelay))

    if can_accel then
        local speed = owner.speed + (owner.m_acceleration * dt)
        speed = owner:getAdjustSpeed(speed)
        owner:setSpeed(speed)
    end

    -- 옵션 체크
    owner:updateMissileOption(dt)
end

-------------------------------------
-- function st_delete
-------------------------------------
function Missile.st_delete(owner, dt)
    if owner.m_stateTimer == 0 then
        owner.m_baseScale = owner.m_animator:getScale()
        owner.m_baseBodySize = owner.body.size
    else
        local rate = dt * 5

        -- 비주얼 크기
        local scale = owner.m_animator:getScale() - (owner.m_baseScale * rate)
        scale = math_max(scale, 0)
        owner.m_animator:setScale(scale)

        -- 충돌 영역
        local body_size = owner.body.size - (owner.m_baseBodySize * rate)
        body_size = math_max(body_size, 0)
        PhysObject_setBody(owner, owner.body.x, owner.body.y, body_size)

        if scale <= 0 then
            owner:changeState('dying')
        end
    end
end

-------------------------------------
-- function st_explosion
-------------------------------------
function Missile.st_explosion(owner, dt)
    if owner.m_stateTimer == 0 then
        --VrpHelper:makeVrpEffect(GameMgr.m_hitEffectNode, 'res/effect/effect_hit_effect/effect_hit_effect', 'hit_effect_splash_fire_critical', owner.pos.x, owner.pos.y)
    end

    local body_size = owner.body.size + (dt * 30000)
    if body_size >= 250 then
        body_size = 250
        if owner.m_stateTimer >= 0.1 then
            owner:changeState('dying')
        end
    end    
    PhysObject_setBody(owner, owner.body.x, owner.body.y, body_size)
end

-------------------------------------
-- function st_explosion2
-------------------------------------
function Missile.st_explosion2(owner, dt)
    if owner.m_stateTimer == 0 then
        --VrpHelper:makeVrpEffect(GameMgr.m_hitEffectNode, 'res/a2d/effect_bomb_critical/effect_bomb_critical', 'idle', owner.pos.x, owner.pos.y)
    end

    local body_size = owner.body.size + (dt * 30000)
    if body_size >= 75 then
        body_size = 75
        if owner.m_stateTimer >= 0.1 then
            owner:changeState('dying')
        end
    end
    PhysObject_setBody(owner, owner.body.x, owner.body.y, body_size)
end

-------------------------------------
-- function st_explosion3
-------------------------------------
function Missile.st_explosion3(owner, dt)
    if owner.m_stateTimer == 0 then
        --VrpHelper:makeVrpEffect(GameMgr.m_hitEffectNode, 'res/a2d/effect_bomb_critical/effect_bomb_critical', 'idle', owner.pos.x, owner.pos.y)
    end

    local body_size = owner.body.size + (dt * 30000)
    if body_size >= 150 then
        body_size = 150
        if owner.m_stateTimer >= 0.1 then
            owner:changeState('dying')
        end
    end
    PhysObject_setBody(owner, owner.body.x, owner.body.y, body_size)
end

-------------------------------------
-- function st_splash
-------------------------------------
function Missile.st_splash(owner, dt)
    owner.speed = 0
    local body_size = owner.body.size + (dt * 30000)
    if body_size >= 200 then
        body_size = 200
        if owner.m_stateTimer >= 0.1 then
            owner:changeState('dying')
        end
    end

    PhysObject_setBody(owner, owner.body.x, owner.body.y, body_size)
end

-------------------------------------
-- function st_magnet
-------------------------------------
function Missile.st_magnet(owner, dt)
    -- 속도 지정, PhysWorld의 영향을 받지 않음
    if owner.m_stateTimer == 0 then
        owner:setSpeed(1500)
        owner.apply_force = false
    end

	--[[
	-- 드히코드가 그대로 있음
    -- 영웅의 방향으로 이동
    local hero = GameMgr:getCurHero()
    local hero_x, hero_y = hero:getCenterPos()
    if (not hero.m_bDead) then
        local dest_degree = getDegree(owner.pos.x, owner.pos.y, hero_x, hero_y)
        owner:setDir(dest_degree)
    else
        owner:changeState('move')
    end
	]]
end

-------------------------------------
-- function st_hole
-------------------------------------
function Missile.st_hole(owner, dt)
    -- 속도 지정, PhysWorld의 영향을 받지 않음
    if owner.m_stateTimer == 0 then
        owner:setSpeed(500)
    else
        owner.speed = owner.speed + (dt * 3000)
        owner:setSpeed(owner.speed)
    end
    
    if owner:isOverTargetPos() then
        owner:setPosition(owner.m_targetPosX, owner.m_targetPosY)
        owner:setSpeed(0)
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function updateMissileOption
-------------------------------------
function Missile:updateMissileOption(dt)
	
	-- n초마다 accel 역전.
	if (self.m_accelReverseInterval) then
	    -- 초기화
		if (not self.m_accelReverseTimer) then
            self.m_accelReverseTimer = 0
        end
		
		-- 시간
		self.m_accelReverseTimer = self.m_accelReverseTimer + dt
		
		-- 조건 충족시 처리
		if (self.m_accelReverseTimer >= self.m_accelReverseInterval) then
			self.m_accelReverseTimer = self.m_accelReverseTimer - self.m_accelReverseInterval
			self.m_acceleration = -self.m_acceleration
		end
	end

	-- n초마다 speed 역전.
	if (self.m_speedReverseInterval) then
	    -- 초기화
		if (not self.m_speedReverseTimer) then
            self.m_speedReverseTimer = 0
        end
		
		-- 시간
		self.m_speedReverseTimer = self.m_speedReverseTimer + dt
		
		-- 조건 충족시 처리
		if (self.m_speedReverseTimer >= self.m_speedReverseInterval) then
			self.m_speedReverseTimer = self.m_speedReverseTimer - self.m_speedReverseInterval
			self.speed = -self.speed
		end
	end

    -- n초마다 충돌 리스트 삭제
    if self.m_resetTime then
        if (not self.m_resetTimeDelay) or (self.m_resetTimeDelay <= self.m_stateTimer) then
            if (not self.m_resetTimer) then
                self.m_resetTimer = self.m_resetTime
            end
        
            self.m_resetTimer = self.m_resetTimer - dt
            if (self.m_resetTimer <= 0) then
                self.m_resetTimer = self.m_resetTimer + self.m_resetTime
                self:clearCollisionObjectList()
            end
        end
    end

	-- n초 후까지 map shake
    if self.m_mapShakeTime then
		if self.m_stateTimer == 0 then
			self.m_world.m_shakeMgr:doShakeForScript(self.m_mapShakeTime)
            self.m_mapShakeTime = nil
        end
    end

    -- n초 후 부터 충돌 체크 시작
    if self.m_collisionCheckTime then
        self:setEnableBody(self.m_stateTimer > self.m_collisionCheckTime)
    end


    -- n초에 걸쳐 리소스 및 충돌박스가 SIZE_UP_SCALE배로 커짐
    if self.m_sizeUpTime then
        if self.m_stateTimer == 0 then
            self.m_baseScale = self.m_animator:getScale()
            self.m_baseBodySize = self.body.size
        elseif self.m_stateTimer < self.m_sizeUpTime then
            local scale = self.m_baseScale + (self.m_baseScale * (self.m_stateTimer/self.m_sizeUpTime) * SIZE_UP_SCALE)
            self.m_animator:setScale(scale)

            local size = self.m_baseBodySize + (self.m_baseBodySize * (self.m_stateTimer/self.m_sizeUpTime) * SIZE_UP_SCALE)
            PhysObject_setBody(self, self.body.x, self.body.y, size)

        elseif self.m_stateTimer >= self.m_sizeUpTime then
            self.m_animator:setScale(self.m_baseScale * SIZE_UP_SCALE)
            PhysObject_setBody(self, self.body.x, self.body.y, self.m_baseBodySize * SIZE_UP_SCALE)
            self.m_sizeUpTime = nil
        end
    end

	-- 특정 시간마다 특정 각도 회전
    if self.m_tRotateTime and self.m_tRotateTime[1] then
        if self.m_tRotateTime[1][1] <= self.m_stateTimer then
            local dir = self.movement_theta + self.m_tRotateTime[1][2]
            self:setDir(dir)
			if (not self.m_bNoRotate) then 
				self:setRotation(dir)
			end
            table.remove(self.m_tRotateTime, 1)
        end
    end

	-- 특정 시간마다 초당 회전각 변경
    if self.m_tAngularVelocity and self.m_tAngularVelocity[1] then
        if self.m_tAngularVelocity[1][1] <= self.m_stateTimer then
            self.m_angularVelocity = self.m_tAngularVelocity[1][2]
            table.remove(self.m_tAngularVelocity, 1)
        end
    end

	-- 초당 n도씩 회전
    if self.m_angularVelocity then
        local dir = self.movement_theta + (self.m_angularVelocity * dt)
        local dir = getAdjustDegree(dir)
        self:setDir(dir)
		if (not self.m_bNoRotate) then 
			self:setRotation(dir)
		end
    end

    -- 바디 사이즈의 간격으로 잔상 생성, 잔상은 3개 정도 보이도록 유지
    if self.m_bAfterimage then
        self.m_afterimageMove = self.m_afterimageMove + (self.speed * dt)

        local interval = self.body.size * 0.2 -- 반지름이기 때문에 2배

        if (self.m_afterimageMove >= interval) then

            self.m_afterimageMove = self.m_afterimageMove - interval
    
            local duration = (interval / self.speed) * 0.2 -- 3개의 잔상이 보일 정도
            duration = math_clamp(duration, 0.3, 0.7)

            local res = self.m_animator.m_resName
			local scale = self.m_animator:getScale()
            local rotation = self.m_animator:getRotation()

			-- GL calls를 줄이기 위해 월드를 통해 sprite를 얻어옴
			local sprite = self.m_world:getDragonBatchNodeSprite(res, scale)
			sprite:setFlippedX(self.m_animator.m_bFlip)
			sprite:setRotation(rotation)
			sprite:setOpacity(255 * 0.3)
			sprite:setPosition(self.pos.x, self.pos.y)

            sprite:runAction(cc.Sequence:create(cc.FadeTo:create(duration*duration, 0), cc.RemoveSelf:create()))
            sprite:runAction(cc.ScaleTo:create(duration*duration, 0))
        end
    end

	-- 확정 공격시 타겟 위치에서 소멸
	if self.bFixedAttack and self.m_target then -- physobject에서의 멤버변수라 m_이 안붙어있다.
		-- 지났는지 체크
		local isPassedTarget = false
        local target_x

        if (self.m_targetBody) then
            target_x = self.m_target.pos.x + self.m_targetBody['x']
        else
            target_x = self.m_target:getCenterPos()
        end

		if (self.m_target.m_bLeftFormation) then
            if (self.pos.x < target_x - 10) then isPassedTarget = true end
        else
			if (self.pos.x > target_x + 10) then isPassedTarget = true end
        end

		-- fade out 처리, motion streak 는 fade out 불가..
		if (isPassedTarget) and 
		(not self.m_isFadeOut) and
		(self.m_animator.m_node) then 
			local fade_out_time = g_constant:get('INGAME', 'MISSILE_FADE_OUT_TIME')
			local removeMissile = cc.CallFunc:create(function() self:changeState('dying') end)
			self.m_animator.m_node:runAction( cc.Sequence:create(cc.FadeOut:create(fade_out_time), removeMissile))
			self.m_isFadeOut = true
		end
	end

	-- 미사일이 미사일을 쏜다ㅏ아아아아ㅏ
	if (self.m_addScript) then
		-- 0. 미리 구한 add missile time list 를 돌면서 시간이 지난 탄을 발사한다
		for i, time in ipairs(self.m_lAddScriptTime) do
			if (self.m_stateTimer > time) then 
				-- 1. 발사!
				self:fireAddScriptMissile()
				self.m_fireCnt = self.m_fireCnt + 1
				table.remove(self.m_lAddScriptTime, i)
				-- 2. 최대발사수가 -1인 경우에는 제한 없이 발사하게 된다.
				if (self.m_addScriptMax ~= -1) then
					-- 2-1. 최대 발사 수 도달 시 스크립트를 지워 처리
					if (self.m_fireCnt >= self.m_addScriptMax) then 
						self.m_addScript = nil
						-- 2-2. addScript 탄을 전부 쏘면 현재 탄을 지우는 기능
						if (self.m_addScriptDead) then 
							self:changeState('dying')
						end
						break
					end
				end
			end
		end
	end

	----------------------------------------------------------------------------------------------------------------------
	-- # State가 변경되는 옵션들은 하위로 몰아둔다.
	----------------------------------------------------------------------------------------------------------------------
    -- n초 후에 영웅 방향으로 빨려들어감
	if self.m_magnetTime then
        if self.m_magnetTime <= self.m_stateTimer then
            self.m_magnetTime = nil
            self:changeState('magnet')
            return true
        end
    end

	
    -- n초 후에 해당 투사체 폭발(반경 50픽셀 데미지)
    if self.m_explosionTime then
        if self.m_explosionTime <= self.m_stateTimer then
            self.m_explosionTime = nil
            self:changeState('explosion')
            return true
        end
    end

    -- n초 후에 해당 투사체 폭발(반경 75픽셀 데미지)
    if self.m_explosionTime2 then
        if self.m_explosionTime2 <= self.m_stateTimer then
            self.m_explosionTime2 = nil
            self:changeState('explosion2')
            return true
        end
    end

    -- n초 후에 해당 투사체 폭발(반경 150픽셀 데미지)
    if self.m_explosionTime3 then
        if self.m_explosionTime3 <= self.m_stateTimer then
            self.m_explosionTime3 = nil
            self:changeState('explosion3')
            return true
        end
    end

    -- n초 후에 해당 투사체 순식간에 작아지며 소멸
    if self.m_deleteTime then
        if self.m_deleteTime <= self.m_stateTimer then
            self.m_deleteTime = nil
            self:changeState('delete')
            return true
        end
    end

    -- n초 후에 갑자기 사라짐
    if self.m_vanishTime then
        if self.m_vanishTime <= self.m_stateTimer then
            self.m_vanishTime = nil
            self:changeState('dying')
            return true
        end
    end
	
    -- n초 후에 fade out
    if self.m_fadeoutTime then
        if (self.m_fadeoutTime <= self.m_stateTimer) then
            self.m_fadeoutTime = nil
			local removeMissile = cc.CallFunc:create(function() 
				self:changeState('dying') 
			end)
			local fade_out_time = g_constant:get('INGAME', 'MISSILE_FADE_OUT_TIME')
			self.m_animator:runAction(cc.Sequence:create(cc.FadeOut:create(fade_out_time), removeMissile))
            return true
        end
    end
	
    return false
end

-------------------------------------
-- function getBodySizeFromAnimator
-- @brief 박스 지정. 미지정 시 png 세로 사이즈의 80% 크기를 중앙에 배치
-------------------------------------
function Missile:getBodySizeFromAnimator()

    -- 1. 컨텐츠 크기를 얻어옴
    local content_size = self.m_animator.m_node:getContentSize()

    -- 2. 작은 크기를 얻어옴
    local min_size = math_min(content_size['width'], content_size['height'])

    -- 3. 80%의 크기, 반지름이므로 2로 나눈 0.4를 곱함
    local body_size = min_size * 0.4
    
    return body_size
end

-------------------------------------
-- function fireAddScriptMissile
-------------------------------------
function Missile:fireAddScriptMissile()
    local start_x = self.pos.x 
    local start_y = self.pos.y
	local owner = self.m_activityCarrier:getActivityOwner()

    -- 미사일 런쳐 (target, dir, left or right)
    local missile_launcher = MissileLauncher(nil)
    local t_launcher_option = missile_launcher:getOptionTable()

    -- 속성 : activityCarrier 에 있는 것은 숫자기 때문에 변환해준다
	local attr_name = attributeNumToStr(self.m_activityCarrier.m_attribute)
    t_launcher_option['attr_name'] = attr_name
    t_launcher_option['target_list'] = self.m_addScriptTargetList

	local phys_group = owner:getMissilePhysGroup()
    
    -- AttackDamage 생성 및 상태효과 복사(테이블의 상태효과를 add_script에도 적용시킴)
    local activity_carrier = owner:makeAttackDamageInstance()
	activity_carrier.m_lStatusEffectRate = clone(self.m_activityCarrier.m_lStatusEffectRate)
    activity_carrier:setAtkDmgStat(self.m_activityCarrier.m_atkDmgStat)
    activity_carrier:setAttackType(self.m_activityCarrier:getAttackType())
    activity_carrier:setSkillId(self.m_activityCarrier:getSkillId())
    activity_carrier:setSkillHitCount(self.m_activityCarrier:getSkillHitCount())
	activity_carrier:setPowerRate(self.m_activityCarrier:getPowerRate())
    activity_carrier:setAddCriPowerRate(self.m_activityCarrier:getAddCriPowerRate())
    activity_carrier:setIgnoreByTable(self.m_activityCarrier.m_ignoreTable)
    
    self.m_world:addToUnitList(missile_launcher)
    self.m_world.m_worldNode:addChild(missile_launcher.m_rootNode)
    
    local t_param = {}

    if (self.m_addScriptRelative) then
        t_param['dir'] = self.movement_theta
    end
    if (self.m_addScriptTargetIdx) then
        t_param['target_idx'] = self.m_addScriptTargetIdx
    end


    missile_launcher:init_missileLauncherByScript(self.m_addScript, phys_group, activity_carrier, t_param)
    missile_launcher.m_animator:changeAni('animation', true)
    missile_launcher:setPosition(start_x, start_y)
    missile_launcher.m_owner = owner
end

-------------------------------------
-- function release
-- @brief
-------------------------------------
function Missile:release()
    local world = self.m_world
	if (world) then
		world.m_lMissileList[self] = nil
		world.m_lSpecailMissileList[self] = nil
	end

	PARENT.release(self)
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function Missile:setTemporaryPause(pause)
    if (PARENT.setTemporaryPause(self, pause)) then
        if (pause) then
            if (self.m_animator) then
                self.m_animator:setVisible(false)
            end
        else
            if (self.m_animator) then
                self.m_animator:setVisible(true)
            end
        end

        return true
    end

    return false
end

-------------------------------------
-- table MissileHitCB
-------------------------------------
MissileHitCB = {}

-------------------------------------
-- function normal
-------------------------------------
MissileHitCB.normal = function(attacker, defender, i_x, i_y)
    attacker:setEnableBody(false)
    attacker:changeState('dying')

    attacker.bFixedAttack = false
end

-------------------------------------
-- function pass
-------------------------------------
MissileHitCB.pass = function(attacker, defender, i_x, i_y)
    if (attacker.m_remainHitCount) then
        attacker.m_remainHitCount = attacker.m_remainHitCount - 1

        if (attacker.m_remainHitCount <= 0) then
            attacker:setEnableBody(false)
            attacker:changeState('dying')
        end
    end
end

-------------------------------------
-- function splash
-------------------------------------
MissileHitCB.splash = function(attacker, defender, i_x, i_y)
    if attacker.m_state ~= 'splash' then
        if attacker.m_animator.m_node then
            attacker.m_animator.m_node:setVisible(false)
        end
        attacker:setPosition(defender.pos.x + defender.body.x, defender.pos.y + defender.body.y)
        attacker:changeState('splash')
    end
end




-------------------------------------
-- class MissileInstant
-------------------------------------
MissileInstant = class(Missile, {
        m_duration = 'number',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileInstant:init(file_name, body)
end

-------------------------------------
-- function initState
-------------------------------------
function MissileInstant:initState()
    Missile.initState(self)

    self:addState('move', MissileInstant.st_move, 'move', false)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileInstant.st_move(owner, dt)
    if (not owner.m_duration) then
        if owner.m_stateTimer == 0 then
            -- 애니메이션 종료 콜백
            owner:addAniHandler(function() owner:changeState('dying') end)
        end
    else
        if (owner.m_duration <= owner.m_stateTimer) then
            owner:changeState('dying')
        end
    end

    Missile.st_move(owner, dt)
end