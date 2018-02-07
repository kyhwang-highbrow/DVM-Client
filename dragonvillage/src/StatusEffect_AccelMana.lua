local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_AccelMana
-------------------------------------
StatusEffect_AccelMana = class(PARENT, {})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_AccelMana:init(file_name, body)
end

-------------------------------------
-- function onApplyOverlab
-- @brief �ش� ����ȿ���� ���� 1ȸ�� �����Ͽ� ��ø ����ɽø��� ȣ��
-------------------------------------
function StatusEffect_AccelMana:onApplyOverlab(unit)
    local duration = unit:getDuration()

    self.m_world:startManaAccel(self.m_owner, duration)

    -- !! unit�� �ٷ� �����Ͽ� �ش� ����ȿ�� �����Ŵ
    unit:finish()
end