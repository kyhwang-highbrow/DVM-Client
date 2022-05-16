-------------------------------------
-- class MissileFactory
-------------------------------------
MissileFactory = class({
        m_world = 'GameWorld',
        m_missileDepthMap = 'table key:res, value:depth',
        m_missileDepthIdx = 'number',
    })
    
-------------------------------------
-- function init
-------------------------------------
function MissileFactory:init(world)
    self.m_world = world
    self.m_missileDepthMap = {}
    self.m_missileDepthIdx = 1
end

-------------------------------------
-- class makeMissile
-------------------------------------
function MissileFactory:makeMissile(t_option)
    if t_option['movement'] and t_option['movement'] == 'zigzag' then
        local t_missile = {}

        -- 공격력 1/2
        if t_option['attack_damage'] then
            local power_idx = t_option['power_idx'] or 1
            t_option['attack_damage'] = t_option['attack_damage']:cloneForMissile()
            for i,v in pairs(t_option['attack_damage'].m_tBaseAtkDmg) do
                t_option['attack_damage'].m_tBaseAtkDmg[i] = (t_option['attack_damage'].m_tBaseAtkDmg[i] / 2)
            end
        end
        
        -- 왼쪽 미사일
        t_option['movement'] = 'zigzag_l'
        local left = self:makeMissile_(t_option)
        if left then table.insert(t_missile, left) end

        -- 오른쪽 미사일
        t_option['movement'] = 'zigzag_r'
        local right = self:makeMissile_(t_option)
        if right then table.insert(t_missile, right) end

        return t_missile
        
    else
        if t_option['is_effect'] then
            return self:makeMissileEffect(t_option)
        else
            return self:makeMissile_(t_option)
        end
    end
end

-------------------------------------
-- function makeMissileEffect
-------------------------------------
function MissileFactory:makeMissileEffect(t_option)
    local target =           t_option['target']
    local missile_res_name = t_option['missile_res_name'] or nil
    local dir =              t_option['dir'] or 270
    local pos_x =            t_option['pos_x'] or 320
    local pos_y =            t_option['pos_y'] or 400
    local depth =            t_option['depth'] or 0
    --local sync_pos =         t_option['sync_pos'] or false
    local visual =           t_option['visual'] or 'idle'
    local scale =            t_option['scale'] or 1
    local parent =           t_option['parent']

    local visual = VrpHelper:createWithParent(parent, pos_x, pos_y, depth, missile_res_name, 'group', visual, false)
    local rotation = (-(dir - 90))
    visual:setRotation(rotation)
    visual:setScale(scale)
    
    -- 재생 후 삭제
    local duation = visual:getDuration()
    local function removeThis(node)
        node:removeFromParent(true)
    end
    visual:runAction(cc.Sequence:create(cc.DelayTime:create(duation), cc.CallFunc:create(removeThis)))
end

