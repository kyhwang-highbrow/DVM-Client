local PARENT = SortManager

-------------------------------------
-- class SortManager_Dragon
-- @breif 열매 정렬 관리자
-------------------------------------
SortManager_Dragon = class(PARENT, {
        m_tableDragon = 'TableDragon',

        m_mRaritySortLevel = 'map',
        m_mAttrSortLevel = 'map',
        m_mRoleSortLevel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Dragon:init()
    self.m_tableDragon = TableDragon()

    -- 속성별 정렬 레벨
    self.m_mAttrSortLevel = {}
    self.m_mAttrSortLevel[''] = -2
    self.m_mAttrSortLevel['display'] = -1
    self.m_mAttrSortLevel['reset'] = 0
    self.m_mAttrSortLevel['light'] = 1
    self.m_mAttrSortLevel['dark'] = 2
    self.m_mAttrSortLevel['earth'] = 3
    self.m_mAttrSortLevel['water'] = 4
    self.m_mAttrSortLevel['fire'] = 5
    self.m_mAttrSortLevel['global'] = 6

    -- 희귀도별 정렬 레벨
    self.m_mRaritySortLevel = {}
    self.m_mRaritySortLevel[''] = -1
    self.m_mRaritySortLevel['common'] = 1
    self.m_mRaritySortLevel['rare'] = 2
    self.m_mRaritySortLevel['hero'] = 3
    self.m_mRaritySortLevel['legend'] = 4

    -- 역할 정렬 레벨
    self.m_mRoleSortLevel = {}
    self.m_mRoleSortLevel[''] = -1
    self.m_mRoleSortLevel['healer'] = 1
    self.m_mRoleSortLevel['supporter'] = 2
    self.m_mRoleSortLevel['dealer'] = 3
    self.m_mRoleSortLevel['tanker'] = 4
    

    self:addSortType('did', false, function(a, b, ascending) return self:sort_did(a, b, ascending) end)
    self:addSortType('role', false, function(a, b, ascending) return self:sort_role(a, b, ascending) end)
    self:addSortType('atk', false, function(a, b, ascending) return self:sort_atk(a, b, ascending) end)
    self:addSortType('def', false, function(a, b, ascending) return self:sort_def(a, b, ascending) end)
    self:addSortType('hp', false, function(a, b, ascending) return self:sort_hp(a, b, ascending) end)
    self:addSortType('attr', false, function(a, b, ascending) return self:sort_attr(a, b, ascending) end)
    self:addSortType('friendship', false, function(a, b, ascending) return self:sort_friendship(a, b, ascending) end)
    self:addSortType('rarity', false, function(a, b, ascending) return self:sort_rarity(a, b, ascending) end)
    self:addSortType('grade', false, function(a, b, ascending) return self:sort_grade(a, b, ascending) end)
    self:addSortType('lv', false, function(a, b, ascending) return self:sort_lv(a, b, ascending) end)
    self:setDefaultSortFunc(function(a, b, ascending) return self:sort_doid(a, b, ascending) end)
end

local T_DRAGON_SORT_TYPE_NAME = {}
T_DRAGON_SORT_TYPE_NAME['did'] = Str('종류')
T_DRAGON_SORT_TYPE_NAME['role'] = Str('역할')
T_DRAGON_SORT_TYPE_NAME['atk'] = Str('공격력')
T_DRAGON_SORT_TYPE_NAME['def'] = Str('방어력')
T_DRAGON_SORT_TYPE_NAME['hp'] = Str('체력')
T_DRAGON_SORT_TYPE_NAME['attr'] = Str('속성')
T_DRAGON_SORT_TYPE_NAME['friendship'] = Str('친밀도')
T_DRAGON_SORT_TYPE_NAME['rarity'] = Str('희귀도')
T_DRAGON_SORT_TYPE_NAME['grade'] = Str('등급')
T_DRAGON_SORT_TYPE_NAME['lv'] = Str('레벨')

-------------------------------------
-- function getTopSortingName
-- @brief 최우선의 정렬 타입 리턴
-------------------------------------
function SortManager_Dragon:getTopSortingName()
    local top_sorting_type = self:getTopSortingType()
    return T_DRAGON_SORT_TYPE_NAME[top_sorting_type]
end

-------------------------------------
-- function sort_did
-- @brief 드래곤 ID
-------------------------------------
function SortManager_Dragon:sort_did(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['did']
    local b_value = b_data['did']

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
-- function sort_role
-- @brief 드래곤 역할
-------------------------------------
function SortManager_Dragon:sort_role(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_role = self.m_tableDragon:getValue(a_data['did'], 'role')
    local b_role = self.m_tableDragon:getValue(b_data['did'], 'role')

    local a_value = self.m_mRoleSortLevel[a_role]
    local b_value = self.m_mRoleSortLevel[b_role]

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_atk
-- @brief 공격력
-------------------------------------
function SortManager_Dragon:sort_atk(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_sort_data = g_dragonsData:getDragonsSortData(a_data['id'])
    local b_sort_data = g_dragonsData:getDragonsSortData(b_data['id'])

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
function SortManager_Dragon:sort_def(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_sort_data = g_dragonsData:getDragonsSortData(a_data['id'])
    local b_sort_data = g_dragonsData:getDragonsSortData(b_data['id'])

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
function SortManager_Dragon:sort_hp(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_sort_data = g_dragonsData:getDragonsSortData(a_data['id'])
    local b_sort_data = g_dragonsData:getDragonsSortData(b_data['id'])

    local a_value = a_sort_data['hp']
    local b_value = b_sort_data['hp']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_attr
-- @brief 속성
-------------------------------------
function SortManager_Dragon:sort_attr(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_attr = self.m_tableDragon:getValue(a_data['did'], 'attr')
    local b_attr = self.m_tableDragon:getValue(b_data['did'], 'attr')

    local a_value = self.m_mAttrSortLevel[a_attr]
    local b_value = self.m_mAttrSortLevel[b_attr]

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_friendship
-- @brief 친밀도
-------------------------------------
function SortManager_Dragon:sort_friendship(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data:getFlv()
    local b_value = b_data:getFlv()

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_rarity
-- @brief 희귀도
-------------------------------------
function SortManager_Dragon:sort_rarity(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_rarity = self.m_tableDragon:getValue(a_data['did'], 'rarity')
    local b_rarity = self.m_tableDragon:getValue(b_data['did'], 'rarity')

    local a_value = self.m_mRaritySortLevel[a_rarity]
    local b_value = self.m_mRaritySortLevel[b_rarity]

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_grade
-- @brief 등급
-------------------------------------
function SortManager_Dragon:sort_grade(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['grade']
    local b_value = b_data['grade']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_lv
-- @brief 레벨
-------------------------------------
function SortManager_Dragon:sort_lv(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['lv']
    local b_value = b_data['lv']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_doid
-- @brief 열매 ID
-------------------------------------
function SortManager_Dragon:sort_doid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['id']
    local b_value = b_data['id']

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function getSortName
-- @brief
-------------------------------------
function SortManager_Dragon:getSortName(type)
    local str = ''
    if (type == 'hp') then
        str = Str('체력')

    elseif (type == 'def') then
        str = Str('방어력')

    elseif (type == 'atk') then
        str = Str('공격력')

    elseif (type == 'attr') then
        str = Str('속성')

    elseif (type == 'lv') then
        str = Str('레벨')

    elseif (type == 'grade') then
        str = Str('등급')

    elseif (type == 'rarity') then
        str = Str('희귀도')

    elseif (type == 'friendship') then
        str = Str('친밀도')

    else
        error('type : ' .. type)
    end

    return str
end