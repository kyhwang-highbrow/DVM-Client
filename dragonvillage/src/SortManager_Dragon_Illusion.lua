local PARENT = SortManager_Dragon

-------------------------------------
-- class SortManager_Dragon_Illusion
-------------------------------------
SortManager_Dragon_Illusion = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Dragon_Illusion:init()
end

-------------------------------------
-- function sort_combat_power
-- @brief 전투력
-------------------------------------
function SortManager_Dragon_Illusion:sort_combat_power(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

	-- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData_Illusion()
    local b_sort_data = b_data:getDragonSortData_Illusion()

    local a_value = a_sort_data['combat_power']
    local b_value = b_sort_data['combat_power']

    -- 같을 경우 리턴
    if (a_value == b_value) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_atk
-- @brief 공격력
-------------------------------------
function SortManager_Dragon_Illusion:sort_atk(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData_Illusion()
    local b_sort_data = b_data:getDragonSortData_Illusion()

    local a_value = a_sort_data['atk']
    local b_value = b_sort_data['atk']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_def
-- @brief 방어력
-------------------------------------
function SortManager_Dragon_Illusion:sort_def(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

	-- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData_Illusion()
    local b_sort_data = b_data:getDragonSortData_Illusion()

    local a_value = a_sort_data['def']
    local b_value = b_sort_data['def']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_hp
-- @brief 체력
-------------------------------------
function SortManager_Dragon_Illusion:sort_hp(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

	-- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData_Illusion()
    local b_sort_data = b_data:getDragonSortData_Illusion()

    local a_value = a_sort_data['hp']
    local b_value = b_sort_data['hp']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end
