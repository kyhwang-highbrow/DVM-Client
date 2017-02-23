local PARENT = class(Skill, IStateDelegate:getCloneTable())

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
function SkillMeleeHack:initState(attack_ani)
    self:setCommonState(self)
    self:addState('start', SkillMeleeHack.st_move, 'attack_hack_move', true)
    self:addState('attack', SkillMeleeHack.st_attack, attack_ani, false)
    self:addState('comeback', SkillMeleeHack.st_comeback, 'idle', true)

	-- 영웅을 제어하는 스킬은 dying state를 별도로 정의
	self:addState('dying', IStateDelegate.st_dying, nil, nil, 10)
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
        char:setMoveHomePos(owner.m_comebackSpeed)
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
        
        local worldNode = char.m_world:getMissileNode('bottom')
        worldNode:addChild(accidental.m_node, 2)

        -- 하이라이트
        if (self.m_bHighlight) then
            char.m_world.m_gameHighlight:addEffect(accidental)
        end
        
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
    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['attack_damage'] = self.m_activityCarrier

    t_option['damage_rate'] = self.m_powerRate / 100
    t_option['movement'] = 'instant'
    t_option['missile_type'] = 'NORMAL'

    t_option['cbFunction'] = function()
		-- 타격 카운트 갱신
        self:addHitCount()
	end

    local missile = self.m_owner.m_world.m_missileFactory:makeMissile(t_option)
    missile.m_duration = 0.1

    do -- 이펙트 생성
        char.m_world:addInstantEffect('res/effect/effect_hit_melee/effect_hit_melee.vrp', 'idle', t_option['pos_x'], t_option['pos_y'])
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillMeleeHack:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local move_speed = t_skill['val_1'] or 1500
    local comeback_speed = t_skill['val_2'] or 1500
	local attack_ani = (t_skill['animation'] == 'x') and 'attack_hack' or t_skill['animation']

	-- 인스턴스 생성부
	------------------------------------------------------	
	-- 1. 스킬 생성
    local skill = SkillMeleeHack('', {0, 0, 0})

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(move_speed, comeback_speed)
	skill:initState(attack_ani)

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        world.m_gameHighlight:addMissile(skill)
    end
end