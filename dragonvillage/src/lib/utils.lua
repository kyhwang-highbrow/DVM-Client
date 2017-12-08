--###############################################
-- utility funciton : table
--###############################################

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

function table.isEmpty(t)
    for _ in pairs(t) do
        return false
    end

    return true
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

function table.addList(t1, t2)
    for i, v in ipairs(t2) do
        table.insert(t1, v)
    end
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
-- function table.clone
-- @brief 테이블을 복사하되 내부 객체들은 복사하지 않는다.
-------------------------------------
function table.clone(t_org)
	local t_ret = {}
    for i, v in ipairs(t_org) do
        table.insert(t_ret, v)
    end
	return t_ret
end

-------------------------------------
-- function listToMap
-- @brief 리스트 형태의 테이블을 맵 형태로 변경
-------------------------------------
function table.listToMap(t, key)
    local t_ret = {}

    for i,v in pairs(t) do
        local primary_key = v[key]

        if t_ret[primary_key] then
            ccdebug()
            cclog('## 키가 중복됩니다 : ' .. primary_key )
        end

        t_ret[primary_key] = v
    end

    return t_ret
end

-------------------------------------
-- function MapToList
-- @brief 맵 -> 리스트
-------------------------------------
function table.MapToList(t)
    local t_ret = {}
	for _, v in pairs(t) do
		table.insert(t_ret, v)
	end

	return t_ret
end

-------------------------------------
-- function changeKeyToNumber
-- @brief json에서 key값이 숫자일 경우 string으로 저장되는 이슈
-------------------------------------
function table.changeKeyToNumber(t)
    local t_ret = {}

    for i,v in pairs(t) do
        t_ret[tonumber(i)] = v
    end

    return t_ret
end

-------------------------------------
-- function toNumber
-- @brief 테이블 안에 테이블을 가지고 있고
--        세부 테이블의 특정 컬럼들을 number타입으로 변경해주는 함수
-- @ex    local to_number_list = {'cash_reward', 'req_point'}
--        table.toNumber(l_collection_table, to_number_list)
-------------------------------------
function table.toNumber(t, to_number_list)
    for i,v in pairs(t) do
        if type(v) ~= 'table' then
            t[i] = tonumber(v)
        else
            for _,key in pairs(to_number_list) do
                if v[key] then
                    v[key] = tonumber(v[key])
                end
            end
        end
    end

    return t
end

