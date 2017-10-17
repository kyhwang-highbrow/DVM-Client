local PARENT = SortManager

-------------------------------------
-- class SortManager_Rune
-- @breif 룬 정렬 관리자
-------------------------------------
SortManager_Rune = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Rune:init()
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_roid(a, b, ascending) end)
    self:addSortType('rid', false, function(a, b, ascending) return self:sort_rid(a, b, ascending) end)
    self:addSortType('slot', false, function(a, b, ascending) return self:sort_slot(a, b, ascending) end, Str('슬롯'))
    self:addSortType('set_id', false, function(a, b, ascending) return self:sort_set_id(a, b, ascending) end, Str('세트'))
    self:addSortType('lv', false, function(a, b, ascending) return self:sort_lv(a, b, ascending) end, Str('레벨'))
    self:addSortType('rarity', false, function(a, b, ascending) return self:sort_rarity(a, b, ascending) end, Str('희귀도'))
    self:addSortType('grade', false, function(a, b, ascending) return self:sort_grade(a, b, ascending) end, Str('등급'))
end


-------------------------------------
-- function sort_grade
-- @brief 등급 으로 정렬
-------------------------------------
function SortManager_Rune:sort_grade(a, b, ascending)
    local key = 'grade'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_lv
-- @brief 레벨 으로 정렬
-------------------------------------
function SortManager_Rune:sort_lv(a, b, ascending)
    local key = 'lv'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_roid
-- @brief 오브젝트 ID로 정렬
-------------------------------------
function SortManager_Rune:sort_roid(a, b, ascending)
    local key = 'roid'
    return self:common_default_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_rarity
-- @brief 레이러티 정렬
-------------------------------------
function SortManager_Rune:sort_rarity(a, b, ascending)
    local key = 'rarity'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_set_id
-- @brief 세트
-------------------------------------
function SortManager_Rune:sort_set_id(a, b, ascending)
    local key = 'set_id'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_slot
-- @brief 슬롯
-------------------------------------
function SortManager_Rune:sort_slot(a, b, ascending)
    local key = 'slot'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_rid
-- @brief
-------------------------------------
function SortManager_Rune:sort_rid(a, b, ascending)
    local key = 'rid'
    return self:common_sort(key, a, b, ascending)
end