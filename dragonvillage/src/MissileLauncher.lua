local PARENT = class(Entity, ISkillSound:getCloneTable())

-------------------------------------
-- class MissileLauncher
-------------------------------------
MissileLauncher = class(PARENT, {
        m_owner = 'Character',
        m_attackOffsetX = 'number',
        m_attackOffsetY = 'number',

        m_attackIdx = 'number',

        -- 탄막 패턴에 필요한 변수
        m_activityCarrier = 'table',
        m_tAttackValueBase = '',

        -- 탄막 관련
        m_tAttackPattern = 'table',
        m_tAttackIdxCache = 'table',
        m_tSoundIdxCache = 'table',
        m_missileDepth = 'number',

        -- 피격시 콜백
        m_cbFunction = 'function',

        m_objectKey = '',
        
        m_bUseOwnerPos = 'boolean',
        m_bUseTargetDir = '',

        -- 탄막 발사 종료 시간
        m_endTime = '',

        m_launcherOption = 'table',
        -- ['target']
        -- ['missile_count']
        -- ['attr_name']        -- 리소스명 변경
        -- ['dir']              -- 런쳐 자체의 각도
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileLauncher:init(file_name, body)
    self.m_owner = nil
    self.m_attackOffsetX = 0
    self.m_attackOffsetY = 0

    self.m_bUseOwnerPos = false
    self.m_bUseTargetDir = false
end

-------------------------------------
-- function init_missileLauncher
-------------------------------------
function MissileLauncher:init_missileLauncher(t_skill, object_key, activity_carrier, attack_idx, script)
    self.m_objectKey = object_key
    self.m_attackIdx = attack_idx or 1
    self.m_activityCarrier = activity_carrier

    -- 상태 생성
    self:addState('attack', MissileLauncher.st_attack, 'idle', true)
    self:addState('dying_wait', MissileLauncher.st_dying_wait, nil, nil, 3)
    self:addState('dying', function(owner, dt) return true end, nil, true, 3)
    self:changeState('attack')

    -- data 파일에서 로드
    local script_name = script or t_skill['skill_type']
    local script = TABLE:loadSkillScript(script_name)
    if (not script) then
        error(script_name .. " DO NOT EXIST!!")
    end
    
    local script_data = script[script_name]
    
    self.m_tAttackValueBase = script_data['attack_value']

    -- 테이블에서 덧씌우는 필드
	-- 기존 스크립트탄은 무시하고 새로 만든 일반탄에 적용한다.
    if t_skill and (t_skill['skill_type'] == 'code') then
        local count = 1
        while (self.m_tAttackValueBase[count]) do
            -- resource 교체
			if (t_skill['res_'..count] ~= 'x') then 
                self.m_tAttackValueBase[count]['res'] = t_skill['res_'..count]
            end
			-- 탄막 여부 
			self.m_tAttackValueBase[count]['bFixedAttack'] = true
            
			count = count + 1
        end
    end
    
    -- 탄막 관련
    self.m_tAttackPattern = {}
    self.m_tAttackIdxCache = {}
    self.m_tSoundIdxCache = {}
    self.m_missileDepth = 0

    -- 탄막 패턴 저장 (self.m_tAttackValueBase는 스크립트상의 'attack_value')
    for i, v in ipairs(self.m_tAttackValueBase) do
        local idx = v.idx or #self.m_tAttackPattern + 1
        if (not self.m_tAttackPattern[idx]) then
            self.m_tAttackPattern[idx] = {}
        end
        table.insert(self.m_tAttackPattern[idx], i)
    end

	-- 상태 효과 적용
	local l_status_effect_struct = SkillHelper:makeStructStatusEffectList(t_skill)
    self.m_activityCarrier:insertStatusEffectRate(l_status_effect_struct)

    -- 미사일 패턴 초기화
    self:init_missilePattern(self.m_attackIdx)

    -- 사운드 설정
    if (t_skill) then
        self:initSkillSound(t_skill['sid'])
    end
end

-------------------------------------
-- function init_missileLauncherByScript
-------------------------------------
function MissileLauncher:init_missileLauncherByScript(script_data, object_key, activity_carrier, t_param)
    self.m_objectKey = object_key
    self.m_attackIdx = 1
    self.m_activityCarrier = activity_carrier

    -- 상태 생성
    self:addState('attack', MissileLauncher.st_attack, 'idle', true)
    self:addState('dying_wait', MissileLauncher.st_dying_wait, nil, nil, 3)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 3)
    self:changeState('attack')
    
    self.m_tAttackValueBase = script_data or {}
	    
    -- 탄막 관련
    self.m_tAttackPattern = {}
    self.m_tAttackIdxCache = {}
    self.m_tSoundIdxCache = {}
    self.m_missileDepth = 0
	
    -- 탄막 패턴 저장 (self.m_tAttackValueBase는 스크립트상의 'attack_value')
    for i, v in ipairs(self.m_tAttackValueBase) do
        local idx = v.idx or #self.m_tAttackPattern + 1
        if (not self.m_tAttackPattern[idx]) then
            self.m_tAttackPattern[idx] = {}
        end

		-- 상대 각도 조정
        if (t_param['dir']) then 
			local dir = getAdjustDegree(t_param['dir'])
			v['dir'] = dir
		end

        if (t_param['target_idx']) then
            v['target_idx'] = t_param['target_idx']
        end

        table.insert(self.m_tAttackPattern[idx], i)
    end

    -- 미사일 패턴 초기화
    self:init_missilePattern(self.m_attackIdx)
end

-------------------------------------
-- function setLauncherOwner
-------------------------------------
function MissileLauncher:setLauncherOwner(owner, attack_offset_x, attack_offset_y)
    self.m_owner = owner
    self.m_attackOffsetX = attack_offset_x
    self.m_attackOffsetY = attack_offset_y
    self.m_bUseOwnerPos = true
end

-------------------------------------
-- function update
-------------------------------------
function MissileLauncher:update(dt)
    PARENT.update(self, dt)

    -- 사운드 업데이트
    self:updateSkillSound(dt)
end

-------------------------------------
-- function st_attack
-------------------------------------
function MissileLauncher.st_attack(owner, dt, pattern_idx)

    if (owner.m_stateTimer == 0) then

    else
        -- 발사 주체 정보 확인
        if (owner.m_owner) then
            -- 주체와 위치 동기화
            if (owner.m_bUseOwnerPos) then
                owner.pos.x = owner.m_owner.pos.x + owner.m_attackOffsetX
                owner.pos.y = owner.m_owner.pos.y + owner.m_attackOffsetY
            end

            -- 로밍 멈춤
            if (owner.m_owner.m_bRoam) then
                owner.m_owner:stopRoaming()
            end
        end

        -- 미사일 발사
        while #owner.m_tAttackIdxCache > 0 do
            local cache = owner.m_tAttackIdxCache[1]

            local time = cache[1]
            local data = cache[2]
            local add_dir = cache[3]
            local offset = cache[4]

            if (owner.m_stateTimer >= time) then
                owner:fireMissile(data, owner.m_missileDepth, add_dir, offset, time)
                table.remove(owner.m_tAttackIdxCache, 1)
                owner.m_missileDepth = owner.m_missileDepth - 1
            else
                break
            end
        end

        -- 사운드 재생
        while owner.m_tSoundIdxCache[1] do
            local cache = owner.m_tSoundIdxCache[1]
            local time = cache[1]
            if owner.m_stateTimer >= time then
                local sound = cache[2]
                ISkillSound:playSkillSound(sound)
                table.remove(owner.m_tSoundIdxCache, 1)
            else
                break
            end
        end

        -- 공격이 종료되었고 에니메이션 재생이 완료되었으면
        if (#owner.m_tAttackIdxCache <= 0) and (owner.m_stateTimer >= owner.m_endTime) then
            owner:changeState('dying_wait')
            return true
        end
    end
end

-------------------------------------
-- function st_dying_wait
-------------------------------------
function MissileLauncher.st_dying_wait(owner, dt)
    if (owner:isEndSkillSound()) then
        owner:changeState('dying', true)
    end
end

-------------------------------------
-- function sortAscending
-- @brief 오름차순 정렬
-------------------------------------
local function sortAscending(a, b)
    if a[1] < b[1] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function init_missilePattern
-------------------------------------
function MissileLauncher:init_missilePattern(pattern_idx)
    local owner = self

    -- 공격 캐시 저장, 사운드 캐시 저장
    owner.m_tAttackIdxCache = {}
    owner.m_tSoundIdxCache = {}

    -- 특정 idx의 공격 리스트를 가져옴
    local t_pattern = owner.m_tAttackPattern[pattern_idx]
    if (not t_pattern) then -- 존재하지 않을 경우 무조건 1번 공격 리스트를 가져옴
        t_pattern = owner.m_tAttackPattern[1]
    end

    -- 공격 리스트
    for i, v in ipairs(t_pattern) do
        local attack_value = owner.m_tAttackValueBase[v]

        local count = attack_value['count'] or 1
        local time = attack_value['time'] or 0
        local period = attack_value['period'] or 0
        local offset_add = attack_value['offset_add']
        local dir = attack_value['dir'] or 0

        -- 런쳐 옵션 적용
        if self.m_launcherOption then
            if self.m_launcherOption['missile_count'] then
                count = self.m_launcherOption['missile_count']
            end
        end

        local add_dir = 0
        for i=1, count do
            local offset = {0, 0}
            if offset_add then
                local idx = i-1
                offset[1] = offset_add[1]*idx
                offset[2] = offset_add[2]*idx
            end
            table.insert(owner.m_tAttackIdxCache, {time, v, dir + add_dir, offset})

            time = time + period
            add_dir = add_dir + (attack_value['dir_add'] or 0)
        end

        -- 사운드 캐시 저장
        local sound = attack_value['sound']
        local sound_time_type = type(attack_value['sound_time'])
        if sound then
            if sound_time_type == 'number' then
                local time = attack_value['sound_time']
                table.insert(owner.m_tSoundIdxCache, {time, sound})
            elseif sound_time_type == 'table' then
                for _, time in ipairs(attack_value['sound_time']) do
                    table.insert(owner.m_tSoundIdxCache, {time, sound})
                end
            end
        end
    end

    -- 시간순으로 정렬 (오름차순 정렬)
    table.sort(owner.m_tAttackIdxCache, sortAscending)
    table.sort(owner.m_tSoundIdxCache, sortAscending)

    -- 패턴 종료 시간
    if (#owner.m_tAttackIdxCache > 0) then
        local cache = owner.m_tAttackIdxCache[#owner.m_tAttackIdxCache]
        owner.m_endTime = cache[1] -- 테이블에서 1번이 time {time, data, add_dir, offset}
    else
        owner.m_endTime = 0
    end

    -- 처음 쏘는 미사일이 위쪽으로 찍히도록 처리
    owner.m_missileDepth = #owner.m_tAttackIdxCache
end

-------------------------------------
-- function getAnotherLiveTarget
-------------------------------------
function MissileLauncher:getAnotherLiveTarget(org_list)
    local target = nil

    if (org_list and #org_list > 0) then
        for _, org_target in ipairs(org_list) do
            if (org_target) and (not org_target:isDead()) then
                target = org_target
            end
        end
    end

    return target
end

-------------------------------------
-- function fireMissile
-------------------------------------
function MissileLauncher:fireMissile(attack_idx, depth, dir_add, offset_add, time)

    local attack_idx = attack_idx or 1
    local depth = depth or 0
    local dir_add = dir_add or 0
    local time = time or 0

    if (not self.m_tAttackValueBase[attack_idx]) then return end
    local attack_value = self.m_tAttackValueBase[attack_idx]

    ---------------------------------------------------
    --    ex) attack_value
    --    {
    --        "res":"res/shot/effect_shot_43.png",
    --         "dir":[270,270],
    --         "body":[0,0,14],
    --        "offset":[[-50,17],[50,17]]
    --        "speed":500
    --    },
    ---------------------------------------------------

    -- 공격 대상
    local l_target = self.m_launcherOption['target_list'] or {}
    local l_target_idx

    if (attack_value['target_idx']) then
        l_target_idx = attack_value['target_idx']
    else
        l_target_idx = { 1 }
    end

    local offset_x = attack_value['offset'][1]
    local offset_y = attack_value['offset'][2]
    local physics_body = attack_value.body -- x, y, radius
    local speed = attack_value.speed or 0
    local damage_rate

    damage_rate = attack_value['damage_rate'] or 100
    damage_rate = damage_rate / 100 * self.m_activityCarrier:getPowerRate()
	
    if (not attack_value.dir_array) then
        attack_value.dir_array = {0}
    end
	
	-- count 수 만큼 random 하게 dir 생성
	local dir_array_org = nil
	if (attack_value.dir_array[1] == 'random') then
		dir_array_org = attack_value.dir_array
		local start_num = attack_value.dir_array[2] or 0
		local end_num = attack_value.dir_array[3] or 360
		if (start_num > end_num) then
			local temp = start_num
			start_num = end_num
			end_num = temp
		end
		attack_value.dir_array = {math_random(start_num, end_num)}
	end
     
    for idx, target_idx in ipairs(l_target_idx) do
        -- 공격 대상
        local target = l_target[target_idx]
        if (not target or target:isDead()) then
            if (target_idx ~= 1 or idx > 1) then break end

            target = self.m_launcherOption['target']

            -- 지정된 타겟마저도 죽었으면?
            -- 공격대상 리스트에서 살아있는 놈 아무나 가지고 온다
            if (not target or target:isDead()) then
                target = self:getAnotherLiveTarget(l_target)
            end

            if (not target or target:isDead()) then break end
        end
        
        -- 공격 위치
        if (type(offset_x) == 'string' and offset_x == 'target') then
            local body = target:getBody()
            pos_x = target.pos.x + body.x
        elseif (attack_value['is_abs_pos']) then
            -- 카메라 기준이라면 캐릭터 위치를 받아오지 않는다.
            pos_x = offset_x
        else
            pos_x = self.pos.x + offset_x   
        end

        if (type(offset_y) == 'string' and offset_y == 'target') then
            local body = target:getBody()
            pos_y = target.pos.y + body.y
        elseif (attack_value['is_abs_pos']) then
            -- 카메라 기준이라면 캐릭터 위치를 받아오지 않는다.
            pos_y = offset_y
        else
            pos_y = self.pos.y + offset_y   
        end 

	    if offset_add then
            pos_x = pos_x + offset_add[1]
            pos_y = pos_y + offset_add[2]
        end


	    for i = 1, #attack_value.dir_array do
		    local t_option = {}

            t_option['owner'] =			    self.m_owner
		    t_option['movement'] =			attack_value.movement
		    t_option['missile_res_name'] =	attack_value['res']
		    t_option['dir'] =				attack_value.dir_array[i] + dir_add
		    t_option['rotation'] =			attack_value.dir_array[i] + dir_add
		    t_option['no_rotate'] =			attack_value.no_rotate or false
		    t_option['pos_x'] =				pos_x
		    t_option['pos_y'] =				pos_y
		    t_option['speed'] =				speed
		    t_option['speed_reverse_time']=	attack_value.speed_reverse_time
		    t_option['l_limit_speed'] =		attack_value.l_limit_speed
		    t_option['h_limit_speed'] =		attack_value.h_limit_speed
		    t_option['scale'] =				attack_value.scale
		    t_option['physics_body'] =		physics_body
		    t_option['attack_damage'] =		(not attack_value['nodamage']) and self.m_activityCarrier:cloneForMissile()
		    t_option['damage_rate'] =		damage_rate
		    t_option['accel'] =				attack_value.accel
		    t_option['accel_delay'] =		attack_value.accel_delay
		    t_option['accel_reverse_time']=	attack_value.accel_reverse_time

		    t_option['delete_time'] =		attack_value.delete_time
		    t_option['vanish_time'] =		attack_value.vanish_time
		    t_option['explosion_time'] =	attack_value.explosion_time
		    t_option['explosion_time2'] =	attack_value.explosion_time2
		    t_option['explosion_time3'] =	attack_value.explosion_time3
		    t_option['reset_time'] =		attack_value.reset_time
		    t_option['reset_time_delay'] =	attack_value.reset_time_delay
		    t_option['size_up_time'] =		attack_value.size_up_time
		    t_option['magnet_time'] =		attack_value.magnet_time
		    t_option['fadeout_time'] =		attack_value.fadeout_time
		    t_option['map_shake_time'] =	attack_value.map_shake_time
		    t_option['collision_check_time'] =	attack_value.collision_check_time

		    t_option['depth'] =				depth
		    t_option['missile_type'] =		attack_value.missile_type
		    t_option['visual'] =			attack_value.visual
		    t_option['gold'] =				attack_value.gold
		    t_option['motion_streak'] =		attack_value.motion_streak
		    t_option['rotate_time'] =		attack_value.rotate_time
		    t_option['angular_velocity'] =	attack_value.angular_velocity
		    t_option['angular_velocity_time'] = attack_value.angular_velocity_time
		    t_option['value_1'] =			attack_value.value_1
		    t_option['object_key'] =		self.m_objectKey
		    t_option['effect'] =			attack_value['effect']
		    t_option['lua_param'] =			attack_value['lua_param']

		    t_option['disable_body'] =		attack_value['disable_body']
		    t_option['bFixedAttack'] =		attack_value['bFixedAttack']
		    t_option['events'] =			attack_value['events']
		    t_option['res_depth'] =			attack_value['res_depth']
		    t_option['is_abs_pos'] =		attack_value['is_abs_pos'] or false

		    t_option['add_script'] =		attack_value['add_script']
		    t_option['add_script_start'] =	attack_value['add_script_start']
		    t_option['add_script_term'] =	attack_value['add_script_term']
		    t_option['add_script_max'] =	attack_value['add_script_max']
		    t_option['add_script_dead'] =	attack_value['add_script_dead']
		    t_option['add_script_relative'] =	attack_value['add_script_relative']

            t_option['cbFunction'] =        self.m_cbFunction

		    -- accel이 발사된 시간차와 상관없이 동시에 걸림
		    if attack_value.accel_delay_fix then
			    t_option['accel_delay'] = t_option['accel_delay'] or 0
			    t_option['accel_delay'] = t_option['accel_delay'] - time
		    end

		    -- 미사일이 사라지는 시간 통일
		    if attack_value.delete_time_fix then
			    t_option['delete_time'] = t_option['delete_time'] or 0
			    t_option['delete_time'] = t_option['delete_time'] - time
		    end
		    if attack_value.vanish_time_fix then
			    t_option['vanish_time'] = t_option['vanish_time'] or 0
			    t_option['vanish_time'] = t_option['vanish_time'] - time
		    end
		    if attack_value.fadeout_time_fix then
			    t_option['fadeout_time'] = t_option['fadeout_time'] or 0
			    t_option['fadeout_time'] = t_option['fadeout_time'] - time
		    end

            if (attack_value['target_idx']) then
                t_option['target_idx'] = attack_value['target_idx']
            end

		    -- 런쳐 옵션 체크
		    if self.m_launcherOption then
			    self:applyLauncherOption(t_option, target_idx, target)
		    end
            
            self.m_world.m_missileFactory:makeMissile(t_option)
	    end
    end

	if dir_array_org then 
		attack_value.dir_array = dir_array_org
	end
end


-------------------------------------
-- function applyLauncherOption
-------------------------------------
function MissileLauncher:applyLauncherOption(t_option, target_idx, target)
    -- 타겟 각도를 사용하는 경우(이 경우 target_list는 반드시 존재해야함)
    if (self.m_bUseTargetDir) then
        local target = target or self.m_launcherOption['target_list'][target_idx]
        if (target) then
            local degree = getDegree(self.pos.x, self.pos.y, target.pos.x, target.pos.y)
            t_option['dir'] = t_option['dir'] + degree
            t_option['rotation'] = t_option['dir']
        end

    -- 런쳐상에 각도가 있을 경우
    elseif (self.m_launcherOption['dir']) then
        t_option['dir'] = t_option['dir'] + self.m_launcherOption['dir']
        t_option['rotation'] = t_option['dir']
    end

    -- 리소스명에 attr 추가
    if self.m_launcherOption['attr_name'] then
        t_option['attr_name'] = self.m_launcherOption['attr_name']
    end

    if (self.m_launcherOption['target_list']) then
        t_option['target_list'] = self.m_launcherOption['target_list']
        t_option['target'] = target or self.m_launcherOption['target_list'][target_idx]
    elseif self.m_launcherOption['target'] then
        t_option['target'] = self.m_launcherOption['target']
    end

    if self.m_launcherOption['target_pos'] then
        t_option['target_pos'] = self.m_launcherOption['target_pos']
    end
end


-------------------------------------
-- function getOptionTable
-------------------------------------
function MissileLauncher:getOptionTable()
    if (not self.m_launcherOption) then
        self.m_launcherOption = {}
    end

    return self.m_launcherOption
end

