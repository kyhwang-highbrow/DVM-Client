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
-- @param type : target_rule( ex) 'enemy_status_atk_down' -> 'status_atk_down' )
-------------------------------------
function TargetRule_getTargetList(type, org_list, x, y, t_data)
    -- 모든 대상
    if (type == 'none') then                return TargetRule_getTargetList_none(org_list)
    elseif (type == 'random') then          return TargetRule_getTargetList_random(org_list)
    
    elseif (type == 'last_attack') then     return TargetRule_getTargetList_lastAttack(org_list, t_data)
    elseif (type == 'last_under_atk') then  return TargetRule_getTargetList_lastUnderAtk(org_list, t_data)
	-- self 
	elseif (type == 'self') then			return TargetRule_getTargetList_self(org_list, t_data)

	-- 거리 관련
	elseif (type == 'distance_line') then   return TargetRule_getTargetList_distance_line(org_list, x, y)
	elseif (type == 'far_line') then		return TargetRule_getTargetList_far_line(org_list, x, y)
    elseif (type == 'distance_x') then      return TargetRule_getTargetList_distance_x(org_list, x)
    elseif (type == 'distance_y') then      return TargetRule_getTargetList_distance_y(org_list, y)

    -- 상태효과 관련
	elseif pl.stringx.startswith(type, 'status') then
		return TargetRule_getTargetList_status_effect(org_list, type)
    
	-- 스탯 관련
    elseif pl.stringx.startswith(type, 'def') or pl.stringx.startswith(type, 'atk') or pl.stringx.startswith(type, 'hp') or
           pl.stringx.startswith(type, 'aspd') or pl.stringx.startswith(type, 'avoid') or pl.stringx.startswith(type, 'cri') or
           pl.stringx.startswith(type, 'hit_rate') then
		return TargetRule_getTargetList_stat(org_list, type)

	-- 속성 관련
	elseif pl.stringx.startswith(type, 'earth') or pl.stringx.startswith(type, 'water') or pl.stringx.startswith(type, 'fire') or
           pl.stringx.startswith(type, 'light') or pl.stringx.startswith(type, 'dark') then
		return TargetRule_getTargetList_attr(org_list, type)

	-- 직군 관련
	elseif pl.stringx.startswith(type, 'tanker') or pl.stringx.startswith(type, 'dealer') or
           pl.stringx.startswith(type, 'supporter') or pl.stringx.startswith(type, 'healer') then
		return TargetRule_getTargetList_role(org_list, type)

	elseif (type == 'buff') then
		return TargetRule_getTargetList_buff(org_list)

	elseif (pl.stringx.startswith(type, 'debuff')) then		
		local t_debuff, t_not_debuff =  TargetRule_getTargetList_debuff(org_list, type)
        if (pl.stringx.startswith(type, 'debuff_not')) then
            return t_not_debuff
        else
            return t_debuff
        end

    elseif (type == 'front') then
		return TargetRule_getTargetList_front(org_list)

    elseif (type == 'back') then
		return TargetRule_getTargetList_back(org_list)

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
-- function TargetRule_getTargetList_none
-- @brief 자기 자신이 1번인 아군 리스트
-------------------------------------
function TargetRule_getTargetList_self(org_list, t_data)
    local t_ret = {}
	local self_char = t_data['self']
	local t_char = table.sortRandom(table.clone(org_list))
	
	-- 자기 자신을 제일 먼저 넣는다.
	table.insert(t_ret, self_char)

    for i, char in pairs(t_char) do
		if (char ~= self_char) then
			table.insert(t_ret, char)
		end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_lastAttack
-- @brief 일반 공격의 타겟이 우선인 적군 리스트
-------------------------------------
function TargetRule_getTargetList_lastAttack(org_list, t_data)
    local t_ret = {}
    local last_attack_char = t_data['defender']
    local t_char = table.sortRandom(table.clone(org_list))

    table.insert(t_ret, last_attack_char)

    for i, char in pairs(t_char) do
        if (char ~= last_attack_char) then
            table.insert(t_ret, char)
        end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_lastUnderAtk
