local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillMeleeHack
-------------------------------------
SkillMeleeHack = class(PARENT, {
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

    local char = self.m_owner
    local target_x = self.m_targetPos.x
    local target_y = self.m_targetPos.y
    if char.m_bLeftFormation then
	    target_x = target_x - 100
    else
        target_x = target_x + 100
    end
    char:setMove(target_x, target_y, self.m_moveSpeed)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillMeleeHack:initState(attack_ani)
    self:setCommonState(self)
    self:addState('start', SkillMeleeHack.st_move, 'attack_hack_move', true)
    self:addState('attack', SkillMeleeHack.st_attack, attack_ani, false)
    self:addState('comeback', SkillMeleeHack.st_comeback, 'idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillMeleeHack:update(dt)
    -- 스킬 멈춤 여부 체크
    if (self.m_state ~= 'dying') then
	    if (self.m_owner:isDead()) then
            self:changeState('dying')
        end
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillMeleeHack.st_move(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        local ani_name, loop = owner:getCurrAniName()
        char.m_animator:changeAni(ani_name, loop)
		char:setAfterImage(true)

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('attack')

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

    elseif (owner.m_stateTimer > 3) then
        owner:changeState('comeback')
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
		char:setAfterImage(false)
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
    t_option['object_key'] = char:getMissilePhysGroup()
    t_option['attack_damage'] = self.m_activityCarrier

	t_option['missile_res_name'] = nil
    
	t_option['damage_rate'] = self.m_powerRate
    t_option['movement'] = 'instant'
    t_option['missile_type'] = 'NORMAL'

    t_option['cbFunction'] = function(attacker, defender, x, y)
        self:onAttack(defender)
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
	local attack_ani = (t_skill['animation'] == '') and 'attack_hack' or t_skill['animation']

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
end