-------------------------------------
-- class makeMissile
-------------------------------------
function MissileFactory:makeMissile_(t_option)
    local owner =            t_option['owner']
    local movement =         t_option['movement'] or 'normal'
    local attack_damage =	 t_option['attack_damage']

    local damage_rate =      t_option['damage_rate']
    local object_key =       t_option['object_key'] or PHYS.MISSILE.ENEMY
    local missile_res_name = t_option['missile_res_name']
    local physics_body =    (t_option['physics_body'] and clone(t_option['physics_body']))
    
	local speed =            t_option['speed'] or 0
	local speed_reverse_time=t_option['speed_reverse_time'] or nil
    local l_limit_speed =    t_option['l_limit_speed']
    local h_limit_speed =    t_option['h_limit_speed']
    
	local dir =              t_option['dir'] or 270
    local rotation =         t_option['rotation'] or 270
	local no_rotate =        t_option['no_rotate'] or false
    local pos_x =            t_option['pos_x'] or 320
    local pos_y =            t_option['pos_y'] or 400
    local scale =            t_option['scale'] or 1
    
	local accel =            t_option['accel'] or 0
    local accel_delay =      t_option['accel_delay'] or nil
	local accel_reverse_time=t_option['accel_reverse_time'] or nil

    local delete_time =      t_option['delete_time'] or nil
    local vanish_time =      t_option['vanish_time'] or nil
    local explosion_time =   t_option['explosion_time'] or nil
    local explosion_time2 =  t_option['explosion_time2'] or nil
    local explosion_time3 =  t_option['explosion_time3'] or nil
    local reset_time =       t_option['reset_time'] or nil
    local reset_time_delay = t_option['reset_time_delay'] or nil
    local size_up_time =     t_option['size_up_time'] or nil
    local magnet_time =      t_option['magnet_time'] or nil
    local fadeout_time =	 t_option['fadeout_time'] or nil
	local map_shake_time =	 t_option['map_shake_time'] or nil
    local collision_check_time =t_option['collision_check_time'] or nil
    local no_check_range =	 t_option['no_check_range'] or nil
    
    local depth =            t_option['depth'] or 0
    local missile_type =     MISSILE_TYPE[t_option['missile_type']]
    local visual =           t_option['visual'] or nil
    local target =           t_option['target']
    local target_body =      t_option['target_body']
    local target_idx =       t_option['target_idx']
    local collision_list =   t_option['collision_list']

    local rotate_time =      t_option['rotate_time'] or nil
    local angular_velocity = t_option['angular_velocity'] or nil
    local angular_velocity_time = t_option['angular_velocity_time'] or nil
    local value_1 =          t_option['value_1']
    local effect =           t_option['effect']
    local lua_param =        t_option['lua_param']
	
	local disable_body =		t_option['disable_body'] or false
	local is_fixed_attack =		t_option['bFixedAttack'] or false
	local missile_cbFunction =	t_option['cbFunction']	-- 이것은 lua상에서 짜여진 스크립트 탄 또는 코드 스킬에서 전달.. 
	local missile_event =		t_option['events']
	local res_depth =			t_option['res_depth']
	local is_abs_pos =			t_option['is_abs_pos'] 


	local add_script =			t_option['add_script']
	local add_script_start =	t_option['add_script_start'] or 0
	local add_script_term =		t_option['add_script_term'] or 5
	local add_script_max =		t_option['add_script_max'] or 1
	local add_script_dead =		t_option['add_script_dead'] or false
	local add_script_relative = t_option['add_script_relative']
    local target_list =         t_option['target_list']
        
    local max_hit_count =       t_option['max_hit_count']

    local lua_missile = nil

    -- 리소스명 변경 (@를 속성명으로 변경)
    if (t_option['attr_name']) then
        if (missile_res_name) then
            missile_res_name = string.gsub(missile_res_name, '@', t_option['attr_name'])
        end
        if (visual) then
            visual = string.gsub(visual, '@', t_option['attr_name'])
        end
    end

    -- 미사일 생성
    local missile = nil
    
	if string.match(movement, 'lua_')then
        missile = MissileLua(missile_res_name, physics_body)
        missile.m_target = target
        missile.m_lTarget = target_list
        lua_missile = true

    elseif (movement == 'normal') then
        missile = Missile(missile_res_name, physics_body)
        missile.m_target = target
        missile.m_targetBody = target_body
        
    elseif (movement == 'instant') then
        missile = MissileInstant(missile_res_name, physics_body)

    elseif (movement == 'guide') then
        missile = MissileGuide(missile_res_name, physics_body)
        missile.m_target = target
        
	elseif (movement == 'guid') then
		missile = MissileGuid(missile_res_name, physics_body)
        missile.m_target = target
        
    elseif (movement == 'guid_strong') then
        missile = MissileGuid(missile_res_name, physics_body)
        missile.m_target = target
        missile.m_angularVelocityGuid = 720
        missile.m_straightWaitTime = 0

    elseif (movement == 'guidtarget') then
        missile = MissileGuidTarget(missile_res_name, physics_body, target)

    elseif (movement ==  'target') then
        missile = MissileTarget(missile_res_name, physics_body)

    -- zigzag
    elseif (movement == 'zigzag_l') then
        missile = MissileZigzag(missile_res_name, physics_body)
        missile.m_leftOrRight = true
    elseif (movement == 'zigzag_r') then
        missile = MissileZigzag(missile_res_name, physics_body)
        missile.m_leftOrRight = false

    -- bounce (뮤탈리스크 공격)
    elseif (movement == 'bounce') or (movement == 'bounce3') then
        missile = MissileBounce(missile_res_name, physics_body, target)
        missile.m_bounceCountMax = 3
    elseif (movement == 'bounce4') then
        missile = MissileBounce(missile_res_name, physics_body, target)
        missile.m_bounceCountMax = 4
    elseif (movement == 'bounce5') then
        missile = MissileBounce(missile_res_name, physics_body, target)
        missile.m_bounceCountMax = 5
    elseif (movement == 'bounce6') then
        missile = MissileBounce(missile_res_name, physics_body, target)
        missile.m_bounceCountMax = 6

    -- 확정 미사일
    elseif (movement == 'fix') then
        missile = MissileFix(missile_res_name, physics_body, target)
    end

    if missile then
        missile.m_owner = owner

		-- 스킬 애니 속성 세팅
		missile.m_animator:setAniAttr(t_option['attr_name'])

        -- body가 지정되지 않았을 경우
        if (not physics_body) then
            local body_size = missile:getBodySizeFromAnimator()
            PhysObject_setBody(missile, 0, 0, body_size)
        end

        missile:initState()

        -- 미사일 효과
        if effect then
            -- 잔상 효과
            if effect['afterimage'] then
                missile.m_bAfterimage = true
            end

            -- 로테이션 효과
            if effect['rotation'] then
                local sequence = cc.Sequence:create(cc.RotateTo:create(0.25, 180), cc.RotateTo:create(0.25, 360))
                local action = cc.RepeatForever:create(sequence)
                missile.m_animator:runAction(action)
            end

            -- 모션스트릭(MotionStreak) 효과
            if (not isLowEndMode()) then
                if effect['motion_streak'] then
				    local motion_streak = string.gsub(effect['motion_streak'], '@', t_option['attr_name'])
                    missile:setMotionStreak(self.m_world.m_missiledNode, motion_streak)
                end
            end
        end

        missile:setSpeed(speed)
		missile.m_speedReverseInterval = speed_reverse_time
        missile.m_acceleration = accel
        missile.m_accelDelay = accel_delay
		missile.m_accelReverseInterval = accel_reverse_time

        missile.m_deleteTime = delete_time
        missile.m_vanishTime = vanish_time
        missile.m_explosionTime = explosion_time
        missile.m_explosionTime2 = explosion_time2
        missile.m_explosionTime3 = explosion_time3
        missile.m_resetTime = reset_time
        missile.m_resetTimeDelay = reset_time_delay
        missile.m_sizeUpTime = size_up_time
        missile.m_magnetTime = magnet_time
        if rotate_time then
            missile.m_tRotateTime = clone(rotate_time)
        end
		missile.m_bNoRotate = no_rotate
		missile.m_fadeoutTime = fadeout_time
		missile.m_collisionCheckTime = collision_check_time
		missile.m_mapShakeTime = map_shake_time
        missile.m_bNoCheckRange = no_check_range

        -- 각속도 지정
        if angular_velocity and (angular_velocity~=0) then
            missile.m_angularVelocity = angular_velocity
        end
        if angular_velocity_time then
            missile.m_tAngularVelocity = clone(angular_velocity_time)
        end

        missile.m_minSpeed = l_limit_speed
        missile.m_maxSpeed = h_limit_speed

		if (type(scale) == 'table') then
            if missile_res_name then
                missile.m_rootNode:setScale(scale[1], scale[2])
            end
		else
			missile.m_rootNode:setScale(scale)
		end
        missile:setDir(dir)
		if (not no_rotate) then 
			missile:setRotation(rotation)
		end

		if (is_abs_pos) then
			-- 절대 좌표 사용중이라면 카메라에 맞게 보정해준다.
			local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
			missile:setPosition(pos_x + cameraHomePosX, pos_y + cameraHomePosY)
		else
			missile:setPosition(pos_x, pos_y)
		end

        if attack_damage then
            missile.m_activityCarrier = attack_damage
        
            -- 미사일 계수 지정
            if damage_rate and (damage_rate ~= 100) then
                missile.m_activityCarrier:setPowerRate(damage_rate)
            end
        end
		
		-- 퍼포먼스 개선을 위해 동일한 리소스 명은 동일한 레이어에 찍도록 처리
        local layer_depth = self:getMissileDepth(missile_res_name)

        -- Physics, Node, GameMgr에 등록
		self.m_world:addMissile(missile, object_key, layer_depth, res_depth)

		if (disable_body) then
			missile.enable_body = false
		end

		if is_fixed_attack then 
			missile:setFixedAttack(true)
			missile.m_target = target
            missile.m_lFixedTargetCollision = collision_list
		end

        -- 미사일 타입 지정, 타입별 히트 콜백 함수 등록
        if (missile_type==nil) or missile_type == MISSILE_TYPE['NORMAL'] then
            missile:addAtkCallback(MissileHitCB.normal)

        elseif (missile_type == MISSILE_TYPE['PASS']) or (missile_type == MISSILE_TYPE['PASS_STRONG']) then
            missile:addAtkCallback(MissileHitCB.pass)

            missile.m_remainHitCount = max_hit_count
            missile.m_bPassType = true

        elseif missile_type == MISSILE_TYPE['PASS_LASER'] then
            missile.m_bPassType = true

        elseif missile_type == MISSILE_TYPE['SPLASH'] then
            missile:addAtkCallback(MissileHitCB.splash)
        end

		-- 공용탄 개발 후 개별적인 콜백이 필요함에 따라 각 탄에서 콜백함수를 던지도록함
		if (missile_cbFunction) then
			missile:addAtkCallback(missile_cbFunction)
		end

		-- 별도의 event 처리가 필요한 미사일 처리
		if (missile_event == 'destroy') then
			self.m_world:addDestructibleMissile(missile)
		end

		-- 미사일이 미사일을 쏜다
		if (add_script) then
			missile.m_addScript = add_script
			missile.m_addScriptStart = add_script_start
			missile.m_addScriptTerm = add_script_term
			missile.m_addScriptMax = add_script_max
			missile.m_addScriptDead = add_script_dead
			missile.m_addScriptRelative = add_script_relative
            missile.m_addScriptTargetList = target_list
            missile.m_addScriptTargetIdx = target_idx

			missile.m_lAddScriptTime = {}
			local time = 0
			for i = 1, add_script_max do
				time = add_script_start + (i-1)*add_script_term
				table.insert(missile.m_lAddScriptTime, time)
			end            
		end

        -- Visual명 변경
        if visual then
            for i,_ in pairs(missile.m_tStateAni) do
                if missile.m_tStateAni[i] == 'move' then
                    missile.m_tStateAni[i] = visual
                end
            end

            -- 현재상태의 visual명이 변경했을 수 있으므로 다시 지정
            local state = missile.m_state
            missile.m_animator:changeAni(missile.m_tStateAni[state], missile.m_tStateAniLoop[state])
        end

        -- 따라가기
        --[[
        if sync_pos and target then
            local offset_x = pos_x - target.pos.x
            local offset_y = pos_y - target.pos.y

            local function co_function(dt)
                local hero_pos_x = target.pos.x
                local hero_pos_y = target.pos.y

                while true do
                    coroutine.yield()
                    local delta_x = target.pos.x - hero_pos_x
                    local delta_y = target.pos.y - hero_pos_y
                    hero_pos_x = target.pos.x
                    hero_pos_y = target.pos.y
                    missile:setPosition(missile.pos.x + delta_x, missile.pos.y + delta_y)
                end
            end

            -- coroutine, type, allow_duplicate, overwrite, escape
            missile:addCoroutine(coroutine.create(co_function), 'movement_sync_pos', false, true, nil)
        end
        --]]


        if (movement == 'laser_missile') then
            -- 임시
            missile:initWorld(self.m_world)
            missile:initTail(7, 80)

        end


        if lua_missile then
            if lua_param then
                missile.m_value1 = lua_param['value1']
                missile.m_value2 = lua_param['value2']
                missile.m_value3 = lua_param['value3']
                missile.m_value4 = lua_param['value4']
                missile.m_value5 = lua_param['value5']
            end

            MissileLua[movement](missile)
        end
    end

    return missile
