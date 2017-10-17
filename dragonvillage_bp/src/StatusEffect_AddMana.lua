local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AddMana
-------------------------------------
StatusEffect_AddMana = class(PARENT, {
    m_addValue = 'number'
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AddMana:init(file_name, body)
    self.m_addValue = 0
end

function StatusEffect_AddMana:init_status(status_effect_value)
    self.m_addValue = status_effect_value
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_AddMana:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_AddMana:onApplyOverlab(unit)
    if (self.m_owner.m_bLeftFormation) then
        self.m_owner.m_world.m_heroMana:addMana(self.m_addValue)
    else
        self.m_owner.m_world.m_enemyMana:addMana(self.m_addValue)
    end
    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end
