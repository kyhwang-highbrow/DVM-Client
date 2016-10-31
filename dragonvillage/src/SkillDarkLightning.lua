

-- @TODO 사용 안함 - 확인 후 삭제




-------------------------------------
-- class SkillDarkLightning
-------------------------------------
SkillDarkLightning = class(Entity, {
        m_owner = 'Character',
        m_activityCarrier = 'AttackDamage',
        m_targetCount = 'number',
		m_res = 'str',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillDarkLightning:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillDarkLightning:init_skill(owner, x, y, t_skill)
    self.m_owner = owner

    if (not x) or (not y) then
        x, y = self:getTargetPos()
    end

    self:setPosition(x, y)

    local target_count = t_skill['val_1']
    self.m_targetCount = target_count
    local skill_range = t_skill['val_2'] -- 반지름
	self.m_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])

    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillDarkLightning:initState()
    self:addState('idle', SkillDarkLightning.st_idle, 'skill_range_normal', true)
    self:addState('attack', SkillDarkLightning.st_attack, nil, true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('attack')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillDarkLightning.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        
    elseif (owner.m_stateTimer >= 0.5) then
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillDarkLightning.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:attack()
    elseif (owner.m_stateTimer >= 0.5) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function getTargetPos
-------------------------------------
function SkillDarkLightning:getTargetPos()
    do
        -- 상대방 진형 얻어옴
        local world = self.m_owner.m_world
        local target_formation_mgr = nil
        if self.m_owner.m_bLeftFormation then
            target_formation_mgr = world.m_rightFormationMgr
        else
            target_formation_mgr = world.m_leftFormationMgr
        end

        local target = target_formation_mgr:getTypicalTarget_Random()
        if target then
            return target.pos.x, target.pos.y
        else
            local x, y = self.m_owner.pos.x, self.m_owner.pos.y
            if self.m_owner.m_bLeftFormation then
                return x + 600, y
            else
                return x - 600, y
            end
        end

        return
    end


    local cast_range = 600
    local skill_range = 150
    local distance = cast_range + skill_range
    local x, y = self.m_owner.pos.x, self.m_owner.pos.y

    -- 상대방 진형 얻어옴
    local world = self.m_owner.m_world
    local target_formation_mgr = nil
    if self.m_owner.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
    else
        target_formation_mgr = world.m_leftFormationMgr
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
        return inside_list[rand_num].pos.x, inside_list[rand_num].pos.y
    end
    
    -- 스킬을 맞출 수 있는 범위
    if (#outside_list > 0) then
        local rand_num = math_random(1, #outside_list)
        local target = outside_list[rand_num]
        local dir = getDegree(x, y, target.pos.x, target.pos.y)
        local pos = getPointFromAngleAndDistance(dir, 600)
        return x + pos['x'], y + pos['y']
    end

    if near_target then
        local target = near_target
        local dir = getDegree(x, y, target.pos.x, target.pos.y)
        local pos = getPointFromAngleAndDistance(dir, 600)
        return x + pos['x'], y + pos['y']
    end

    if self.m_owner.m_bLeftFormation then
        return x + 600, y
    else
        return x - 600, y
    end
end

-------------------------------------
-- function attack
-------------------------------------
function SkillDarkLightning:attack()

    local t_targets = self:findTarget(self.pos.x, self.pos.y, 150, self.m_targetCount)

    for i,target_char in ipairs(t_targets) do
        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)		

		-- 이펙트 생성
        self.m_world:addInstantEffect(self.m_res, 'idle', target_char.pos.x, target_char.pos.y)
    end
	
	-- 화면 떨림 연출
    ShakeDir2(math_random(335-20, 335+20), math_random(500, 1500))
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillDarkLightning:findTarget(x, y, range, count)

    local world = self.m_world
    local target_formation_mgr = nil

    if self.m_owner.m_bLeftFormation then
        target_formation_mgr = world.m_rightFormationMgr
    else
        target_formation_mgr = world.m_leftFormationMgr
    end

    local l_remove = {}
    -- 본인도 포함하도록 변경
    --l_remove[self.m_owner.phys_idx] = true

    local l_target = target_formation_mgr:findNearTarget(x, y, range, count, l_remove)

    local l_ret = {}
    
    while (#l_target > 0) and (#l_ret < count) do
        local rand_num = math_random(1, #l_target)
        local target = l_target[rand_num]
        table.insert(l_ret, target)
        table.remove(l_target, rand_num)
    end
    
    return l_ret
end