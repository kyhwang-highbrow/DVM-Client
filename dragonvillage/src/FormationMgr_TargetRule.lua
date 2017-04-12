-- FormationMgr_TargetRule

-- target_team
-- target_formation
-- target_rule

-------------------------------------
-- function sortAscending
-------------------------------------
local function sortAscending(a, b)
    if (a.m_sortValue == b.m_sortValue) then
        if (not a.m_sortRandomIdx) then
            a.m_sortRandomIdx = math_random(1, 100)
        end

        if (not b.m_sortRandomIdx) then
            b.m_sortRandomIdx = math_random(1, 100)
        end

        return (a.m_sortRandomIdx < b.m_sortRandomIdx)
    else
        return (a.m_sortValue < b.m_sortValue)
    end
end

-------------------------------------
-- function sortDescending
-------------------------------------
local function sortDescending(a, b)
    if (a.m_sortValue == b.m_sortValue) then
        if (not a.m_sortRandomIdx) then
            a.m_sortRandomIdx = math_random(1, 100)
        end

        if (not b.m_sortRandomIdx) then
            b.m_sortRandomIdx = math_random(1, 100)
        end

        return (a.m_sortRandomIdx > b.m_sortRandomIdx)
    else
        return (a.m_sortValue > b.m_sortValue)
    end
end



-------------------------------------
-- function TargetRule_getTargetList
-------------------------------------
function TargetRule_getTargetList(type, org_list, x, y, t_data)
    -- 모든 대상
    if (type == 'none') then                return TargetRule_getTargetList_none(org_list)
    elseif (type == 'random') then          return TargetRule_getTargetList_random(org_list)
    
	-- 거리 관련
	elseif (type == 'distance_line') then   return TargetRule_getTargetList_distance_line(org_list, x, y)
	elseif (type == 'far_line') then		return TargetRule_getTargetList_far_line(org_list, x, y)
    elseif (type == 'distance_x') then      return TargetRule_getTargetList_distance_x(org_list, x)
    elseif (type == 'distance_y') then      return TargetRule_getTargetList_distance_y(org_list, y)
    
	-- 스탯 관련
	elseif string.find(type, 'def') or string.find(type, 'atk') or string.find(type, 'hp') then
		return TargetRule_getTargetList_stat(org_list, type)

	-- 속성 관련
	elseif isExistValue(type, 'earth', 'water', 'fire', 'light', 'dark') then
		return TargetRule_getTargetList_attr(org_list, type)

	-- 직군 관련
	elseif isExistValue(type, 'tanker', 'dealer', 'supporter', 'healer') then
		return TargetRule_getTargetList_role(org_list, type)

	-- 상태효과 관련
	elseif string.find(type, 'status') then
		return TargetRule_getTargetList_status_effect(org_list, type)
	elseif (type == 'buff') then		
		return TargetRule_getTargetList_buff(org_list)
	elseif (type == 'debuff') then		
		return TargetRule_getTargetList_debuff(org_list)

	-- 특수
    --elseif (type == 'fan_shape') then       return TargetRule_getTargetList_fan_shape(org_list, t_data)
	--elseif (type == 'rectangle') then		return TargetRule_getTargetList_rectangle(org_list, t_data)

	--[[ 미사용
	elseif (type == 'cp_low') then          return TargetRule_getTargetList_cp_low(org_list)
	elseif (type == 'cp_high') then         return TargetRule_getTargetList_cp_high(org_list)
	elseif (type == 'physical_char') then      return TargetRule_getTargetList_charType(org_list, 'physical')
	elseif (type == 'magical_char') then      return TargetRule_getTargetList_charType(org_list, 'magical')
	elseif (type == 'front_line') then      return TargetRule_getTargetList_row(FORMATION_FRONT)
	]]

	else
        error("미구현 Target Rule!! : " .. type)
    end

end


-------------------------------------
-- function TargetRule_getTargetList_none
-- @brief 모든 대상
-------------------------------------
function TargetRule_getTargetList_none(org_list)
    local t_ret = {}

    for i,v in pairs(org_list) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_distance_line
-- @brief 직선거리 가까운 대상
-------------------------------------
function TargetRule_getTargetList_distance_line(org_list, x, y)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = getDistance(x, y, v.pos.x, v.pos.y)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_far_line
-- @brief 직선거리 먼 대상
-------------------------------------
function TargetRule_getTargetList_far_line(org_list, x, y)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = getDistance(x, y, v.pos.x, v.pos.y)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortDescending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_distance_x
-- @brief x축 가까운 대상
-------------------------------------
function TargetRule_getTargetList_distance_x(org_list, x)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = math_abs(x - v.pos.x)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_distance_y
-- @brief y축 가까운 대상
-------------------------------------
function TargetRule_getTargetList_distance_y(org_list, y)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = math_abs(y - v.pos.y)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end


