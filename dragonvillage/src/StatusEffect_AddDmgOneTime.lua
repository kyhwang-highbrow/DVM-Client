local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AddDmgOneTime
-- @breif 추가피해를 모아놨다가 종료시 한번에 줌
-------------------------------------
StatusEffect_AddDmgOneTime = class(PARENT, {
        m_resAttackEffect = 'string',
        m_caster = 'Character',
		m_savedDmg = 'number',  -- 모여진 데미지량
        m_activityCarrier = 'ActivityCarrier',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AddDmgOneTime:init(file_name, body, ...)
	self.m_savedDmg = 0

    self.m_bStopUntilSkillEnd = false
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_AddDmgOneTime:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    if (t_status_effect['res_2'] and t_status_effect['res_2'] ~= '') then
        local type = self:getTypeName()
        local attr = self.m_caster:getAttributeForRes()

        self.m_resAttackEffect = TableStatusEffect():getRes2(type, attr)
    end
end

-------------------------------------
-- function init_statusEffect
-------------------------------------
function StatusEffect_AddDmgOneTime:init_statusEffect(caster)
    self.m_caster = caster
    self.m_activityCarrier = self.m_caster:makeAttackDamageInstance()
    self.m_activityCarrier:setAttackType('add_dmg')
    self.m_activityCarrier:setIgnoreDef(true)
    self.m_activityCarrier:setParam('add_dmg', true)
end

-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_AddDmgOneTime:onEnd()
    if (self.m_savedDmg > 0) then
        self.m_activityCarrier:setAtkDmgStat(self.m_savedDmg)
    
        self.m_owner:undergoAttack(self, self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, 0, true)

        if (self.m_resAttackEffect) then
            self.m_world:addInstantEffect(self.m_resAttackEffect, 'idle', self.m_owner.pos.x, self.m_owner.pos.y)
        end
    end
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_AddDmgOneTime:onApplyOverlab(unit)
    local activityCarrier = unit:getActivityCarrier()
	local atk_dmg = activityCarrier:getFinalAtkDmg(self.m_owner)
        
    self.m_savedDmg = self.m_savedDmg + atk_dmg
end