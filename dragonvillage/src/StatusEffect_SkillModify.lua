local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_SkillModify
-- @brief 실시간 해제는 구현 안되어잇음...
-------------------------------------
StatusEffect_SkillModify = class(PARENT, {
    m_lModifyInfo = 'table',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_SkillModify:init(file_name, body)
    self.m_lModifyInfo = {}
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_SkillModify:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    for i = 1, 4 do
        local str = t_status_effect['val_' .. i]
        if (str and str ~= '') then
            local temp = pl.stringx.split(str, ';')
            local skill_id
            
            if (type(temp[1]) == 'number') then
                skill_id = temp[1]
            else
                -- 드래곤 테이블에서 해당하는 칼럼의 스킬 아이디를 가져온다
                local column = temp[1]
                local char_table = self.m_owner:getCharTable()
                skill_id = char_table[column]
            end

            local t_info = {
                skill_id = skill_id,
                col = temp[2],
                val = temp[3],
                action = temp[4]
            }

            table.insert(self.m_lModifyInfo, t_info)
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

    for _, v in ipairs(self.m_lModifyInfo) do
        local skill_indivisual_info = self.m_owner:findSkillInfoByID(v['skill_id'])
        if (skill_indivisual_info) then
            -- 남은 쿨타임 시간 변경
            skill_indivisual_info.m_timer = skill_indivisual_info.m_timer * cooltime_rate
            skill_indivisual_info.m_cooldownTimer = skill_indivisual_info.m_cooldownTimer * cooltime_rate

            -- 스킬 테이블 변경
            if (v['col'] and v['val']) then
                skill_indivisual_info:addBuff(v['col'], v['val'], v['action'])
            end
        end
    end
        
    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end