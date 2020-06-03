local function makeSortedBodyList(list)
    local ret = {}

    -- 거리가 가까운 순서로 정렬
    if (#list > 1) then
        table.sort(list, function(a, b)
            return a['distance'] < b['distance']
        end)
    end

    for i, v in ipairs(list) do
        table.insert(ret, v['key'])
    end

    return ret
end

-------------------------------------
-- function isCollision
-- @brief body size를 고려한 충돌 여부 판단, 원형
-- @return boolean
-------------------------------------
function isCollision(target, x, y, range)    
    local is_collision = false
    
    if (range <= 0) then
        return is_collision
    end

    for _, body in ipairs(target:getBodyList()) do
        local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
        local body_size = body['size']

	    local distance = getDistance(x, y, target_x, target_y)
	    if (distance - body_size < range) then
            is_collision = true
        end
    end

    return is_collision
end


-------------------------------------
-- function isCollision_Rect
-- @brief body size를 고려한 충돌 여부 판단, 사각형
-- @return boolean
-------------------------------------
function isCollision_Rect(target, x, y, range_x, range_y)
    local is_collision = false
    local l_body = {}
    local l_temp = {}
    local distance = nil

    for _, body in ipairs(target:getBodyList()) do
	    local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
	    local body_size = body['size']

        if ((math_abs(target_x - x) - body_size < range_x) and (math_abs(target_y - y) - body_size  < range_y)) then
            is_collision = true

            local distance = getDistance(x, y, target_x, target_y)
            table.insert(l_temp, { distance = distance, key = body['key'] })
        end
    end

    -- 거리가 가까운 순서로 정렬
    l_body = makeSortedBodyList(l_temp)
    
    -- 가장 가까운 바디의 거리
    if (l_temp[1]) then
        distance = l_temp[1]['distance']
    end

    return is_collision, l_body, distance
end

-------------------------------------
-- function getCollisionList
-- @brief body size를 고려한 충돌 여부 판단, 원형
-- @return boolean
-------------------------------------
function getCollisionList(target, x, y, range)    
    local l_collision = {}
    
    if (range <= 0) then
        return l_collision
    end

    for _, body in ipairs(target:getBodyList()) do
        local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
        local body_size = body['size']

	    local distance = getDistance(x, y, target_x, target_y)
	    if (distance - body_size < range) then
            local collision_data = StructCollisionData(target, body['key'], distance, target_x, target_y)
            table.insert(l_collision, collision_data)
        end
    end

    return l_collision
end

-------------------------------------
-- function getCollisionList_Rect
-- @brief body size를 고려한 충돌 여부 판단, 사각형
-- @return boolean
-------------------------------------
function getCollisionList_Rect(target, x, y, range_x, range_y)
    local l_collision = {}

    for _, body in ipairs(target:getBodyList()) do
	    local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
	    local body_size = body['size']

        if ((math_abs(target_x - x) - body_size < range_x) and (math_abs(target_y - y) - body_size  < range_y)) then
            local distance = getDistance(x, y, target_x, target_y)
            local collision_data = StructCollisionData(target, body['key'], distance, target_x, target_y)
            table.insert(l_collision, collision_data)
        end
    end

    return l_collision
end

-------------------------------------
-- function getCollisionList_Line
-- @brief body size를 고려한 충돌 여부 판단, 직선
-------------------------------------
function getCollisionList_Line(target, x1, y1, x2, y2, thickness)
    local l_collision = {}

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

    for _, body in ipairs(target:getBodyList()) do
        local target_x = target.pos.x + body.x
        local target_y = target.pos.y + body.y
        local target_size = body.size

        local is_collision = false
        local x3, y3 = getRectangularCoordinates(x1, y1, x2, y2, target_x, target_y)
        
        -- 직교 좌표가 범위를 넘어갔을 경우
        if (x3 < min_x) or (max_x < x3) or (y3 < min_y) or (max_y < y3) then

            -- 시작 좌표와 충돌 확인
            if (not is_collision) then
                local distance = math_distance(target_x, target_y, x1, y1)
                if distance <= (target_size + thickness) then
                    is_collision = true
                end
            end

            -- 종료 좌표와 충돌 확인
            if (not is_collision) then
                local distance = math_distance(target_x, target_y, x2, y2)
                if distance <= (target_size + thickness) then
                    is_collision = true
                end
            end
        else
            -- 직교 좌표가 범위안에 존재할 경우
            local distance = math_distance(target_x, target_y, x3, y3)
            if distance <= (target_size + thickness) then
                is_collision = true
            end
        end

        -- 충돌된 객체라면
        if (is_collision) then
            local distance = math_distance(x1, y1, target_x, target_y)
            local collision_data = StructCollisionData(target, body['key'], distance, target_x, target_y)
            table.insert(l_collision, collision_data)
        end
    end

    return l_collision
end

-------------------------------------
-- function getCollisionList_Fan
-- @brief body size를 고려한 충돌 여부 판단, 부채꼴
-------------------------------------
function getCollisionList_Fan(target, x, y, dir, radius, angle_range)
    local l_collision = {}
    local m_collision = {}

    local dir_min = dir - (angle_range/2)
    local dir_max = dir + (angle_range/2)

    local low_pos = getPointFromAngleAndDistance(dir_min, radius)
    low_pos['x'] = (low_pos['x'] + x)
    low_pos['y'] = (low_pos['y'] + y)
    local high_pos = getPointFromAngleAndDistance(dir_max, radius)
    high_pos['x'] = (high_pos['x'] + x)
    high_pos['y'] = (high_pos['y'] + y)

    for _, body in ipairs(target:getBodyList()) do
        local target_x = target.pos.x + body.x
        local target_y = target.pos.y + body.y
        local target_size = body.size

        -- 거리 및 각도 체크
        local distance = getDistance(x, y, target_x, target_y)
        local degree = getDegree(x, y, target_x, target_y)
        if ((radius + target_size) >= distance) and angleIsBetweenAngles(degree, dir_min, dir_max) then
            local body_key = body['key']
            m_collision[body_key] = StructCollisionData(target, body_key, distance, target_x, target_y)
        end
    end
            
    do
        -- 낮은 각도 라인 체크
        local collisions = getCollisionList_Line(target, x, y, low_pos['x'], low_pos['y'], 0)
        for i, collision in ipairs(collisions) do
            local body_key = collision:getBodyKey()
            m_collision[body_key] = collision
        end
    end
           
    do
        -- 높은 각도 라인 체크
        local collisions = getCollisionList_Line(target, x, y, high_pos['x'], high_pos['y'], 0)
        for i, collision in ipairs(collisions) do
            local body_key = collision:getBodyKey()
            m_collision[body_key] = collision
        end
    end

    -- 맵을 리스트 형태로 변경
    for _, collision in pairs(m_collision) do
        table.insert(l_collision, collision)
    end
    
    return l_collision
end

-------------------------------------
-- function getCollisionList_Bezier
-------------------------------------
function getCollisionList_Bezier(target, t_bezier_pos, thickness, x, y)
    local l_collision = {}
    local m_collision = {}

    -- 가져온 베지어 곡선 좌표를 순회하면서 각각에서 근처에 위치한 적을 찾는다. 
	for _, bezier_pos in pairs(t_bezier_pos) do
        local collisions = getCollisionList(target, bezier_pos['x'], bezier_pos['y'], thickness)

        for i, collision in ipairs(collisions) do
            -- 거리 계산을 다시해야함(시작 지점 기준)
            collision.m_distance = getDistance(x, y, bezier_pos['x'], bezier_pos['y'])

            local body_key = collision:getBodyKey()
            m_collision[body_key] = collision
        end
    end

    -- 맵을 리스트 형태로 변경
    for _, collision in pairs(m_collision) do
        table.insert(l_collision, collision)
    end

    return l_collision
end

-------------------------------------
-- function convertToListFrom2DArray
-- @brief 2차원 배열을 리스트로 변환
-------------------------------------
function convertToListFrom2DArray(array)
    local l_ret = {}
    
    for _, map in pairs(array) do
        for _, v in pairs(map) do
            table.insert(l_ret, v)
        end
    end

    return l_ret
end

-------------------------------------
-- function mergeCollisionLists
-- @brief lists내의 충돌 리스트들을 중복정보가 들어가지 않도록 merge
-------------------------------------
function mergeCollisionLists(lists)
    local m_temp = {}

    for _, list in ipairs(lists) do
        for _, collision in ipairs(list) do
            local target = collision:getTarget()
            local body_key = collision:getBodyKey()

            if (not m_temp[target]) then
                m_temp[target] = {}
            end

            m_temp[target][body_key] = collision
        end
    end
    
    -- 인덱스 테이블로 다시 담는다
    local l_ret = {}
    
    for _, map in pairs(m_temp) do
        for _, collision in pairs(map) do
            table.insert(l_ret, collision)
        end
    end

    return l_ret
end