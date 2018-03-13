local PARENT = SortManager

-------------------------------------
-- class SortManager_ClanRequest
-- @breif 클랜 가입 신청자 정렬
-------------------------------------
SortManager_ClanRequest = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_ClanRequest:init()
    self:addSortType('active_time', false, function(a, b, ascending) return self:sort_active_time(a, b, ascending) end)
    self:addSortType('level', false, function(a, b, ascending) return self:sort_level(a, b, ascending) end)

    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_uid(a, b, ascending) end)
end

-------------------------------------
-- function sort_level
-- @brief 레벨
-------------------------------------
function SortManager_ClanRequest:sort_level(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getLv()
    local b_value = b_data:getLv()

    if (a_value == b_value) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_active_time
-- @brief 마지막 활동 시간
-------------------------------------
function SortManager_ClanRequest:sort_active_time(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getLastActiveTime()
    local b_value = b_data:getLastActiveTime()

    if (a_value == b_value) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_uid
-- @brief uid로 정렬
-------------------------------------
function SortManager_ClanRequest:sort_uid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getUid()
    local b_value = b_data:getUid()

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end