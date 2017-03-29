local PARENT = SkillEnumrate

-------------------------------------
-- class SkillEnumrate_Penetration
-------------------------------------
SkillEnumrate_Penetration = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillEnumrate_Penetration:init(file_name, body, ...)
end

-------------------------------------
-- function init_SkillEnumrate_Penetration
-------------------------------------
function SkillEnumrate_Penetration:init_skill(missile_res, motionstreak_res, line_num, line_size, pos_type, target_type)
	PARENT.init_skill(self, missile_res, motionstreak_res, line_num, line_size)

	-- 1. 멤버 변수
	self.m_skillInterval = g_constant:get('SKILL', 'PENERATION_APPEAR_INTERVAR')
	self.m_skillTotalTime = (self.m_skillLineNum * self.m_skillInterval) + g_constant:get('SKILL', 'PENERATION_FIRE_DELAY')
	self.m_enumTargetType = target_type
	self.m_enumPosType = pos_type
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillEnumrate_Penetration:fireMissile(idx)
    local char = self.m_owner
    local world = self.m_world

    local t_option = {}

    t_option['owner'] = char

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
	t_option['accel'] = 20000
	t_option['accel_delay'] = self.m_skillTotalTime - (self.m_skillInterval * idx)

	t_option['missile_type'] = 'PASS'
    t_option['movement'] ='normal' 

    t_option['missile_res_name'] = self.m_missileRes
	t_option['scale'] = self.m_resScale
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes

    -- 하이라이트
    t_option['highlight'] = self.m_bHighlight
    
	t_option['cbFunction'] = function(attacker, defender, x, y)
		self.m_skillHitEffctDirector:doWork(defender)

        -- 타격 카운트 갱신
        self:addHitCount()

		self:doSpecialEffect()
	end

	-- fire!!
    world.m_missileFactory:makeMissile(t_option)
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
	local line_size = t_skill['val_1']
	local pos_type = t_skill['val_2']
	local target_type = t_skill['val_3']

	-- 인스턴스 생성부
	------------------------------------------------------ 
	-- 1. 스킬 생성
    local skill = SkillEnumrate_Penetration(nil)

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