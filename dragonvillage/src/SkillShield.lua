-------------------------------------
-- class SkillShield
-------------------------------------
SkillShield = class(Entity, {
        m_owner = 'Character',

        m_hpRange = 'number',
        m_currHP = 'number',
        m_currDamage = 'number',
		m_duration = 'number',

        m_shieldHP = 'number', -- 실드로 추가될 체력
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
function SkillShield:init_skill(owner, res, x, y, t_skill)
    self.m_owner = owner

	-- 1. 발동 조건 (체력의 x % 소진시)
    local rate = (t_skill['val_1'] / 100)
    self.m_hpRange = owner.m_maxHp * rate
    self.m_currHP = owner.m_hp
    self.m_currDamage = 0

	-- 2. 제한 시간
	self.m_duration = t_skill['val_2']

    -- 3. 실드로 추가될 체력
    self.m_shieldHP = owner.m_maxHp * (t_skill['val_3'] / 100)

    -- 4. 콜백 함수 등록
    owner:addHpEventListener(self)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillShield:initState()
    self:addState('idle', SkillShield.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
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
            self:makeShield()
        end
    end

    self.m_currHP = hp
end


-------------------------------------
-- function makeShield
-------------------------------------
function SkillShield:makeShield()
    local shield = Buff_Shield('res/effect/effect_shield/effect_shield.spine')

    self.m_world.m_worldNode:addChild(shield.m_rootNode, 5)
    self.m_world:addToUnitList(shield)

	shield:init_buff(self.m_owner, self.m_shieldHP, self.m_duration)

	-- @TODO effect_shield.spine는 너무 커서 일단 줄임... 
	shield.m_animator:setScale(0.5)
end