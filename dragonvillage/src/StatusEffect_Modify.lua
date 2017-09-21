local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Modify
-------------------------------------
StatusEffect_Modify = class(PARENT, {
    m_mConditionInfo = 'table',     -- 변경할 상태효과를 구분하기 위한 조건 정보를 담기 위한 테이블
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

    -- 변경할 상태효과를 구분하기 위한 조건 정보를 저장
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
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_Modify:onApplyOverlab(unit)
    -- 해당 상태효과가 변경 대상인지 검사
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

    -- 해당 상태효과의 값을 수정
    -- !! unit의 value는 변경할 상태효과의 value의 증가값(%)으로 사용
    -- !! unit의 duration은 변경할 상태효과의 duration의 증가값(%)으로 사용
    local modify = function(status_effect)
        local list = status_effect:getOverlabUnitList()
        local value_rate = unit.m_value / 100
        local duration_rate = unit.m_duration / 100

        for _, v in ipairs(list) do
            if (v ~= unit) then
                do  -- 적용값 변경
                    local new_value = v.m_value + v.m_value * value_rate
                    v:onChangeValue(new_value)
                end

                do  -- 유지시간 변경
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

    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end