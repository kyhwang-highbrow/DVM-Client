local PARENT = Skill

-------------------------------------
-- class SkillLeafBlade
-------------------------------------
SkillLeafBlade = class(PARENT, {
		m_missileRes = 'string',
        m_motionStreakRes = 'string',
        m_targetCount = 'number',
		m_bodySize = 'number',
		m_isPass = 'bool'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillLeafBlade:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillLeafBlade
-------------------------------------
function SkillLeafBlade:init_skill(missile_res, motionstreak_res, target_count, body_size, isPass)
	PARENT.init_skill(self)

	-- 1. 멤버 변수
    self.m_missileRes = missile_res
    self.m_motionStreakRes = motionstreak_res
    self.m_targetCount = target_count
	self.m_isPass = isPass
	self.m_bodySize = body_size
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLeafBlade:initState()
	self:setCommonState(self)
    self:addState('start', SkillLeafBlade.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillLeafBlade.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:fireMissile()
        owner:changeState('dying')
    end
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillLeafBlade:fireMissile()
    local targetPos = self.m_targetPos
    if (not targetPos) then
        return 
    end

    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char

    t_option['pos_x'] = char.pos.x
    t_option['pos_y'] = char.pos.y

    t_option['physics_body'] = {0, 0, self.m_bodySize}
    t_option['attack_damage'] = self.m_activityCarrier

    t_option['object_key'] = char:getAttackPhysGroup()

    t_option['missile_res_name'] = self.m_missileRes
	t_option['attr_name'] = self.m_owner:getAttribute()

	if (self.m_isPass) then 
		t_option['missile_type'] = 'PASS'
	end

    t_option['movement'] ='lua_bezier' 
    
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
    
	t_option['scale'] = self.m_resScale
    
    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = targetPos
    
	t_option['cbFunction'] = function(attacker, defender, x, y)
		self:onAttack(defender)
	end

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight

    -- 타격 횟수 설정
    t_option['max_hit_count'] = self.m_targetLimit

    -- 상탄
    t_option['lua_param']['value2'] = 'top'
    for i = 1, self.m_targetCount do 
        t_option['lua_param']['value3'] = 0.15 * (i-1)
        local missile = world.m_missileFactory:makeMissile(t_option)
    end
    
    -- 하탄 
    t_option['lua_param']['value2'] = 'bottom'
    for i = 1, self.m_targetCount do
        t_option['lua_param']['value3'] = 0.15 * (i-1)
        local missile = world.m_missileFactory:makeMissile(t_option)
    end
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillLeafBlade:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
	local target_count = t_skill['hit']
	local isPass = true
	local leaf_body_size = g_constant:get('SKILL', 'LEAF_COLLISION_SIZE')

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillLeafBlade(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, target_count, leaf_body_size, isPass)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end