local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillScript
-------------------------------------
SkillScript = class(PARENT, {
        m_scriptName = 'string',
	})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillScript:init(file_name, body, ...)
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillScript:init_skill(script_name)
    PARENT.init_skill(self)

    self.m_scriptName = script_name
end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript:initState()
	self:setCommonState(self)
    self:addState('start', SkillScript.st_idle, 'back', false)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillScript.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
	end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript(res)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(script_name)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode('bottom')
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end