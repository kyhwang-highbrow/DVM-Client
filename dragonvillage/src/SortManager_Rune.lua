local PARENT = SortManager

-------------------------------------
-- class SortManager_Rune
-- @breif 룬 정렬 관리자
-------------------------------------
SortManager_Rune = class(PARENT, {
        m_mMoptSortLevel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Rune:init()
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_roid(a, b, ascending) end)
    self:addSortType('rid', false, function(a, b, ascending) return self:sort_rid(a, b, ascending) end)
    self:addSortType('slot', false, function(a, b, ascending) return self:sort_slot(a, b, ascending) end, Str('슬롯'))
    self:addSortType('set_id', false, function(a, b, ascending) return self:sort_set_id(a, b, ascending) end, Str('세트'))
    self:addSortType('grade', false, function(a, b, ascending) return self:sort_grade(a, b, ascending) end, Str('등급'))
    self:addSortType('lv', false, function(a, b, ascending) return self:sort_lv(a, b, ascending) end, Str('레벨'))
    self:addSortType('rarity', false, function(a, b, ascending) return self:sort_rarity(a, b, ascending) end, Str('희귀도'))
	self:addSortType('created_at', false, function(a, b, ascending) return self:sort_created_at(a, b, ascending) end, Str('획득순'))
    self:addSortType('mopt', false, function(a, b, ascending) return self:sort_mopt(a, b, ascending) end, Str('주옵션'))
    self:addSortType('equipped', false, function(a, b, ascending) return self:sort_equipped(a, b, ascending) end, Str('장착'))
    self:addSortType('filter_point', false, function(a, b, ascending) return self:sort_filter_point(a, b, ascending) end, Str('룬점수'))

	self:pushSortOrder('created_at')
	self:pushSortOrder('rarity')
	self:pushSortOrder('lv')
	self:pushSortOrder('grade')
	self:pushSortOrder('set_id')

    -- 주옵션 정렬 레벨
    self.m_mMoptSortLevel = {}
    self.m_mMoptSortLevel[''] = 999
    self.m_mMoptSortLevel['atk_multi'] = 15
    self.m_mMoptSortLevel['atk_add'] = 14
    self.m_mMoptSortLevel['def_multi'] = 13
    self.m_mMoptSortLevel['def_add'] = 12
    self.m_mMoptSortLevel['hp_multi'] = 11
    self.m_mMoptSortLevel['hp_add'] = 10
    self.m_mMoptSortLevel['aspd_multy'] = 9
    self.m_mMoptSortLevel['aspd_add'] = 8
    self.m_mMoptSortLevel['cri_chance_add'] = 7
    self.m_mMoptSortLevel['cri_chance_multi'] = 6
    self.m_mMoptSortLevel['cri_dmg_add'] = 5
    self.m_mMoptSortLevel['cri_dmg_multi'] = 4
    self.m_mMoptSortLevel['accuracy_add'] = 3
    self.m_mMoptSortLevel['resistance_add'] = 2
    self.m_mMoptSortLevel['resistance_multi'] = 1
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

-------------------------------------
-- function sort_created_at
-- @brief 획득순
-------------------------------------
function SortManager_Rune:sort_created_at(a, b, ascending)
    local key = 'created_at'
    return self:common_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_mopt
-- @brief 획득순
-------------------------------------
function SortManager_Rune:sort_mopt(a, b, ascending)
    local key = 'mopt'
    return self:mopt_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_equipped
-- @brief 획득순
-------------------------------------
function SortManager_Rune:sort_equipped(a, b, ascending)
    local key = 'equipped'
    return self:equipped_sort(key, a, b, ascending)
end

-------------------------------------
-- function sort_filter_point
-- @brief 룬 점수
-------------------------------------
function SortManager_Rune:sort_filter_point(a, b, ascending)
    local a_value = a['data'] and a['data']:getRuneFilterPoint() or 0
    local b_value = b['data'] and b['data']:getRuneFilterPoint() or 0

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
-- function mopt_sort
-- @brief 주 옵션 정렬
-------------------------------------
function SortManager:mopt_sort(key, a, b, ascending)
    local a_value = (a['data'] and a['data'][key] or a[key]) or ''
    local b_value = (b['data'] and b['data'][key] or b[key]) or ''

    a_value = self:getMoptPriority(a_value)
    b_value = self:getMoptPriority(b_value)

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
-- function equipped_sort
-- @brief 장착 정렬
-------------------------------------
function SortManager:equipped_sort(key, a, b, ascending)
    local a_value = (a['data'] and a['data']['owner_doid'] and 1) or 0
    local b_value = (b['data'] and b['data']['owner_doid'] and 1) or 0

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
-- function getMoptPriority
-- @brief 주 옵션을 우선순위로 변환, hp_add;34440 -> hp_add -> 1(우선순위 반환)
-------------------------------------
function SortManager:getMoptPriority(mopt_str)
    if (mopt_str == '') then
        return 999
    end

    local l_mopt = pl.stringx.split(mopt_str, ';')

    if (not l_mopt) then
        return 999
    end

    if (#l_mopt<2) then
        return 999
    end

    local mopt = l_mopt[1]
    local mopt_priority = self.m_mMoptSortLevel[mopt]
      
    if (not mopt_priority) then
        return 999
    end

    return mopt_priority
end

