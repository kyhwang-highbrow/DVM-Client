local PARENT = Skill

-------------------------------------
-- class SkillProtection
-------------------------------------
SkillProtection = class(PARENT, {
		m_protectionRes = '',
		m_duration = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillProtection:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillProtection:init_skill()
	PARENT.init_skill(self)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillProtection:initState()
	self:setCommonState(self)
    self:addState('start', SkillProtection.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillProtection.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
		-- 기본 타겟에 실드
		--StatusEffectHelper:doStatusEffectByStr(owner.m_owner, {owner.m_targetChar}, owner.m_lStatusEffectStr)
        owner:doStatusEffect({
            STATUS_EFFECT_CON__SKILL_HIT,
            STATUS_EFFECT_CON__SKILL_HIT_CRI,
            STATUS_EFFECT_CON__SKILL_SLAIN
        })
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillProtection:findTarget()
    return {self.m_targetChar}
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillProtection:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillProtection(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(nil)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end