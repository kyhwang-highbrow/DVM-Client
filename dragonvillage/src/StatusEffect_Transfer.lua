local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Transfer
-------------------------------------
StatusEffect_Transfer = class(PARENT, {
    m_mConditionInfo = 'table',     -- 전이할 상태효과를 구분하기 위한 조건 정보를 담기 위한 테이블
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Transfer:init(file_name, body)
    self.m_mConditionInfo = {}
end


-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Transfer:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- 전이할 상태효과를 구분하기 위한 조건 정보를 저장
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
function StatusEffect_Transfer:onApplyOverlab(unit)
    local target_count = unit.m_value   -- 적용값을 전이될 대상 수로 사용
    local rate = unit.m_duration        -- 시간을 대상 별 전이 확률로 사용(%)

    -- 해당 상태효과가 전이 대상인지 검사
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

    -- 전이할 대상(Character)을 구한다
    local getTargetList = function()
        local l_target = self.m_owner:getTargetListByType('teammate_random', target_count)
        return l_target
    end

    -- 대상에게 해당 상태효과와 동일한 적용값과 시간으로 전이
    local transfer = function(target, status_effect)
        local list = status_effect:getOverlabUnitList()
        local type = status_effect:getTypeName()
                        
        for _, v in ipairs(list) do
            if (v ~= unit) then
                local caster = v:getCaster()
                local value = v:getValue()
                local source = v:getSource()
                local duration = v:getDuration()
                local skill_id = v:getSkillId()
                local add_param = v.m_tParam

                StatusEffectHelper:invokeStatusEffect(caster, target, type, value, source, rate, duration, skill_id, add_param)
            end
        end
    end

    for _, status_effect in pairs(self.m_owner:getStatusEffectList()) do
        if (checkCondition(status_effect)) then
            for i, target in ipairs(getTargetList()) do
                transfer(target, status_effect)
            end
        end
    end

    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end