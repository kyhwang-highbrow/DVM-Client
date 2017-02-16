local PARENT = SkillEnumrate

-------------------------------------
-- class SkillEnumrate_Curve
-------------------------------------
SkillEnumrate_Curve = class(PARENT, {
		m_lRandomTargetList = 'character list',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Curve:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillEnumrate_Curve
-------------------------------------
function SkillEnumrate_Curve:init_skill(missile_res, motionstreak_res, line_num, line_size)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, line_size)

	-- 1. 멤버 변수
	self.m_skillInterval = P_RANDOM_INTERVAL
	self.m_enumTargetType = 'enemy_random'
	self.m_enumPosType = 'pentagon'
end

-------------------------------------
-- function fireMissile
-- @override
-------------------------------------
function SkillEnumrate_Curve:fireMissile(idx)
    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = self.m_skillTargetList[idx]

    t_option['pos_x'] = char.pos.x
	t_option['pos_y'] = char.pos.y
	
    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['physics_body'] = {0, 0, self.m_skillLineSize}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='lua_arrange_curve' 
	t_option['bFixedAttack'] = true

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = math_random(-P_RANDOM_HEIGHT_RANGE, P_RANDOM_HEIGHT_RANGE)
	t_option['lua_param']['value2'] = P_RANDOM_SPEED
	t_option['lua_param']['value3'] = P_RANDOM_FIRE_DELAY
	t_option['lua_param']['value4'] = self.m_skillStartPosList[idx]

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale
	t_option['visual'] = ('move_' .. math_random(1, 5))
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
	
	-- fire!!
    world.m_missileFactory:makeMissile(t_option)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate_Curve:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

	local line_num = t_skill['hit']
	local line_size = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate_Curve(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, line_size)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end