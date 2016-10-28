-------------------------------------
-- class SkillLeafBlade
-------------------------------------
SkillLeafBlade = class(Entity, {
        m_owner = 'Character',
        m_targetPos = '',

        m_activityCarrier = 'AttackDamage',
        
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
    self:initState()
end

-------------------------------------
-- function init_SkillLeafBlade
-------------------------------------
function SkillLeafBlade:init_skill(owner, t_skill, t_data)
    self.m_owner = owner

    local tar_x, tar_y = t_data.x, t_data.y
    if (nil == tar_x) or (nil == tar_y) then 
        tar_x, tar_y = self:getTargetPos() 
    end
    self.m_targetPos = {x = tar_x, y = tar_y}

    self.m_missileRes = string.gsub(t_skill['res_1'], '@', owner.m_charTable['attr'])
    self.m_motionStreakRes = (t_skill['res_2'] == 'x') and nil or string.gsub(t_skill['res_2'], '@', owner.m_charTable['attr'])
    self.m_targetCount = t_skill['hit']
	self.m_resScale = 0.5 -- t_skill['val_1']
	self.m_bodySize = 30  -- t_skill['val_2']
	self:initActvityCarrier(t_skill)

    self:changeState('idle')
end

-------------------------------------
-- function initActvityCarrier
-------------------------------------
function SkillLeafBlade:initActvityCarrier(t_skill)    
    self.m_activityCarrier = self.m_owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)
	
	-- 상태효과 적용
    self.m_activityCarrier:insertStatusEffectRate(t_skill['status_effect_type'], t_skill['status_effect_rate'])
end

-------------------------------------
-- function initState
-------------------------------------
function SkillLeafBlade:initState()
    self:addState('idle', SkillLeafBlade.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
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