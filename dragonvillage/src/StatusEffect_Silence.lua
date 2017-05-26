local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Silence
-------------------------------------
StatusEffect_Silence = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Silence:init(file_name, body)
end

-------------------------------------
-- function onApplyCommon
-- @brief ��ø�� ������� �ѹ��� ����Ǿ���ϴ� ȿ���� ����
-------------------------------------
function StatusEffect_Silence:onApplyCommon()
    StatusEffect.onApplyCommon(self)

    self.m_owner:setSilence(true)
end

-------------------------------------
-- function onUnapplyCommon
-- @brief ��ø�� ������� �ѹ��� ����Ǿ���ϴ� ȿ���� ����
-------------------------------------
function StatusEffect_Silence:onUnapplyCommon()
    StatusEffect.onUnapplyCommon(self)

    self.m_owner:setSilence(false)
end