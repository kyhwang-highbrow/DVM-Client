local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillLeonBasic
-------------------------------------
SkillLeonBasic = class(PARENT, {
        m_owner = 'Character',
        m_damageRate = 'number',
        m_afterimageMove = 'number',

        m_waitTime = 'number', -- 공격 전 대기시간
        m_moveSpeed = 'number', -- 이동 속도
        m_combackDuration = 'number', -- 복귀 시간

        m_hackPosX = 'number', -- 공격을 하는 위치
        m_hackPosY = 'number', -- 공격을 하는 위치

        m_targetX = 'number', -- 타겟이 있는 위치
        m_targetY = 'number', -- 타겟이 있는 위치

        m_destPosX = 'number', -- 도착 위치
        m_destPosY = 'number', -- 도착 위치

        m_attackType = 'string',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLeonBasic:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLeonBasic:init_skill(owner, target_x, target_y, wait_time, damage_rate, move_speed, comback_duration, attack_type)
    self.m_owner = owner
    local char = owner

    self.m_waitTime = wait_time
    self.m_damageRate = damage_rate
    self.m_moveSpeed = move_speed or 1500
    self.m_combackDuration = comback_duration or 0.5
    self.m_attackType = attack_type

    -- 위치 지정
    if (not target_x) or (not target_y) then
        if char.m_targetChar then
            target_x = char.m_targetChar.pos.x
            target_y = char.m_targetChar.pos.y
        else
            local add_x = 0
            if char.m_bLeftFormation then
                add_x = 300
            else 
                add_x = -300
            end
            target_x = owner.pos.x + add_x
            target_y = owner.pos.y
        end
    end

    self.m_targetX = target_x
    self.m_targetY = target_y

    do -- hack위치
        local degree = getDegree(self.m_targetX, self.m_targetY, char.pos['x'], char.pos['y'])
        local offset = getPointFromAngleAndDistance(degree, 100)
        self.m_hackPosX = (self.m_targetX + offset['x'])
        self.m_hackPosY = (self.m_targetY + offset['y'])
    end

    do -- dest위치
        local degree = getDegree(char.pos['x'], char.pos['y'], self.m_targetX, self.m_targetY)
        local offset = getPointFromAngleAndDistance(degree, 50)
        self.m_destPosX = (self.m_targetX + offset['x'])
        self.m_destPosY = (self.m_targetY + offset['y'])
    end

    -- StateDelegate 적용
    owner:setStateDelegate(self)
    if wait_time then
        self:changeState('wait')
    else
        self:changeState('move')
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLeonBasic:initState()
    PARENT.initState(self)
    self:addState('wait', SkillLeonBasic.st_wait, 'idle', true)
    self:addState('move', SkillLeonBasic.st_move, 'attack_hack_move', true)
    self:addState('move2', SkillLeonBasic.st_move2, 'attack_hack', false)
    self:addState('attack', SkillLeonBasic.st_attack, nil, false)
    self:addState('comeback', SkillLeonBasic.st_comeback, 'idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillLeonBasic:update(dt)
    local char = self.m_owner
    
    if char.m_bDead then
        self:changeState('dying')
    end

    return PARENT.update(self, dt)
end


-------------------------------------
-- function st_wait
-------------------------------------
function SkillLeonBasic.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:syncAnimation()
    elseif (owner.m_waitTime <= owner.m_stateTimer) then
        owner:changeState('move')
    end
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillLeonBasic.st_move(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then

        do -- 이펙트 생성
            local effect = char.m_world:addInstantEffect('res/effect/effect_dash_start/effect_dash_start.vrp', 'idle', char.pos['x'], char.pos['y'])
            effect:setScale(0.7)
            effect:setTimeScale(2)
        end

        owner.m_afterimageMove = 0
        owner:syncAnimation()

        char:setMove(owner.m_hackPosX, owner.m_hackPosY, owner.m_moveSpeed)

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('move2')

    else
        owner:updateAfterImage(dt)
    end
end

-------------------------------------
-- function st_move2
-------------------------------------
function SkillLeonBasic.st_move2(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        owner:attackMelee()
        owner:syncAnimation()

        char:setMove(owner.m_destPosX, owner.m_destPosY, owner.m_moveSpeed)
        --ShakeDir2(char.movement_theta, char.speed / 2)

        do -- 이펙트 생성
            local effect = char.m_world:addInstantEffect('res/effect/effect_hit_tamer/effect_hit_tamer.vrp', 'idle', owner.m_targetX, owner.m_targetY)
        end
    elseif (char.m_isOnTheMove == false) then
        owner:changeState('attack')
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillLeonBasic.st_attack(owner, dt)
    local char = owner.m_owner

    -- 에니메이션이 종료되거나 0.3초 후에 comeback 
    if (owner.m_stateTimer == 0) then
        char:addAniHandler(function() owner:changeState('comeback') end)
    elseif (owner.m_stateTimer >= 0.3) then
        --owner:changeState('comeback')
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillLeonBasic.st_comeback(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then

        local dest_rotation = 720
        if (char.m_homePosX < char.pos['x']) then
            dest_rotation = (dest_rotation * -1)
        end

        -- 2바퀴 돌면서 점프하는 액션
        local target_pos = cc.p(char.m_homePosX, char.m_homePosY)
        local action = cc.JumpTo:create(owner.m_combackDuration, target_pos, 250, 1)
		local action2 = cc.RotateTo:create(owner.m_combackDuration, dest_rotation)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function()
            char:setPosition(char.m_rootNode:getPosition())
            owner:changeState('dying')
        end)
		
		char.m_rootNode:runAction(cc.Sequence:create(cc.Spawn:create(cc.EaseIn:create(action, 1), action2), cbFunc))	
    end
    char:setPosition(char.m_rootNode:getPosition())
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function SkillLeonBasic:changeState(state, forced)
    local char = self.m_owner

    if char then
        char:addAniHandler(nil)
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillLeonBasic:updateAfterImage(dt)
    local char = self.m_owner

    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + (char.speed * dt)

    --local interval = char.body.size * 0.5 -- 반지름이기 때문에 2배
    local interval = 50

    if (self.m_afterimageMove >= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval

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
function SkillLeonBasic:attackMelee()
    local char = self.m_owner

    local t_option = {}

    t_option['owner'] = char

    t_option['pos_x'] = self.m_targetX
    t_option['pos_y'] = self.m_targetY

    t_option['physics_body'] = {0, 0, 100}
    
    t_option['attack_damage'] = self.m_activityCarrier
    t_option['attack_damage']:setAttackType(self.m_attackType)

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

-------------------------------------
-- function makeSkillInstnce
-- @param missile_res 
-------------------------------------
function SkillLeonBasic:makeSkillInstnce(owner, target_x, target_y, wait_time, damage_rate, move_speed, comback_duration, attack_type)
    local world = owner.m_world

    local skill = SkillLeonBasic(nil)
    skill:initState()
    skill:init_skill(owner, target_x, target_y, wait_time, damage_rate, move_speed, comback_duration, attack_type)

    -- Physics, Node, GameMgr에 등록
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillLeonBasic:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local target_x = (t_data and t_data['x'])
    local target_y = (t_data and t_data['y'])
    local damage_rate = (t_skill['power_rate'] / 100)
    local move_speed = t_skill['val_1']
    local comback_duration = t_skill['val_2']
    local attack_type = t_skill['chance_type']
    local wait_time = nil

    SkillLeonBasic:makeSkillInstnce(owner, target_x, target_y, wait_time, damage_rate, move_speed, comback_duration, attack_type)
end


-------------------------------------
-- function syncAnimation
-------------------------------------
function SkillLeonBasic:syncAnimation()
    local char = self.m_owner
    local ani_name, loop = self:getCurrAniName()
    char.m_animator:changeAni(ani_name, loop)
end

        