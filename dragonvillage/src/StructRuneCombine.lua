-- 룬 합성에 필요한 룬 갯수
RUNE_COMBINE_REQUIRE = 5

-------------------------------------
-- class StructRuneCombine
-------------------------------------
StructRuneCombine = class({
    m_grade = 'number', -- 어떠한 등급의 룬을 합성할지
    m_mRuneObjectMap = 'map', -- 현재 등록된 룬들의 정보를 저장, key = roid, map[roid] = StructRuneObject
    m_mRuneIndexMap = 'map', -- 현재 등록된 룬들의 인덱스를 저장, key = roid, map[roid] = index
    m_mRuneMappingIndex = 'map', -- 현재 인덱스별로 등록된 룬 roid, map[index] = StructRuneObject
    
    })

-------------------------------------
-- function init
-------------------------------------
function StructRuneCombine:init(grade)
    
    self.m_grade = grade
    self.m_mRuneObjectMap = {}
    self.m_mRuneIndexMap = {}
    self.m_mRuneMappingIndex = {}
    
end

-------------------------------------
-- function hasRuneObject
-- @brief 등록된 재료 룬이 있는지 찾음
-- @param roid : rune object id
-- @return boolean
-------------------------------------
function StructRuneCombine:hasRuneObject(roid)
    if self.m_mRuneIndexMap[roid] then
        return true
    end

    return false
end


-------------------------------------
-- function addRuneObject
-- @brief 새로운 재료 룬을 등록함 
-------------------------------------
function StructRuneCombine:addRuneObject(t_rune_data)
    local t_rune_data = t_rune_data
    local roid = t_rune_data['roid']

    if (self.m_grade == nil) then
        local grade = t_rune_data['grade']
        self.m_grade = grade
    end

    local lowest_index = self:getNextIndex() -- 빈 칸 중 가장 낮은 인덱스

    self.m_mRuneIndexMap[roid] = lowest_index -- 몇번에 등록될지
    self.m_mRuneObjectMap[roid] = t_rune_data
    self.m_mRuneMappingIndex[lowest_index] = t_rune_data
end

-------------------------------------
-- function removeRuneObject
-- @brief 등록된 재료 룬을 제거함 
-------------------------------------
function StructRuneCombine:removeRuneObject(roid)
    local index = self.m_mRuneIndexMap[roid]

    if (index == nil) then 
        return 
    end

    self.m_mRuneMappingIndex[index] = nil
    self.m_mRuneObjectMap[roid] = nil
    self.m_mRuneIndexMap[roid] = nil

    if(self:isEmpty()) then
        self.m_grade = nil
    end
end


-------------------------------------
-- function isFull
-- @brief 현재 모든 재료를 채웠는지 
-- @return true면 모든 재료를 채웠음
-------------------------------------
function StructRuneCombine:isFull()
    local b_is_full = (table.count(self.m_mRuneMappingIndex) == RUNE_COMBINE_REQUIRE)

    return b_is_full
end

-------------------------------------
-- function isEmpty
-- @brief 현재 모든 재료칸이 비워져있는지 
-- @return true면 모든 재료칸이 비워져있음
-------------------------------------
function StructRuneCombine:isEmpty()
    local b_is_empty = (table.count(self.m_mRuneMappingIndex) == 0)

    return b_is_empty
end

-------------------------------------
-- function isEmpty
-- @brief 현재 몇개의 재료칸이 비워져있는지 
-- @return number
-------------------------------------
function StructRuneCombine:getBlankSlotCount()
    local blank_slot_count = (RUNE_COMBINE_REQUIRE - table.count(self.m_mRuneMappingIndex))

    return blank_slot_count
end

-------------------------------------
-- function getRuneDataFromIndex
-- @brief 해당 인덱스에 매칭되는 룬 정보 반환
-------------------------------------
function StructRuneCombine:getRuneDataFromIndex(idx)
    local t_rune_data = self.m_mRuneMappingIndex[idx]

    return t_rune_data
end

-------------------------------------
-- function isBlankIndex
-- @brief 해당 인덱스가 비어있는지
-------------------------------------
function StructRuneCombine:isBlankIndex(idx)
    local b_is_blank_index = (self.m_mRuneMappingIndex[idx] == nil)

    return b_is_blank_index
end

-------------------------------------
-- function getRoids
-- @brief 현재 저장하고 있는 룬들의 roid를 문자열로 반환
-------------------------------------
function StructRuneCombine:getRoids()
    local roids = ''

    for idx, rune_data in pairs(self.m_mRuneMappingIndex) do
        if (roids == '') then
            roids = rune_data['roid']
        else
            roids = roids .. ',' .. rune_data['roid']
        end
    end

    return roids
end

-------------------------------------
-- function getNextIndex
-- @brief 비어있는 가장 낮은 인덱스를 반환
-------------------------------------
function StructRuneCombine:getNextIndex()
    local lowest_index = 1
    
    while(self.m_mRuneMappingIndex[lowest_index] ~= nil) do
        lowest_index = lowest_index + 1
    end

    return lowest_index
end



