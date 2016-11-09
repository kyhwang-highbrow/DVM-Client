local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillCrash
-- @brief 가루다의 액티스 스킬 (skill_crash)
-- t_skill
-- ['res_1']        충격파 이펙트
-- ['res_2']        돌진 이펙트 (드래곤에 붙어서 출력)
-- ['power_rate']   충격 데미지 (%)
-- ['val_1']        충격파 데미지 (%)
-- ['val_2']        충격파 반지름
-------------------------------------
SkillCrash = class(PARENT, {
        m_tSkill = 'table',

        -- t_skill에서 얻어오는 데이터
        m_shockwaveEffectRes = 'string',    -- t_skill['res_1']
        m_dashEffectRes = 'string',         -- t_skill['res_2']
        m_damageRate = 'number',            -- t_skill['power_rate']
        m_damageRateShockwave = 'number',   -- t_skill['val_1']
        m_shockwaveRadius = 'number',

        -- 내부에서 사용하는 변수들
        m_afterimageMove = 'number',
        m_physObject = 'PhysObject', -- 돌진 바디
        m_collisionChar = 'Character',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillCrash:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillCrash:init_skill(owner, t_skill, t_data)
    self.m_owner = owner
    self.m_tSkill = t_skill

    -- t_skill에서 얻어오는 데이터
    self.m_shockwaveEffectRes = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
    self.m_dashEffectRes = string.gsub(t_skill['res_2'], '@', owner:getAttribute())
    self.m_damageRate = (t_skill['power_rate'] / 100)
    self.m_damageRateShockwave = (t_skill['val_1'] / 100)
    self.m_shockwaveRadius = t_skill['val_2']

    -- AttackDamage clone
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()

    -- Dash Effect 초기화
    self:initAnimator(self.m_dashEffectRes)

    local target_x, target_y = self:getTargetPos(t_data)    
    owner:setMove(target_x, target_y, 1500)
    

    -- StateDelegate 적용
    owner:setStateDelegate(self)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillCrash:initState()
    PARENT.initState(self)
    self:addState('warning', SkillCrash.st_warning, 'idle', true)
    self:addState('move', SkillCrash.st_move, 'idle', true)
    self:addState('comeback', SkillCrash.st_comeback, 'idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillCrash:update(dt)
    local char = self.m_owner
    
    if char.m_bDead then
        self:changeState('dying')
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillCrash.st_move(owner, dt)
    local char = owner.m_owner
    owner:setPosition(char.pos.x, char.pos.y)

    if (owner.m_stateTimer == 0) then
        owner.m_afterimageMove = 0
        local ani_name, loop = owner:getCurrAniName()
        char.m_animator:changeAni(ani_name, loop)

        owner:makeCrashPhsyObject()

        owner:setRotation(char.movement_theta)

    elseif (char.m_isOnTheMove == false) then
        owner:changeState('comeback')
    else
        owner:updateAfterImage(dt)
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillCrash.st_comeback(owner, dt)
    local char = owner.m_owner

    if (owner.m_stateTimer == 0) then
        owner:releaseAnimator()
        owner:releaseCrashPhsyObject()

        -- 화면 떨림 연출
        ShakeDir2(char.movement_theta, 1500)

        -- 충격파 발생
        local x = char.pos.x
        local y = char.pos.y
        owner:attackShockwave(x, y)

        char:setMove(char.m_homePosX, char.m_homePosY, 800)
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
function SkillCrash:changeState(state, forced)
    local char = self.m_owner

    if char then
        char:addAniHandler(nil)
    end

    return PARENT.changeState(self, state, forced)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillCrash:updateAfterImage(dt)
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
-- function makeCrashPhsyObject
-------------------------------------
function SkillCrash:makeCrashPhsyObject()
    if (self.m_physObject) then
        error()
    end

    local char = self.m_owner
    local object_key = nil

    if (char.phys_key == 'hero') then
        object_key = 'missile_h'
    else
        object_key = 'missile_e'
    end

    local phys_object = char:addPhysObject(object_key, {0, 0, 20})

    phys_object:addAtkCallback(function(attacker, defender, i_x, i_y)
        self.m_collisionChar = defender
        self:changeState('comeback')
        attacker.enable_body = false
    end)

    self.m_physObject = phys_object
end

-------------------------------------
-- function releaseCrashPhsyObject
-------------------------------------
function SkillCrash:releaseCrashPhsyObject()
    local char = self.m_owner
    char:removePhysObject(self.m_physObject)
    self.m_physObject = nil
end

-------------------------------------
-- function attackShockwave
-------------------------------------
function SkillCrash:attackShockwave(x, y)
    local world = self.m_world
    local char = self.m_owner
    local is_left = char.m_bLeftFormation

    -- 이펙트 생성
    local res = self.m_shockwaveEffectRes
    local effect = self.m_world:addInstantEffect(res, 'idle', x, y)

    if is_left then
        effect:setRotation(0)
    else
        effect:setRotation(180)
    end

    -- 충돌 공격
    if self.m_collisionChar then
        local target_char = self.m_collisionChar
        self.m_activityCarrier.m_skillCoefficient = self.m_damageRate
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
    end


    local t_data = {}
    t_data['x'] = x
    t_data['y'] = y
    t_data['dir'] = 0
    t_data['angle_range'] = 60 -- 변경되지 않는 값
    t_data['radius'] = self.m_shockwaveRadius -- 360

    if char.m_bLeftFormation then
        t_data['dir'] = 0
    else
        t_data['dir'] = 180
    end

    local l_target = world:getTargetList(self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, 'enemy', 'x', 'fan_shape', t_data)

    -- 공격에 성공한 카운트
    local target_count = 0
    if self.m_collisionChar then
        target_count = 1
    end

    target_count = (target_count + #l_target)

    -- 충격파 공격
    self.m_activityCarrier.m_skillCoefficient = self.m_damageRateShockwave
    for i,target_char in ipairs(l_target) do
        if (self.m_collisionChar ~= target_char) then
            self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
            target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)
        else
            target_count = (target_count - 1)
        end
    end

    -- 메뉴얼 스킬 발동
    self:doManualSkill(target_count)

	-- 상태효과
	StatusEffectHelper:doStatusEffectByStr(self.m_owner, t_target, self.m_lStatusEffectStr)
end

-------------------------------------
-- function getTargetPos
-------------------------------------
function SkillCrash:getTargetPos(t_data)

    -- t_data(인디케이터에서 전달하는 위치)의 위치
    if (t_data and t_data['x'] and t_data['y']) then
        return t_data['x'], t_data['y']
    end

    -- 기본 타겟의 위치
    local target = self:getBaseTarget()
    if target then
        return target.pos.x, target.pos.y
    end

    -- 자신의 위치를 기반한 위치
    local char = self.m_owner
    if char.m_bLeftFormation then
        return char.pos.x + 500, char.pos.y
    else
        return char.pos.x - 500, char.pos.y
    end
end

-------------------------------------
-- function getBaseTarget
-------------------------------------
function SkillCrash:getBaseTarget()
    local l_target = self.m_owner:getTargetList(self.m_tSkill)
    local target = l_target[1]
    return target
end

-------------------------------------
-- function doManualSkill
-- @brief
-------------------------------------
function SkillCrash:doManualSkill(add_seconds)
    local char = self.m_owner

    local l_skill_id = char:getSkillID('manual')
	
    for _,skill_id in ipairs(l_skill_id) do
        local t_data = {add_duration = add_seconds}
        char:doSkill(skill_id, nil, 0, 0, t_data)
    end
end

-------------------------------------
-- function release
-------------------------------------
function SkillCrash:release()
    self:releaseCrashPhsyObject()
    PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillCrash:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillCrash(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(owner, t_skill, t_data)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('move')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end