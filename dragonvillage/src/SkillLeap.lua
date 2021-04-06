local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillLeap
-------------------------------------
SkillLeap = class(PARENT, {
		m_jumpRes = 'str',
        m_rotateCount = 'number',

        m_attackAniName = 'string',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLeap:init(file_name, body, ...)
    self.m_rotateCount = 2
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillLeap:init_skill(jump_res)
	PARENT.init_skill(self)
	
	-- 멤버 변수
    self.m_jumpRes = jump_res

	self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillLeap:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		--self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end

    self.m_range = 100
end

-------------------------------------
-- function setSkillParams
-- @brief 
-------------------------------------
function SkillLeap:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    if (not t_skill) then return end

    if (t_skill['val_1'] and tonumber(t_skill['val_1'])) then
        -- 회전각도 비율 * 360
        -- 정수 부수 모두 가능
        self.m_rotateCount = tonumber(t_skill['val_1'])
    end

    if (t_skill['animation']) then self.m_attackAniName = t_skill['animation'] end

end

-------------------------------------
-- function initState
-------------------------------------
function SkillLeap:initState()
	self:setCommonState(self)
    self:addState('start', SkillLeap.st_move, 'move', true)
    self:addState('attack', SkillLeap.st_attack, 'idle', false)
	self:addState('comeback', SkillLeap.st_comeback, 'move', true)
end

-------------------------------------
-- function update
-------------------------------------
function SkillLeap:update(dt)
    -- 사망 체크
	if (self.m_owner:isDead()) and (self.m_state ~= 'dying') then
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
function SkillLeap.st_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_owner:resetMove()
		owner.m_owner:setAfterImage(true)
        owner.m_owner.m_animator:changeAni(owner.m_attackAniName, true)

		-- 점프 이펙트
		local animator = MakeAnimator(owner.m_jumpRes)
		if animator then 
			animator:changeAni('idle', false)
			animator.m_node:setPosition(owner.m_owner.pos.x, owner.m_owner.pos.y - 40)

            local missileNode = owner.m_world:getMissileNode()
            missileNode:addChild(animator.m_node)
		end 

        -- 2바퀴 돌면서 점프하는 액션
        local target_pos = cc.p(owner.m_targetPos.x, owner.m_targetPos.y)
        local action = cc.JumpTo:create(0.5, target_pos, 250, 1)
		local action2 = cc.RotateTo:create(0.5, 360 * owner.m_rotateCount)

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
function SkillLeap.st_attack(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 공격
		owner:runAttack()
		owner.m_world.m_shakeMgr:shakeBySpeed(owner.movement_theta, 1500)
		owner:changeState('comeback')
    end
end

-------------------------------------
-- function st_comeback
-------------------------------------
function SkillLeap.st_comeback(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 1바퀴 돌면서 되돌아가는 액션
        local target_pos = cc.p(owner.m_owner.m_homePosX, owner.m_owner.m_homePosY)
        local action = cc.MoveTo:create(0.5, target_pos)
		local action2 = cc.RotateTo:create(0.5, -360)
		
		-- state change 함수 콜
		local cbFunc = cc.CallFunc:create(function() 
			owner.m_owner:setAfterImage(false)
			owner:changeState('dying')  
		end)

		owner.m_owner:runAction(cc.Sequence:create(cc.Spawn:create(action, action2), cbFunc))
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillLeap:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local jump_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillLeap(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(jump_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end