-------------------------------------
-- function sortRandom
-- @brief 인덱스 테이블을 랜덤하게 정렬
-------------------------------------
function table.sortRandom(t_org)
    local t_ret = {}
    local t_random = {}

    for i,v in pairs(t_org) do
        table.insert(t_random, i)
    end

    while (0 < #t_random) do
        local rand_num = math_random(1, #t_random)
        local rand_idx = t_random[rand_num]
        table.insert(t_ret, t_org[rand_idx])
        table.remove(t_random, rand_num)
    end

    return t_ret
end

-------------------------------------
-- function getRandom
-- @brief 인덱스 테이블에서 랜덤 값 리턴
-------------------------------------
function table.getRandom(t)
    local cnt = #t

    if (cnt <= 0) then
        return nil
    elseif (cnt == 1) then
        return t[1]
    else
        local rand = math_random(1, #t)
        return t[rand]
    end
end

-------------------------------------
-- function getRandomList
-- @brief 인덱스 테이블에서 max_cnt 만큼 중복되지 않은 리스트 추출
-------------------------------------
function table.getRandomList(list, max_cnt)
	local l_random = table.sortRandom(list)
	local l_ret = {}
	local count = 0

	for _, item in pairs(l_random) do
		table.insert(l_ret, item)
		count = count + 1
		if (count >= max_cnt) then
			break;
		end
	end

	return l_ret
end

-------------------------------------
-- function getFirst
-- @brief 인덱스 테이블 처음값 리턴
-------------------------------------
function table.getFirst(t)
    local first = nil
    local key = nil
    first = t[1]

    if (first) then
        key = 1
        return first, key
    end

    for i,v in pairs(t) do
        first = v
        key = i
        break
    end
    return first, key
end

-------------------------------------
-- function getLast
-- @brief 인덱스 테이블 마지막값 리턴
-------------------------------------
function table.getLast(t)
	return t[table.count(t)]
end

-------------------------------------
-- function getPartList
-- @brief 인덱스 테이블 앞에서부터 지정된 갯수만 추출
-------------------------------------
function table.getPartList(t, count)
    if (not count) then return t end

	local t_ret = {}
	for i = 1, count do
		if (t[i]) then
			table.insert(t_ret, t[i])
		end
	end
	return t_ret
end

-------------------------------------
-- function pop
-- @brief stack의 pop
-------------------------------------
function table.pop(t)
	local item = table.getFirst(t)
	if (#t > 0) then
		table.remove(t, 1)
	end
	return item
end

-------------------------------------
-- function apply
-- @brief 덮어씌우기
-------------------------------------
function table.apply(t_org, t_data)
	for i, v in pairs(t_org) do
		t_org[i] = t_data[i]
	end
end

--###############################################
-- utility funciton : datetime
--###############################################
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

--###############################################
-- utility funciton : Stack
--###############################################
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

--###############################################
-- utility funciton : Queue
--###############################################
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


--###############################################
-- utility funciton : others
--###############################################

-- 코루틴을 한 번 실행하고, s, r을 리턴한다.
-- s: 코루틴이 살아 있으면 true, 죽었으면 false (에러가 없어도 실행이 종료되었으면 false이다)
-- r: coroutine.yield()의 첫번째 인자
function updateCoroutine(c, ...)
    if not c then
        return false, 'cannot resume nil value'
    end

    local s, r = coroutine.resume(c, ...)
    local msg = ''
    if not s then
        -- 문제 상황 발생 (코루틴은 콜스택을 되돌리지 않기 때문에 여기서 바로 볼 수 있다)
        --_ErrorHandler(r, c)
        msg = debug.traceback(c, r)
        cclog("----------------------------------------")
        cclog("LUA ERROR in coroutine\n")
        cclog(msg)
        cclog("----------------------------------------")
    end
    s = coroutine.status(c) ~= 'dead'
    return s, r, msg
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
-- function json_decode
---------------------------------
function json_decode(content, remove_comment)
	if (remove_comment) then
		content = json_removeComment(content)
	end
	return json.decode(content)
end

---------------------------------
-- function json_removeComment
---------------------------------
function json_removeComment(content)
	return string.gsub(content, '/%/.-%\n', '')
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

-------------------------------------
-- function ccdisplay
-- @brief cclog와 동시에 UI에 메세지를 출력해준다.
-------------------------------------
function ccdisplay(...)
	cclog(...)
	
	local str = ''
	for i, v in pairs({...}) do
        if (not v) then
            v = 'nil'
        end
		str = str .. v
	end

    UIManager:toastNotificationGreen(str)
end

-------------------------------------
-- function isNumber
-------------------------------------
function isNumber(v)
	return v and (type(v) == 'number')
end

-------------------------------------
-- function isString
-------------------------------------
function isString(v)
	return v and (type(v) == 'string')
end

-------------------------------------
-- function isTable
-------------------------------------
function isTable(v)
	return v and (type(v) == 'table')
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

--add number format(2012/11/13 by jjo)
function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    if (not num) then
        error('invalid paramater in comma_value function : ' .. n)
    end
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

-------------------------------------
-- function Str
-- @brief add Str method for translation
-------------------------------------
function Str(id, ...)
    return formatMessage(Translate:get(id), ...)
end

-------------------------------------
-- function formatMessage
-------------------------------------
function formatMessage(str, ...)
    local args = {...}
    local value
    for i = 1, #args do
        value = args[i]
        if (type(value) == 'string') then
            value = Translate:get(value)
        end
        str = str:gsub('{'..(i)..'}', value)
    end
    return str
end

-------------------------------------
-- function stringSplit
-- @brief 문자열을 sep문자 기준으로 분리
-- @comment 사용하는 곳이 없음
-------------------------------------
function stringSplit(inputstr, sep)
	if (not inputstr) then 
		return nil
	end
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

-------------------------------------
-- function plSplit
-- @brief penlight 사용한 split
-------------------------------------
function plSplit(inputstr, sep)
    if (not inputstr) or (not sep) then
        return
    end
    local t = pl.stringx.split(inputstr, sep)
    return t
end

-------------------------------------
-- function getHeadCapitalStr
-- @brief 첫글자 대문자로 변환
-------------------------------------
function getHeadCapitalStr(str)
    local head = str:sub(1,1)
    return str:gsub(head, head:upper(), 1)
end

-------------------------------------
-- function doAllChildren
-------------------------------------
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
-- function isContainValue
-- @breif value를 포함하는 테이블인지 여부
-------------------------------------
function isContainValue(value, t)
    for i,v in pairs(t) do
        if (value == v) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function getDegreeFromChar
-------------------------------------
function getDegreeFromChar(char1, char2)
	if (not char2) then return nil end
    return getDegree(char1.pos.x, char1.pos.y, char2.pos.x, char2.pos.y)
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
-- function getRandomBezier
-------------------------------------
function getRandomBezier(tar_x, tar_y, pos_x, pos_y, distance)
	local dist_x = tar_x - pos_x
	local dist_y = tar_y - pos_y

	local temp_x1 = dist_x/3
	local temp_y1 = dist_y/3

	local temp_x2 = temp_x1 * 2
	local temp_y2 = temp_y1 * 2

	local degree = getDegree(pos_x, pos_y, tar_x, tar_y)
	local angle = degree + 90 * (math_random(0, 2) - 1)
	--local distance = getDistance(tar_x, tar_y, pos_x, pos_y)/3
	
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

-------------------------------------
-- function convertToWorldSpace
-- @breif Node클래스의 convertToWorldSpace는
--        퍼플랩에서 새로 추가한 DockPoint가
--        고려되어 있지 않아서 Lua에서 별도로 구현함
-- @return cc.p 화면의 좌하단을 0, 0으로 하는 좌표의 포지션 리턴
-------------------------------------
function convertToWorldSpace(node)
    local parent = node:getParent()

    if (not parent) then
        local x, y = node:getPosition()
        return cc.p(x, y)
    end

    local x, y = node:getPosition()
    local dock_point = node:getDockPoint()

    local parent_content_size = parent:getContentSize()

    x = x + (dock_point['x'] * parent_content_size['width'])
    y = y + (dock_point['y'] * parent_content_size['height'])

    local world_space = parent:convertToWorldSpace(cc.p(x, y))

    return world_space
end

-------------------------------------
-- function convertToNodeSpace
-- @breif
-------------------------------------
function convertToNodeSpace(node, location, dock_point)
    local node_space = node:convertToNodeSpace(location)
    local dock_point = (dock_point or cc.p(0.5, 0.5))

    local content_size = node:getContentSize()

    node_space['x'] = node_space['x'] - (dock_point['x'] * content_size['width'])
    node_space['y'] = node_space['y'] - (dock_point['y'] * content_size['height'])

    return node_space
end

-------------------------------------
-- function convertToAnoterParentSpace
-- @breif 다른 부모 노드의 기준으로 위치를 변경
--        예를들어 테이블뷰의 하나의 Cell을 클릭했을 때
--        테이블뷰는 사라지고 해당 Cell만 UI의 root에 붙이고 싶을 때 사용
-------------------------------------
function convertToAnoterParentSpace(node, anoter_parent)
    local world_pos = convertToWorldSpace(node)

    local node_space = anoter_parent:convertToNodeSpace(world_pos)

    local dock_point = node:getDockPoint()
    local anoter_parent_content_size = anoter_parent:getContentSize()

    node_space['x'] = node_space['x'] - (dock_point['x'] * anoter_parent_content_size['width'])
    node_space['y'] = node_space['y'] - (dock_point['y'] * anoter_parent_content_size['height'])

    return node_space
end


-------------------------------------
-- function convertToAnoterNodeSpace
-- @brief parent가 같고 dock_point가 서로 다른 두개의 Node가 있을 경우
--        target_node의 position을 node의 dock_point 기준으로 변경해주는 함수
--        즉, node를 target_node의 위치로 옮기고 싶을 때 사용하면 됨
-------------------------------------
function convertToAnoterNodeSpace(node, target_node)
    local parent = target_node:getParent()
    local parent_content_size = parent:getContentSize()

    local x, y = target_node:getPosition()
    local dock_point = target_node:getDockPoint()

    local x = x + (dock_point['x'] * parent_content_size['width'])
    local y = y + (dock_point['y'] * parent_content_size['height'])

    local dock_point = node:getDockPoint()

    local x = x - (dock_point['x'] * parent_content_size['width'])
    local y = y - (dock_point['y'] * parent_content_size['height'])

    return cc.p(x, y)
end

-------------------------------------
-- function listToScv
-- @brief 리스트 항목을 comma separated value 형태의 문자열로 변환
-------------------------------------
function listToCsv(list)
    local str = nil
    for i,v in ipairs(list) do
        if (str == nil) then
            str = tostring(v)
        else
            str = str .. ',' .. tostring(v)
        end
    end

    return str
end

-------------------------------------
-- function getDigit
-- @brief id에서 특정 자릿수를 리턴
-- @param id
-- @param base_digit 기본 자릿수
-- @param range 자릿수 범위
-- ex) IDHelper:getDigit(12345, 100, 2) = 23
-------------------------------------
function getDigit(id, base_digit, range)
    local range = range or 1
    local digit = math_floor((id % (base_digit * math_pow(10, range)))/base_digit)
    return digit
end

-------------------------------------
-- function getQuadrant
-- @brief 기준점으로부터 해당 좌표가 몇사분면인지 계산
-------------------------------------
function getQuadrant(center_x, center_y, pos_x, pos_y)
    local quadrant

    if (pos_x >= center_x) then
        if (pos_y >= center_y) then     quadrant = 1
        else                            quadrant = 2
        end
    elseif (pos_x < center_x) then
        if (pos_y >= center_y) then     quadrant = 4
        else                            quadrant = 3
        end
    end

    return quadrant
end

-------------------------------------
-- function changeAnchorPointWithOutTransPos
-- @brief 포지션 변경없이 앵커 포인트만 변경
-------------------------------------
function changeAnchorPointWithOutTransPos(node, cha_anchor)
    local ori_anchor = node:getAnchorPoint()
    local ori_pos_x, ori_pos_y = node:getPosition()
    local content_size = node:getContentSize()

    local cha_pos_x = ori_pos_x + (cha_anchor.x - ori_anchor.x) * content_size['width']
    local cha_pos_y = ori_pos_y + (cha_anchor.y - ori_anchor.y) * content_size['height']

    node:setAnchorPoint(cha_anchor)
    node:setPosition(cha_pos_x, cha_pos_y)
end