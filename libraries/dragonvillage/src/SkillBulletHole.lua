-------------------------------------
-- class SkillBulletHole
-------------------------------------
SkillBulletHole = class(Entity, {
        m_owner = 'Character',
        m_duration = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillBulletHole:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillBulletHole:init_skill(owner, x, y, t_skill)
    self.m_owner = owner

    if (not x) or (not y) then
        x, y = self:getTargetPos()
    end

    self:setPosition(x, y)

    local range = t_skill['val_1']
    self.m_duration = t_skill['val_2']

    -- 사라지는 에니메이션 시간
    self.m_animator:changeAni('hole_disappear')
    local duration = self.m_animator:getDuration()
    self.m_animator:changeAni('hole_appear', false)

    -- 사라지는 에니메이션 시간을 빼준다
    self.m_duration = (self.m_duration - duration)

    self:addAtkCallback(function(attacker, defender, i_x, i_y)
        defender.enable_body = false
        defender:setTargetPos(x, y)
        defender:setRotation(defender.movement_theta)
        defender:changeState('hole')
    end)

	-- @TODO 공격에 묻어나는 이펙트 Carrier 에 담아서..
	StatusEffectHelper:doStatusEffect(owner, t_skill)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillBulletHole:initState()
    self:addState('idle', SkillBulletHole.st_idle, 'hole_appear', false)
    self:addState('end', SkillBulletHole.st_end, 'hole_disappear', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillBulletHole.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function() owner.m_animator:changeAni('hole_idle', true) end)
    elseif (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_end
-------------------------------------
function SkillBulletHole.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function() owner:changeState('dying') end)
    end
end

-------------------------------------
-- function getTargetPos
-------------------------------------
function SkillBulletHole:getTargetPos()
    local cast_range = 600
    local skill_range = 150
    local distance = cast_range + skill_range
    local x, y = self.m_owner.pos.x, self.m_owner.pos.y

    -- 상대방 진형 얻어옴
    local world = self.m_owner.m_world
    local target_formation_mgr = nil
    local offset_x = nil
    if self.m_owner.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
        offset_x = -100
    else
        target_formation_mgr = world.m_leftFormationMgr
        offset_x = 100
    end

    -- 캐스팅 범위 안에 적군이 있을 경우
    local inside_list = {}
    local outside_list = {}
    local near_target = nil
    local near_dist = nil
    for i,v in ipairs(target_formation_mgr.m_globalCharList) do
        local dist = getDistance(x, y, v.pos.x, v.pos.y)
        
        if (dist <= cast_range) then
            table.insert(inside_list, v)
        end

        if (dist <= distance) then
            table.insert(outside_list, v)
        end

        if (near_target == nil) or (dist <near_dist) then
            near_target = v
            near_dist = dist
        end
    end

    -- 랜덤하게 하나를 리턴
    if (#inside_list > 0) then
        local rand_num = math_random(1, #inside_list)
        return inside_list[rand_num].pos.x + offset_x, inside_list[rand_num].pos.y
    end
    
    -- 스킬을 맞출 수 있는 범위
    if (#outside_list > 0) then
        local rand_num = math_random(1, #outside_list)
        local target = outside_list[rand_num]
        local dir = getDegree(x, y, target.pos.x, target.pos.y)
        local pos = getPointFromAngleAndDistance(dir, 600)
        return x + pos['x'] + offset_x, y + pos['y']
    end

    if near_target then
        local target = near_target
        local dir = getDegree(x, y, target.pos.x, target.pos.y)
        local pos = getPointFromAngleAndDistance(dir, 600)
        return x + pos['x'] + offset_x, y + pos['y']
    end

    if self.m_owner.m_bLeftFormation then
        return x + 100, y
    else
        return x - 100, y
    end
end
