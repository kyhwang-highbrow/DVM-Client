math_floor = math.floor
math_random = math.random
math_ceil = math.ceil
math_pow = math.pow
math_max = math.max
math_min = math.min
math_sqrt = math.sqrt
math_abs = math.abs
math_sin = math.sin
math_cos = math.cos
math_atan2 = math.atan2
math_deg = math.deg
math_rad = math.rad

if isWin32() then
    math_random = function(lower, uper)

        -- Number between 0 and 1
        if (lower == nil) and (uper == nil) then
            return math.random()

        -- int between 1 and uper
        elseif (uper == nil) then
            return math.random(lower)
        end

        if (lower > uper) then
            error('interval is empty')
        end

        -- int between l and uper
        return math.random(lower, uper)
    end
end

function math_sign(num)
    if     num > 0 then return 1
    elseif num < 0 then return -1
    end
    return 0
end

function math_clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end

    return value
end

function math_clamp2(value, value1, value2)
    local min, max
    if value1 < value2 then
        min = value1
        max = value2
    else
        min = value2
        max = value1
    end

    if value < min then
        return min
    elseif value > max then
        return max
    end

    return value
end

function math_round(num)
    under = math_floor(num)
    upper = under + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

-------------------------------------
-- function math_distance
-------------------------------------
function math_distance(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return math_sqrt(dx*dx + dy*dy)
end

--[[ math 라이브러리 함수 사용 횟수 체크
local t_call_count = {
math_floor = 0,
math_random = 0,
math_ceil = 0,
math_pow = 0,
math_max = 0,
math_min = 0,
math_sqrt = 0,
math_abs = 0,
math_sin = 0,
math_cos = 0,
math_atan2 = 0,
math_deg = 0,
math_rad = 0,
}

function math_floor(data)
    t_call_count.math_floor = t_call_count.math_floor + 1
    return math.floor(data)
end

function math_random(data1, data2)
    t_call_count.math_random = t_call_count.math_random + 1
    return math.random(data1, data2)
end

function math_ceil(data)
    t_call_count.math_ceil = t_call_count.math_ceil + 1
    return math.ceil(data)
end

function math_pow(data1, data2)
    t_call_count.math_pow = t_call_count.math_pow + 1
    return math.pow(data1, data2)
end

function math_max(data1, data2)
    t_call_count.math_max = t_call_count.math_max + 1
    return math.max(data1, data2)
end

function math_min(data1, data2)
    t_call_count.math_min = t_call_count.math_min + 1
    return math.min(data1, data2)
end

function math_sqrt(data)
    t_call_count.math_sqrt = t_call_count.math_sqrt + 1
    return math.sqrt(data)
end

function math_abs(data)
    t_call_count.math_abs = t_call_count.math_abs + 1
    return math.abs(data)
end

function math_sin(data)
    t_call_count.math_sin = t_call_count.math_sin + 1
    return math.sin(data)
end

function math_cos(data)
    t_call_count.math_cos = t_call_count.math_cos + 1
    return math.cos(data)
end

function math_atan2(data1, data2)
    t_call_count.math_atan2 = t_call_count.math_atan2 + 1
    return math.atan2(data1, data2)
end

function math_deg(data)
    t_call_count.math_deg = t_call_count.math_deg + 1
    return math.deg(data)
end

function math_rad(data)
    t_call_count.math_rad = t_call_count.math_rad + 1
    return math.rad(data)
end

function math_report()
    cclog(luadump(t_call_count))
end

function math_report_clear()
    for i,_ in pairs(t_call_count) do
        t_call_count[i] = 0
    end
end
--]]