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
    cclog('SkillScript')
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
    self:addState('start', SkillScript.st_appear, nil, false)
    self:addState('attack', SkillScript.st_attack, nil, false)
    self:addState('end', SkillScript.st_disappear, nil, false)
end

-------------------------------------
-- function st_appear
-------------------------------------
function SkillScript.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then        
        -- 주체 유닛 스킬 시작 애니 설정
        owner.m_owner.m_animator:changeAni('skill_appear', false)
        owner.m_owner.m_animator:addAniHandler(function()
            owner:changeState('attack')
        end)
    end
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillScript.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 애니메이션
        owner.m_owner.m_animator:changeAni('skill_idle', true)

        owner:makeMissileLauncher()
	end

    if (owner.m_stateTimer >= 12) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function SkillScript.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 주체 유닛 스킬 종료 애니 설정
        owner.m_owner.m_animator:changeAni('skill_disappear', false)
        owner.m_owner.m_animator:addAniHandler(function()
            owner:changeState('dying')
        end)
    end
end

-------------------------------------
-- function makeMissileLauncher
-------------------------------------
function SkillScript:makeMissileLauncher()
    local missile_launcher = MissileLauncher(nil)
    local t_launcher_option = missile_launcher:getOptionTable()

    local start_x, start_y = self:getAttackPositionAtWorld()

    -- 속성
    t_launcher_option['attr_name'] = self.m_owner:getAttribute()

    -- 타겟 지정
    t_launcher_option['target'] = self.m_targetChar
    t_launcher_option['target_list'] = self.m_lTargetChar

    -- 각도 지정
	local degree = getDegree(start_x, start_y, self.m_targetPos['x'], self.m_targetPos['y'])
    t_launcher_option['dir'] = degree

    self.m_world:addToMissileList(missile_launcher)
    self.m_world.m_worldNode:addChild(missile_launcher.m_rootNode)

    local script = TABLE:loadSkillScript(self.m_scriptName)
    local script_data = script[self.m_scriptName]
    local phys_group = self.m_owner:getMissilePhysGroup()
    missile_launcher:init_missileLauncherByScript(script_data['attack_value'], phys_group, self.m_activityCarrier, {})
    missile_launcher.m_animator:changeAni('animation', true)
    missile_launcher:setPosition(start_x, start_y)
    missile_launcher.m_owner = self.m_owner
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
    script_name = 'skill_boss_clanraid_2'
	
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