local PARENT = StatusEffectUnit

-------------------------------------
-- class StatusEffectUnit_AddHeal
-------------------------------------
StatusEffectUnit_AddHeal = class(PARENT, {
    m_heal = '',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_AddHeal:init()
    self.m_heal = self:calculatetHeal()
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectUnit_AddHeal:update(dt, modified_dt)
    local b = PARENT.update(self, dt, modified_dt)

    if (b) then
        self:doHeal()
    end

    return b
end

-------------------------------------
-- function doHeal
-------------------------------------
function StatusEffectUnit_AddHeal:doHeal()
    self.m_owner:healAbs(self.m_caster, self.m_heal, false)
end

-------------------------------------
-- function calculatetHeal
-------------------------------------
function StatusEffectUnit_AddHeal:calculatetHeal()
    local t_status_effect = TableStatusEffect():get(self.m_statusEffectName)
    local heal
    
    -- 힐 계산
    if (t_status_effect['val_1'] == 'hp_target') then 
        heal = self.m_owner:getStat('hp') * (self.m_value / 100)

    elseif (t_status_effect['abs_switch'] == 1) then 
        heal = self.m_value

    else
        local atk_dmg = self:getStandardStat()
        heal = HealCalc_M(atk_dmg)

        heal = heal * (self.m_value / 100)
    end

    return heal
end