local PARENT = class(Skill, IStateDelegate:getCloneTable())

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
	
    do -- 기본 타겟에 실드
--        local shield_hp = self.m_owner.m_maxHp * (self.m_powerRate / 100)
  --      self:makeShield(self.m_targetChar, shield_hp)
		StatusEffectHelper:doStatusEffectByType(self.m_targetChar, self.m_statusEffectType, self.m_statusEffectValue, self.m_statusEffectRate)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function SkillProtection:initState()
	self:setCommonState(self)
    self:addState('start', SkillProtection.st_idle, 'idle', true)
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
-- function makeSkillInstance
-------------------------------------
function SkillProtection:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local missile_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())
	local spin_res = t_skill['res_2']
	local target_count = t_skill['val_1']
	local buff_prob = t_skill['val_2']
	local atk_count = t_skill['hit']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillProtection(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(nil)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end