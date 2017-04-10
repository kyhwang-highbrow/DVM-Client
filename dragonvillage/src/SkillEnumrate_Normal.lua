local PARENT = SkillEnumrate

-------------------------------------
-- class   
-------------------------------------
SkillEnumrate_Normal = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Normal:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillEnumrate_Normal
-------------------------------------
function SkillEnumrate_Normal:init_skill(missile_res, motionstreak_res, line_num, pos_type, target_type)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, pos_type, target_type)

	-- 1. 멤버 변수
	self.m_skillInterval = g_constant:get('SKILL', 'ENUMRATE_APPEAR_INTERVAR')
	self.m_skillTotalTime = (self.m_skillLineNum * self.m_skillInterval) + g_constant:get('SKILL', 'ENUMRATE_FIRE_DELAY') -- 발사 간격 * 발사 수 + 발사 딜레이
	self.m_skillLineTotalWidth = 300
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate_Normal:fireMissile(idx)
    local world = self.m_world
    
	local char = self.m_owner
	local target_char = self.m_skillTargetList[idx]
	if (not traget_char) or (target_char.m_bDead) then
		local l_target = self:getProperTargetList()
        target_char = l_target[1]
	end

    local t_option = {}

    t_option['owner'] = char
	t_option['target'] = target_char

    t_option['pos_x'] = char.pos.x + self.m_skillStartPosList[idx].x
	t_option['pos_y'] = char.pos.y + self.m_skillStartPosList[idx].y
	t_option['dir'] = self:getAttackDir(idx)
	t_option['rotation'] = t_option['dir']

    t_option['object_key'] = char:getAttackPhysGroup()
    t_option['physics_body'] = {0, 0, self.m_skillLineSize}
    t_option['attack_damage'] = self.m_activityCarrier
	t_option['attr_name'] = char:getAttribute()

    t_option['speed'] = 0
	t_option['h_limit_speed'] = 2000
	t_option['accel'] = 50000
	t_option['accel_delay'] = self.m_skillTotalTime - (self.m_skillInterval * idx)

	t_option['missile_type'] = 'NORMAL'
    t_option['movement'] ='guide' 
	t_option['bFixedAttack'] = true

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight
    
	t_option['cbFunction'] = function(attacker, defender, x, y)
		self:onAttack(defender)
	end

	-- fire!!
    world.m_missileFactory:makeMissile(t_option)
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillEnumrate_Normal:makeSkillInstance(owner, t_skill, t_data)
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
    local skill = SkillEnumrate_Normal(nil)

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