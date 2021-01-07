-------------------------------------
-- class StructUpgradeMaterialCombine
-------------------------------------
StructUpgradeMaterialCombine = class({
    m_grade = 'number', -- 현재 합성할 재료들의 등급    
    m_needGold = 'number', -- 승급에 들어가는 골드
    m_needExp = 'number', -- 승급에 들어가는 경험치

    m_mDragonObjectMap = 'map', -- 현재 등록된 드래곤들의 정보를 저장, map[doid] = StructDragonObject
    m_mDragonIndexMap = 'map', -- 현재 등록된 드래곤들의 인덱스를 저장, map[doid] = index
    m_mDragonMappingIndex = 'map', -- 현재 인덱스별로 등록된 룬 정보, map[index] = StructDragonObject

    m_lDirtyList = 'list', -- 각 인덱스별 dirty flag
    
    })

-------------------------------------
-- function init
-------------------------------------
function StructUpgradeMaterialCombine:init(grade)
    self.m_grade = grade
    self.m_needGold = 0
    self.m_needExp = 0

    self.m_mDragonObjectMap = {}
    self.m_mDragonIndexMap = {}
    self.m_mDragonMappingIndex = {}
    
    local l_dirty_list = {}
    local require_count = self:getRequireCount()
    for i = 1, require_count do 
        l_dirty_list[i] = false
    end
    self.m_lDirtyList = l_dirty_list
end

-------------------------------------
-- function addDragonObject
-- @brief 새로운 재료 드래곤을 등록함 
-------------------------------------
function StructUpgradeMaterialCombine:addDragonObject(t_dragon_data)
    local doid = t_dragon_data['id']

    local index = self:getNextIndex(t_dragon_data) -- 놓여질 인덱스 찾기

    if (index == 1) then
        -- 기존에 가장 높은 녀석이 있었던 경우 그 녀석의 위치 바꿔주기
        if (self.m_mDragonMappingIndex[1] ~= nil) then
            local curr_lowest_index = 2
            
            while(self.m_mDragonMappingIndex[curr_lowest_index] ~= nil) do
                curr_lowest_index = curr_lowest_index + 1
            end   

            local before_highest_data = self.m_mDragonMappingIndex[1]
            local before_highest_doid = before_highest_data['id']

            self.m_mDragonIndexMap[before_highest_doid] = curr_lowest_index
            self.m_mDragonObjectMap[before_highest_doid] = before_highest_data
            self.m_mDragonMappingIndex[curr_lowest_index] = before_highest_data
            self.m_lDirtyList[curr_lowest_index] = true
        end        
    end

    self.m_mDragonIndexMap[doid] = index -- 몇번에 등록될지
    self.m_mDragonObjectMap[doid] = t_dragon_data
    self.m_mDragonMappingIndex[index] = t_dragon_data

    self:refreshPrice()

    self.m_lDirtyList[index] = true
end

-------------------------------------
-- function removeDragonObject
-- @brief 등록된 재료 드래곤을 제거함 
-------------------------------------
function StructUpgradeMaterialCombine:removeDragonObject(doid)
    local index = self.m_mDragonIndexMap[doid]

    if (index == nil) then 
        return 
    end

    self.m_mDragonMappingIndex[index] = nil
    self.m_mDragonObjectMap[doid] = nil
    self.m_mDragonIndexMap[doid] = nil

    -- 만약 제거된 재료 드래곤이 1번이었다면
    -- 남은 드래곤 중 가장 레벨이 높은 드래곤을 1번으로 옮긴다
    if (index == 1) then
        local max_index = nil
        local max_lv = nil
        local full_slot_count = self:getRequireCount()

        for i = 2, full_slot_count do
            local t_dragon_data = self.m_mDragonMappingIndex[i]
            if (t_dragon_data ~= nil) then
                local lv = t_dragon_data['lv']
                if (max_lv == nil) or (max_lv < lv) then
                    max_index = i
                    max_lv = lv
                end
            end
        end

        if (max_index ~= nil) then
            local highest_data = self.m_mDragonMappingIndex[max_index]
            local highest_doid = highest_data['id']
            
            self.m_mDragonIndexMap[highest_doid] = 1
            self.m_mDragonMappingIndex[max_index] = nil
            self.m_mDragonMappingIndex[1] = highest_data

            self.m_lDirtyList[max_index] = true
        end
    end

    self:refreshPrice()

    self.m_lDirtyList[index] = true
end

