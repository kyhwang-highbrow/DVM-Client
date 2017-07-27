local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ConditionalModify
-------------------------------------
StatusEffect_ConditionalModify = class(PARENT, {
    m_totalValue = 'number',
    m_branch = 'number',
    m_targetStatusEffectName = 'string',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ConditionalModify:init(file_name, body)
    self.m_totalValue = 0
    self.m_targetStatusEffectName = ''

end


-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_ConditionalModify:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self.m_branch = t_status_effect['val_1']
    self.m_targetStatusEffectName = t_status_effect['val_2']
end

-------------------------------------
-- function onApplyOverlab
-- @brief �ش� ����ȿ���� ���� 1ȸ�� �����Ͽ� ��ø ����ɽø��� ȣ��
-------------------------------------
function StatusEffect_ConditionalModify:onApplyOverlab(unit)
    self.m_totalValue = unit.m_value
end