local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ConsumeToMissile
-------------------------------------
StatusEffect_ConsumeToMissile = class(PARENT, {
        m_resMissile = 'string',
        m_resMotionStreak = 'string',

        m_srcStatusEffectName = 'string',   -- 소비될 상태효과의 name
        m_movementForMissile = 'string',    -- 미사일의 이동 타입
        m_lStatusEffectInfo = 'table',      -- 미사일이 명중시 부여될 상태효과 정보

        m_lCollision = 'table',             -- 미사일의 타겟 리스트
        m_activityCarrier = 'ActivityCarrier',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ConsumeToMissile:init(file_name, body)
    self.m_resMissile = file_name
    self.m_lStatusEffectInfo = {}
    self.m_lCollision = {}
end

-------------------------------------
-- function init_statusEffect
-- @breif 미사일을 발사할 대상을 설정
-------------------------------------
function StatusEffect_ConsumeToMissile:init_statusEffect(caster, l_collision)
    self.m_lCollision = l_collision or {}
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_ConsumeToMissile:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:initMissile(t_status_effect)
end

-------------------------------------
-- function initMissile
-------------------------------------
function StatusEffect_ConsumeToMissile:initMissile(t_status_effect)
    self.m_resMotionStreak = t_status_effect['res_2']
    self.m_srcStatusEffectName = t_status_effect['val_1']   -- 해제될 상태효과 이름
    self.m_movementForMissile = t_status_effect['val_2']    -- 미사일 이동 패턴
    
    -- 상태효과 정보를 파싱하여 저장
    for i = 1, 5 do
        local name = t_status_effect['add_option_type_' .. i]
        if (name and name ~= '') then
            local value = t_status_effect['add_option_value_' .. i]
            local time = t_status_effect['add_option_time_' .. i]
            local source = t_status_effect['add_option_source_' .. i]
            local rate = t_status_effect['add_option_rate_' .. i]
                        
            table.insert(self.m_lStatusEffectInfo, { name = name, value = value, time = time, source = source, rate = rate })
        end
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function StatusEffect_ConsumeToMissile:initAnimator(file_name)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_ConsumeToMissile:onApplyOverlab(unit)
    self.m_activityCarrier = unit:makeActivityCarrier()
    self.m_activityCarrier:setAttackType('add_dmg')
    self.m_activityCarrier:setIgnoreDef(true)
    self.m_activityCarrier:setParam('add_dmg', true)

    local delay_time = unit.m_duration  -- 미사일 대기 시간
    local skill_id = unit.m_skillId

    -- 재료가 될 상태효과를 가져옴
    local srcStatusEffect = self.m_owner:getStatusEffect(self.m_srcStatusEffectName)

    -- 특정 상태효과의 중첩 수를 가져온다
    local missile_count = self.m_owner:getStatusEffectCount('name', self.m_srcStatusEffectName)
    local collision_count = #self.m_lCollision

    if (srcStatusEffect and missile_count > 0 and collision_count > 0) then
        local edge_director = srcStatusEffect:getEdgeDirector()

        for i = 1, missile_count do
            local random_idx = math_random(1, collision_count)
            local collision = self.m_lCollision[random_idx]
            local edge_pos = { x = 0, y = 0 }
            if (edge_director) then
                edge_pos = edge_director:getEdgePos(i)
            end

            local world_pos = { x = self.m_owner.pos['x'] + edge_pos['x'], y = self.m_owner.pos['y'] + edge_pos['y'] }

            self:fireMissile(collision, world_pos, delay_time + i * 0.1, skill_id)
        end
    end

    -- 특정 상태효과 해제
    StatusEffectHelper:releaseStatusEffectByType(self.m_owner, self.m_srcStatusEffectName)

    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end

-------------------------------------
-- function fireMissile
-------------------------------------
function StatusEffect_ConsumeToMissile:fireMissile(collision, start_pos, delay_time, skill_id)
    local char = self.m_owner
    local target = collision:getTarget()
	    
    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target
    t_option['target_body'] = target:getBody(collision:getBodyKey())

    t_option['pos_x'] = start_pos['x']
	t_option['pos_y'] = start_pos['y']
	
    t_option['object_key'] = char:getMissilePhysGroup()
    t_option['physics_body'] = {0, 0, 0}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()
    t_option['disable_body'] = true

    t_option['missile_res_name'] = self.m_resMissile
	t_option['visual'] = 'idle'
    t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_resMotionStreak

    ---------------------------------------------------------------------------------------------------

	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='lua_curve' 

	local random_height = g_constant:get('SKILL', 'CURVE_HEIGHT_RANGE')

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = math_random(-random_height, random_height)
	t_option['lua_param']['value2'] = g_constant:get('SKILL', 'CURVE_SPEED')
	t_option['lua_param']['value3'] = delay_time or 0
	t_option['lua_param']['value5'] = function()
        -- 피격 처리
		target:undergoAttack(self, target, collision:getPosX(), collision:getPosY(), collision:getBodyKey(), true)

        -- 상태효과 적용
        for i, v in ipairs(self.m_lStatusEffectInfo) do
            StatusEffectHelper:invokeStatusEffect(char, target, v['name'], v['value'], v['source'], v['rate'], v['time'], skill_id)
        end
	end

	-- fire!!
    self.m_owner.m_world.m_missileFactory:makeMissile(t_option)
end