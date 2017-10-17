local PARENT = StatusEffectUnit

-------------------------------------
-- class StatusEffectUnit_AddDmg
-------------------------------------
StatusEffectUnit_AddDmg = class(PARENT, {
    m_activityCarrier = 'ActivityCarrier',
    m_targetStatusEffectName = 'str',       -- 설정되면 해당하는 상태효과가 있을 경우만 추가피해를 줌

    m_bEndDamage = 'bool',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_AddDmg:init()
    self.m_activityCarrier = self:makeActivityCarrier()
    self.m_activityCarrier:setAttackType('add_dmg')
    self.m_activityCarrier:setIgnoreDef(true)
	self.m_activityCarrier:setParam('add_dmg', true)

    if (string.match(self.m_statusEffectName, 'add_dmg_')) then
        self.m_targetStatusEffectName = string.gsub(self.m_statusEffectName, 'add_dmg_', '')
    end

    self.m_bEndDamage = false
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectUnit_AddDmg:update(dt, modified_dt)
    local b = PARENT.update(self, dt, modified_dt)

    if (b) then
        self:doDamage()
    end

    return b
end

-------------------------------------
-- function doDamage
-------------------------------------
function StatusEffectUnit_AddDmg:doDamage()
    if (self.m_bEndDamage) then return end
    self.m_bEndDamage = true

    local is_add_damage = false
    
    -- 지칭된 상태효과가 있다면 해당 상태효과가 대상에게 존재하는지 체크
    if (self.m_targetStatusEffectName) then
        if (self.m_owner:isExistStatusEffectName(self.m_targetStatusEffectName, self.m_statusEffectName)) then
            is_add_damage = true
        end
    else
        is_add_damage = true
    end

    if (is_add_damage) then
        self.m_owner:undergoAttack(self, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, 0, true)
    end
end