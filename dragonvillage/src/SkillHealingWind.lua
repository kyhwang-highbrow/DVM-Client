-------------------------------------
-- class SkillHealingWind
-------------------------------------
SkillHealingWind = class(Entity, {
        m_owner = 'Character',
        m_activityCarrier = 'AttackDamage',
        m_tSkill = 'table',
        m_skillWidth = 'number',

        m_hitCount = 'number',
        m_hitInterval = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillHealingWind:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillHealingWind:init_skill(owner, x, y, t_skill)
    self.m_owner = owner
    self.m_tSkill = t_skill

    if (not x) or (not y) then
        x, y = self:getTargetPos()
    end
    y = 0

    self:setPosition(x, y)

    -- 공격력 계산을 위해
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)

    -- 스킬 범위
    self.m_skillWidth = t_skill['val_2']

    -- 스킬 횟수
    self.m_hitCount = t_skill['hit']
    self.m_hitInterval = 0
end

-------------------------------------
-- function initState
-------------------------------------
function SkillHealingWind:initState()
    self:addState('attack', SkillHealingWind.st_attack, 'tornado', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('attack')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillHealingWind.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
                owner:changeState('dying')
            end)
    elseif (owner.m_stateTimer >= 0.5) then
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillHealingWind.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
                owner:changeState('dying')
            end)
        owner:attack()
    end

    if (0 < owner.m_hitCount) then
        if (owner.m_hitInterval == 0) then
            owner.m_hitInterval = (owner.m_hitInterval + 0.3)
            owner:attack()
            owner.m_hitCount = (owner.m_hitCount - 1)
        else
            owner.m_hitInterval = (owner.m_hitInterval - dt)
            if (owner.m_hitInterval <= 0) then
                owner.m_hitInterval = (owner.m_hitInterval + 0.3)
                owner:attack()
                owner.m_hitCount = (owner.m_hitCount - 1)
            end
        end
    end
end

-------------------------------------
-- function getTargetPos
-------------------------------------
function SkillHealingWind:getTargetPos()
    local l_target = self.m_owner:getTargetList(self.m_tSkill)
    local target = l_target[1]

    if target then
        return target.pos.x, target.pos.y
    else
        return self.m_owner.pos.x, self.m_owner.pos.y
    end
end

-------------------------------------
-- function attack
-------------------------------------
function SkillHealingWind:attack()
    local t_targets = self:findTarget(self.pos.x, self.pos.y)

    for i,target_char in ipairs(t_targets) do

        if (self.m_owner.m_bLeftFormation == target_char.m_bLeftFormation) then
            -- 아군 회복
            local heal_rate = (self.m_tSkill['power_rate'] / 100)
            local atk_dmg = self.m_activityCarrier:getStat('atk')
            local heal = HealCalc_M(atk_dmg) * heal_rate
            target_char:healAbs(heal)

            -- 회복 이펙트
            local effect = self.m_world:addInstantEffect('res/effect/effect_heal/effect_heal.vrp', 'idle', target_char.pos.x, target_char.pos.y)
            effect:setScale(1.5)
        else
            -- 적군 공격
            self.m_activityCarrier.m_skillCoefficient = (self.m_tSkill['val_1'] / 100)
            self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
            target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
            --self.m_world:addInstantEffect('res/effect/shot_super_thunder/shot_super_thunder.vrp', 'idle', target_char.pos.x, target_char.pos.y)
        end
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillHealingWind:findTarget(x, y)
    local world = self.m_world

    local l_target = world:getTargetList(nil, x, y, 'all', 'x', 'distance_x')
    
    local l_ret = {}

    local half_skill_width = (self.m_skillWidth / 2)

    for i,v in ipairs(l_target) do
        local distance = math_abs(v.pos.x - x)
        if (distance <= half_skill_width) then
            table.insert(l_ret, v)
        else
            break
        end
    end

    return l_ret
end