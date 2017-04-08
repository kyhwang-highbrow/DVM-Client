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
-- function findTarget_AoECone
-------------------------------------
function SkillTargetFinder:findTarget_AoECone(l_target, x, y, dir, range, angle)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_bodyKey = {}
    
	for i, target in ipairs(l_target) do
        local b, body_key = isCollision_Fan(target, x, y, dir, range, angle)
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
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_bodyKey = {}
    
	for i, target in ipairs(l_target) do
        local b, body_key = isCollision_Fan(target, x, y, dir, range, angle)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_bodyKey, body_key)
		end
    end

    return l_ret, l_bodyKey
end

-------------------------------------
-- function findTarget_Crash
-------------------------------------
function SkillTargetFinder:findTarget_Crash(l_target, x, y, dir, range, angle)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_bodyKey = {}
    
	for i, target in ipairs(l_target) do
        local b, body_key = isCollision_Fan(target, x, y, dir, range, angle)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_bodyKey, body_key)
		end
    end

    return l_ret, l_bodyKey
end

-------------------------------------
-- function findTarget_Bar
-------------------------------------
function SkillTargetFinder:findTarget_Bar(l_target, start_x, start_y, end_x, end_y, thickness)
    local l_target = l_target or {}
	
	local l_ret = {}
    local l_bodyKey = {}
    
	for i, target in ipairs(l_target) do
        local b, body_key = isCollision_Line(target, start_x, start_y, end_x, end_y, thickness)
		if (b) then
            table.insert(l_ret, target)
            table.insert(l_bodyKey, body_key)
		end
    end

    return l_ret, l_bodyKey
end