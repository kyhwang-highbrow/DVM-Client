function math.sign(num)
    if     num > 0 then return 1
    elseif num < 0 then return -1
    end
    return 0
end

-- only for indexed tables!
function table.reverse ( tab )
    local size = #tab
    local newTable = {}

    for i,v in ipairs ( tab ) do
        newTable[size-i+1] = v
    end

    return newTable
end

function table.find(t, item)
    for k, v in pairs(t) do
        if v == item then
            return k
        end
    end

    return nil
end

function table.count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function table.getTwoPairs(t)
    return iterTwo, t, 1
end

function table.merge(t1, t2)
    local t = {}
    local t1 = t1 or {}
    local t2 = t2 or {}

    for i, v in pairs(t1) do
        table.insert(t, v)
    end
    for i, v in pairs(t2) do
        table.insert(t, v)
    end

    return t
end

function table.getLast(t)
	return t[table.count(t)]
end

function iterTwo(t, i)
    local v1, v2 = t[i], t[i + 1]
    i = i + 2
    if v2 then
        return i, v1, v2
    elseif v1 then
        return i, v1, v1
    end
end

-------------------------------------
-- function strSplit
-- @brief 문자열을 sep문자 기준으로 분리
-------------------------------------
function stringSplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
	local i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end


datetime = {}
function datetime.getTimeZoneOffset()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end

function datetime.parseDate(str, pattern)
    local pattern = pattern or '(%d+)-(%d+)-(%d+)T(%d+):(%d+)'
    local t = {}
    t.year, t.month, t.day, t.hour, t.min, t.sec = str:match(pattern)
    return os.time(t) - datetime.getTimeZoneOffset() + 9 *60*60
end

function datetime.getTimestamp(tbl)
    local localtime
    if not tbl then
        localtime = os.time()
    else
        local date = os.date('*t')
        for k, v in pairs(tbl) do
            date[k] = v
        end
        localtime = os.time(date)
    end
    return localtime - datetime.getTimeZoneOffset() + 9 * 60 * 60
end

--fixed Str -> string.format(2012/11/15 by jjo)
function datetime.makeTimeDesc(sec, showSeconds, firstOnly)
    local showSeconds = showSeconds and true or false
    local sec = math.floor(sec)
    if sec < 60 then
        if showSeconds then
            return string.format('%d초', sec)
            --return Str('{1}초', sec)
        else
            return string.format('1분 미만')
            --return Str('1분 미만')
        end

    elseif sec < 3600 then
        local min = math.floor(sec / 60)
        sec = sec % 60
        if sec == 0 or firstOnly then
            return Str('{1}분', min)
        else
            return Str('{1}분 {2}초', min, sec)
        end

    elseif sec < 86400 then
        local hour = math.floor(sec / 3600)
        local min = math.floor(sec / 60) % 60
        if min == 0 or firstOnly then
            return Str('{1}시간', hour)
        else
            return Str('{1}시간 {2}분', hour, min)
        end

    else
        local day = math.floor(sec / 86400)
        local hour = math.floor(sec / 3600) % 24
        if hour == 0 or firstOnly then
            return Str('{1}일', day)
        else
            return Str('{1}일 {2}시간', day, hour)
        end
    end
end

function datetime.strformat(t)
    return os.date('%Y-%m-%d %H:%M', t)
end

Queue = {}
function Queue.new()
    local q = { first = 0, last = -1 }
    setmetatable(q, {__index = Queue})
    return q
