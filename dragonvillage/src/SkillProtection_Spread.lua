-------------------------------------
-- class SkillProtection_Spread
-------------------------------------
SkillProtection_Spread = class(Entity, {
        m_owner = 'Character',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillProtection_Spread:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillProtection_Spread:init_skill(owner, t_skill, target)
    self.m_owner = owner

    -- 지속 시간 (단위 : 초)
    local duration = t_skill['val_1']

    -- 방어력 증가 량 (단위 : %)
    local def_up = t_skill['val_2']

	-- res 경로
	local res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])

    local target = target
    if (not target) then
        target = self:findTarget()
    end

    if target then
        local buff = Buff_Protection()
        self.m_world.m_worldNode:addChild(buff.m_rootNode, 10)
        self.m_world:addToUnitList(buff)
        buff:init_buff(self.m_owner, duration, def_up, target, res)
    end

	-- @TODO 공격에 묻어나는 이펙트 Carrier 에 담아서..
	StatusEffectHelper:doStatusEffect(target, t_skill)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillProtection_Spread:initState()
    self:addState('idle', SkillProtection_Spread.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('dying')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillProtection_Spread.st_idle(owner, dt)
    if (not owner.m_owner) or owner.m_owner.m_bDead then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillProtection_Spread:findTarget()
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