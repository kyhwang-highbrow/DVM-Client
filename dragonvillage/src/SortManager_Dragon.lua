local PARENT = SortManager

-------------------------------------
-- class SortManager_Dragon
-- @breif 열매 정렬 관리자
-------------------------------------
SortManager_Dragon = class(PARENT, {
        m_tableDragon = 'TableDragon',

        m_mObjectTypeSortLevel = 'map',
        m_mRaritySortLevel = 'map',
        m_mAttrSortLevel = 'map',
        m_mRoleSortLevel = 'map',
        m_mTypeSortLevel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_Dragon:init()
    self.m_tableDragon = TableDragon()

    -- 오브젝트 타입별 레벨
    self.m_mObjectTypeSortLevel = {}
    self.m_mObjectTypeSortLevel['dragon'] = 100
    self.m_mObjectTypeSortLevel['undering'] = 2
    self.m_mObjectTypeSortLevel['slime'] = 1

    -- 드래곤 타입별 레벨 (한정, 카드팩, 이벤트)
    self.m_mTypeSortLevel = {}
    self.m_mTypeSortLevel['cardpack'] = 1
    self.m_mTypeSortLevel['limited'] = 2
    self.m_mTypeSortLevel['event'] = 3
    self.m_mTypeSortLevel['none'] = 4

    -- 속성별 정렬 레벨
    self.m_mAttrSortLevel = {}
    self.m_mAttrSortLevel[''] = -2
    self.m_mAttrSortLevel['display'] = -1
    self.m_mAttrSortLevel['reset'] = 0
    self.m_mAttrSortLevel['light'] = 1
    self.m_mAttrSortLevel['dark'] = 2
    self.m_mAttrSortLevel['fire'] = 3
    self.m_mAttrSortLevel['water'] = 4
    self.m_mAttrSortLevel['earth'] = 5
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
    
	-- @mskim 보선님 요청으로 삭제
    -- self:addPreSortType('object_type', false, function(a, b, ascending) return self:sort_object_type(a, b, ascending) end)

    self:addSortType('did', false, function(a, b, ascending) return self:sort_did(a, b, ascending) end)
    self:addSortType('combat_power', false, function(a, b, ascending) return self:sort_combat_power(a, b, ascending) end)
    self:addSortType('role', false, function(a, b, ascending) return self:sort_role(a, b, ascending) end)
    self:addSortType('atk', false, function(a, b, ascending) return self:sort_atk(a, b, ascending) end)
    self:addSortType('def', false, function(a, b, ascending) return self:sort_def(a, b, ascending) end)
    self:addSortType('hp', false, function(a, b, ascending) return self:sort_hp(a, b, ascending) end)
    self:addSortType('attr', false, function(a, b, ascending) return self:sort_attr(a, b, ascending) end)
    self:addSortType('friendship', false, function(a, b, ascending) return self:sort_friendship(a, b, ascending) end)
    self:addSortType('rarity', false, function(a, b, ascending) return self:sort_rarity(a, b, ascending) end)
    self:addSortType('grade', false, function(a, b, ascending) return self:sort_grade(a, b, ascending) end)
    self:addSortType('evolution', false, function(a, b, ascending) return self:sort_evolution(a, b, ascending) end)
    self:addSortType('lv', false, function(a, b, ascending) return self:sort_lv(a, b, ascending) end)
    self:addSortType('underling', false, function(a, b, ascending) return self:sort_underling(a, b, ascending) end)
    self:addSortType('created_at', false, function(a, b, ascending) return self:sort_created_at(a, b, ascending) end)

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
T_DRAGON_SORT_TYPE_NAME['created_at'] = Str('획득순')

-------------------------------------
-- function getTopSortingName
-- @brief 최우선의 정렬 타입 리턴
-------------------------------------
function SortManager_Dragon:getTopSortingName()
    local top_sorting_type = self:getTopSortingType()
    return Str(T_DRAGON_SORT_TYPE_NAME[top_sorting_type])
end

-------------------------------------
-- function sort_object_type
-- @brief 오브젝트 타입 (슬라임이 껴있을 수 있음)
-------------------------------------
function SortManager_Dragon:sort_object_type(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = self.m_mObjectTypeSortLevel[a_data.m_objectType]
    local b_value = self.m_mObjectTypeSortLevel[b_data.m_objectType]

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
-- function sort_object_type_book
-- @brief 도감 정렬 조건 추가 - 오브젝트 타입 (슬라임 뒤로)
-------------------------------------
function SortManager_Dragon:sort_object_type_book(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local table_dragon = TableDragon()
    local get_book_type = function(data)
        local did = data['did']
        local book_type = data['bookType']
        if (table_dragon:exists(did) and table_dragon:isUnderling(did)) then
            book_type = 'undering'
        end
        return book_type
    end

    local a_value = self.m_mObjectTypeSortLevel[get_book_type(a_data)]
    local b_value = self.m_mObjectTypeSortLevel[get_book_type(b_data)]

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
-- function sort_combat_power
-- @brief 전투력
-------------------------------------
function SortManager_Dragon:sort_combat_power(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

	-- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData()
    local b_sort_data = b_data:getDragonSortData()

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
-- function sort_role
-- @brief 드래곤 역할
-------------------------------------
function SortManager_Dragon:sort_role(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_role = a_data.getRole and a_data:getRole() or a_data['role']
    local b_role = b_data.getRole and b_data:getRole() or b_data['role']

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

    -- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData()
    local b_sort_data = b_data:getDragonSortData()

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

	-- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData()
    local b_sort_data = b_data:getDragonSortData()

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

	-- sturct 타입의 데이터 아닌 경우에 통과
    if (not a_data.m_objectType) or (not b_data.m_objectType) then
        return nil
    end

    local a_sort_data = a_data:getDragonSortData()
    local b_sort_data = b_data:getDragonSortData()

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

    local a_attr = a_data.getAttr and a_data:getAttr() or a_data['attr']
    local b_attr = b_data.getAttr and b_data:getAttr() or b_data['attr']

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

    local a_value = a_data.getFlv and a_data:getFlv() or a_data['flv']
    local b_value = b_data.getFlv and b_data:getFlv() or b_data['flv']

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

    local a_rarity = a_data.getRarity and a_data:getRarity() or a_data['rarity']
    local b_rarity = a_data.getRarity and b_data:getRarity() or b_data['rarity']

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
-- function sort_evolution
-- @brief 진화도 
-- @comment 디폴트로 push 하지는 않음 .. 
-------------------------------------
function SortManager_Dragon:sort_evolution(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

	local a_value = a_data['evolution']
	local b_value = b_data['evolution']

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
-- function sort_underling
-- @brief 자코 여부.. 는 did를 역으로 활용
-------------------------------------
function SortManager_Dragon:sort_underling(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['did']
    local b_value = b_data['did']

    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value > b_value
    else              return a_value < b_value
    end
end

-------------------------------------
-- function sort_created_at
-- @brief 획득순
-------------------------------------
function SortManager_Dragon:sort_created_at(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['created_at']
    local b_value = b_data['created_at']
    
    -- 같을 경우 리턴
    if (a_value == b_value) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_value < b_value
    else              return a_value > b_value
    end
end

-------------------------------------
-- function sort_with_material
-- @brief 특성 재료를 맨 앞으로 정렬
-------------------------------------
function SortManager_Dragon:sort_with_material(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['did']
    local b_value = b_data['did']

    -- 비교값이 모두 특성재료라면 nil 반환(다음 정렬규칙을 적용)
    if (a_value ~= 'mastery_material') and (b_value ~= 'mastery_material') then
        return nil
    end

    -- 특성 재료라면 속성 특성 재료가 앞으로 오도록 id를 사용한다.
    if (a_value == 'mastery_material') then
        a_value = a_data['item_id']
    end

    if (b_value == 'mastery_material') then
        b_value = b_data['item_id']
    end

    return a_value > b_value
end

-------------------------------------
-- function sort_doid
-- @brief 오브젝트 ID
-------------------------------------
function SortManager_Dragon:sort_doid(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a_data['id'] or 0
    local b_value = b_data['id'] or 0

    -- 최종 정렬 조건으로 사용하기때문에 같은 경우에도 리턴함
    if ascending then
        return a_value < b_value
    else
        return a_value > b_value
    end
end

-------------------------------------
-- function sort_dragon_type
-- @brief 한정, 카드팩, 이벤트 드래곤 순으로 정렬
-------------------------------------
function SortManager_Dragon:sort_dragon_type(a, b, ascending)
    local a_data = a['data']
    local b_data = b['data']

    local a_value = a['data']['category']
    local b_value = b['data']['category']

    local a_order = self.m_mTypeSortLevel[a_value] or 99
    local b_order = self.m_mTypeSortLevel[b_value] or 99

    -- 같을 경우 리턴
    if (a_order == b_order) then return nil end

    -- 오름차순 or 내림차순
    if ascending then return a_order > b_order
    else              return a_order < b_order
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

    elseif (type == 'created_at') then
        str = Str('획득순')

    else
        error('type : ' .. type)
    end

    return str
end