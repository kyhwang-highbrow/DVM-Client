local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillRolling
-------------------------------------
SkillRolling = class(PARENT, {
		-- 전체 타겟 Stack
		m_lCollisionList = '',
        m_targetCollision = '',

		-- 공격 횟수 관리 용
		m_attackCnt = 'number',
		m_maxAttackCnt = 'number',

		-- 첫 이동 체크
        m_bFirstMoving = 'bool',
		
		-- 반복 공격 위한 시간 관리 용
        m_multiAtkTimer = 'dt',
        m_hitInterval = 'number',

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
function SkillRolling:init_skill(spin_res, atk_count)
    PARENT.init_skill(self)
	
	-- 멤버 변수 
	self.m_maxAttackCnt = atk_count
	self.m_spinRes = spin_res
	self.m_attackCnt = 0
    self.m_bFirstMoving = true
	
    self.m_lCollisionList = self:findCollision()
            
	-- 최초 위치 지정
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

	-- 스핀 이펙트 속도 조절
	self.m_animator:setTimeScale(2)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillRolling:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillRolling:initState()
    self:setCommonState(self)
    self:addState('start', SkillRolling.st_move, 'idle', true)
    self:addState('attack', SkillRolling.st_attack, 'idle', true)
	self:addState('comeback', SkillRolling.st_comeback, 'remove', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillRolling:update(dt)
	-- 드래곤의 애니와 객체, 스킬 위치 동기화
    do
	    self.m_owner:syncAniAndPhys()
	    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
	    if (self.m_spinAnimator) then
		    self.m_spinAnimator:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
	    end
    end
	
    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_move
-------------------------------------
function SkillRolling.st_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 드래곤 숨김
		owner.m_owner.m_animator:setVisible(false)

        -- 공격 카운트 초기화
        owner.m_attackCnt = 0

        -- 대상을 가져옴
        owner.m_targetCollision = table.pop(owner.m_lCollisionList)

		-- 스핀 이펙트
		if (owner.m_bFirstMoving and not owner.m_spinAnimator) then 
			local animator = MakeAnimator(owner.m_spinRes)
			animator:changeAni('idle', true)
			animator.m_node:setPosition(owner.m_owner.pos.x, owner.m_owner.pos.y)

            if (owner:isRightFormation()) then
                animator:setFlip(true)
            end

            local missileNode = owner.m_world:getMissileNode()
            missileNode:addChild(animator.m_node)

			owner.m_spinAnimator = animator
		end

		local releaseFunc = cc.CallFunc:create(function() owner.m_spinAnimator:release(); owner.m_spinAnimator = nil end)

        -- 이동
        if (owner.m_targetCollision) then
            local target = owner.m_targetCollision:getTarget()
            local body_key = owner.m_targetCollision:getBodyKey()

            local body = target:getBody(body_key)
            local target_pos

            if (owner:isRightFormation()) then
                target_pos = cc.p(
                    target.pos.x + body.x + 40, 
                    target.pos.y + body.y
                )
            else
                target_pos = cc.p(
                    target.pos.x + body.x - 40, 
                    target.pos.y + body.y
                )
            end

            local cbFunc = cc.CallFunc:create(function() owner:changeState('attack') end)

            if (owner.m_bFirstMoving) then
                local action = cc.MoveTo:create(0.2, target_pos)
                local delay = cc.DelayTime:create(0.3)
                owner.m_owner:runAction(cc.Sequence:create(delay, releaseFunc, cc.EaseIn:create(action, 2), cbFunc))

                owner.m_bFirstMoving = false
            else
                local action = cc.MoveTo:create(0.1, target_pos)
                owner.m_owner:runAction(cc.Sequence:create(action, cbFunc))
            end
            		
		    
        else
            owner:changeState('comeback')
        end
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
    end

    owner.m_multiAtkTimer = owner.m_multiAtkTimer + dt
	
	-- 반복 공격
    if (owner.m_multiAtkTimer > owner.m_hitInterval) then
		-- 첫공격시에만 화면 쉐이크
		if (owner.m_attackCnt == 0) then 
			owner.m_world.m_shakeMgr:shakeBySpeed(owner.movement_theta, 300) 
		end
		
        owner:attack(owner.m_targetCollision)

        owner.m_multiAtkTimer = owner.m_multiAtkTimer - owner.m_hitInterval
		owner.m_attackCnt = owner.m_attackCnt + 1
    end
	
	-- 현재 공격 대상이 죽었다면 state move_attack 로 변경
    if (owner.m_targetCollision) then
        local target = owner.m_targetCollision:getTarget()
        if (target:isDead()) then
            owner:changeState('start')
        end
	end

	-- 최대 공격 횟수 초과시 state move_attack 로 변경
    if (owner.m_maxAttackCnt <= owner.m_attackCnt) then
		owner:changeState('start')
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
-- function release
-------------------------------------
function SkillRolling:release()
    if (self.m_spinAnimator) then
        self.m_spinAnimator:release()
        self.m_spinAnimator = nil
    end

    PARENT.release(self)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillRolling:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local spin_res = t_skill['res_2']

	local atk_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 인스턴스 생성
    local skill = SkillRolling(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(spin_res, atk_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end