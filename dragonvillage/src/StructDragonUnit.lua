-------------------------------------
-- class StructDragonUnit
-- @instance
-------------------------------------
StructDragonUnit = class({
        m_unitID = 'number',
        m_lStructDragonUnitCondition = 'list',

        m_satisfiedCollection = 'boolean',
        m_rewardReceived = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function StructDragonUnit:init(unit_id)
    self.m_unitID = unit_id
    
    -- 조건 문자열
    -- ex) '102011;friendship;2,120012;friendship;2'
    local condition_str = TableDragonUnit:getUnitConditionStr(unit_id)
    self:parseConditionStr(condition_str)

    self:checkCondition()
end

-------------------------------------
-- function parseConditionStr
-------------------------------------
function StructDragonUnit:parseConditionStr(condition_str)
    -- ex) '102011;friendship;2,120012;friendship;2'
    -- 조건 문자열에서 개행 삭제
    condition_str = string.gsub(condition_str, '\n', '')

    -- 조건 문자열에서 ','로 분리
    local l_condition_str = TableClass:seperate(condition_str, ',', true)

    self.m_lStructDragonUnitCondition = {}

    for i,v in ipairs(l_condition_str) do
        local struct_dragon_unit_condition = StructDragonUnitCondition(v)
        table.insert(self.m_lStructDragonUnitCondition, struct_dragon_unit_condition)
    end
end

-------------------------------------
-- function checkCondition
-------------------------------------
function StructDragonUnit:checkCondition()
    self.m_satisfiedCollection = true

    for _, struct_dragon_unit_condition in ipairs(self.m_lStructDragonUnitCondition) do
        struct_dragon_unit_condition:checkCondition_collectionData()

        if (not struct_dragon_unit_condition.m_satisfiedCollection) then
            self.m_satisfiedCollection = false
        end
    end
end

-------------------------------------
-- function containsDid
-- @brief
-------------------------------------
function StructDragonUnit:containsDid(did)
    for _, struct_dragon_unit_condition in ipairs(self.m_lStructDragonUnitCondition) do
        if struct_dragon_unit_condition:containsDid(did) then
            return true
        end
    end

    return false
end







-------------------------------------
-- function checkCondition_deck
-- @brief
-------------------------------------
function StructDragonUnit:checkCondition_deck(l_dragons)
    for _, struct_dragon_unit_condition in ipairs(self.m_lStructDragonUnitCondition) do
        local ret = struct_dragon_unit_condition:checkCondition_dragons(l_dragons)
        if (not ret) then
            return false
        end
    end

    return true
end