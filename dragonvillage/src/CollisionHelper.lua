-------------------------------------
-- function isCollision
-- @brief body size를 고려한 충돌 여부 판단, 원형
-- @return boolean
-------------------------------------
function isCollision(target, x, y, range)    
    local is_collision = false
    local l_body = {}
    local l_temp = {}
    local distance = nil

    if (range <= 0) then
        return is_collision, l_body
    end

    for _, body in ipairs(target:getBodyList()) do
        local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
        local body_size = body['size']

	    local distance = getDistance(x, y, target_x, target_y)
	    if (distance - body_size < range) then
            is_collision = true
            table.insert(l_temp, { distance = distance, key = body['key'] })
        end
    end

    -- 거리가 가까운 순서로 정렬
    if (#l_temp > 1) then
        table.sort(l_temp, function(a, b)
            return a['distance'] < b['distance']
        end)
    end

    for i, v in ipairs(l_temp) do
        table.insert(l_body, v['key'])
    end

    if (l_temp[1]) then
        distance = l_temp[1]['distance']
    end
    
    return is_collision, l_body, distance
end

-------------------------------------
-- function isCollision_Rect
-- @brief body size를 고려한 충돌 여부 판단, 사각형
-- @return boolean
-------------------------------------
function isCollision_Rect(target, x, y, range_x, range_y)
    local is_collision = false
    local l_body = {}

    for _, body in ipairs(target:getBodyList()) do
	    local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
	    local body_size = body['size']

        if ((math_abs(target_x - x) - body_size < range_x) and (math_abs(target_y - y) - body_size  < range_y)) then
            is_collision = true
            table.insert(l_body, body['key'])
        end
    end

    return is_collision, l_body
end

-------------------------------------
-- function isCollision_Line
-- @brief body size를 고려한 충돌 여부 판단, 직선
-------------------------------------
function isCollision_Line(target, x1, y1, x2, y2, thickness)
    local is_collision = false
    local l_body = {}

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

        local not_finish = true
        local x3, y3 = getRectangularCoordinates(x1, y1, x2, y2, target_x, target_y)

        -- 직교 좌표가 범위를 넘어갔을 경우
        if (x3 < min_x) or (max_x < x3) or (y3 < min_y) or (max_y < y3) then

            -- 시작 좌표와 충돌 확인
            if not_finish then
                local dist = math_distance(target_x, target_y, x1, y1)
                if dist <= (target_size + thickness) then
                    not_finish = false
                end
            end

            -- 종료 좌표와 충돌 확인
            if not_finish then
                local dist = math_distance(target_x, target_y, x2, y2)
                if dist <= (target_size + thickness) then
                    not_finish = false
                end
            end
        else
            -- 직교 좌표가 범위안에 존재할 경우
            local dist = math_distance(target_x, target_y, x3, y3)
            if dist <= (target_size + thickness) then
                not_finish = false
            end
        end

        -- 충돌된 객체라면
        if (not_finish == false) then
            is_collision = true
            table.insert(l_body, body['key'])
        end
    end

    return is_collision, l_body
end

-------------------------------------
-- function isCollision_Fan
-- @brief body size를 고려한 충돌 여부 판단, 부채꼴
-------------------------------------
function isCollision_Fan(target, x, y, dir, radius, angle_range)
    local is_collision = false
    local l_body = {}
    local m_body = {}

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
            is_collision = true
            m_body[body['key']] = true
        end
    end
            
    do
        -- 낮은 각도 라인 체크
        local b, bodys = isCollision_Line(target, x, y, low_pos['x'], low_pos['y'], 0)
        if (b) then
            is_collision = true

            for i, k in ipairs(bodys) do
               m_body[k] = true
            end
        end
    end
           
    do
        -- 높은 각도 라인 체크
        local b, bodys = isCollision_Line(target, x, y, high_pos['x'], high_pos['y'], 0)
        if (b) then
            is_collision = true
            
            for i, k in ipairs(bodys) do
               m_body[k] = true
            end
        end
    end

    for k, _ in pairs(m_body) do
        table.insert(l_body, k)
    end
    
    return is_collision, l_body
end

-------------------------------------
-- function isCollision_Fan
-- @brief body size를 고려한 충돌 여부 판단, 부채꼴
-------------------------------------
function isCollision_Bezier(target, t_bezier_pos, thickness)
    local is_collision = false
    local l_body = {}
    local m_body = {}

    -- 가져온 베지어 곡선 좌표를 순회하면서 각각에서 근처에 위치한 적을 찾는다. 
	for _, bezier_pos in pairs(t_bezier_pos) do
        local b, bodys = isCollision(target, bezier_pos['x'], bezier_pos['y'], thickness)

		if (b) then
            is_collision = true
            
            for i, k in ipairs(bodys) do
               m_body[k] = true
            end
		end
    end

    for k, _ in pairs(m_body) do
        table.insert(l_body, k)
    end

    return is_collision, l_body
end