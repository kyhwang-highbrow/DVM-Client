local PARENT = Skill

-------------------------------------
-- class SkillSummon
-------------------------------------
SkillSummon = class(PARENT, {
		m_summonIdx = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillSummon:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillSummon:init_skill(summon_idx)
	PARENT.init_skill(self)

    self.m_summonIdx = summon_idx
end

-------------------------------------
-- function initState
-------------------------------------
function SkillSummon:initState()
	self:setCommonState(self)
    self:addState('start', SkillSummon.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillSummon.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_world.m_waveMgr:summonWave(owner.m_summonIdx)
    else
        owner:changeState('dying')
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillSummon:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local summon_idx = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillSummon(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(summon_idx)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

	return true
end