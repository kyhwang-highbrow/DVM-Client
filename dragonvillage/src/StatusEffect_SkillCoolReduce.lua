local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_SkillCoolReduce
-------------------------------------
StatusEffect_SkillCoolReduce = class(PARENT, {
    m_lSkillId = 'table',
    m_bUseSecUnit = 'boolean'
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_SkillCoolReduce:init(file_name, body)
    self.m_lSkillId = {}
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_SkillCoolReduce:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- 절대값인 경우 초단위로 감소 처리시킴
    self.m_bUseSecUnit = (t_status_effect['abs_switch'] == 1)
    
    for i = 1, 4 do
        local str = t_status_effect['val_' .. i]
        if (str and str ~= '') then
            -- 스킬 아이디 or table_dragon의 칼럼명(이 경우 테이블 참조해서 스킬 아이디를 가져옴)
            local l_skill_key = pl.stringx.split(str, ',')
            local idx = 1

            while (l_skill_key[idx]) do
                local key = l_skill_key[idx]
                local skill_id, metamorphosis_skill_id = SkillHelper:getValidSkillIdFromKey(self.m_owner, key)
                
                if (self.m_owner:findSkillInfoByID(skill_id)) then
                    table.insert(self.m_lSkillId, tonumber(skill_id))
                end
                if (self.m_owner:findSkillInfoByID(metamorphosis_skill_id)) then
                    table.insert(self.m_lSkillId, tonumber(metamorphosis_skill_id))
                end

                idx = idx + 1
            end
        end
    end
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_SkillCoolReduce:onApplyOverlab(unit)
    -- 해당 스킬의 쿨타임 시간값을 수정
    for _, skill_id in ipairs(self.m_lSkillId) do
        local skill_indivisual_info = self.m_owner:findSkillInfoByID(skill_id)
        if (skill_indivisual_info) then
            if (self.m_bUseSecUnit) then
                skill_indivisual_info:updateTimer(unit.m_value)
            else
                skill_indivisual_info.m_reducedCoolPercentage = skill_indivisual_info.m_reducedCoolPercentage + unit.m_value
            end
        end
    end

    -- !! 초단위로 사용된 경우 즉시 효과로만 사용됨
    if (self.m_bUseSecUnit) then
        unit:finish()
    end
end

-------------------------------------
-- function onUnapplyOverlab
-- @brief 해당 상태효과가 중첩 해제될시마다 호출
-------------------------------------
function StatusEffect_SkillCoolReduce:onUnapplyOverlab(unit)
    if (self.m_bUseSecUnit) then return end

    for _, skill_id in ipairs(self.m_lSkillId) do
        local skill_indivisual_info = self.m_owner:findSkillInfoByID(skill_id)
        if (skill_indivisual_info) then
            skill_indivisual_info.m_reducedCoolPercentage = skill_indivisual_info.m_reducedCoolPercentage - unit.m_value
        end
    end
end