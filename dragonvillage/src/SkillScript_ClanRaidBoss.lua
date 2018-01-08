local PARENT = class(SkillScript, IStateDelegate:getCloneTable())

local CON_SKILL_IDLE = 'skill_idle'

-------------------------------------
-- class SkillScript_ClanRaidBoss
-------------------------------------
SkillScript_ClanRaidBoss = class(PARENT, {})

-------------------------------------
-- function initEventListener
-- @breif 이벤트 처리..
-------------------------------------
function SkillScript_ClanRaidBoss:initEventListener()
    PARENT.initEventListener(self)

    self:addListener(CON_SKILL_IDLE, self)
end

-------------------------------------
-- function setSkillParams
-- @brief 멤버변수 정의
-------------------------------------
function SkillScript_ClanRaidBoss:setSkillParams(owner, t_skill, t_data)
    PARENT.setSkillParams(self, owner, t_skill, t_data)

    self.m_lTargetChar = self.m_world:getDragonList()

    -- 받는 피해 증가 상태효과 설정
    local struct_status_effect = StructStatusEffect({
        type = 'dmg_add',
		target_type = 'self',
		target_count = 1,
		trigger = CON_SKILL_IDLE,
		duration = 12,
		rate = 100,
		value = 100,
        source = '',
    })
    table.insert(self.m_lStatusEffect, struct_status_effect)

    -- 다중 광폭화 상태효과 설정
    for i = 1, 5 do
        local struct_status_effect = StructStatusEffect({
            type = 'passive_fury',
			target_type = 'self',
			target_count = 1,
			trigger = CON_SKILL_END,
			duration = -1,
			rate = 100,
			value = 20,
            source = '',
        })
        table.insert(self.m_lStatusEffect, struct_status_effect)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillScript_ClanRaidBoss:initState()
    PARENT.initState(self)
	
    self:addState('attack', SkillScript_ClanRaidBoss.st_attack, nil, false)
end

-------------------------------------
-- function st_attack
-------------------------------------
function SkillScript_ClanRaidBoss.st_attack(owner, dt)
	if (owner.m_stateTimer == 0) then
        -- 애니메이션
        owner.m_owner.m_animator:changeAni('skill_idle', true)

        owner:makeMissileLauncher()

        -- idle 애니메이션 시작시 발동되는 status effect를 적용
		owner:dispatch(CON_SKILL_IDLE, {l_target = {owner.m_targetChar}})
	end

    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function makeMissileLauncher
-------------------------------------
function SkillScript_ClanRaidBoss:makeMissileLauncher()
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
    local phys_group = PHYS.MISSILE.ENEMY   -- 모든 드래곤을 공격할 수 있도록 설정
    missile_launcher:init_missileLauncherByScript(script_data['attack_value'], phys_group, self.m_activityCarrier, {})
    missile_launcher.m_animator:changeAni('animation', true)
    missile_launcher:setPosition(start_x, start_y)
    missile_launcher.m_owner = self.m_owner
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillScript_ClanRaidBoss:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local res = t_skill['res_1']
    local script_name = t_skill['val_1']
	
	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillScript_ClanRaidBoss(res)

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