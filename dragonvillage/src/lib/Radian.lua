-------------------------------------
-- function getAdjustDegree
-- @brief degree를 0~360 사이 값으로 보정
-- @param degree
-------------------------------------
function getAdjustDegree(degree)
    local degree = degree % 360
    if degree < 0 then degree = 360 + degree end
    return degree
end

-------------------------------------
-- function getRotationDegree
-- @brief curr의 각도를 dest의 방향으로 rotation만큼 회전
-- @param curr
-- @param dest
-- @param rotation
-------------------------------------
function getRotationDegree(curr, dest, rotation)
    -- 0~360의 값으로 보정
    local curr = getAdjustDegree(curr)
    local dest = getAdjustDegree(dest)
    local rotaition_degree = curr

    -- 두 각도의 차이가 180 이상이라면, 단순 비교를 위해 더 작은 각도에 360을 더한다
    local gap = math_abs(curr - dest)
    if gap > 180 then
        if curr < dest then
            curr = curr + 360
        else
            dest = dest + 360
        end
    end
    local real_gap = curr - dest
    gap = math_abs(curr - dest)

    -- 목표 각도가 현재 각도보다 클 경우
    if curr < dest then
        rotaition_degree = curr + rotation
        if rotaition_degree > dest then rotaition_degree = dest end
    -- 목표 각도가 현재 각도보다 작을 경우
    else
        rotaition_degree = curr - rotation
        if rotaition_degree < dest then rotaition_degree = dest end
    end

    -- 0~360의 값으로 보정
    rotaition_degree = getAdjustDegree(rotaition_degree)

    return rotaition_degree, gap, real_gap
end

-------------------------------------
-- function getDegree
-- @brief curr에서 dest를 바라보는 degree를 리턴
-- @param curr_x
-- @param curr_y
-- @param dest_x
-- @param dest_y
-------------------------------------
function getDegree(curr_x, curr_y, dest_x, dest_y)
	if (not curr_x) then return nil end
	if (not curr_y) then return nil end
	if (not dest_x) then return nil end
	if (not dest_y) then return nil end

    local dx, dy = dest_x - curr_x, dest_y - curr_y
    local rad = math_atan2(dy, dx)
    local deg = math_deg(rad)
    return deg
end

-------------------------------------
-- function getDistanceFromTwoPoint
-------------------------------------
function getDistanceFromTwoPoint(p1, p2)
    local dx, dy = p2.x - p1.x, p2.y - p1.y
    return math_sqrt(dx*dx + dy*dy)
end

-------------------------------------
-- function getDistance
-------------------------------------
function getDistance(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return math_sqrt(dx*dx + dy*dy)
end

-------------------------------------
-- function getPointFromAngleAndDistance
-- @param angle
-- @param distance
-------------------------------------
function getPointFromAngleAndDistance(angle, distance)
    local distance = distance or 0
    local angle = angle or 0
    local x = distance * math_cos(math_rad(angle))
    local y = distance * math_sin(math_rad(angle))

    return {x=x, y=y}
end

-------------------------------------
-- function getIntersectPoint
-- @brief 두 직전의 교차점
-------------------------------------
function getIntersectPoint(AP1, AP2, BP1, BP2)
    local IP_X = 0
    local IP_Y = 0

    local t = nil
    local s = nil
    local under = (BP2.y-BP1.y) * (AP2.x-AP1.x) - (BP2.x-BP1.x) * (AP2.y-AP1.y)
 
    if (under == 0) then
        --return false
        return IP_X, IP_Y
    end
 
    local _t = (BP2.x-BP1.x)*(AP1.y-BP1.y) - (BP2.y-BP1.y)*(AP1.x-BP1.x)
    local _s = (AP2.x-AP1.x)*(AP1.y-BP1.y) - (AP2.y-AP1.y)*(AP1.x-BP1.x)
 
    t = _t/under
    s = _s/under
 
    --[[
    if (t<0.0 or t>1.0 or s<0.0 or s>1.0) then
        --return false
        return IP_X, IP_Y
    end
    --]]
 
    if (_t==0 and _s==0) then
        --return false
        return IP_X, IP_Y
    end
 
    IP_X = AP1.x + t * (AP2.x-AP1.x)
    IP_Y = AP1.y + t * (AP2.y-AP1.y)
 
    --return true, IP
    return IP_X, IP_Y
end

-------------------------------------
-- function angleIsBetweenAngles
-- @brief check if angle is between angles
-------------------------------------
function angleIsBetweenAngles(n, a, b)
    local n = getAdjustDegree(n) --normalize angles to be 1-360 degrees
    local a = getAdjustDegree(a)
    local  b = getAdjustDegree(b)

    if (a < b) then
        return (a <= n) and (n <= b)
    else
        return (a <= n) or (n <= b)
    end
end

-------------------------------------
-- function getRectangularCoordinates
-- @brief 선분과 임의의 점의 직교 좌표
-- @param x1, y1, x2, y2 선분의 시작과 끝
-- @param px, py 임의의 점
-- @return ax, ay 직교 좌표
-------------------------------------
function getRectangularCoordinates(x1, y1, x2, y2, px, py)
    local ax, ay;   -- 교점
    local ml;       -- 기울기
    local kl;       -- 방정식 y = mx + k1의 상수 k1

    local m2; -- 수직인 직선의 기울기
    local k2; -- 수직인 직선의 방정식 y = mx + k2의 상수 k2

    -- 먼저 직선의 방정식부터 구한다
    -- 구하는 방법은 두 점 p1, p2 를 지나는 직선의 방정식
    -- y - yp1 = (yp1-yp2)/(xp1-xp2) * (x-xp1) 이 됨

    -- 기울기를 구할 건데 예외 상황부터 먼저 처리

    -- 선분이 수직일 경우
    if ( x1 == x2 ) then
        ax = x1;
        ay = py;
    -- 선분이 수평일 경우
    elseif ( y1 == y2 ) then
        ax = px;
        ay = y1;
    -- 그 외의 경우
    else
        -- 기울기 m1
        m1 = (y1 - y2) / (x1 - x2);
        -- 상수 k1
        k1 = -m1 * x1 + y1;

        -- 선분 l 을 포함하는 직선의 방정식은 y = m1x + k1
        -- 남은 것은 점 p 를 지나고 위의 직선과 직교하는 직선의 방정식을 구한다
        -- 두 직선은 직교하기 때문에 m1 * m2 = -1

        -- 기울기 m2
        m2 = -1.0 / m1;
        -- p 를 지나기 때문에 yp = m2 * xp + k2 => k2 = yp - m2 * xp
        k2 = py - m2 * px;

        -- 두 직선 y = m1x + k1, y = m2x + k2 의 교점을 구한다
        ax = (k2 - k1) / (m1 - m2);
        ay = m1 * ax + k1;
    end

    return ax, ay
end