local PARENT = TableClass
-------------------------------------
-- class TableLairCondition
-------------------------------------
TableLairCondition = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLairCondition:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_lair_condition'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLairCondition instance
-------------------------------------
function TableLairCondition:getInstance()
    if (instance == nil) then
        instance = TableLairCondition()
    end
    return instance
end

-------------------------------------
-- function getLairConditionGrade
---@return number
-------------------------------------
function TableLairCondition:getLairConditionGrade(birth_grade)
    return self:getValue(birth_grade, 'grade')
end

-------------------------------------
-- function getLairConditionLevel
---@return number
-------------------------------------
function TableLairCondition:getLairConditionLevel(birth_grade)
    return self:getValue(birth_grade, 'level')
end

-------------------------------------
-- function isMeetCondition
---@return  boolean
-------------------------------------
function TableLairCondition:isMeetCondition(struct_dragon_object)
    local birth_grade = struct_dragon_object:getBirthGrade()

    -- 존재 여부
    if self:exists(birth_grade) == false then
        return false
    end

    --cclog('birth_grade', birth_grade, struct_dragon_object:getDragonNameWithEclv())

    -- 등급
    if struct_dragon_object['grade'] < self:getValue(birth_grade, 'grade') then
        --cclog('grade', struct_dragon_object['grade'])
        return false
    end

    -- 레벨
    if struct_dragon_object:getLv() < self:getValue(birth_grade, 'level') then
        --cclog('level', struct_dragon_object:getLv())
        return false
    end

    -- 진화
    if struct_dragon_object:getEvolution() < self:getValue(birth_grade, 'evolution') then
        --cclog('evolution', struct_dragon_object:getEvolution())
        return false
    end

    -- 친밀도
    if struct_dragon_object['friendship']['flv'] < self:getValue(birth_grade, 'friendship') then
        --cclog('friendship', struct_dragon_object['friendship']['flv'])
        return false
    end

    -- 강화 단계
    if struct_dragon_object:getRlv() < self:getValue(birth_grade, 'reinforce') then
        --cclog('reinforce', struct_dragon_object:getRlv())
        return false
    end

    -- 마스터리 레벨
    if struct_dragon_object:getMasteryLevel() < self:getValue(birth_grade, 'mastery') then
        --cclog('mastery', struct_dragon_object:getMasteryLevel())
        return false
    end

    -- 스킬 강화 단계 합계
    if struct_dragon_object:getDragonSkillLevelSum() < self:getValue(birth_grade, 'sum_skill_level') then
        --cclog('sum_skill_level', struct_dragon_object:getDragonSkillLevelUpNum())
        return false
    end

    return true
end