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
    local l_bodyKey = {}

	-- 바디사이즈를 감안한 충돌 체크
    for _, target in pairs(l_target) do
        local b, body_key = isCollision(target, x, y, range)
		if (b) then
			table.insert(l_ret, target)
            table.insert(l_bodyKey, body_key)
		end
    end
    
    return l_ret, l_bodyKey
end

-------------------------------------
-- function findTarget_AoESquare
-------------------------------------
function SkillTargetFinder:findTarget_AoESquare(l_target, x, y, width, height)
	local l_target = l_target or {}
	
	local l_ret = {}
    local l_bodyKey = {}
    
	for i, target in ipairs(l_target) do
        local b, body_key = isCollision_Rect(target, x, y, width, height)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_bodyKey, body_key)
		end
    end

    return l_ret, l_bodyKey
end

-------------------------------------
-- function findTarget_AoEWedge
-------------------------------------
function SkillTargetFinder:findTarget_AoEWedge(l_target, x, y, dir, range, angle)
	local t_data = {
		x = x,					-- 회전축 좌표 x
		y = y,					-- 회전축 좌표 y
		dir = dir,				-- 방향
		radius = range,			-- 거리
		angle_range = angle		-- 각도
	}

	return TargetRule_getTargetList_fan_shape(l_target, t_data)
end

-------------------------------------
-- function findTarget_Bar
-------------------------------------
function SkillTargetFinder:findTarget_Bar(l_target, start_x, start_y, end_x, end_y, thickness)
	local t_data = {
		x1 = start_x,
		y1 = start_y,
		x2 = end_x,
		y2 = end_y,
		thickness = thickness
	}

	return TargetRule_getTargetList_rectangle(l_target, t_data)
end