-------------------------------------
-- function refreshPrice
-- @brief 필요한 골드와 경험치 계산
-------------------------------------
function StructUpgradeMaterialCombine:refreshPrice()
    -- 비어있는 경우
    if (self:isEmpty()) then
        self.m_needGold = 0
        self.m_needExp = 0
        return
    end

    -- 비어있지 않은 경우 1번 재료를 기준으로 추가로 필요한 경험치 계산
    local table_exp = TableDragonExp()
    local grade = self.m_grade
    local t_dragon_data = self.m_mDragonMappingIndex[1]
    local lv = t_dragon_data['lv']
    local max_lv = TableGradeInfo():getValue(grade, 'max_lv')

    local need_gold, need_exp = TableDragonExp():getGoldAndDragonEXPForDragonLevelUp(grade, lv, max_lv)

    -- 골드는 현재 등급의 승급 비용 + 1번 재료 레벨업 비용
    need_gold = need_gold +  TableGradeInfo():getValue(grade, 'req_gold')
   
    self.m_needGold = need_gold
    self.m_needExp = need_exp
end

-------------------------------------
-- function isFull
-- @brief 현재 모든 재료를 채웠는지 
-- @return true면 모든 재료를 채웠음
-------------------------------------
function StructUpgradeMaterialCombine:isFull()
    local full_slot_count = self:getRequireCount()
    local b_is_full = (table.count(self.m_mDragonMappingIndex) == full_slot_count)

    return b_is_full
end

-------------------------------------
-- function isEmpty
-- @brief 현재 모든 재료칸이 비워져있는지 
-- @return true면 모든 재료칸이 비워져있음
-------------------------------------
function StructUpgradeMaterialCombine:isEmpty()
    local b_is_empty = (table.count(self.m_mDragonMappingIndex) == 0)

    return b_is_empty
end

-------------------------------------
-- function isEmpty
-- @brief 현재 몇개의 재료칸이 비워져있는지 
-- @return number
-------------------------------------
function StructUpgradeMaterialCombine:getBlankSlotCount()
    local full_slot_count = self:getRequireCount()
    local blank_slot_count = (full_slot_count - table.count(self.m_mDragonMappingIndex))

    return blank_slot_count
end

-------------------------------------
-- function getRuneDataFromIndex
-- @brief 해당 인덱스에 매칭되는 드래곤 정보 반환
-------------------------------------
function StructUpgradeMaterialCombine:getDragonDataFromIndex(idx)
    local t_dragon_data = self.m_mDragonMappingIndex[idx]

    return t_dragon_data
end

-------------------------------------
-- function isDirtyIndex
-- @brief 갱신된 인덱스인지
-------------------------------------
function StructUpgradeMaterialCombine:isDirtyIndex(idx)
    local b_is_dirty_index = (self.m_lDirtyList[idx])

    return b_is_dirty_index
end

-------------------------------------
-- function setDirtyIndex
-- @brief dirty flag 설정
-------------------------------------
function StructUpgradeMaterialCombine:setDirtyIndex(idx, b_is_dirty)
    self.m_lDirtyList[idx] = b_is_dirty
end

-------------------------------------
-- function getDoids
-- @brief 현재 저장하고 있는 룬들의 doid를 문자열로 반환
-------------------------------------
function StructUpgradeMaterialCombine:getDoids()
    local doids = ''

    for idx, dragon_data in pairs(self.m_mDragonMappingIndex) do
        if (doids == '') then
            doids = dragon_data['id']
        else
            doids = doids .. ',' .. dragon_data['id']
        end
    end

    return doids
end

-------------------------------------
-- function getNextIndex
-- @brief 가장 레벨이 높은 재료가 1번 인덱스, 나머지는 순서대로
-------------------------------------
function StructUpgradeMaterialCombine:getNextIndex(t_dragon_data)
    local lv = t_dragon_data['lv']
    local b_is_highest = true

    for doid, data in pairs(self.m_mDragonObjectMap) do
        if (data['lv'] >= lv) then
            b_is_highest = false
            break
        end
    end

    local lowest_index = 1

    if (b_is_highest == false) then
        lowest_index = 2

        while(self.m_mDragonMappingIndex[lowest_index] ~= nil) do
            lowest_index = lowest_index + 1
        end
    end

    return lowest_index
end

-------------------------------------
-- function getRequireCount
-------------------------------------
function StructUpgradeMaterialCombine:getRequireCount()
    local grade = self.m_grade

    return grade + 1
end

