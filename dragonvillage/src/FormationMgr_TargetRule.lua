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
    elseif (type == 'distance_line') then   return TargetRule_getTargetList_distance_line(org_list, x, y)
    elseif (type == 'distance_x') then      return TargetRule_getTargetList_distance_x(org_list, x)
    elseif (type == 'distance_y') then      return TargetRule_getTargetList_distance_y(org_list, y)
    elseif (type == 'hp_low') then          return TargetRule_getTargetList_hp_low(org_list, y)
    elseif (type == 'hp_high') then         return TargetRule_getTargetList_hp_high(org_list, y)
    elseif (type == 'cp_low') then          return TargetRule_getTargetList_cp_low(org_list, y)
    elseif (type == 'cp_high') then         return TargetRule_getTargetList_cp_high(org_list, y)
    elseif (type == 'random') then          return TargetRule_getTargetList_random(org_list)
    elseif (type == 'fan_shape') then       return TargetRule_getTargetList_fan_shape(org_list, t_data)
	
	elseif (type == 'status_not_stun') then return TargetRule_getTargetList_status_effect(org_list, 'stun', false)
	elseif (type == 'status_stun') then		return TargetRule_getTargetList_status_effect(org_list, 'stun', true)

	--elseif (type == 'front_line') then      return TargetRule_getTargetList_row(FORMATION_FRONT)
	--elseif (type == 'middle_line') then     return TargetRule_getTargetList_row(FORMATION_MIDDLE)
	--elseif (type == 'back_line') then       return TargetRule_getTargetList_row(FORMATION_REAR)

	elseif (type == 'earth_group') then     return TargetRule_getTargetList_attr(org_list, ATTR_EARTH)
	elseif (type == 'water_group') then     return TargetRule_getTargetList_attr(org_list, ATTR_WATER)
	elseif (type == 'wind_group') then      return TargetRule_getTargetList_attr(org_list, ATTR_WIND)
	elseif (type == 'fire_group') then      return TargetRule_getTargetList_attr(org_list, ATTR_FIRE)
	elseif (type == 'light_group') then     return TargetRule_getTargetList_attr(org_list, ATTR_LIGHT)
	elseif (type == 'dark_group') then      return TargetRule_getTargetList_attr(org_list, ATTR_DARK)
	
	elseif (type == 'physical_char') then      return TargetRule_getTargetList_charType(org_list, 'physical')
	elseif (type == 'magical_char') then      return TargetRule_getTargetList_charType(org_list, 'magical')

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
-- function TargetRule_getTargetList_status_effect
-- @brief 특정 상태효과에 따른 구분
-- @param org_list : 전체 타겟 리스트
-- @param status_effect_name : 제외하거나 대상으로할 상태효과 이름
-- @param b_include : 해당 상태효과를 제외할지 대상으로할지 여부 / true 일 때 대상으로함
-------------------------------------
function TargetRule_getTargetList_status_effect(org_list, status_effect_name, b_include)
    local t_ret = {}
	local isInsert = nil
	
    for i,v in pairs(org_list) do
		isInsert = not b_include
		for name, status_effect in pairs(v:getStatusEffectList()) do
			if (name == status_effect_name) then
				isInsert = b_include
			end
		end
		if isInsert then 
			table.insert(t_ret, v)
		end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_fan_shape
