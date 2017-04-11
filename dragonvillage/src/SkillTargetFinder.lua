-------------------------------------
-- table SkillTargetFinder
-- @brief 스킬과 인디케이터가 공통으로 사용할 find target 함수
-------------------------------------
SkillTargetFinder = {}

-------------------------------------
-- function findTarget_AoERound
-------------------------------------
function SkillTargetFinder:findTarget_AoERound(l_target, x, y, range)
	local l_target = l_target or {}

	local l_ret = {}
    local l_ret_bodys = {}

	-- 바디사이즈를 감안한 충돌 체크
    for _, target in pairs(l_target) do
        local b, bodys = isCollision(target, x, y, range)
		if (b) then
			table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end
    
    return l_ret, l_ret_bodys
end

-------------------------------------
-- function findTarget_AoECone
-------------------------------------
function SkillTargetFinder:findTarget_AoECone(l_target, x, y, dir, range, angle)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_ret_bodys = {}
    
	for i, target in ipairs(l_target) do
        local b, bodys = isCollision_Fan(target, x, y, dir, range, angle)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end

    return l_ret, l_ret_bodys
end

-------------------------------------
-- function findTarget_AoESquare
-------------------------------------
function SkillTargetFinder:findTarget_AoESquare(l_target, x, y, width, height)
	local l_target = l_target or {}
	
	local l_ret = {}
    local l_ret_bodys = {}
    
	for i, target in ipairs(l_target) do
        local b, bodys = isCollision_Rect(target, x, y, width, height)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end

    return l_ret, l_ret_bodys
end

-------------------------------------
-- function findTarget_AoEWedge
-------------------------------------
function SkillTargetFinder:findTarget_AoEWedge(l_target, x, y, dir, range, angle)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_ret_bodys = {}
    
	for i, target in ipairs(l_target) do
        local b, bodys = isCollision_Fan(target, x, y, dir, range, angle)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end

    return l_ret, l_ret_bodys
end

-------------------------------------
-- function findTarget_Crash
-------------------------------------
function SkillTargetFinder:findTarget_Crash(l_target, x, y, dir, range, angle)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_ret_bodys = {}
    
	for i, target in ipairs(l_target) do
        local b, bodys = isCollision_Fan(target, x, y, dir, range, angle)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end

    return l_ret, l_ret_bodys
end

-------------------------------------
-- function findTarget_Bar
-------------------------------------
function SkillTargetFinder:findTarget_Bar(l_target, start_x, start_y, end_x, end_y, thickness)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_ret_bodys = {}
    
	for i, target in ipairs(l_target) do
        local b, bodys = isCollision_Line(target, start_x, start_y, end_x, end_y, thickness)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end

    return l_ret, l_ret_bodys
end

-------------------------------------
-- function findTarget_Near
-------------------------------------
function SkillTargetFinder:findTarget_Near(l_target, x, y, range)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_ret_bodys = {}

    -- 최대 사이즈
    if (range == -1) then
        range = 2500
    end

    local l_temp = {}

    for i, target in ipairs(l_target) do
        local b, bodys, distance = isCollision(target, x, y, range)
		if (b) then
            table.insert(l_temp, {
                distance = distance,
                target = target,
                bodys = bodys
            })
		end
    end

    if (#l_temp > 1) then
        table.sort(l_temp, function(a, b)
            return (a['distance'] < b['distance'])
        end)
    end

    for i, v in ipairs(l_temp) do
        table.insert(l_ret, v['target'])
        table.insert(l_ret_bodys, v['bodys'])
    end

    return l_ret, l_ret_bodys
end


-------------------------------------
-- function findTarget_Bezier
-------------------------------------
function SkillTargetFinder:findTarget_Bezier(l_target, tar_x, tar_y, pos_x, pos_y, course)
    local l_target = l_target or {}

    local l_ret = {}
    local l_ret_bodys = {}

    -- 베지어 곡선의 좌표값을 가져온다.
    local t_bezier_pos = getBezierPosList(tar_x, tar_y, pos_x, pos_y, course)
    local leaf_body_size = g_constant:get('SKILL', 'LEAF_COLLISION_SIZE')
    
    for i, target in ipairs(l_target) do
        local b, bodys = isCollision_Bezier(target, t_bezier_pos, leaf_body_size)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_ret_bodys, bodys)
		end
    end

    return l_ret, l_ret_bodys
end