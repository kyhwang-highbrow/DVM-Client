local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ConsumeToMissile
-------------------------------------
StatusEffect_ConsumeToMissile = class(PARENT, {
        m_resMissile = 'string',
        m_srcStatusEffectName = 'string',   -- 소비될 상태효과의 name
        m_movementForMissile = 'string',    -- 미사일의 이동 타입
        m_lCollision = 'table',            -- 미사일의 타겟 리스트
        m_activityCarrier = 'ActivityCarrier',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ConsumeToMissile:init(file_name, body)
    self.m_resMissile = file_name
    self.m_lCollision = {}
end

-------------------------------------
-- function init_statusEffect
-- @breif 미사일을 발사할 대상을 설정
-------------------------------------
function StatusEffect_ConsumeToMissile:init_statusEffect(caster, l_collision)
    if (not l_collision) then
        local l_target = self.m_owner:getTargetListByType('enemy_random')
        local pos_x = caster.pos.x
        local pos_y = caster.pos.y

        l_collision = SkillTargetFinder:getCollisionFromTargetList(l_target, pos_x, pos_y, true)
    end

    self.m_lCollision = l_collision
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_ConsumeToMissile:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self.m_srcStatusEffectName = t_status_effect['val_1']
    self.m_movementForMissile = t_status_effect['val_2']
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
    self.m_activityCarrier:setParam('add_dmg', true)

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
            local edge_pos = edge_director:getEdgePos(i)
            local world_pos = { x = self.m_owner.pos['x'] + edge_pos['x'], y = self.m_owner.pos['y'] + edge_pos['y'] }

            self:fireMissile(collision, world_pos)
        end
    end

    -- 특정 상태효과 해제
    StatusEffectHelper:releaseStatusEffectByType(self.m_owner, self.m_srcStatusEffectName)

    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit.m_durationTimer = 0
end

-------------------------------------
-- function fireMissile
-------------------------------------
function StatusEffect_ConsumeToMissile:fireMissile(collision, start_pos)
    local char = self.m_owner
    local target = collision:getTarget()
	    
    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target
    t_option['target_body'] = target:getBody(collision:getBodyKey())

    t_option['pos_x'] = start_pos['x']
	t_option['pos_y'] = start_pos['y']
	
    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['physics_body'] = {0, 0, 0}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()
    t_option['disable_body'] = true

    t_option['missile_res_name'] = self.m_resMissile
	t_option['visual'] = 'idle'

    ---------------------------------------------------------------------------------------------------

	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='lua_curve' 

	local random_height = g_constant:get('SKILL', 'CURVE_HEIGHT_RANGE')

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = math_random(-random_height, random_height)
	t_option['lua_param']['value2'] = g_constant:get('SKILL', 'CURVE_SPEED')
	t_option['lua_param']['value3'] = g_constant:get('SKILL', 'CURVE_FIRE_DELAY')
	t_option['lua_param']['value5'] = function()
        -- 피격 처리
		target:undergoAttack(self, target, collision:getPosX(), collision:getPosY(), collision:getBodyKey(), true)
	end

	-- fire!!
    self.m_owner.m_world.m_missileFactory:makeMissile(t_option)
end