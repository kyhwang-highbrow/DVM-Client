local PARENT = TableClass
-------------------------------------
-- class TableLateaCondition
-------------------------------------
TableLateaCondition = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLateaCondition:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_latea_condition'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLateaCondition instance
-------------------------------------
function TableLateaCondition:getInstance()
    if (instance == nil) then
        instance = TableLateaCondition()
    end
    return instance
end

-------------------------------------
-- function isMeetCondition
---@return  boolean
-------------------------------------
function TableLateaCondition:isMeetCondition(struct_dragon_object)
    local birth_grade = struct_dragon_object:getBirthGrade()

    -- 존재 여부
    if self:exists(birth_grade) == false then
        return false
    end

    -- 등급
    if struct_dragon_object:getGrade() < self:getValue(birth_grade, 'grade') then
        return false
    end

    -- 레벨
    if struct_dragon_object:getLv() < self:getValue(birth_grade, 'level') then
        return false
    end

    -- 진화
    if struct_dragon_object:getEvolution() < self:getValue(birth_grade, 'evolution') then
        return false
    end

    -- 친밀도
    if struct_dragon_object['friendship']['flv'] < self:getValue(birth_grade, 'friendship') then
        return false
    end

    -- 강화 단계
    if struct_dragon_object:getRlv() < self:getValue(birth_grade, 'reinforce') then
        return false
    end

    -- 마스터리 레벨
    if struct_dragon_object:getMasteryLevel() < self:getValue(birth_grade, 'mastery') then
        return false
    end

    -- 스킬 강화 단계 합계
    if struct_dragon_object:getDragonSkillLevelUpNum() < self:getValue(birth_grade, 'sum_skill_level') then
        return false
    end

    return true
end