-- @brief 공격자 우선인 적군 리스트
-------------------------------------
function TargetRule_getTargetList_lastUnderAtk(org_list, t_data)
    local t_ret = {}
    local last_under_atk_char = t_data['attacker']
    local t_char = table.sortRandom(table.clone(org_list))

    table.insert(t_ret, last_under_atk_char)

    for i, char in pairs(t_char) do
        if (char ~= last_under_atk_char) then
            table.insert(t_ret, char)
        end
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
        local v_x, v_y = v:getPosForFormation()
        v.m_sortValue = getDistance(x, y, v_x, v_y)
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
        local v_x, v_y = v:getPosForFormation()
        v.m_sortValue = getDistance(x, y, v_x, v_y)
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
        local v_x, v_y = v:getPosForFormation()
        v.m_sortValue = math_abs(x - v_x)
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

    if (not org_list or #org_list == 0) then
        return t_ret
    end

    for i, v in ipairs(org_list) do
        table.insert(t_random, i)
    end

    t_random = randomShuffle(t_random)

    for i, v in ipairs(t_random) do
        table.insert(t_ret, org_list[v])
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
    for i = 2, (#temp - 1) do
        target_stat = target_stat .. '_' .. temp[i]
    end
	local is_descending = (temp[#temp] == 'high')

	-- 별도 로직이 필요한 정렬
	if (target_stat == 'hp') then
		table.sort(t_ret, function(a, b)
			local a_stat = a:getHpRate()
			local b_stat = b:getHpRate()
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
function TargetRule_getTargetList_role(org_list, keyword)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}

	-- 직업군이 같은 아이들을 추출한다
    for i = #t_char, 1, -1 do
		if (string.find(keyword, t_char[i]:getRole())) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
		end
	end
    
    if(not pl.stringx.endswith(keyword, 'only')) then
	    -- 남은 애들도 다시 담는다.
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_attr
-- @brief 해당 속성의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_attr(org_list, keyword)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}
    
	-- 속성이 같은 아이들을 추출한다.
    -- index를 검사하는 와중에 remove를 하면 table의 전체 index가 바뀌기 때문에, 테이블 index를 역순으로 검사하여 
    -- 모든 구성요소들이 검사될 수 있도록 한다.
    for i = #t_char, 1, -1 do
		if (string.find(keyword, t_char[i]:getAttribute())) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
    	end
	end
    
    if (not pl.stringx.endswith(keyword, 'only')) then
	    -- 남은 애들도 다시 담는다.
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
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

	local temp = seperate(raw_str, '_')
    local status_effect_name = temp[2]
    if(#temp > 2) then
        for i = 3, (#temp - 1) do
           status_effect_name = status_effect_name .. '_' .. temp[i]
        end
    end
	-- 상태효과가 있다면 새로운 테이블로 옮긴다. 차곡차곡
    for i = #t_char, 1, -1 do
        if (t_char[i]:isExistStatusEffectName(status_effect_name)) then
            table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
        end
    end
    
    if (not pl.stringx.endswith(raw_str, 'only')) then
	-- 남은 애들도 다시 담는다.
        for i, char in pairs(t_char) do
	        table.insert(t_ret, char)
        end
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
    for i = #t_char, 1, -1 do
		if (t_char[i]:hasHelpfulStatusEffect()) then
			table.insert(t_ret, t_char[i])
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
function TargetRule_getTargetList_debuff(org_list, keyword)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}
    local t_ret_not_harmful = {}
	-- 버프
    for i = #t_char, 1, -1 do
		if (t_char[i]:hasHarmfulStatusEffect()) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
		else 
            table.insert(t_ret_not_harmful, t_char[i])
        end
	end

    if (not pl.stringx.endswith(keyword, 'only')) then
        -- 남은 애들도 다시 담는다. (남은 애들 = 디버프 걸린)
        for i, char in pairs(t_ret) do
            table.insert(t_ret_not_harmful, char)
        end

	    -- 남은 애들도 다시 담는다. (남은 애들 = 디버프 안걸린)
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
    end
    return t_ret, t_ret_not_harmful
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
-- function TargetRule_getTargetList_hp_low
-- @brief 낮은 HP%
-------------------------------------
function TargetRule_getTargetList_hp_low(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = v:getHpRate()
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
        v.m_sortValue = v:getHpRate()
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
-- function TargetRule_getTargetList_front
-- @brief 
-------------------------------------
function TargetRule_getTargetList_front(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()

        if (v.m_bLeftFormation) then
            v.m_sortValue = -v_x
        else
            v.m_sortValue = v_x
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
-- function TargetRule_getTargetList_back
-- @brief 
-------------------------------------
function TargetRule_getTargetList_back(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()

        if (v.m_bLeftFormation) then
            v.m_sortValue = v_x
        else
            v.m_sortValue = -v_x
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
