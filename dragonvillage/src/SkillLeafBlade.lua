local PARENT = class(Entity, ISkill:getCloneTable())

-------------------------------------
-- class SkillLeafBlade
-------------------------------------
SkillLeafBlade = class(PARENT, {
		m_missileRes = 'string',
        m_motionStreakRes = 'string',
		m_resScale = 'num',

        m_targetCount = 'number',

		m_bodySize = 'number',
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
function SkillLeafBlade:init_skill(missile_res, motionstreak_res, target_count, res_scale, body_size)
	PARENT.init_skill(self)

	-- 1. 멤버 변수
    self.m_missileRes = missile_res
    self.m_motionStreakRes = motionstreak_res
    self.m_targetCount = target_count
	self.m_resScale = res_scale
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
-- function getTargetPos
-------------------------------------
function SkillLeafBlade:getTargetPos()
    -- 상대방 진형 얻어옴
    local target_formation_mgr = self.m_owner:getFormationMgr('opposite')

    local target = target_formation_mgr:getTypicalTarget_Random()
    if target then
        return target.pos.x, target.pos.y
    else
        local x, y = self.m_owner.pos.x, self.m_owner.pos.y
        if self.m_owner.m_bLeftFormation then
            return x + 600, y
        else
            return x - 600, y
        end
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

    if (char.phys_key == 'hero') then
        t_option['object_key'] = 'missile_h'
    else
        t_option['object_key'] = 'missile_e'
    end

    t_option['missile_res_name'] = self.m_missileRes
	t_option['attr_name'] = self.m_owner:getAttribute()

    t_option['missile_type'] = 'PASS'
    t_option['movement'] ='lua_bezier' 
    
	t_option['effect'] = {}
    t_option['effect']['motion_streak'] = self.m_motionStreakRes
    
	t_option['scale'] = self.m_resScale
    
    t_option['lua_param'] = {}
    t_option['lua_param']['value1'] = targetPos
    
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
-- function makeSkillInstnce
-------------------------------------
function SkillLeafBlade:makeSkillInstnce(missile_res, motionstreak_res, target_count, res_scale, body_size, ...)
	-- 1. 스킬 생성
    local skill = SkillLeafBlade(nil)

	-- 2. 초기화 관련 함수
	skill:setParams(...)
    skill:init_skill(missile_res, motionstreak_res, target_count, res_scale, body_size)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillLeafBlade:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner
    
	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local pre_delay = t_skill['pre_delay']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_value = t_skill['status_effect_value']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target

	-- 2. 특수 변수
    local missile_res = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
	local motionstreak_res = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner.m_charTable['attr'])
	local target_count = t_skill['hit']
	local res_scale = 0.5 -- t_skill['val_1']
	local body_size = 30  -- t_skill['val_2']

    SkillLeafBlade:makeSkillInstnce(missile_res, motionstreak_res, target_count, res_scale, body_size, owner, power_rate, target_type, pre_delay, status_effect_type, status_effect_value, status_effect_rate, skill_type, tar_x, tar_y, target)
end