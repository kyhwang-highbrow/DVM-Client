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
function SkillEnumrate_Curve:init_skill(missile_res, motionstreak_res, line_num, line_size, pos_type, target_type)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, line_size)

	-- 1. 멤버 변수
	self.m_skillInterval = g_constant:get('SKILL', 'RANDOM_CARD_INTERVAL')
	self.m_enumTargetType = target_type
	self.m_enumPosType = pos_type
	self.m_bSkillHitEffect = false
end

-------------------------------------
-- function fireMissile
-- @override
-------------------------------------
function SkillEnumrate_Curve:fireMissile(idx)
    local world = self.m_world
    
	local char = self.m_owner
	local target_char = self.m_skillTargetList[idx]
	if (not traget_char) or (target_char.m_bDead) then
		local l_target = self.m_owner:getTargetListByType(self.m_targetType, self.m_targetFormation)
        target_char = l_target[1]
	end

    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target_char

    t_option['pos_x'] = char.pos.x
	t_option['pos_y'] = char.pos.y
	
    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['physics_body'] = {0, 0, 0}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='lua_arrange_curve' 
	t_option['disable_body'] = true

	local random_height = g_constant:get('SKILL', 'RANDOM_CARD_HEIGHT_RANGE')

    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = math_random(-random_height, random_height)
	t_option['lua_param']['value2'] = g_constant:get('SKILL', 'RANDOM_CARD_SPEED')
	t_option['lua_param']['value3'] = g_constant:get('SKILL', 'RANDOM_CARD_FIRE_DELAY')
	t_option['lua_param']['value4'] = self.m_skillStartPosList[idx]
	if (target_char) then
		t_option['lua_param']['value5'] = function()
			-- 공격
			self:attack(target_char)
		end
	end

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale
	t_option['visual'] = ('move_' .. math_random(1, 5))
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight
	
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
	local pos_type = t_skill['val_2']
	local target_type = t_skill['val_3']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate_Curve(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(missile_res, motionstreak_res, line_num, line_size, pos_type, target_type)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    local missileNode = world:getMissileNode()
    missileNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)

    -- 5. 하이라이트
    if (skill.m_bHighlight) then
        --world.m_gameHighlight:addMissile(skill)
    end
end