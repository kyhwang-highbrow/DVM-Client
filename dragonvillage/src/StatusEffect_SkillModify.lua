local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_SkillModify
-------------------------------------
StatusEffect_SkillModify = class(PARENT, {
    m_lSkillColumn = 'table',   -- 변경할 스킬의 아이디를 가진 칼럼명 리스트(table_dragon, table_monster 테이블 내에서의 칼럼명)
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_SkillModify:init(file_name, body)
    self.m_lSkillColumn = {}
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_SkillModify:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- 변경할 스킬 아이디를 가진 칼럼명 리스트를 저장
    local str = t_status_effect['val_1']
    if (str and str ~= '') then
        local temp = pl.stringx.split(str, ';')
        local idx = 1
        
        while (temp[idx] and string.find(temp[idx], 'skill_')) do
            table.insert(self.m_lSkillColumn, temp[idx])
            idx = idx + 1
        end
    end
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_SkillModify:onApplyOverlab(unit)
    -- 해당 스킬의 값을 수정
    -- !! unit의 duration은 해당 스킬의 현재 남은 쿨타임 시간 비율값(%)으로 사용
    local cooltime_rate = unit.m_duration / 100

    for _, column in ipairs(self.m_lSkillColumn) do
        local char_table = self.m_owner:getCharTable()
        local skill_id = char_table[column]
        if (skill_id and skill_id ~= '') then
            local skill_indivisual_info = self.m_owner:findSkillInfoByID(skill_id)
            if (skill_indivisual_info) then
                skill_indivisual_info.m_timer = skill_indivisual_info.m_timer * cooltime_rate
                skill_indivisual_info.m_cooldownTimer = skill_indivisual_info.m_cooldownTimer * cooltime_rate
            end
        end
    end
    
    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end