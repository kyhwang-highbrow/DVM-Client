local PARENT = class(Entity, ISkill:getCloneTable(), IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillMeleeHack
-------------------------------------
SkillMeleeHack = class(PARENT, {
        m_afterimageMove = 'number',
        m_moveSpeed = 'number',
        m_comebackSpeed = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillMeleeHack:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillMeleeHack:init_skill(move_speed, comeback_speed)
    PARENT.init_skill(self)
	
	-- 멤버 변수 
	self.m_moveSpeed = move_speed
	self.m_comebackSpeed = comeback_speed
	self.m_afterimageMove = 0

    local char = self.m_owner

    local target_x = self.m_targetPos.x
    local target_y = self.m_targetPos.y

    if (not target_x) or (not target_y) then
        if char.m_targetChar then
            target_x = char.m_targetChar.pos.x
            target_y = char.m_targetChar.pos.y

			self.m_target = char.m_targetChar
        else
            local add_x = 0
            if char.m_bLeftFormation then
                add_x = 300
            else 
                add_x = -300
            end
            target_x = char.pos.x + add_x
            target_y = char.pos.y
        end
    end

    if char.m_bLeftFormation then
        target_x = target_x - 100
    else
        target_x = target_x + 100
    end

    char:setMove(target_x, target_y, self.m_moveSpeed)

    -- StateDelegate 적용
    char:setStateDelegate(self)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillMeleeHack:initState()
    PARENT.initState(self)
    self:addState('move', SkillMeleeHack.st_move, 'attack_hack_move', true)
    self:addState('attack', SkillMeleeHack.st_attack, 'attack_hack', false)
    self:addState('comeback', SkillMeleeHack.st_comeback, 'idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillMeleeHack:update(dt)
    local char = self.m_owner
    
    if char.m_bDead then
        self:changeState('dying')
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillMeleeHack.st_move(owner, dt)
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
function SkillMeleeHack.st_attack(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        local ani_name, loop = owner:getCurrAniName()
        char.m_animator:changeAni(ani_name, loop)
        char:addAniHandler(function() owner:changeState('comeback') end)
        
        local function attack_cb(event)
            owner:attackMelee()
        end
        char.m_animator:setEventHandler(attack_cb)
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillMeleeHack.st_comeback(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        char:setMove(char.m_homePosX, char.m_homePosY, owner.m_comebackSpeed)
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
function SkillMeleeHack:changeState(state, forced)
    local char = self.m_owner

    if char then
        char:addAniHandler(nil)
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillMeleeHack:updateAfterImage(dt)
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
function SkillMeleeHack:attackMelee()
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

    t_option['physics_body'] = {0, 0, 30}
    --t_option['attack_damage'] = char:makeAttackDamageInstance()
    t_option['attack_damage'] = self.m_activityCarrier

    if (char.phys_key == 'hero') then
        t_option['object_key'] = 'missile_h'
    else
        t_option['object_key'] = 'missile_e'
    end

    t_option['damage_rate'] = self.m_powerRate / 100
    t_option['movement'] = 'instant'
    t_option['missile_type'] = 'NORMAL'

    local missile = self.m_owner.m_world.m_missileFactory:makeMissile(t_option)
    missile.m_duration = 0.1

    do -- 이펙트 생성
        char.m_world:addInstantEffect('res/effect/effect_hit_melee/effect_hit_melee.vrp', 'idle', t_option['pos_x'], t_option['pos_y'])
    end
end

-------------------------------------
-- function makeSkillInstnce
-------------------------------------
function SkillMeleeHack:makeSkillInstnce(move_speed, comeback_speed, ...)
	-- 1. 스킬 생성
    local skill = SkillMeleeHack('', {0, 0, 0})

	-- 2. 초기화 관련 함수
	skill:setParams(...)
    skill:init_skill(move_speed, comeback_speed)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('move')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillMeleeHack:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner
    
	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local pre_delay = t_skill['pre_delay']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_value = t_skill['status_effect_value']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target

	-- 2. 특수 변수
	local move_speed = t_skill['val_1'] or 1500
    local comeback_speed = t_skill['val_2'] or 1500

    SkillMeleeHack:makeSkillInstnce(move_speed, comeback_speed, owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
end