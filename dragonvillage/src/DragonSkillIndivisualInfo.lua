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
    
    -- 2레벨부터 해당 레벨까지의 lvid를 저장
    for i=2, self.m_skillLevel do
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

    self.m_tSkill = clone(self.m_tSkill)

    -- TODO 스킬 modify 적용
end