local PARENT = StatusEffectUnit_Dot

-------------------------------------
-- class StatusEffectUnit_Dot_Heal
-------------------------------------
StatusEffectUnit_Dot_Heal = class(PARENT, {
        m_dotHeal = '',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffectUnit_Dot_Heal:init()
    self.m_dotHeal = self:calculateDotHeal()

	-- 힐 사운드
	if (self.m_owner:isDragon()) then
		SoundMgr:playEffect('SFX', 'sfx_heal')
	end
end

-------------------------------------
-- function doDot
-------------------------------------
function StatusEffectUnit_Dot_Heal:doDot()
    self.m_owner:healAbs(self.m_caster, self.m_dotHeal, false)
end

-------------------------------------
-- function calculateDotHeal
-------------------------------------
function StatusEffectUnit_Dot_Heal:calculateDotHeal()
    local t_status_effect = TableStatusEffect():get(self.m_statusEffectName)
    local heal
    
    -- 힐 계산
    if (t_status_effect['val_1'] == 'hp_target') then 
        heal = self.m_owner:getStat('hp') * (self.m_value / 100)

    elseif (t_status_effect['abs_switch'] == 1) then 
        heal = self.m_value

    else
        local atk_dmg = self:getStandardStat()
        heal = HealCalc_M(atk_dmg, false, true)

        heal = heal * (self.m_value / 100)
    end

    return heal
end

-------------------------------------
-- function onChangeValue
-- @brief 적용값이 변경되었을 경우 호출(StatusEffect_Modify를 통한 적용값 변경 시)
-------------------------------------
function StatusEffectUnit_Dot_Heal:onChangeValue(new_value)
    PARENT.onChangeValue(self, new_value)

    self.m_dotHeal = self:calculateDotHeal()
end