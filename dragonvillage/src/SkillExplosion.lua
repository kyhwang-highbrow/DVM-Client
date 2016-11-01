local PARENT = class(Entity, ISkill:getCloneTable(), IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillExplosion
-------------------------------------
SkillExplosion = class(PARENT, {
		m_afterimageMove = 'time',
		m_targetCount= '',
		m_range = 'num',
		m_jumpRes = 'str',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillExplosion:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillExplosion:init_skill(target_count, range, jump_res)
    PARENT.init_skill(self)
	
	-- 멤버 변수 
	self.m_targetCount = target_count
	self.m_range = range
	self.m_jumpRes = jump_res
	self.m_afterimageMove = 0

	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    
	-- character를 delegate상태로 변경
    self.m_owner:setStateDelegate(self)

	-- 특정 드래곤 전용 
	self:boombaSideEffect()
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function SkillExplosion:initActvityCarrier(power_rate)    
    PARENT.initActvityCarrier(self, power_rate)    

	self.m_activityCarrier:setAtkDmgStat('def')
	self.m_activityCarrier:setIgnoreDef(power_rate == 100 and false or true)
end

-------------------------------------
-- function boombaSideEffect
-- @breif 특정 드래곤 하드 코딩
-------------------------------------
function SkillExplosion:boombaSideEffect() 
	-- 액티브 스킬 사용시 def 버프 해제
	StatusEffectHelper:releaseStatusEffect(self.m_owner, self.m_statusEffectType)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillExplosion:initState()
	self:setCommonState(self)
    self:addState('start', SkillExplosion.st_move, 'move', true)
    self:addState('attack', SkillExplosion.st_attack, 'idle', false)
	self:addState('comeback', SkillExplosion.st_comeback, 'move', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillExplosion:update(dt)
    -- 사망 체크
	if (self.m_owner.m_bDead) and (self.m_state ~= 'dying') then
        self:changeState('dying')
    end
	-- 드래곤의 애니와 객체 위치 동기화
	if (self.m_state ~= 'dying') then 
		self.m_owner:syncAniAndPhys()
	end
	
    return PARENT.update(self, dt)
end


-------------------------------------
-- function st_move
-------------------------------------
function SkillExplosion.st_move(owner, dt)
	-- 잔상 효과
	owner:updateAfterImage(dt)

    if (owner.m_stateTimer == 0) then
		-- 점프 이펙트
		local animator = MakeAnimator(owner.m_jumpRes)
		animator:changeAni('idle', false)
		animator.m_node:setPosition(owner.m_owner.m_homePosX, owner.m_owner.m_homePosY - 40)
		owner.m_owner.m_world.m_missiledNode:addChild(animator.m_node)
		
        -- 2바퀴 돌면서 점프하는 액션
        local target_pos = cc.p(owner.m_targetPos.x, owner.m_targetPos.y)
        local action = cc.JumpTo:create(0.5, target_pos, 250, 1)
		local action2 = cc.RotateTo:create(0.5, 720)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function() owner:changeState('attack') end)
		
		owner.m_owner:runAction(cc.Sequence:create(cc.Spawn:create(cc.EaseIn:create(action, 1), action2), cbFunc))

		-- 스킬 이펙트 위치 이동
		owner:setPosition(owner.m_targetPos.x, owner.m_targetPos.y)
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillExplosion.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 공격
		local attackFunc = cc.CallFunc:create(function() 
			owner:attack()
			ShakeDir2(owner.movement_theta, 1500)
		end)

		-- 1바퀴 돌면서 되돌아가는 액션
        local target_pos = cc.p(owner.m_owner.m_homePosX, owner.m_owner.m_homePosY)
        local action = cc.MoveTo:create(0.5, target_pos)
		local action2 = cc.RotateTo:create(0.5, -360)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function() owner:changeState('comeback') end)

		owner.m_owner:runAction(cc.Sequence:create(attackFunc, cc.Spawn:create(action, action2), cbFunc))
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillExplosion.st_comeback(owner, dt)
    if (owner.m_stateTimer == 0) then

	elseif (owner.m_stateTimer > 0.5) then
		owner:changeState('dying')
    end
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillExplosion:updateAfterImage(dt)
    local char = self.m_owner
	
    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + dt

    local interval = 1/30

    if (self.m_afterimageMove >= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval

        local duration = 0.3 -- 3개 잔상이 보일 정도?

        local res = char.m_animator.m_resName
        local rotation = math_random(0,360) --char.m_animator:getRotation()
        local accidental = MakeAnimator(res)

        accidental.m_node:setRotation(rotation)
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
-- function getDefaultTargetPos
-- @brief 디폴트 타겟 좌표
-------------------------------------
function SkillExplosion:getDefaultTargetPos()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
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
function SkillExplosion:attack()
    local t_targets = self:findTarget(self.m_targetPos.x, self.m_targetPos.y, self.m_range)
	
    for i,target_char in ipairs(t_targets) do
        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)

		-- 상태효과 체크
		StatusEffectHelper:doStatusEffectByType(target_char, self.m_statusEffectType, self.m_statusEffectValue, self.m_statusEffectRate)
    end
end

-------------------------------------
-- function findTarget
-- @brief 공격 대상 찾음
-------------------------------------
function SkillExplosion:findTarget(x, y, range)
    local world = self.m_world
	local l_target = world:getTargetList(self.m_owner, x, y, 'enemy', 'x', 'distance_line')
    
	local l_ret = {}
    local distance = 0

    for _, target in pairs(l_target) do
		if isCollision(x, y, target, range) then 
			table.insert(l_ret, target)
		end
    end

    return l_ret
end

-------------------------------------
-- function makeSkillInstnce
-- @param missile_res 
-------------------------------------
function SkillExplosion:makeSkillInstnce(missile_res, jump_res, range, target_count, ...)
	-- 1. 스킬 생성
    local skill = SkillExplosion(missile_res)

	-- 2. 초기화 관련 함수
	skill:setParams(...)
    skill:init_skill(target_count, range, jump_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillExplosion:makeSkillInstnceFromSkill(owner, t_skill, t_data)
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
    local missile_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
	local jump_res = t_skill['res_2']
    local range = t_skill['val_1']
	local target_count = t_skill['val_2']

    SkillExplosion:makeSkillInstnce(missile_res, jump_res, range, target_count, owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
end
