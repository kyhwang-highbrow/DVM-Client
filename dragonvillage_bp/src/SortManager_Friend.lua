local PARENT = SortManager

-------------------------------------
-- class SortManager_Friend
-- @breif 친구 정렬 관리자
-------------------------------------
SortManager_Friend = class(PARENT, {
    m_sortManagerDragon = 'SortManager_Dragon'
})

-------------------------------------
-- function init
-------------------------------------
function SortManager_Friend:init(mode)
    -- 친구 리스트 정렬
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_uid(a, b, ascending) end)
    self:addSortType('level', false, function(a, b, ascending) return self:sort_tamer_level(a, b, ascending) end)
end

-------------------------------------
-- function sort_draon_level
-- @brief 드래곤의 레벨로 정렬
-------------------------------------
function SortManager_Friend:sort_draon_level(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_dragon = a_data.m_leaderDragonObject
    local b_dragon = b_data.m_leaderDragonObject

    -- 레벨 높은 순서
    if (a_dragon['lv'] ~= b_dragon['lv']) then
        return a_dragon['lv'] > b_dragon['lv']

    -- 등급 높은 순서
    elseif (a_dragon['grade'] ~= b_dragon['grade']) then
        return a_dragon['grade'] > b_dragon['grade']

    -- 진화단계 높은 순서
    else
        return a_dragon['evolution'] > b_dragon['evolution']
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_tamer_level
-- @brief 테이머 레벨로 정렬
-------------------------------------
function SortManager_Friend:sort_tamer_level(a, b, ascending)
    local key = 'm_lv'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_used_time
-- @brief 드래곤 사용 시간으로 정렬
-------------------------------------
function SortManager_Friend:sort_used_time(a, b, ascending)
    local key = 'm_usedTime'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_uid
-- @brief 최종 판정
-------------------------------------
function SortManager_Friend:sort_uid(a, b, ascending)
    local key = 'm_uid'
    return self:common_sort(key, a, b, ascending)
end
