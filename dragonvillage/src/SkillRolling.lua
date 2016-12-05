local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillRolling
-------------------------------------
SkillRolling = class(PARENT, {
		-- 공격 횟수 관리 용
		m_attackCnt = 'number',
		m_targetCnt = 'number',
		m_maxTargetCnt = 'number',
		m_maxAttackCnt = 'number',

		-- 이동 체크
		m_bMoving = 'bool',

		-- 반복 공격 위한 시간 관리 용
        m_multiAtkTimer = 'dt',
        m_hitInterval = 'number',
		
		-- 잔상 시간 관리 용
		m_afterimageMove = '',

		-- 스핀 애니메이션 관련
		m_spinRes = 'str',
		m_spinAnimator = 'ani',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillRolling:init(file_name, body, ...)    
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillRolling:init_skill(spin_res, target_count, buff_prob, atk_count)
    PARENT.init_skill(self)
	
	-- 멤버 변수 
	self.m_maxTargetCnt = target_count
	self.m_maxAttackCnt = atk_count
	self.m_spinRes = spin_res
	self.m_afterimageMove = 0
	self.m_targetCnt = 0
	self.m_attackCnt = 0
	self.m_bMoving = false

    -- 최초 위치 지정
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

	-- 스핀 이펙트 속도 조절
	self.m_animator:setTimeScale(2)

    -- StateDelegate 적용
    self.m_owner:setStateDelegate(self)
end

-------------------------------------
-- function initSpineSideEffect
-- @breif 특정 드래곤 하드 코딩
-------------------------------------
function SkillRolling:spineSideEffect()
end

-------------------------------------
-- function initState
-------------------------------------
function SkillRolling:initState()
    self:setCommonState(self)
    self:addState('start', SkillRolling.st_move, 'idle', true)
    self:addState('attack', SkillRolling.st_attack, 'idle', true)
	self:addState('moveAttack', SkillRolling.st_move_attack, 'idle', true)
	self:addState('comeback', SkillRolling.st_comeback, 'remove', true)

	-- 영웅을 제어하는 스킬은 dying state를 별도로 정의 
    self:addState('dying', IStateDelegate.st_dying, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function SkillRolling:update(dt)
	-- 사망 체크
    if (self.m_owner.m_bDead) and (self.m_state ~= 'dying') then
        self:changeState('dying')
    end
	-- 드래곤의 애니와 객체, 스킬 위치 동기화
	self.m_owner:syncAniAndPhys()
	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
	if (nil ~= self.m_spinAnimator) then
		self.m_spinAnimator:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
	end
	
    return PARENT.update(self, dt)
end


-------------------------------------
-- function st_move
-------------------------------------
function SkillRolling.st_move(owner, dt)
	-- 잔상 효과
	owner:updateAfterImage(dt)

    if (owner.m_stateTimer == 0) then
		owner.m_owner.m_animator:setVisible(false) 
		-- 스핀 이펙트
		if (nil == owner.m_spinAnimator) then 
			local animator = MakeAnimator(owner.m_spinRes)
			animator:changeAni('idle', true)
			animator.m_node:setPosition(owner.m_owner.pos.x, owner.m_owner.pos.y)
			owner.m_owner.m_world.m_missiledNode:addChild(animator.m_node)
			owner.m_spinAnimator = animator
		end

		local releaseFunc = cc.CallFunc:create(function() owner.m_spinAnimator:release(); owner.m_spinAnimator = nil end)
		

        -- 이동
        local target_pos = cc.p(owner.m_targetPos.x - 40, owner.m_targetPos.y)
        local action = cc.MoveTo:create(0.2, target_pos)
		local delay = cc.DelayTime:create(0.5)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function() owner:changeState('attack') end)
		
		owner.m_owner:runAction(cc.Sequence:create(delay, releaseFunc, cc.EaseIn:create(action, 2), cbFunc))
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillRolling.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 이펙트 재생 단위 시간
		owner.m_hitInterval = 5/30
		-- 첫프레임부터 공격하기 위해서 인터벌 타임으로 설정
        owner.m_multiAtkTimer = owner.m_hitInterval
		owner.m_attackCnt = 0
    end

    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt
	
	-- 반복 공격
    if (owner.m_multiAtkTimer > owner.m_hitInterval) then
		-- 첫공격시에만 화면 쉐이크
		if (owner.m_attackCnt == 0) then ShakeDir2(owner.movement_theta, 300) end
		owner:runAttack(true) -- @TODO 구조 개선 필요

        owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
		owner.m_attackCnt = owner.m_attackCnt + 1
    end
	
	-- 현재 공격 대상이 죽었다면 state move_attack 로 변경
	if (owner.m_targetChar) and (owner.m_targetChar.m_bDead) then
		owner:changeState('moveAttack')
		
		-- 스파인 드래곤 .. 적 죽일 시 상태효과
		if (owner.m_targetChar) and (owner.m_targetChar.m_bDead) then
			StatusEffectHelper:doStatusEffectByStr(owner.m_owner, {}, owner.m_lStatusEffectStr)
		end
	end

	-- 최대 공격 횟수 초과시 돌아감
    if (owner.m_maxAttackCnt <= owner.m_attackCnt) then
		owner:changeState('comeback')
    end
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillRolling.st_move_attack(owner, dt)
	-- 잔상 효과
	owner:updateAfterImage(dt)

	-- a. 이동중인지 체크
	if (not owner.m_bMoving) then 
		-- 1. 다음 타겟을 검색
		if (not owner.m_targetChar) then
			-- 1-1. 최대 충돌 갯수 체크
			if (owner.m_maxTargetCnt > owner.m_targetCnt) then
				local t_targets = owner.m_world:getTargetList(owner.m_owner, 0, 0, 'enemy', 'x', 'distance_line')
				-- 1-2. 타겟이 있는지 체크
				local rand = math_random(1, #t_targets)
				if t_targets[rand] then 
					owner.m_targetChar = t_targets[rand]
					owner.m_targetPos = t_targets[rand].pos
				else
					owner:changeState('comeback')
				end
			else
				owner:changeState('comeback')
			end

		-- 2. 타겟이 있으면 이동 공격
		else
			-- 2-1. 이동
			local target_pos = cc.p(owner.m_targetPos.x, owner.m_targetPos.y)
			local action = cc.MoveTo:create(0.1, target_pos)
			owner.m_bMoving = true

			-- 2-2. state chnage 함수 콜
			local cbFunc = cc.CallFunc:create(function() 
				local animator = MakeAnimator('res/effect/effect_hit_01/effect_hit_01.vrp')
				animator:changeAni('idle', true)
				animator.m_node:setPosition(owner.m_owner.pos.x, owner.m_owner.pos.y)
				owner.m_owner.m_world.m_missiledNode:addChild(animator.m_node)

				ShakeDir2(owner.movement_theta, 300)
				owner:runAttack(true) -- @TODO 구조 개선 필요
				owner.m_bMoving = false
			end)
		
			-- 2-3. 액션 실행 및 후 타겟 지움
			owner.m_owner:runAction(cc.Sequence:create(cc.EaseIn:create(action, 2), cbFunc))
			owner.m_targetCnt = owner.m_targetCnt + 1
			owner.m_targetChar = nil
		end
	end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillRolling.st_comeback(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 이동
        local target_pos = cc.p(owner.m_owner.m_homePosX, owner.m_owner.m_homePosY)
        local action = cc.MoveTo:create(0.1, target_pos)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function()	
			owner.m_owner.m_animator:setVisible(true)
			owner:changeState('dying') 
		end)
		
		owner.m_owner:runAction(cc.Sequence:create(cc.EaseOut:create(action, 2), cbFunc))
    end
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function SkillRolling:updateAfterImage(dt)
    local char = self
	
    -- 에프터이미지
    self.m_afterimageMove = self.m_afterimageMove + dt

    local interval = 1/30

    if (self.m_afterimageMove >= interval) then
        self.m_afterimageMove = self.m_afterimageMove - interval

        local duration = 0.3 -- 3개 잔상이 보일 정도?

        local res = char.m_animator.m_resName
        local accidental = MakeAnimator(res)
        accidental:changeAni(char.m_animator.m_currAnimation)

        local parent = char.m_rootNode:getParent()
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
function SkillRolling:getDefaultTargetPos()
    local l_target = self.m_owner:getTargetListByType(self.m_targetType)
    local target = l_target[1]

    if target then
        return target.pos.x, target.pos.y
    else
        return self.m_owner.pos.x, self.m_owner.pos.y
    end
end

-------------------------------------
-- function findTarget
-- @brief 공격 대상 찾음
-------------------------------------
function SkillRolling:findTarget()
	local x = self.m_targetPos.x
	local y = self.m_targetPos.y
	local range = 1

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
-- function makeSkillInstance
-------------------------------------
function SkillRolling:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local spin_res = t_skill['res_2']
	local target_count = t_skill['val_1']
	local buff_prob = t_skill['val_2']
	local atk_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 인스턴스 생성
    local skill = SkillRolling(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(spin_res, target_count, buff_prob, atk_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end