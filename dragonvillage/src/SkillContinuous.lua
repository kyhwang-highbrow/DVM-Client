local PARENT = Skill

-------------------------------------
-- class SkillContinuous
-------------------------------------
SkillContinuous = class(PARENT, {
		m_statusEffectType = 'str',
		m_interval = 'num'
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillContinuous:init(file_name, body)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillContinuous:init_skill()
    PARENT.init_skill(self)

	-- 멤버 변수
   	self.m_interval = 1
end

-------------------------------------
-- function initState
-------------------------------------
function SkillContinuous:initState()
	self:setCommonState(self)
    self:addState('start', SkillContinuous.st_idle, nil, false)
end


-------------------------------------
-- function update
-------------------------------------
function SkillContinuous.st_idle(owner, dt)
	if (owner.m_stateTimer > owner.m_interval) then   
		local char_list = owner.m_owner:getFormationMgr(true):getEntireCharList()
		StatusEffectHelper:doStatusEffectByStr(owner.m_owner, char_list, owner.m_lStatusEffectStr)
		
		owner.m_stateTimer = 0
	end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillContinuous:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillContinuous(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end