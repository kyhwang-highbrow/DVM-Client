-------------------------------------
-- class SkillPurpleProtection
-------------------------------------
SkillPurpleProtection = class(Entity, {
        m_owner = 'Character',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillPurpleProtection:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillPurpleProtection:init_skill(owner, t_skill, target)

    local add_target = (t_skill['val_2'] ~= 0)
    local base_target, l_target = self:findTargetList(target, add_target)

    if (not base_target) then
        self:changeState('dying')
        return
    end

    do -- 기본 타겟에 실드
        local res = t_skill['res_1']
        local shield_hp = base_target.m_maxHp * (t_skill['power_rate'] / 100)
        local duration = t_skill['val_1']
        self:makeShield(base_target, res, shield_hp, duration)
    end

    do -- 추가 타겟에 실드
        local res = t_skill['res_2']
        local duration = t_skill['val_1']

        for _,char in pairs(l_target) do
            local shield_hp = char.m_maxHp * (t_skill['power_rate'] / 100) / 2
            self:makeShield(char, res, shield_hp, duration)
        end
    end

    self:changeState('idle')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillPurpleProtection:initState()
    self:addState('idle', SkillPurpleProtection.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillPurpleProtection.st_idle(owner, dt)
    if (not owner.m_owner) or owner.m_owner.m_bDead then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function findTargetList
-------------------------------------
function SkillPurpleProtection:findTargetList(base_target, add_target)
    local base_target = base_target or self:findTarget()
    local l_target = {}

    if (not base_target) then
        return nil, l_target
    end

    if (not add_target) then
        return base_target, l_target
    end

    -- 기본 타겟이 중위일 경우
    if (base_target:getFormationMgr():getFormation(base_target.pos.x, base_target.pos.y) == FORMATION_MIDDLE) then 
		for _, dragon in pairs(base_target:getFormationMgr().m_middleCharList) do
			if (dragon.m_charTable['id'] ~= base_target.m_charTable['id']) then 
				table.insert(l_target, dragon)
			end
		end
	end

    return base_target, l_target
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillPurpleProtection:findTarget()
    local world = self.m_world
    local l_target = world.m_participants

    local cnt = #l_target

    if (cnt == 0) then
        return nil
    elseif (cnt == 1) then
        return l_target[1]
    else
        local random_num = math_random(1, #l_target)
        return l_target[random_num]
    end
end


-------------------------------------
-- function makeShield
-------------------------------------
function SkillPurpleProtection:makeShield(target, res, shield_hp, duration)
    local buff = Buff_Shield(res)
    self.m_world.m_worldNode:addChild(buff.m_rootNode, 10)
    self.m_world:addToUnitList(buff)
    buff:init_buff(target, shield_hp, duration)
end