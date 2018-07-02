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
            --cclog('val_' .. i .. ' : ' .. str)
            local param = pl.stringx.split(str, ';')
            local l_skill_id = {}

            -- 첫번째 인자는 스킬 아이디 or table_dragon의 칼럼명(이 경우 테이블 참조해서 스킬 아이디를 가져옴)
            do
                local l_skill_key = pl.stringx.split(param[1], ',')
                local idx = 1

                while (l_skill_key[idx]) do
                    local key = l_skill_key[idx]
                    local skill_id, metamorphosis_skill_id = SkillHelper:getValidSkillIdFromKey(self.m_owner, key)

                    if (self.m_owner:findSkillInfoByID(skill_id)) then
                        table.insert(l_skill_id, skill_id)
                    end
                    if (self.m_owner:findSkillInfoByID(metamorphosis_skill_id)) then
                        table.insert(l_skill_id, metamorphosis_skill_id)
                    end

                    idx = idx + 1
                end
            end

            local t_info = {
                l_skill_id = l_skill_id,
                col = param[2],
                val = tonumber(param[3]),
                action = param[4]
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
        local l_skill_id = v['l_skill_id']

        for _, skill_id in ipairs(l_skill_id) do
            local skill_indivisual_info = self.m_owner:findSkillInfoByID(skill_id)
            if (skill_indivisual_info) then
                -- 남은 쿨타임 시간 변경
                if (cooltime_rate ~= 1) then
                    skill_indivisual_info.m_timer = skill_indivisual_info.m_timer * cooltime_rate
                    skill_indivisual_info.m_cooldownTimer = skill_indivisual_info.m_cooldownTimer * cooltime_rate
                end

                -- 스킬 테이블 변경
                if (v['col'] and v['val']) then
                    skill_indivisual_info:addBuff(v['col'], v['val'], v['action'], true)
                end
            end
        end
    end
        
    -- !! unit을 바로 삭제하여 해당 상태효과 종료시킴
    unit:finish()
end