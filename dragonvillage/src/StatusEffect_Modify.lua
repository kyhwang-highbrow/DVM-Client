local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Modify
-------------------------------------
StatusEffect_Modify = class(PARENT, {
    m_mConditionInfo = 'table',     -- ������ ����ȿ���� �����ϱ� ���� ���� ������ ��� ���� ���̺�
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Modify:init(file_name, body)
    self.m_mConditionInfo = {}
end


-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Modify:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- ������ ����ȿ���� �����ϱ� ���� ���� ������ ����
    for i = 1, 4 do
        local str = t_status_effect['val_' .. i]
        if (str and str ~= '') then
            local temp = pl.stringx.split(str, ';')
            local column = temp[1]
            local value = temp[2]

            self.m_mConditionInfo[column] = value
        end
    end
end

-------------------------------------
-- function onApplyOverlab
-- @brief �ش� ����ȿ���� ���� 1ȸ�� �����Ͽ� ��ø ����ɽø��� ȣ��
-------------------------------------
function StatusEffect_Modify:onApplyOverlab(unit)
    -- �ش� ����ȿ���� ���� ������� �˻�
    local checkCondition = function(status_effect)
        if (table.count(self.m_mConditionInfo) == 0) then return true end

        local t_status_effect = status_effect.m_statusEffectTable
        local b = true

        for column, value in pairs(self.m_mConditionInfo) do
            if (t_status_effect[column] ~= value) then
                b = false
                break
            end
        end

        return b
    end

    -- �ش� ����ȿ���� ���� ����
    -- !! unit�� value�� ������ ����ȿ���� value�� ������(%)���� ���
    -- !! unit�� duration�� ������ ����ȿ���� duration�� ������(%)���� ���
    local modify = function(status_effect)
        local list = status_effect:getOverlabUnitList()
        local value_rate = unit.m_value / 100
        local duration_rate = unit.m_duration / 100

        for _, v in ipairs(list) do
            if (v ~= unit) then
                do  -- ���밪 ����
                    v.m_value = v.m_value + v.m_value * value_rate
                end

                do  -- �����ð� ����
                    v.m_durationTimer = v.m_durationTimer + v.m_durationTimer * duration_rate
                end
            end
        end
    end

    for _, status_effect in pairs(self.m_owner:getStatusEffectList()) do
        if (checkCondition(status_effect)) then
            modify(status_effect)
        end
    end

    -- !! unit�� �ٷ� �����Ͽ� �ش� ����ȿ�� �����Ŵ
    unit.m_durationTimer = 0
end