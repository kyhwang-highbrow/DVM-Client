-------------------------------------
-- table SkillTargetFinder
-- @brief 스킬과 인디케이터가 공통으로 사용할 find target 함수
-------------------------------------
SkillTargetFinder = {}

-------------------------------------
-- function findCollision_AoERound
-------------------------------------
function SkillTargetFinder:findCollision_AoERound(l_target, x, y, range)
    local l_target = l_target or {}
    local l_ret = {}

    -- 최대 사이즈
    if (range == -1) then
        range = 2500
    end
    
	-- 바디사이즈를 감안한 충돌 체크
    for _, target in pairs(l_target) do
        local collisions = getCollisionList(target, x, y, range)
		
        for i, collision in ipairs(collisions) do
            table.insert(l_ret, collision)
		end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getDistance() < b:getDistance()
        end)
    end
    
    return l_ret
end

-------------------------------------
-- function findCollision_Bar
-------------------------------------
function SkillTargetFinder:findCollision_Bar(l_target, start_x, start_y, end_x, end_y, thickness)
    local l_target = l_target or {}
	local l_ret = {}
    
	for _, target in ipairs(l_target) do
        local collisions = getCollisionList_Line(target, start_x, start_y, end_x, end_y, thickness)

		for _, collision in ipairs(collisions) do
            table.insert(l_ret, collision)
		end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getDistance() < b:getDistance()
        end)
    end

    return l_ret
end

-------------------------------------
-- function findCollision_AoESquare
-------------------------------------
function SkillTargetFinder:findCollision_AoESquare(l_target, x, y, half_width, half_height, no_sort)
	local l_target = l_target or {}
	local l_ret = {}
    
	for i, target in ipairs(l_target) do
        local collisions = getCollisionList_Rect(target, x, y, half_width, half_height)

		for i, collision in ipairs(collisions) do
            table.insert(l_ret, collision)
		end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_ret > 1 and not no_sort) then
        table.sort(l_ret, function(a, b)
            return a:getDistance() < b:getDistance()
        end)
    end

    return l_ret
end

-------------------------------------
-- function findCollision_AoESquare_Multi
-------------------------------------
function SkillTargetFinder:findCollision_AoESquare_Multi(l_target, l_x, y, half_width, half_height)
	local l_target = l_target or {}
    local l_ret = {}
	local m_temp = {}
    
    for _, x in ipairs(l_x) do
	    for _, target in ipairs(l_target) do
            local collisions = getCollisionList_Rect(target, x, y, half_width, half_height)

		    for _, collision in ipairs(collisions) do
                local target = collision:getTarget()
                local body_key = collision:getBodyKey()
            
                if (not m_temp[target]) then
                    m_temp[target] = {}
                end

                m_temp[target][body_key] = collision
		    end
        end
    end

    -- 리스트 형태로 변환
    for _, v in pairs(m_temp) do
        for _, collision in pairs(v) do
            table.insert(l_ret, collision)
        end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getDistance() < b:getDistance()
        end)
    end

    return l_ret
end

-------------------------------------
-- function findCollision_AoECone
-------------------------------------
function SkillTargetFinder:findCollision_AoECone(l_target, x, y, dir, range, angle)
    local l_target = l_target or {}
	local l_ret = {}
        
	for _, target in ipairs(l_target) do
        local collisions = getCollisionList_Fan(target, x, y, dir, range, angle)

		for _, collision in ipairs(collisions) do
            table.insert(l_ret, collision)
		end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getDistance() < b:getDistance()
        end)
    end

   return l_ret
end

-------------------------------------
-- function findCollision_Bezier
-------------------------------------
function SkillTargetFinder:findCollision_Bezier(l_target, tar_x, tar_y, pos_x, pos_y, course)
    local l_target = l_target or {}
    local l_ret = {}
    
    -- 베지어 곡선의 좌표값을 가져온다.
    local t_bezier_pos = getBezierPosList(tar_x, tar_y, pos_x, pos_y, course)
    local leaf_body_size = g_constant:get('SKILL', 'LEAF_COLLISION_SIZE')
    
    for _, target in ipairs(l_target) do
        local collisions = getCollisionList_Bezier(target, t_bezier_pos, leaf_body_size, pos_x, pos_y)

        for _, collision in ipairs(collisions) do
            table.insert(l_ret, collision)
        end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_ret > 1) then
        table.sort(l_ret, function(a, b)
            return a:getDistance() < b:getDistance()
        end)
    end

    return l_ret
end

-------------------------------------
-- function findCollision_Penetration
-------------------------------------
function SkillTargetFinder:findCollision_Penetration(l_target, pos_x, pos_y, owner, idx, target_limit, size, dir)
    -- 참조하는 좌표
	local end_pos = getPointFromAngleAndDistance(dir, 2560)
	local hero_pos = owner.pos

	-- 실제 사용할 좌표
	-- 계산한 start_pos는 incator_root_node를 기반(0, 0)으로 한것이므로 영웅 좌표를 더해서 월드에서 계산할수 있도록 한다
	local start_x = pos_x + hero_pos.x
	local start_y = pos_y + hero_pos.y
    local end_x = start_x + end_pos['x']
    local end_y = start_y + end_pos['y']
	local collisions = SkillTargetFinder:findCollision_Bar(l_target, start_x, start_y, end_x, end_y, (SkillHelper:getSizeAndScale('fan', size)['size']/2))
    collisions = table.getPartList(collisions, target_limit)

    local l_ret = {}
    for _, collision in pairs(collisions) do
        table.insert(l_ret, collision)
    end

    return l_ret
end

-------------------------------------
-- function getCollisionFromTargetList
-- @brief 해당 타겟들의 모든 바디 리스트를 얻는다
-------------------------------------
function SkillTargetFinder:getCollisionFromTargetList(l_target, pos_x, pos_y, do_not_sort)
    local l_target = l_target or {}
    local l_ret = {}
    local do_not_sort = do_not_sort or false

    for _, target in ipairs(l_target) do
        for _, body in ipairs(target:getBodyList()) do
            local target_x = target.pos.x + body['x']
	        local target_y = target.pos.y + body['y']
            local body_key = body['key']
            local distance = getDistance(pos_x, pos_y, target_x, target_y)

            local collision = StructCollisionData(target, body_key, distance, target_x, target_y)
            table.insert(l_ret, collision)
        end
    end

    if(not do_not_sort) then
        -- 거리가 가까운 순서로 정렬
        if (#l_ret > 1) then
            table.sort(l_ret, function(a, b)
                return a:getDistance() < b:getDistance()
            end)
        end
    end

    return l_ret
end