end

-------------------------------------
-- function makeInstantMissile
-------------------------------------
function MissileFactory:makeInstantMissile(res, visual, x, y, body_size, owner, t_option)
    local t_option = (t_option or {})
    t_option['missile_res_name'] = res
    t_option['visual'] = visual
    t_option['physics_body'] = {0, 0, body_size or 150}
    t_option['attack_damage'] = owner.m_activityCarrier
    t_option['object_key'] = owner.phys_key
    t_option['pos_x'] = x
    t_option['pos_y'] = y
    t_option['movement'] = 'instant'
    t_option['missile_type'] = 'PASS'
    
    return self:makeMissile(t_option)
end

-------------------------------------
-- class clearMissileDepthMap
-------------------------------------
function MissileFactory:clearMissileDepthMap()
    self.m_missileDepthMap = {}
    self.m_missileDepthIdx = 1
end

-------------------------------------
-- class getMissileDepth
-- @brief 리소스명으로 미사일 레이어를 정함
--        GL calls 최적화가 목적 sgkim 2017-08-21
-------------------------------------
function MissileFactory:getMissileDepth(res)
    if (not res) then
        return self.m_missileDepthIdx
    end

    if (not self.m_missileDepthMap[res]) then
        self.m_missileDepthMap[res] = self.m_missileDepthIdx
        self.m_missileDepthIdx = (self.m_missileDepthIdx + 1)
    end

    local depth = self.m_missileDepthMap[res]

    return depth
end