-- @brief 부채꼴
-------------------------------------
function TargetRule_getTargetList_fan_shape(org_list, t_data)

    -- 시작 위치
    local x = t_data['x']
    local y = t_data['y']

    -- 방향
    local dir = t_data['dir']

    -- 각도 범위
    local angle_range = t_data['angle_range']

    -- 반지름
    local radius = t_data['radius']

    local dir_min = dir - (angle_range/2)
    local dir_max = dir + (angle_range/2)

    local low_pos = getPointFromAngleAndDistance(dir_min, radius)
    low_pos['x'] = (low_pos['x'] + x)
    low_pos['y'] = (low_pos['y'] + y)
    local high_pos = getPointFromAngleAndDistance(dir_max, radius)
    high_pos['x'] = (high_pos['x'] + x)
    high_pos['y'] = (high_pos['y'] + y)

    local t_ret = {}

    for i,v in pairs(org_list) do
        local continue = false
        -- 거리 체크
        if (not continue) then
            local distance = getDistance(x, y, v.pos.x, v.pos.y)
            if ((radius + v.body.size) < distance) then
                continue = true
            end
        end

        -- 각도 체크
        if (not continue) then
            local degree = getDegree(x, y, v.pos.x, v.pos.y)
            if angleIsBetweenAngles(degree, dir_min, dir_max) then
                table.insert(t_ret, v)
                continue = true
            end
        end

        -- 낮은 각도 라인 체크
        if (not continue) then
            local is_collision, dist, x3, y3 = TargetRule_getTargetList_line(v, x, y, low_pos['x'], low_pos['y'], 0)
            if is_collision then
                table.insert(t_ret, v)
                continue = true
            end
        end

        -- 높은 각도 라인 체크
        if (not continue) then
            local is_collision, dist, x3, y3 = TargetRule_getTargetList_line(v, x, y, high_pos['x'], high_pos['y'], 0)
            if is_collision then
                table.insert(t_ret, v)
                continue = true
            end
        end        
    end

    return t_ret
end


-------------------------------------
-- function TargetRule_getTargetList_rectangle
-- @brief 부채꼴
-------------------------------------
function TargetRule_getTargetList_rectangle(org_list, t_data)

    -- 시작 위치
    local x1 = t_data['x1']
    local y1 = t_data['y1']

    -- 종료 위치
    local x2 = t_data['x2']
    local y2 = t_data['y2']

    local thickness = t_data['thickness'] or 0

    local t_ret = {}

    for i,v in org_list do
        local is_collision, dist, x3, y3 = TargetRule_getTargetList_line(v, x1, y1, x2, y2, thickness)

        if is_collision then
            table.insert(t_ret, {obj=v, dist=dist, x=x3, y=y3})
        end
    end

    -- dist가 짧은 순으로 정렬
    table.sort(t_ret, function(a, b)
        return a['dist'] < b['dist']
    end)

    return t_ret
end


-------------------------------------
-- function TargetRule_getTargetList_line
-- @brief
-------------------------------------
function TargetRule_getTargetList_line(obj, x1, y1, x2, y2, thickness)
    -- 충돌 처리 범위 확인
    local min_x, max_x
    if (x1 < x2) then
        min_x = x1 - thickness
        max_x = x2 + thickness
    else
        min_x = x2 - thickness
        max_x = x1 + thickness
    end
    local min_y, max_y
    if (y1 < y2) then
        min_y = y1 - thickness
        max_y = y2 + thickness
    else
        min_y = y2 - thickness
        max_y = y1 + thickness
    end


    local obj_x = obj.pos.x + obj.body.x
    local obj_y = obj.pos.y + obj.body.y
    local obj_size = obj.body.size

    local not_finish = true
    local x3, y3 = getRectangularCoordinates(x1, y1, x2, y2, obj_x, obj_y)

    -- 직교 좌표가 범위를 넘어갔을 경우
    if (x3 < min_x) or (max_x < x3) or (y3 < min_y) or (max_y < y3) then

        -- 시작 좌표와 충돌 확인
        if not_finish then
            local dist = math_distance(obj_x, obj_y, x1, y1)
            if dist <= (obj_size + thickness) then
                not_finish = false
            end
        end

        -- 종료 좌표와 충돌 확인
        if not_finish then
            local dist = math_distance(obj_x, obj_y, x2, y2)
            if dist <= (obj_size + thickness) then
                not_finish = false
            end
        end
    else
        -- 직교 좌표가 범위안에 존재할 경우
        local dist = math_distance(obj_x, obj_y, x3, y3)
        if dist <= (obj_size + thickness) then
            not_finish = false
        end
    end

    -- 충돌된 객체라면
    if (not_finish == false) then
        local distance = math_distance(x1, y1, x3, y3)
        return true, distance, x3, y3
    end

    return false
end

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
-- function TargetRule_getTargetList_attr
-- @brief 해당 속성의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_attr(org_list, attr)
    local t_ret = {}
	local attr = attributeNumToStr(attr)

	for i, character in pairs(org_list) do
		if (character:getAttribute() == attr) then
			table.insert(t_ret, character)
		end
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