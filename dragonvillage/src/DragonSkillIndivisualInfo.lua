-------------------------------------
-- class DragonSkillIndivisualInfo
-------------------------------------
DragonSkillIndivisualInfo = class({
        m_charType = 'string',  -- 캐릭터 타입 'dragon', 'enemy'
        m_skillID = 'number',   -- 스킬 ID
        m_skillType = 'string',
        m_tSkill = 'table',     -- 스킬 테이블
        m_turnCount = 'number', -- 턴 공격 횟수 저장용

        m_skillLevel = 'number',
        m_lSkillLevelupIDList = 'list', -- 스킬 레벨업이 적용된 ID 저장
    })

-------------------------------------
-- function init
-------------------------------------
function DragonSkillIndivisualInfo:init(char_type, skill_type, skill_id, skill_level)
    self.m_charType = char_type
    self.m_skillType = skill_type
    self.m_skillID = skill_id
    self.m_skillLevel = (skill_level or 1)
    self.m_turnCount = 0
end

-------------------------------------
-- function init_skillLevelupIDList
-------------------------------------
function DragonSkillIndivisualInfo:init_skillLevelupIDList(l_existing_list)
    self.m_lSkillLevelupIDList = l_existing_list and clone(l_existing_list) or {}

    local skill_id = self.m_skillID
    
    -- 1레벨부터 해당 레벨까지의 lvid를 저장
    for i=1, self.m_skillLevel do
        local skill_level_id = (skill_id * 100) + i
        table.insert(self.m_lSkillLevelupIDList, skill_level_id)
    end
end

-------------------------------------
-- function applySkillLevel
-------------------------------------
function DragonSkillIndivisualInfo:applySkillLevel()
    local skill_id = self.m_skillID

    local table_skill = TABLE:get(self.m_charType .. '_skill')
    self.m_tSkill = table_skill[skill_id]

    if (not self.m_tSkill) then
        error('skill_id ' .. skill_id)
    end

    -- 값이 변경되므로 복사해서 사용
    self.m_tSkill = clone(self.m_tSkill)

    if true then
        return
    end

    cclog('### DragonSkillIndivisualInfo:applySkillLevel() : ' .. skill_id)

    local table_dragon_skill_modify = TABLE:get('dragon_skill_modify')
    
    local l_modify_list = {}

    for _,v in ipairs(self.m_lSkillLevelupIDList) do
        local t_dragon_skill_modify = table_dragon_skill_modify[v]
        
        if t_dragon_skill_modify then
            for i=1, 10 do
                local column = t_dragon_skill_modify[string.format('col_%.2d', i)]
                local modify = t_dragon_skill_modify[string.format('mod_%.2d', i)]
                local value = t_dragon_skill_modify[string.format('val_%.2d', i)]

                if column and (column ~= 'x') then
                    cclog('column ' .. column)

                    local t_modify = l_modify_list[column]
                    if (not t_modify) then
                        t_modify = {column=column, modify=modify, value=value}
                        l_modify_list[column] = t_modify
                    else
                        if (t_modify['modify'] ~= modify) then
                            error('modify타입이 다르게 사용되었습니다.')
                        end
                        
                        if (modify == 'exchange') then
                            t_modify['value'] = value
                        elseif (modify == 'add') then
                            t_modify['value'] = (t_modify['value'] + value)
                        elseif (modify == 'multiply') then
                            t_modify['value'] = (t_modify['value'] + value)
                        end
                    end
                end
            end
        end
    end

    -- 적용
    for column, t_modify in pairs(l_modify_list) do
        local modify = t_modify['modify']

        if (modify == 'exchange') then
            t_modify['value'] = value
        elseif (modify == 'add') then
            t_modify['value'] = (t_modify['value'] + value)
        elseif (modify == 'multiply') then
            t_modify['value'] = (t_modify['value'] + value)
        end
    end
end