-------------------------------------
-- function TargetRule_getTargetList_random
-- @brief 랜덤
-------------------------------------
function TargetRule_getTargetList_random(org_list)
    local t_ret = {}
    local t_random = {}

    for i,v in pairs(org_list) do
        table.insert(t_random, i)
    end

    while (0 < #t_random) do
        local rand_num = math_random(1, #t_random)
        local rand_idx = t_random[rand_num]
        table.insert(t_ret, org_list[rand_idx])
        table.remove(t_random, rand_num)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_stat
-- @brief 특정 스탯에 따른 구분
-- @param org_list : 전체 타겟 리스트
-- @param stat_type : stat명_높낮이
-------------------------------------
function TargetRule_getTargetList_stat(org_list, stat_type)
	local t_ret = org_list or {}

	local temp = seperate(stat_type, '_')
	local target_stat = temp[1]
	local is_descending = (temp[2] == 'high')
	
	-- 별도 로직이 필요한 정렬
	if (target_stat == 'hp') then
		table.sort(t_ret, function(a, b)
			local a_stat = a.m_hp / a.m_maxHp
			local b_stat = b.m_hp / b.m_maxHp
			if (is_descending) then
				return a_stat > b_stat
			else
				return a_stat < b_stat
			end
		end)

	-- status Calculator를 통해 가져올수 있는 stat
	else
		table.sort(t_ret, function(a, b)
			local a_stat = a:getStat(target_stat)
			local b_stat = b:getStat(target_stat)
			if (is_descending) then
				return a_stat > b_stat
			else
				return a_stat < b_stat
			end
		end)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_role
-- @brief 해당 직업군의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_role(org_list, role)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}

	-- 직업군이 같은 아이들을 추출한다
	for i, character in pairs(t_char) do
		if (character:getRole() == role) then
			table.insert(t_ret, character)
			table.remove(t_char, i)
		end
	end

	-- 남은 애들도 다시 담는다.
	for i, char in pairs(t_char) do
		table.insert(t_ret, char)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_attr
-- @brief 해당 속성의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_attr(org_list, attr)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}

	-- 속성이 같은 아이들을 추출한다
	for i, character in pairs(t_char) do
		if (character:getAttribute() == attr) then
			table.insert(t_ret, character)
			table.remove(t_char, i)
		end
	end

	-- 남은 애들도 다시 담는다.
	for i, char in pairs(t_char) do
		table.insert(t_ret, char)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_status_effect
-- @brief 특정 상태효과에 따른 구분
-- @param org_list : 전체 타겟 리스트
-- @param status_effect_type : status_상태효과
-------------------------------------
function TargetRule_getTargetList_status_effect(org_list, raw_str)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}

	local temp = seperate(raw_str, '_') or {}
	local status_effect_name = temp[2]

	-- 상태효과가 있다면 새로운 테이블로 옮긴다. 차곡차곡
	for i, char in pairs(t_char) do
		for name, status_effect in pairs(char:getStatusEffectList()) do
			if (status_effect_name == name) then
				table.insert(t_ret, char)
				table.remove(t_char, i)
				break
			end
		end
	end

	-- 남은 애들도 다시 담는다.
	for i, char in pairs(t_char) do
		table.insert(t_ret, char)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_buff 
-- @brief 특정 상태효과에 따른 구분
-------------------------------------
function TargetRule_getTargetList_buff(org_list)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}

	-- 버프
	for i, char in pairs(t_char) do
		if (char:hasHelpfulStatusEffect()) then
			table.insert(t_ret, char)
			table.remove(t_char, i)
		end
	end

	-- 남은 애들도 다시 담는다.
	for i, char in pairs(t_char) do
		table.insert(t_ret, char)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_debuff 
-- @brief 특정 상태효과에 따른 구분
-------------------------------------
function TargetRule_getTargetList_debuff(org_list)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}

	-- 버프
	for i, char in pairs(t_char) do
		if (char:hasHarmfulStatusEffect()) then
			table.insert(t_ret, char)
			table.remove(t_char, i)
		end
	end

	-- 남은 애들도 다시 담는다.
	for i, char in pairs(t_char) do
		table.insert(t_ret, char)
	end

    return t_ret
end

------------------------------------- 미사용 -------------------------------------

-------------------------------------
-- function TargetRule_getTargetList_row
-- @brief 해당 열의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_row(formation_type)
    local t_ret = {}

    for i,v in pairs(org_list) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_charType
-- @brief 해당 공격 속성의 리스트 반환 (마법, 물리)
-------------------------------------
function TargetRule_getTargetList_charType(org_list, char_type)
    local t_ret = {}

	for i, character in pairs(org_list) do
		if (character:getCharAttackAttr() == char_type) then
			table.insert(t_ret, character)
		end
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_hp_low
-- @brief 낮은 HP%
-------------------------------------
function TargetRule_getTargetList_hp_low(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = (v.m_hp / v.m_maxHp)
        v.m_sortRandomIdx = v.m_hp
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_hp_high
-- @brief 높은 HP%
-------------------------------------
function TargetRule_getTargetList_hp_high(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = (v.m_hp / v.m_maxHp)
        v.m_sortRandomIdx = v.m_hp
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortDescending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_cp_low
-- @brief 낮은 CP%
-------------------------------------
function TargetRule_getTargetList_cp_low(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        if v.m_chargeSkill then
            v.m_sortValue = v.m_chargeSkill.m_gauge
        else
            v.m_sortValue = 0
        end
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_cp_high
-- @brief 높은 CP%
-------------------------------------
function TargetRule_getTargetList_cp_high(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        if v.m_chargeSkill then
            v.m_sortValue = v.m_chargeSkill.m_gauge
        else
            v.m_sortValue = 0
        end
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortDescending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end