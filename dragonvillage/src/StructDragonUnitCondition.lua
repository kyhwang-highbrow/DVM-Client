-------------------------------------
-- class StructDragonUnitCondition
-- @instance
-------------------------------------
StructDragonUnitCondition = class({
        did = 'number',
        dragon_type = 'string',
        condition_type = 'string',
        condition_value = 'number',

        m_satisfiedCollection = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function StructDragonUnitCondition:init(condition_str)
    self.m_satisfiedCollection = false
    self:parseConditionStr(condition_str)
end

-------------------------------------
-- function parseConditionStr
-------------------------------------
function StructDragonUnitCondition:parseConditionStr(condition_str)
    -- ex) '120012;friendship;2' or 'leafdragon; grade; 2'
    local l_data = TableClass:seperate(condition_str, ';', true)
    local target = l_data[1] -- did or dragon_type

    local dragon_type = nil
    local did = tonumber(target)
    if (not did) then
        dragon_type = target
    end

    local condition_type = l_data[2] or 'none'
    local condition_value = l_data[3] or 0

    self['did'] = did
    self['dragon_type'] = dragon_type
    self['condition_type'] = condition_type
    self['condition_value'] = tonumber(condition_value)
end

-------------------------------------
-- function checkCondition_collectionData
-- @brief 도감 정보로 확인
-------------------------------------
function StructDragonUnitCondition:checkCondition_collectionData()
    if self:_checkCondition_collectionData() then
        self.m_satisfiedCollection = true
    else
        self.m_satisfiedCollection = false
    end
end

-------------------------------------
-- function _checkCondition_collectionData
-- @brief 도감 정보로 확인
-------------------------------------
function StructDragonUnitCondition:_checkCondition_collectionData()
    local did = self['did']
    local dragon_type = self['dragon_type']
    local condition_type = self['condition_type']
    local condition_value = self['condition_value']

    if did then
        local struct_collection_data = g_collectionData:getCollectionData(did)

        if struct_collection_data:isExist() then
            if (condition_type == 'none') then
                return true

            elseif (condition_type == 'grade') then
                return (struct_collection_data:getGrade() >= condition_value)

            elseif (condition_type == 'friendship') then
                return (struct_collection_data:getFLv() >= condition_value)

            elseif (condition_type == 'research') then
                local research_lv = g_collectionData:getDragonResearchLevel_did(did)
                return (research_lv >= condition_value)

            elseif (condition_type == 'evolution') then
                return (struct_collection_data:getEvolution() >= condition_value)

            else
                error('condition_type : ' .. condition_type)
            end
        end

    elseif dragon_type then
        if g_collectionData:isExistDragonType(dragon_type) then
            -- 아직 세부 조건은 처리하지 않음
            return true
        end
        --error('ServerData_DragonUnit:checkExistDragon(t_data)')
    end

    return false
end

-------------------------------------
-- function isSatisfiedCollectionData
-- @brief 도감 정보로 조건을 충족하는지 여부
-------------------------------------
function StructDragonUnitCondition:isSatisfiedCollectionData()
    return self.m_satisfiedCollection
end


-------------------------------------
-- function makeDragonConditionCard
-- @brief UI에서 사용될 드래곤 조건 카드
-------------------------------------
function StructDragonUnitCondition:makeDragonConditionCard()
    local did = self['did']

    -- 드래곤의 타입으로 지정되었을 경우
    if (not did) then
        local dragon_type = self['dragon_type']
        did = TableDragonType:getBaseDid(dragon_type)
    end

    local condition_type = self['condition_type']
    local condition_value = self['condition_value']

    local t_data = {}

    -- 조건별로 카드에 정보 추가
    if (condition_type == 'grade') then
        t_data['grade'] = condition_value
    elseif (condition_type == 'evolution') then
        t_data['evolution'] = condition_value
    end

    local card = MakeSimpleDragonCard(did, t_data)

    -- 등급이 조건이 아닌 경우 별 아이콘 제거
    if (condition_type ~= 'grade') then
        card.vars['starIcon']:setVisible(false)
    end

    return card
end