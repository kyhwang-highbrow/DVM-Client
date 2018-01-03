local PARENT = SkillAoERound

-------------------------------------
-- class SkillAoERound_Throw
-------------------------------------
SkillAoERound_Throw = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAoERound_Throw:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAoERound_Throw:init_skill(attack_count)
    PARENT.init_skill(self)

    -- 멤버 변수
    self.m_maxAttackCount = attack_count 

    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillAoERound_Throw:initSkillSize()
	if (self.m_skillSize) and (not (self.m_skillSize == '')) then
		local t_data = SkillHelper:getSizeAndScale('round', self.m_skillSize)  

		self.m_resScale = t_data['scale']
		self.m_range = t_data['size']
	end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAoERound_Throw:initState()
	self:setCommonState(self)
    self:addState('start', SkillAoERound_Throw.st_idle, nil, true)
    self:addState('draw', SkillAoERound_Throw.st_draw, 'idle', true)
	self:addState('attack', SkillAoERound_Throw.st_attack, 'disappear', false)
    self:addState('disappear', SkillAoERound_Throw.st_disappear, nil, false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAoERound_Throw.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:changeState('draw')
    end
end

-------------------------------------
-- function st_draw
-------------------------------------
function SkillAoERound_Throw.st_draw(owner, dt)
	if (owner.m_stateTimer == 0) then
		-- 투사체 투척
        local target_pos = cc.p(owner.m_targetPos.x, owner.m_targetPos.y)
        local action = cc.JumpTo:create(0.5, target_pos, 250, 1)

		-- state chnage 함수 콜
		local cbFunc = cc.CallFunc:create(function() owner:changeState('attack') end)

		owner:runAction(cc.Sequence:create(cc.EaseIn:create(action, 1), cbFunc))
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillAoERound_Throw.st_disappear(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner:onDisappear()

        -- 스킬 종료시 발동되는 status effect를 적용
		owner:dispatch(CON_SKILL_END, {l_target = {owner.m_targetChar}})

		return true
    end
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillAoERound_Throw:runAttack()
    local l_target, l_collision = self:findTarget()

    for _, collision in ipairs(l_collision) do
        self:attack(collision)

        -- 타겟별 리소스
        self:makeEffect(self.m_aoeRes, collision:getPosX(), collision:getPosY())
    end
    
	-- 특수한 부가 효과 구현
	self:doSpecialEffect(l_target)

	self:doCommonAttackEffect()
end

-------------------------------------
-- function escapeAttack
-- @brief 공격이 종료되는 시점에 실행
-------------------------------------
function SkillAoERound_Throw:escapeAttack()
	self:changeState('disappear')
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillAoERound_Throw:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local attack_count = t_skill['hit']	  -- 공격 횟수
	
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)	-- 스킬 본연의 리소스

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillAoERound_Throw(missile_res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(attack_count)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end