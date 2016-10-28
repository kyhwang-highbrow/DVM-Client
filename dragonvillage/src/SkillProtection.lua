local PARENT = class(Entity, ISkill:getCloneTable(), IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillProtection
-------------------------------------
SkillProtection = class(PARENT, {
		m_protectionRes = '',
		m_duration = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillProtection:init(file_name, body, ...)
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillProtection:init_skill(protection_res, duration)
	PARENT.init_skill(self)
	
    if (not self.m_targetChar) then
		self.m_targetChar = self:getDefaultTarget()
	end
    if (not self.m_targetChar) then
        self:changeState('dying')
        return
    end
	--cclog(self.m_targetChar.m_charTable['t_name'])
    do -- 기본 타겟에 실드
--        local shield_hp = self.m_owner.m_maxHp * (self.m_powerRate / 100)
  --      self:makeShield(self.m_targetChar, shield_hp)
		StatusEffectHelper:doStatusEffectByType(self.m_targetChar, self.m_statusEffectType, self.m_statusEffectRate)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillProtection:initState()
    self:addState('idle', SkillProtection.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillProtection.st_idle(owner, dt)
    if (not owner.m_owner) or owner.m_owner.m_bDead then
        owner:changeState('dying')
        return
    end
end

-------------------------------------
-- function makeShield
-------------------------------------
function SkillProtection:makeShield(target, shield_hp)
	local world = self.m_owner.m_world
    local buff = Buff_Shield(self.m_protectionRes)
    world.m_worldNode:addChild(buff.m_rootNode, 10)
    world:addToUnitList(buff)
    buff:init_buff(target, shield_hp, self.m_duration)
end

-------------------------------------
-- function makeSkillInstnce
-- @param missile_res 
-------------------------------------
function SkillProtection:makeSkillInstnce(owner, --[[missile_res,]] power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target)
	-- 1. 스킬 생성
    local skill = SkillProtection(missile_res)

	-- 2. 초기화 관련 함수
	skill:setParams(owner, power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target)
    skill:init_skill()
	skill:initState()

	-- 3. state 시작 
    skill:changeState('dying')

    -- 4. Physics, Node, GameMgr에 등록
    local world = owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToUnitList(skill)
end

-------------------------------------
-- function makeSkillInstnceFromSkill
-------------------------------------
function SkillProtection:makeSkillInstnceFromSkill(owner, t_skill, t_data)
    local owner = owner

	-- 1. 공통 변수
	local power_rate = t_skill['power_rate']
	local target_type = t_skill['target_type']
	local status_effect_type = t_skill['status_effect_type']
	local status_effect_rate = t_skill['status_effect_rate']
	local skill_type = t_skill['type']
	local tar_x = t_data.x
	local tar_y = t_data.y
	local target = t_data.target
    
	-- 2. 특수 변수

    SkillProtection:makeSkillInstnce(owner, --[[missile_res,]] power_rate, target_type, status_effect_type, status_effect_rate, skill_type, tar_x, tar_y, target)
end