end
function Queue:push(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
end
function Queue:pop()
    local first = self.first
    if first > self.last then error('queue empty') end
    local value = self[first]
    self[first] = nil
    self.first = first + 1
    return value
end
function Queue:empty()
    return self.first > self.last
end

-- 코루틴을 한 번 실행하고, s, r을 리턴한다.
-- s: 코루틴이 살아 있으면 true, 죽었으면 false (에러가 없어도 실행이 종료되었으면 false이다)
-- r: coroutine.yield()의 첫번째 인자
function updateCoroutine(c, ...)
    if not c then
        return false, 'cannot resume nil value'
    end
    local s, r = coroutine.resume(c, ...)
    if not s then
        -- 문제 상황 발생 (코루틴은 콜스택을 되돌리지 않기 때문에 여기서 바로 볼 수 있다)
        --_ErrorHandler(r, c)
        cclog("----------------------------------------")
        cclog("LUA ERROR in coroutine\n")
        cclog(debug.traceback(c, r))
        cclog("----------------------------------------")
    end
    s = coroutine.status(c) ~= 'dead'
    return s, r
end

-- 코루틴을 만들고 한 번 실행해 준다.
-- 그 실행에서 에러가 나거나 끝났으면 nil과 에러를 리턴한다.
function startCoroutine(f, ...)
    local c = coroutine.create(f)
    local s, r = updateCoroutine(c, ...)
    if s then
        return c
    else
        return nil, r
    end
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function randomShuffle(array)
    local arrayCount = #array
    for i = arrayCount, 2, -1 do
        local j = math.random(1, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function luadump(value, depth)
    local t = type(value)
    if t == 'table' then
        depth = depth or ''
        local newdepth = depth .. '\t'

        local s = '{\n'
        local n = #value
        for i = 1, n do
            s = s .. newdepth .. luadump(value[i], newdepth) .. ';\n'
        end
        for k, v in pairs(value) do
            if type(k) ~= 'number' or k <= 0 or k > n then
                s = s .. newdepth .. "['" .. k .. "']=" .. luadump(value[k], newdepth) .. ';\n'
            end
        end
        return s .. depth .. '}'

    elseif t == 'string' then
        return "'" .. value .. "'"
    else
        return tostring(value)
    end
end

---------------------------------
-- function ccdump
-- cclog + luadump 
---------------------------------
function ccdump(value, file_name)
	local dump = luadump(value)
	print('==================DUMP=====================')
	print(dump)
	print('-------------------------------------------')

	if (not file_name) then
		return
	end

	if (not isWin32()) then 
		return
	end

	local path = cc.FileUtils:getInstance():getWritablePath()
	local full_path = string.format('%sdump/%s.txt', path, file_name)

	local f = io.open(full_path,'w')
	if (not f) then
		return
	end

	f:write(dump)
	f:close()
end

---------------------------------
-- function ccdebug
-- cclog + debug.traceback() 
---------------------------------
function ccdebug()
    cclog(debug.traceback())
end

function convertToParentCoord(parent, target)
    local p, x, y = target, 0, 0
    repeat
        x = x + p:getPositionX()
        y = y + p:getPositionY()
        p = p:getParent()
    until p == nil or p == parent

    return CCPoint(x, y)
end

--add stack(2012/11/08 by jjo)
Stack={}
function Stack:new(t)
    return setmetatable(t or {}, {__index = Stack})
end
function Stack:push(...)
    for _,v in ipairs{...} do
        self[#self+1] = v
    end
end
function Stack:pop(n)
    local n = n or 1
    if n > #self then
        return nil
    end
    local ret = {}
    for i = n,1,-1 do
        ret[#ret+1] = table.remove(self)
    end
    return unpack(ret)
end

--add number format(2012/11/13 by jjo)
function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

--lap number format
--전체 초를 넣으면 00:00.00 형태 (분, 초, 형태로 리턴해준다)
function lap_value(sec)
    --local m = sec / 60
    --local s = sec % 60
    --return string.format('%02d:%2.2f', m, s)
    return string.format('%2.2f', sec)
end

--add Str method for translation
function Str(id, ...)
    return formatMessage(Translate:get(id), ...)
end

function formatMessage(str, ...)
    local args = {...}
    for i = 1, #args do
        str = str:gsub('{'..(i)..'}', tostring(string.gsub(args[i], '\n', ' ')))
    end
    return str
end

function doAllChildren(node, func)
    local childs = node:getChildren()
    for i,v in pairs(childs) do
        doAllChildren(v, func)
    end

    if func then
        func(node)
    end
end

-------------------------------------
-- function isExistValue
-- @breif value가 존재하는지 여부
-------------------------------------
function isExistValue(value, ...)
    local args = {...}
    for i,v in ipairs(args) do
        if (value == v) then
            return true
        end
    end

    return false
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
-- function getDegreeFromChar
-------------------------------------
function getDegreeFromChar(char1, char2)
	if (not char2) then return nil end
    return getDegree(char1.pos.x, char1.pos.y, char2.pos.x, char2.pos.y)
end

-------------------------------------
-- function getDegree
-------------------------------------
function getDegree(curr_x, curr_y, dest_x, dest_y)
    local dx, dy = dest_x - curr_x, dest_y - curr_y
    local rad = math_atan2(dy, dx)
    local deg = math_deg(rad)
    return deg
end

-------------------------------------
-- function bezierat
-- @breif bezier 좌표 계산
-------------------------------------
function bezierat(a, b, c, d, t)
    return (math_pow(1-t,3) * a + 
            3*t*(math_pow(1-t,2))*b + 
            3*math_pow(t,2)*(1-t)*c +
            math_pow(t,3)*d );
end

-------------------------------------
-- function getBezier
-------------------------------------
function getBezier(tar_x, tar_y, pos_x, pos_y, course)
	local dist_x = tar_x - pos_x
	local dist_y = tar_y - pos_y

	local temp_x1 = dist_x/3
	local temp_y1 = dist_y/3

	local temp_x2 = temp_x1 * 2
	local temp_y2 = temp_y1 * 2

	local degree = getDegree(pos_x, pos_y, tar_x, tar_y)
	local angle = degree + 90 * course
	local distance = getDistance(tar_x, tar_y, pos_x, pos_y)/3
	
	local move_size = getPointFromAngleAndDistance(angle, distance)

    local bezier = {
        cc.p(temp_x1 + move_size['x'], temp_y1 + move_size['y']),
        cc.p(temp_x2 + move_size['x'], temp_y2 + move_size['y']),
        cc.p(dist_x, dist_y),
    }

	return bezier
end

-------------------------------------
-- function getBezierPosList
-------------------------------------
function getBezierPosList(tar_x, tar_y, pos_x, pos_y, course)
    local t_pos_list = {}

	local bezier = getBezier(tar_x, tar_y, pos_x, pos_y, course)
	local distance = getDistance(tar_x, tar_y, pos_x, pos_y)

	local count = (distance / 70)

    for time=0, 1, 1/count do
        local xa = 0
        local xb = bezier[1]['x']
        local xc = bezier[2]['x']
        local xd = bezier[3]['x']

        local ya = 0
        local yb = bezier[1]['y']
        local yc = bezier[2]['y']
        local yd = bezier[3]['y']

        local x = bezierat(xa, xb, xc, xd, time) + pos_x
        local y = bezierat(ya, yb, yc, yd, time) + pos_y

        table.insert(t_pos_list, {x = x, y = y})
    end

    return t_pos_list
end

-------------------------------------
-- function isCollision
-- @brief body size를 고려한 충돌 여부 판단, 원형 
-- @return boolean
-------------------------------------
function isCollision(x, y, target, range)
	local distance = getDistance(x, y, target.pos['x'], target.pos['y'])
	return distance - target.body['size'] < range
end

-------------------------------------
-- function isCollision_Rect
-- @brief body size를 고려한 충돌 여부 판단, 사각형 
-- @return boolean
-------------------------------------
function isCollision_Rect(x, y, target, range_x, range_y)
	local target_x = target.pos.x
	local target_y = target.pos.y
	return (math_abs(target_x - x) < range_x) and (math_abs(target_y - y) < range_y)
end

-------------------------------------
-- function addChild
-- @brief addChild수행과 parent의 globalZOrder를 자식들이 따르도록 지정
-------------------------------------
function addChild(parent, child, local_z_order)
    parent:addChild(child, local_z_order or 0)

    local global_z_order = parent:getGlobalZOrder()
    setGlobalZOrderRecursive(child, global_z_order)
end

-------------------------------------
-- function setGlobalZOrderRecursive
-- @brief globalZOrder지정
-------------------------------------
function setGlobalZOrderRecursive(node, global_z_order)
    if (not node) then
        return
    end

    node:setGlobalZOrder(global_z_order)
    local childs = node:getChildren()
    for _,child in ipairs(childs) do
        setGlobalZOrderRecursive(child, global_z_order)
    end
end

-------------------------------------
-- function getSortPosList
-- @brief 리스트를 가운데 정렬 시킬 때 사용
-------------------------------------
function getSortPosList(interval, count)

    local start_pos = 0

    if ((count % 2) == 0) then
        start_pos = (-((count / 2) - 0.5)) * interval
    else
        start_pos = (-((count - 1) / 2)) * interval
    end

    local l_pos = {}
    for i=1, count do
        table.insert(l_pos, start_pos)
        start_pos = start_pos + interval
    end

    return l_pos
end

-------------------------------------
-- function printMemory
-- @brief 보기 좋게 현재 메모리 출력
-------------------------------------
function PrintMemory(str)
	local str = str or 'CHECK MEMORY'
	cclog(string.format('### %s : %.2f MB', str, collectgarbage('count') / 1024))
end