-------------------------------------
-- class SkillDeepStab
-------------------------------------
SkillDeepStab = class(Entity, {
        m_owner = 'Character',

        m_damageRate = 'number',

        m_startPosX = 'number',
        m_startPosY = 'number',

        m_targetPosX = 'number',
        m_targetPosY = 'number',

        m_afterimageMove = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillDeepStab:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillDeepStab:init_skill(owner, t_skill, t_data)
    self.m_owner = owner
    local char = owner

    self.m_damageRate = (t_skill['power_rate'] / 100)

    char:changeState('delegate')

    -- 제자리로 돌아가기 위해 위치 저장
    self.m_startPosX = char.pos.x
    self.m_startPosY = char.pos.y

    local target_x = nil
    local target_y = nil

    if t_data then
        target_x = t_data['x']
        target_y = t_data['y']
    end

    if (not target_x) or (not target_y) then
        if char.m_targetChar then
            target_x = char.m_targetChar.pos.x
            target_y = char.m_targetChar.pos.y
        else
            target_x = x
            target_y = y
        end
    end

    local effect = char.m_world:addInstantEffect('res/indicator/warning_sign/warning_sign.vrp', 'warning_circle', target_x, target_y)
    effect:setScale(0.5)

    if char.m_bLeftFormation then
        target_x = target_x - 100
    else
        target_x = target_x + 100
    end

    self.m_targetPosX = target_x
    self.m_targetPosY = target_y
end

-------------------------------------
-- function initState
-------------------------------------
function SkillDeepStab:initState()
    self:addState('warning', SkillDeepStab.st_warning, 'idle', true)

  
    self:addState('move', SkillDeepStab.st_move, 'move', true)
    self:addState('attack', SkillDeepStab.st_attack, 'attack_3', false)
    self:addState('comeback', SkillDeepStab.st_comeback, 'move', true)

    self:addState('dying', function(owner, dt) 
            if (not owner.m_owner.m_bDead) then
                owner.m_owner:changeState('attackDelay')
            end
            return true
        end, nil, nil, 10)
    
    self:changeState('warning')
end

-------------------------------------
-- function update
-------------------------------------
function SkillDeepStab:update(dt)
    local char = self.m_owner
    
    if char.m_bDead then
        self:changeState('dying')
    end

    return Entity.update(self, dt)
end

-------------------------------------
-- function st_warning
-------------------------------------
function SkillDeepStab.st_warning(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer >= 2) then
        char:setMove(owner.m_targetPosX, owner.m_targetPosY, 1500)
        owner:changeState('move')
    end
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillDeepStab.st_move(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        owner.m_afterimageMove = 0
        local ani_name, loop = owner:getCurrAniName()
        char.m_animator:changeAni(ani_name, loop)

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('attack')
    else
        owner:updateAfterImage(dt)
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillDeepStab.st_attack(owner, dt)
    local char = owner.m_owner
    if (owner.m_stateTimer == 0) then

        -- 에니메이션 변경
        local ani_name, loop = owner:getCurrAniName()
        char.m_animator:changeAni(ani_name, loop)

        -- 에니메이션 종료 후 컴백
        char:addAniHandler(function()
            owner:changeState('comeback')
        end)

        -- 공격
        char.m_animator:setEventHandler(function()
            owner:attackMelee()

            -- 화면 떨림 연출
            ShakeDir2(char.movement_theta, char.speed)

            -- 이팩트 생성
            char.m_world:addInstantEffect('res/effect/effect_hit_physical_wind/effect_hit_physical_wind.spine', 'idle', char.pos.x, char.pos.y)
        end)
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillDeepStab.st_comeback(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then        
        char:setMove(owner.m_startPosX, owner.m_startPosY, 800)
    elseif (char.m_isOnTheMove == false) then
        owner:changeState('dying')
    end
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function SkillDeepStab:changeState(state, forced)
    local char = self.m_owner

    if char then
        char:addAniHandler(nil)
    end

    return Entity.changeState(self, state, forced)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillDeepStab:updateAfterImage(dt)
    local char = self.m_owner

    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + (char.speed * dt)

    --local interval = char.body.size * 0.5 -- 반지름이기 때문에 2배
    local interval = 50

    if (self.m_afterimageMove >= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval
        -- cclog('출력 출력 출력')

        local duration = (interval / char.speed) * 1.5 -- 3개의 잔상이 보일 정도
        duration = math_clamp(duration, 0.3, 0.7)

        local res = char.m_animator.m_resName
        local rotation = char.m_animator:getRotation()
        local accidental = MakeAnimator(res)
        --accidental.m_node:setRotation(rotation)
        accidental:changeAni(char.m_animator.m_currAnimation)
        local parent = char.m_rootNode:getParent()
        --parent:addChild(accidental.m_node)
        char.m_world.m_worldNode:addChild(accidental.m_node, 2)
        accidental:setScale(char.m_animator:getScale())
        accidental:setFlip(char.m_animator.m_bFlip)
        accidental.m_node:setOpacity(255 * 0.3)
        accidental.m_node:setPosition(char.pos.x, char.pos.y)
        accidental.m_node:runAction(cc.Sequence:create(cc.FadeTo:create(duration, 0), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function attackMelee
-------------------------------------
function SkillDeepStab:attackMelee()
    local char = self.m_owner

    local t_option = {}

    t_option['owner'] = char

    if (char.m_bLeftFormation == true) then
        t_option['pos_x'] = char.pos.x + 100
        t_option['pos_y'] = char.pos.y
    else
        t_option['pos_x'] = char.pos.x - 100
        t_option['pos_y'] = char.pos.y
    end

    t_option['physics_body'] = {0, 0, 100}
    t_option['attack_damage'] = char:makeAttackDamageInstance()

    if (char.phys_key == 'hero') then
        t_option['object_key'] = 'missile_h'
    else
        t_option['object_key'] = 'missile_e'
    end

    t_option['damage_rate'] = self.m_damageRate
    t_option['movement'] = 'instant'
    t_option['missile_type'] = 'PASS'

    local missile = self.m_owner.m_world.m_missileFactory:makeMissile(t_option)
    missile.m_duration = 0.1
end