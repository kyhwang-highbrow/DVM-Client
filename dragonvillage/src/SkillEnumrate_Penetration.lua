local PARENT = SkillEnumrate

-------------------------------------
-- class SkillEnumrate_Penetration
-------------------------------------
SkillEnumrate_Penetration = class(PARENT, {
    m_size = 'number',
    m_lDir = 'list'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Penetration:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillEnumrate_Penetration:init_skill(missile_res, motionstreak_res, line_num, pos_type, target_type)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, pos_type, target_type)

	-- 1. 멤버 변수
	self.m_skillInterval = g_constant:get('SKILL', 'PENERATION_APPEAR_INTERVAR')
	self.m_skillTotalTime = (self.m_skillLineNum * self.m_skillInterval) + g_constant:get('SKILL', 'PENERATION_FIRE_DELAY')
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate_Penetration:fireMissile(idx)
    local char = self.m_owner
    local t_option = {}

    t_option['owner'] = char
	t_option['attr_name'] = char:getAttribute()

    t_option['pos_x'] = char.pos.x + self.m_skillStartPosList[idx].x
	t_option['pos_y'] = char.pos.y + self.m_skillStartPosList[idx].y
	t_option['dir'] = self:getAttackDir(idx)
	t_option['rotation'] = t_option['dir']

    t_option['object_key'] = char:getMissilePhysGroup()
    t_option['physics_body'] = { 0, 0, self.m_skillLineSize * 1.5}  -- body 크기를 일괄적으로 키운다
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

    t_option['speed'] = 0
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 20000
	t_option['accel_delay'] = self.m_skillTotalTime - (self.m_skillInterval * idx)

	t_option['missile_type'] = 'PASS'
    t_option['movement'] ='normal' 

    t_option['missile_res_name'] = self.m_missileRes
	t_option['visual'] = 'idle'
	t_option['scale'] = self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    -- 타격 횟수 설정
    t_option['max_hit_count'] = self.m_targetLimit
        
	t_option['cbFunction'] = function(attacker, defender, x, y)
		self:onAttack(defender)
	end

    local l_target = self:getProperTargetList()
    t_option['collision_list'] = SkillTargetFinder:findCollision_Penetration(l_target, self.m_skillStartPosList[idx].x, self.m_skillStartPosList[idx].y, char, idx, self.m_targetLimit, self.m_size, self.m_lDir[idx])

	-- fire!!
    self:makeMissile(t_option)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate_Penetration:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
    local missile_res = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
	local motionstreak_res = SkillHelper:getAttributeRes(t_skill['res_2'], owner)

	local line_num = t_skill['hit']
	local pos_type = t_skill['val_1']
	local target_type = t_skill['val_2']

    

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate_Penetration(nil)

    skill.m_size = t_skill['skill_size']
    skill.m_lDir = t_data['additional_info']
	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, pos_type, target_type)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end