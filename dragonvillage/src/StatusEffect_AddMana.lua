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
-- @brief �ش� ����ȿ���� ���� 1ȸ�� �����Ͽ� ��ø ����ɽø��� ȣ��
-------------------------------------
function StatusEffect_AddMana:onApplyOverlab(unit)
    self.m_owner.m_world.m_heroMana:addMana(self.m_addValue)
    -- !! unit�� �ٷ� �����Ͽ� �ش� ����ȿ�� �����Ŵ
    unit.m_durationTimer = 0
end
