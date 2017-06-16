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
function StatusEffectUnit_Dot_Heal:init(name, owner, caster, skill_id, value, source, duration)
    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]
    
    -- 힐 계산
    if (t_status_effect['abs_switch'] == 1) then 
        self.m_dotHeal = self.m_value

    else
        local atk_dmg = self:getStandardStat()
        local heal = HealCalc_M(atk_dmg)

        self.m_dotHeal = heal * (self.m_value / 100)
    end

	-- 힐 사운드
	if (owner:isDragon()) then
		SoundMgr:playEffect('SFX', 'sfx_heal')
	end
end

-------------------------------------
-- function doDot
-------------------------------------
function StatusEffectUnit_Dot_Heal:doDot()
    self.m_owner:healAbs(self.m_caster, self.m_dotHeal, false)
end
