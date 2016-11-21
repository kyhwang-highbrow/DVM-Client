local PARENT = class(Skill, IStateDelegate:getCloneTable())

-------------------------------------
-- class SkillShield
-------------------------------------
SkillShield = class(PARENT, {
        m_hpRange = 'number',
        m_currHP = 'number',
        m_currDamage = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillShield:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_skill
-------------------------------------
function SkillShield:init_skill(active_rate, shield_hp_rate)
	PARENT.init_skill(self)

	-- 1. 발동 조건 (체력의 x % 소진시)
    local rate = (active_rate / 100)
    self.m_hpRange = self.m_owner.m_maxHp * rate
    self.m_currHP = self.m_owner.m_hp
    self.m_currDamage = 0

    -- 2. 콜백 함수 등록
    self.m_owner:addHpEventListener(self)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillShield:initState()
	self:setCommonState(self)
    self:addState('start', SkillShield.st_idle, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillShield.st_idle(owner, dt)
    -- 종료
    if (not owner.m_owner) or owner.m_owner.m_bDead then
        owner:changeState('dying')
        return
    end
end


-------------------------------------
-- function changeHpCB
-------------------------------------
function SkillShield:changeHpCB(char, hp, max_hp)

    if hp < self.m_currHP then
        local damage = self.m_currHP - hp
        self.m_currDamage = self.m_currDamage + damage

        if self.m_hpRange <= self.m_currDamage then
            self.m_currDamage = (self.m_currDamage % self.m_hpRange)
            StatusEffectHelper:doStatusEffectByStr(self.m_owner, {self.m_targetChar}, self.m_lStatusEffectStr)
        end
    end

    self.m_currHP = hp
end

-------------------------------------
-- function makeSkillInstance
-------------------------------------
function SkillShield:makeSkillInstance(owner, t_skill, t_data)
	-- 변수 선언부
	------------------------------------------------------
	local active_rate = t_skill['val_1']

	-- 인스턴스 생성부
	------------------------------------------------------
	-- 1. 스킬 생성
    local skill = SkillShield(nil)

	-- 2. 초기화 관련 함수
	skill:setSkillParams(owner, t_skill, t_data)
    skill:init_skill(active_rate)
	skill:initState()

	-- 3. state 시작 
    skill:changeState('delay')

    -- 4. Physics, Node, GameMgr에 등록
    local world = skill.m_owner.m_world
    world.m_missiledNode:addChild(skill.m_rootNode, 0)
    world:addToSkillList(skill)
end