
-- @TODO 사용 안함 - 확인 후 삭제


-------------------------------------
-- class SkillCurve
-------------------------------------
SkillCurve = class(Entity, {
        m_owner = 'Character',
        m_activityCarrier = 'AttackDamage',
        m_targetList = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCurve:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function init_SkillCurve
-------------------------------------
function SkillCurve:init_skill(owner, t_skill)
    self.m_owner = owner
    self.m_targetList = self:findTarget(t_skill['val_1'])

    for i,v in pairs(self.m_targetList) do
        self:makeEffect(BoomerangCalc.DIR_LEFT, v.pos.x, v.pos.y)
        self:makeEffect(BoomerangCalc.DIR_RIGHT, v.pos.x, v.pos.y)
    end


    self.m_activityCarrier = owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCurve:initState()
    self:addState('idle', SkillCurve.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillCurve.st_idle(owner, dt)
    if owner.m_stateTimer >= (BoomerangCalc.DURATION/2) then
        for i,target_char in ipairs(owner.m_targetList) do
            -- 공격
            owner:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
            target_char:runDefCallback(owner, target_char.pos.x, target_char.pos.y)
        end

        owner:changeState('dying')
    end
end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillCurve:makeEffect(direction, x, y)
    -- 레이어를 정함
    local parent = nil
    local is_foreground = false
    if self.m_owner.m_bLeftFormation then
        if (direction == BoomerangCalc.DIR_LEFT) then
            parent = self.m_world.m_worldNode
        else
            parent = self.m_world.m_missiledNode
            is_foreground = true
        end
    else
        if (direction == BoomerangCalc.DIR_LEFT) then
            parent = self.m_world.m_missiledNode
            is_foreground = true
        else
            parent = self.m_world.m_worldNode
        end
    end

    -- 이팩트 생성
    local effect = SkillCurve_Effect('res/effect/shot_boomerang_fire/shot_boomerang_fire.spine')
    effect.m_direction = direction
    effect.m_bForeground = is_foreground
    effect.m_animator:setScale(0.3)
    effect.m_animator.m_node:setScaleY(0.4 * 0.8)

    parent:addChild(effect.m_rootNode, 0)
    self.m_world:addToUnitList(effect)

    effect:setPosition(self.pos.x, self.pos.y)

    effect.m_cTargetPosX = x
    effect.m_cTargetPosY = y
end


-------------------------------------
-- function findTarget
-------------------------------------
function SkillCurve:findTarget(count)
    local l_idx = {}
    for i,v in ipairs(self.m_world.m_tEnemyList) do
        table.insert(l_idx, i)
    end

    local l_target = {}

    while (#l_target < count) and (#l_idx > 0) do
        local rand_num = math_random(1, #l_idx)
        local target = self.m_world.m_tEnemyList[rand_num]
        table.insert(l_target, target)
    end
    
    return l_target
end


-------------------------------------
-- class SkillCurve_Effect
-------------------------------------
SkillCurve_Effect = class(Entity, {
        m_cStartPosX = '',
        m_cStartPosY = '',
        m_cDir = '',

        m_cTargetPosX = '',
        m_cTargetPosY = '',

        m_direction = '',
        m_bForeground = '',

        m_boomerangCalc = 'BoomerangCalc',
     })


-------------------------------------
-- function init
-------------------------------------
function SkillCurve_Effect:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCurve_Effect:initState()
    self:addState('move', SkillCurve_Effect.st_move, 'move', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillCurve_Effect.st_move(owner, dt)
    if owner.m_stateTimer == 0 then
        owner.m_cStartPosX = owner.pos.x
        owner.m_cStartPosY = owner.pos.y


        local target_x = owner.m_cTargetPosX
        local target_y = owner.m_cTargetPosY

        local dist = getDistance(owner.m_cStartPosX, owner.m_cStartPosY, target_x, target_y)
        owner.m_boomerangCalc = BoomerangCalc(owner.m_direction, dist)

        owner.m_cDir = getDegree(owner.m_cStartPosX, owner.m_cStartPosY, target_x, target_y)

        owner:setSpeed(0)
        owner:setRotation(owner.m_cDir + 90)
    else
        owner.m_boomerangCalc:update(dt)

        local dir = getDegree(0, 0, owner.m_boomerangCalc.m_posX, owner.m_boomerangCalc.m_posY)
        local dist = getDistance(0, 0, owner.m_boomerangCalc.m_posX, owner.m_boomerangCalc.m_posY)
        local pos = getPointFromAngleAndDistance(owner.m_cDir + dir, dist)

        local x = owner.m_cStartPosX + pos['x']
        local y = owner.m_cStartPosY + pos['y']
        owner:setPosition(x, y)


        -- 스케일
        local max_y = (owner.m_boomerangCalc.m_distance / 2) * 0.2
        local scale = 0.8 - (owner.m_boomerangCalc.m_posY / max_y * 0.2)
        owner.m_rootNode:setScale(scale)
    end


    -- 1초가 지나면 끝 위치에 도달했으므로 삭제
    if owner.m_stateTimer >= (BoomerangCalc.DURATION/2) then
        owner:changeState('dying')
    end
end