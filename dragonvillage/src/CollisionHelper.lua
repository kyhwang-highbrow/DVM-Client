-------------------------------------
-- function isCollision
-- @brief body size를 고려한 충돌 여부 판단, 원형
-- @return boolean
-------------------------------------
function isCollision(target, x, y, range)    
    for _, body in ipairs(target:getBodyList()) do
        local target_x = target.pos.x + body['x']
	    local target_y = target.pos.y + body['y']
        local body_size = target.body['size']

	    local distance = getDistance(x, y, target_x, target_y)
	    if (distance - body_size < range) then
            return true, body['key']
        end
    end
end

-------------------------------------
-- function isCollision_Rect
-- @brief body size를 고려한 충돌 여부 판단, 사각형
-- @return boolean
-------------------------------------
function isCollision_Rect(target, x, y, range_x, range_y)
    for _, body in ipairs(target:getBodyList()) do
	    local target_x = target.pos.x + target.body['x']
	    local target_y = target.pos.y + target.body['y']
	    local body_size = target.body['size']

        if ((math_abs(target_x - x) - body_size < range_x) and (math_abs(target_y - y) - body_size  < range_y)) then
            return true, body['key']
        end
    end
end

-------------------------------------
-- function isCollision_Line
-- @brief body size를 고려한 충돌 여부 판단, 직선
-------------------------------------
function isCollision_Line(target, x1, y1, x2, y2, thickness)
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

    local body_list = target:getBodyList()

    for _, body in ipairs(body_list) do
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
            return true, body['key']
        end
    end

    return false
end