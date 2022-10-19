local PARENT = TableClass

-------------------------------------
---@class TableDragonTransform
---@return TableDragonTransform
-------------------------------------
TableDragonTransform = class(PARENT, {
    })

-- 외형 변환 가능한 진화 단계
POSSIBLE_TRANSFORM_CHANGE_EVO = 3

-------------------------------------
-- function init
-------------------------------------
function TableDragonTransform:init()
    self.m_tableName = 'table_dragon_transform'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getMaterialInfoByDragon
-- @brief 해당 드래곤의 외형 변환 재료 반환
--[[
    ['material_1']={
            ['item_id']=705012,
            ['cnt']=10
    },
    ['material_4']={
            ['item_id']=705042,
            ['cnt']=25
    },
    ['material_2']={
            ['item_id']=705022,
            ['cnt']=15
    },
    ['material_3']={
            ['item_id']=705032,
            ['cnt']=20
    },
    ['gold']=1250000,
    ['d_grade']=5,
--]]
-------------------------------------
function TableDragonTransform:getMaterialInfoByDragon(struct_dragon_data)
    local map_material = {}
    if (not struct_dragon_data) then
        return map_material
    end

    local t_dragon = TableDragon()
    local did = struct_dragon_data['did']
    local birth_grade = t_dragon:getBirthGrade(did)

    -- 태생등급에 따라 재료가 다름
    local t_transform = self:get(birth_grade)

    local base_item_id = 705000

    -- 10의 자리 : materail 등급, 1의 자리 : 속성
    local attr_num = did % 10
    for k, v in pairs(t_transform) do
        local data
        if string.find(k, 'material') then
            local mtr_num = string.gsub(k, 'material_', '')
            local item_id = base_item_id + (tonumber(mtr_num) * 10) + (tonumber(attr_num))
            data = { item_id = item_id, cnt = v }
        else
            data = v
        end

        map_material[k] = data
    end

    return map_material
end

-------------------------------------
-- function getPrice
-- @brief 해당 드래곤의 외형 변환 소모 골드 반환
-------------------------------------
function TableDragonTransform:getPrice(struct_dragon_data)
    if (not struct_dragon_data) then
        return nil
    end

    local t_dragon = TableDragon()
    local did = struct_dragon_data['did']
    local birth_grade = t_dragon:getBirthGrade(did)

    -- 태생등급에 따라 재료가 다름
    local t_transform = self:get(birth_grade)
    local gold = t_transform['gold']
    return gold
end