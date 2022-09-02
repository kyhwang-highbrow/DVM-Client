local PARENT = SkillEnumrate

-------------------------------------
-- class   
-------------------------------------
SkillEnumrate_Release = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Release:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillEnumrate_Release:init_skill(missile_res, motionstreak_res, line_num, pos_type, target_type)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, pos_type, target_type)

	-- 1. 멤버 변수
	self.m_skillInterval = g_constant:get('SKILL', 'ENUMRATE_APPEAR_INTERVAR')
	self.m_skillTotalTime = (self.m_skillLineNum * self.m_skillInterval) + g_constant:get('SKILL', 'ENUMRATE_FIRE_DELAY') -- 발사 간격 * 발사 수 + 발사 딜레이
	self.m_skillLineTotalWidth = 300
end

-------------------------------------
-- function initSkillSize
-------------------------------------
function SkillEnumrate_Release:initSkillSize()
	self.m_skillLineSize = 25
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate_Release:fireMissile(idx)
	local char = self.m_owner
	local target_char = self:getNextTarget(idx)
    
    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target_char

    t_option['pos_x'] = char.pos.x
	t_option['pos_y'] = char.pos.y
	
    t_option['object_key'] = char:getMissilePhysGroup()
    t_option['physics_body'] = {0, 0, 0}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='lua_arrange_curve' 
	t_option['disable_body'] = true

	local random_height = g_constant:get('SKILL', 'CURVE_HEIGHT_RANGE')

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = math_random(-random_height*1.5, random_height*1.5)
	t_option['lua_param']['value2'] = g_constant:get('SKILL', 'CURVE_SPEED')
	t_option['lua_param']['value3'] = 0
	t_option['lua_param']['value4'] = self.m_skillStartPosList[idx]
	if (target_char) then
        local pos_x, pos_y = self:getAttackPositionAtWorld()
        local l_collision = SkillTargetFinder:getCollisionFromTargetList({target_char}, pos_x, pos_y)

		t_option['lua_param']['value5'] = function()
			-- 공격
			self:attack(l_collision[1])
		end
	end

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale
	t_option['visual'] = 'idle'
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    -- 타격 횟수 설정
    t_option['max_hit_count'] = self.m_targetLimit
	
	-- fire!!
    self:makeMissile(t_option)

end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate_Release:makeSkillInstance(owner, t_skill, t_data)
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
    local skill = SkillEnumrate_Release(nil)

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