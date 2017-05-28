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
    local b = PARENT.onApplyCommon(self)

    self.m_owner:setSilence(true)

    return b
end

-------------------------------------
-- function onUnapplyCommon
-- @brief ��ø�� ������� �ѹ��� ����Ǿ���ϴ� ȿ���� ����
-------------------------------------
function StatusEffect_Silence:onUnapplyCommon()
    local b = PARENT.onUnapplyCommon(self)

    self.m_owner:setSilence(false)

    return b
end