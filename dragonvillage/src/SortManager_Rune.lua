local PARENT = SortManager

-------------------------------------
-- class SortManager_Rune
-- @breif 룬 정렬 관리자
-------------------------------------
SortManager_Rune = class(PARENT, {
        m_tableRune = 'TableRune',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Rune:init()
    self.m_tableRune = TableRune()

    self:addSortType('grade', false, function(a, b, ascending) return self:sort_grade(a, b, ascending) end)
    self:addSortType('set_color', false, function(a, b, ascending) return self:sort_set_color(a, b, ascending) end)
    self:addSortType('lv', false, function(a, b, ascending) return self:sort_lv(a, b, ascending) end)
    self:setDefaultSortFunc(function(a, b, ascending) self:sort_roid(a, b, ascending) end)
end


-------------------------------------
-- function sort_set_color
-- @brief 세트 색상으로 정렬
-------------------------------------
function SortManager_Rune:sort_set_color(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_rid = a_data['rid']
    local b_rid = b_data['rid']
    local t_rune_a = self.m_tableRune:get(a_rid)
    local t_rune_b = self.m_tableRune:get(b_rid)

    -- 세트 색상
    if (t_rune_a['set_color'] == t_rune_b['set_color']) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return t_rune_a['set_color'] < t_rune_b['set_color']
    else
        return t_rune_a['set_color'] > t_rune_b['set_color']
    end
end

-------------------------------------
-- function sort_grade
-- @brief 등급 으로 정렬
-------------------------------------
function SortManager_Rune:sort_grade(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- 등급
    if (a_data['grade'] == b_data['grade']) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_data['grade'] < b_data['grade']
    else
        return a_data['grade'] > b_data['grade']
    end
end

-------------------------------------
-- function sort_lv
-- @brief 레벨 으로 정렬
-------------------------------------
function SortManager_Rune:sort_lv(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- 등급
    if (a_data['lv'] == b_data['lv']) then
        return nil
    end

    -- 오름차순 or 내림차순
    if ascending then
        return a_data['lv'] < b_data['lv']
    else
        return a_data['lv'] > b_data['lv']
    end
end

-------------------------------------
-- function sort_roid
-- @brief 오브젝트 ID로 정렬
-------------------------------------
function SortManager_Rune:sort_roid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_data['id'] < b_data['id']
    else
        return a_data['id'] > b_data['id']
    end
end