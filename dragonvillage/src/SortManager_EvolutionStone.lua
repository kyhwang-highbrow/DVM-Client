local PARENT = SortManager

-------------------------------------
-- class SortManager_EvolutionStone
-- @breif 열매 정렬 관리자
-------------------------------------
SortManager_EvolutionStone = class(PARENT, {
        m_tableItem = 'TableItem',

        m_mRoleSortLevel = 'map',
        m_mAttrSortLevel = 'map',
        m_mRaritySortLevel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_EvolutionStone:init()
    self.m_tableItem = TableItem()

    -- 역할별 정렬 레벨
    self.m_mRoleSortLevel = {}
    self.m_mRoleSortLevel['tanker'] = 4
    self.m_mRoleSortLevel['dealer'] = 3
    self.m_mRoleSortLevel['supporter'] = 2
    self.m_mRoleSortLevel['healer'] = 1
    self.m_mRoleSortLevel[''] = -1

    -- 속성별 정렬 레벨
    self.m_mAttrSortLevel = {}
    self.m_mAttrSortLevel[''] = -2
    self.m_mAttrSortLevel['display'] = -1
    self.m_mAttrSortLevel['reset'] = 0
    self.m_mAttrSortLevel['dark'] = 1
    self.m_mAttrSortLevel['light'] = 2
    self.m_mAttrSortLevel['fire'] = 3
    self.m_mAttrSortLevel['water'] = 4
    self.m_mAttrSortLevel['earth'] = 5
    self.m_mAttrSortLevel['global'] = 6
    self.m_mAttrSortLevel['all'] = 7

    -- 희귀도별 정렬 레벨
    self.m_mRaritySortLevel = {}
    self.m_mRaritySortLevel[''] = -1
    self.m_mRaritySortLevel['common'] = 1
    self.m_mRaritySortLevel['rare'] = 2
    self.m_mRaritySortLevel['hero'] = 3
    self.m_mRaritySortLevel['legend'] = 4

    self:addSortType('grade', false, function(a, b, ascending) return self:sort_grade(a, b, ascending) end)
    self:addSortType('attr', false, function(a, b, ascending) return self:sort_attr(a, b, ascending) end)
    self:addSortType('role', false, function(a, b, ascending) return self:sort_role(a, b, ascending) end)
    self:addSortType('rarity', false, function(a, b, ascending) return self:sort_rarity(a, b, ascending) end)
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_esid(a, b, ascending) end)
end

-------------------------------------
-- function sort_rarity
-- @brief 희귀도
-------------------------------------
function SortManager_EvolutionStone:sort_rarity(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['esid'])
    local b_item = self.m_tableItem:get(b_data['esid'])

    local a_value = a_item['rarity']
    local b_value = b_item['rarity']

    a_value = self.m_mRaritySortLevel[a_value]
    b_value = self.m_mRaritySortLevel[b_value]

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
-- function sort_role
-- @brief 역할
-------------------------------------
function SortManager_EvolutionStone:sort_role(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['esid'])
    local b_item = self.m_tableItem:get(b_data['esid'])

    local a_value = a_item['role']
    local b_value = b_item['role']

    a_value = self.m_mRoleSortLevel[a_value]
    b_value = self.m_mRoleSortLevel[b_value]

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
-- function sort_attr
-- @brief 속성
-------------------------------------
function SortManager_EvolutionStone:sort_attr(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['esid'])
    local b_item = self.m_tableItem:get(b_data['esid'])

    local a_value = a_item['attr']
    local b_value = b_item['attr']

    a_value = self.m_mAttrSortLevel[a_value]
    b_value = self.m_mAttrSortLevel[b_value]

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
-- function sort_grade
-- @brief 등급
-------------------------------------
function SortManager_EvolutionStone:sort_grade(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_item = self.m_tableItem:get(a_data['esid'])
    local b_item = self.m_tableItem:get(b_data['esid'])

    local a_value = a_item['grade']
    local b_value = b_item['grade']

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
-- function sort_esid
-- @brief ID
-------------------------------------
function SortManager_EvolutionStone:sort_esid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_data['esid'] < b_data['esid']
    else
        return a_data['esid'] > b_data['esid']
    end
end