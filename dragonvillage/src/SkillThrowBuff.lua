local PARENT = Skill

-------------------------------------
-- class SkillThrowBuff
-------------------------------------
SkillThrowBuff = class(PARENT, {
        m_missileRes = 'string',
        m_duration = 'number',
        m_lEffect = 'table',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillThrowBuff:init(file_name, body, ...)    
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillThrowBuff:init_skill(res)
    PARENT.init_skill(self)

    -- 멤버 변수
    self.m_missileRes = res
    self.m_duration = 1
    self.m_lEffect = {}

    -- 타겟 리스트가 없을 경우(인디케이터로부터 받은 정보가 없을 경우)
    if (not self.m_lTargetChar) then
        self.m_lTargetChar = self.m_owner:getTargetListByType(self.m_targetType, nil, self.m_targetFormation)
    end

    -- 타겟 수만큼만 가져옴
    self.m_lTargetChar = table.getPartList(self.m_lTargetChar, self.m_targetLimit)

    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillThrowBuff:initState()
	self:setCommonState(self)
    self:addState('start', SkillThrowBuff.st_idle, nil, true)
    self:addState('draw', SkillThrowBuff.st_draw, 'idle', true)
	self:addState('obtain', SkillThrowBuff.st_obtain, 'obtain', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillThrowBuff.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:throwEffect()
    
    elseif (owner.m_stateTimer > owner.m_duration) then
        owner:changeState('dying')

    end
end

-------------------------------------
-- function throwEffect
-------------------------------------
function SkillThrowBuff:throwEffect()
    for _, v in pairs(self.m_lTargetChar) do
        local x = v.pos.x - self.pos.x
        local y = v.pos.y - self.pos.y

        local animator = MakeAnimator(self.m_missileRes)
        animator:changeAni('idle', true)
        self.m_rootNode:addChild(animator.m_node)

        -- 투척 액션
        local action = cc.JumpTo:create(self.m_duration, cc.p(x, y), 250, 1)
        local cbFunc = cc.CallFunc:create(function()
            animator:setVisible(false)

            -- 상태효과
            self:dispatch(CON_SKILL_HIT, { l_target = {v} })

            -- 이펙트
            self.m_world:addInstantEffect(self.m_missileRes, 'obtain', v.pos.x, v.pos.y + 100)
        end)

		animator:runAction(cc.Sequence:create(cc.EaseIn:create(action, self.m_duration), cbFunc))
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillThrowBuff:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillThrowBuff(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end