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

function table.removeItemFromList(list, remove_v)
    for i, v in ipairs(list) do
        if (v == remove_v) then
            table.remove(list, i)
            break
        end
    end
end

function table.removeAllItemFromList(list, remove_v)
    for i = #list, 1, -1 do 
        local v = list[i]
        if (v == remove_v) then
            table.remove(list, i)
        end
    end
end

-------------------------------------
-- function removeIndexFromList
-- @brief 리스트에서 s_idx부터 e_idx까지 제거한다.
-- @param s_idx(number) 제거하려는 인덱스 리스트의 시작 인덱스, 없으면 1
-- @param e_idx(number) 제거하려는 인덱스 리스트의 마지막 인덱스, 없으면 #list
-------------------------------------
function table.removeIndexFromList(list, s_idx, e_idx)
    local s_idx = (s_idx or 1)
    local e_idx = (e_idx or #list)
    for idx = #list, 1, - 1 do
        if ((s_idx <= idx) and (idx <= e_idx)) then
            table.remove(list, idx)
        end
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
-- function clone
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
	local item, key = table.getFirst(t)
	if (#t > 0) then
		table.remove(t, key)
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

-------------------------------------
-- function contain
-- @breif isContainValue과 같다
-------------------------------------
function table.contain(t, value)
    for i, v in pairs(t) do
        if (value == v) then
            return true
        end
    end

    return false
end


--###############################################
-- utility funciton : datetime
--###############################################
datetime = {}
-------------------------------------
-- function getTimeZoneOffset
-- @brief 로컬(기기)의 타임존 차이 확인
-------------------------------------
function datetime.getTimeZoneOffset()
    local now = os.time() -- UTC+0 기준
    local now_utc = os.time(os.date("!*t", now))
    return now - now_utc -- 서버와 로컬 기기의 타임존 차이를 리턴 (한국의 경우 32400(+9시간) 반환 )
end

function datetime.parseDate(str, pattern)
    local pattern = pattern or '(%d+)-(%d+)-(%d+)T(%d+):(%d+)'
    local t = {}
    t.year, t.month, t.day, t.hour, t.min, t.sec = str:match(pattern)

    if (tonumber(t.year) > 2037) then
        cclog('#### WARNING!! #### datetime.parseDate year : ' .. t.year)
        cclog('year가 2037 이상이 되면 os.time함수에서 nil을 리턴함. 따라서 2037로 보정함.')
        t.year = '2037'
    end
    return os.time(t) + datetime.getTimeZoneOffset()
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
    return localtime + datetime.getTimeZoneOffset()
end

--fixed Str -> string.format(2012/11/15 by jjo)
function datetime.makeTimeDesc(sec, showSeconds, firstOnly, timeOnly)
    local showSeconds = showSeconds and true or false
    local sec = math.floor(sec)
    if sec < 60 then
        if showSeconds then
            --return string.format('%d초', sec)
            return Str('{1}초', sec)
        else
            --return string.format('1분 미만')
            return Str('1분 미만')
        end

    elseif sec < 3600 then
        local min = math.floor(sec / 60)
        sec = sec % 60
        if sec == 0 or firstOnly then
            return Str('{1}분', min)
        else
            return Str('{1}분 {2}초', min, sec)
        end

    elseif sec < 86400 or timeOnly then
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

-------------------------------------
-- function makeTimeDesc2
-------------------------------------
function datetime.makeTimeDesc2(sec)
    local sec = math.floor(sec)
    if sec < 3600 then
        local min = math.floor(sec / 60)
        return Str('{1}분', min)

    elseif sec < 86400 or timeOnly then
        local hour = math.floor(sec / 3600)
        local min = math.floor(sec / 60) % 60
        return Str('{1}시간 {2}분', hour, min)

    else
        local day = math.floor(sec / 86400)
        local hour = math.floor(sec / 3600) % 24
        local min = math.floor(sec / 60) % 60
        return Str('{1}일 {2}시간 {3}분', day, hour, min)
    end
end

-------------------------------------
-- function makeTimeDesc_HHMM
-- @brief 'hh:mm:ss', '00:00', '23:59' 형식의 시간 표기
-- @param seconds(number) 단위:초
-- @return time_str(string) 'hh:mm'
-------------------------------------
function datetime.makeTimeDesc_HHMM(seconds)
    local _seconds = tonumber(seconds)
    if (_seconds == nil) then
        return '00:00:00'
    end

    -- 시 (60초 * 60분 = 3600초)
    local hour = math.floor(_seconds / 3600)
    _seconds = _seconds - (hour * 3600)

    -- 분 (60초)
    local min = math.floor(_seconds / 60)
    _seconds = _seconds - (min * 60)

    -- 문자열 포맷팅
    local time_str = string.format('%.2d:%.2d',  hour, min)
    return time_str
end

-------------------------------------
-- function makeTimeDesc_HHMMSS
-- @brief 'hh:mm:ss', '00:00:00', '23:59:04' 형식의 시간 표기
-- @param seconds(number) 단위:초
-- @return time_str(string) 'hh:mm:ss'
-------------------------------------
function datetime.makeTimeDesc_HHMMSS(seconds)
    local _seconds = tonumber(seconds)
    if (_seconds == nil) then
        return '00:00:00'
    end

    -- 시 (60초 * 60분 = 3600초)
    local hour = math.floor(_seconds / 3600)
    _seconds = _seconds - (hour * 3600)

    -- 분 (60초)
    local min = math.floor(_seconds / 60)
    _seconds = _seconds - (min * 60)

    -- 초
    local sec = math.floor(_seconds)

    -- 문자열 포맷팅
    local time_str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)
    return time_str
end

function datetime.makeTimeDesc_timer(milliseconds, day_special)
    local day = math.floor(milliseconds / 86400000)
    milliseconds = milliseconds - (day * 86400000)

    local hour = math.floor(milliseconds / 3600000)
    milliseconds = milliseconds - (hour * 3600000)

    local min = math.floor(milliseconds / 60000)
    milliseconds = milliseconds - (min * 60000)

    local sec = math.floor(milliseconds / 1000)
    milliseconds = milliseconds - (sec * 1000)

    local millisec = milliseconds

    local str = ''
    if (0 < day) then
        --str = string.format('%.2d:%.2d:%.2d:%.2d:%.3d', day, hour, min, sec, millisec)
        str = string.format('%.2d:%.2d:%.2d:%.2d', day, hour, min, sec)
        if day_special then
            --local day_str = Str('{1}일', day)
            --local hour_min_sec_str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)
            --str = Str('{1} {2}', day_str, hour_min_sec_str)

            str = Str('{1}일 {2}:{3}:{4}', day, string.format('%.2d',  hour), string.format('%.2d',  min), string.format('%.2d',  sec))
        end

    elseif (0 < hour) then
        --str = string.format('%.2d:%.2d:%.2d:%.3d',  hour, min, sec, millisec)
        str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)

    elseif (0 < min) then
        --str = string.format('%.2d:%.2d:%.3d',  min, sec, millisec)
        str = string.format('%.2d:%.2d',  min, sec)

    --elseif (0 < sec) then
    else
        --str = string.format('%.2d:%.3d', sec, millisec)
        str = string.format('%d', sec)

    end

    return str
end

-------------------------------------
-- function makeTimeDesc_millsecTimer
-------------------------------------
function datetime.makeTimeDesc_millsecTimer(milliseconds, timeOnly)
    local day = math.floor(milliseconds / 86400000)
    if (timeOnly) then
        day = 0
    else
        milliseconds = milliseconds - (day * 86400000)
    end

    local hour = math.floor(milliseconds / 3600000)
    milliseconds = milliseconds - (hour * 3600000)

    local min = math.floor(milliseconds / 60000)
    milliseconds = milliseconds - (min * 60000)

    local sec = math.floor(milliseconds / 1000)
    milliseconds = milliseconds - (sec * 1000)

    local millisec = milliseconds

    local str = ''
    if (0 < day) then
        if hour == 0 then
            return Str('{1}일', day)
        else
            return Str('{1}일 {2}시간', day, hour)
        end

    else
        str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)

    end

    return str
end

-------------------------------------
-- function makeTimeDesc_millsec
-------------------------------------
function datetime.makeTimeDesc_millsec(milliseconds)
    local day = math.floor(milliseconds / 86400000)
    milliseconds = milliseconds - (day * 86400000)

    local hour = math.floor(milliseconds / 3600000)
    milliseconds = milliseconds - (hour * 3600000)

    local min = math.floor(milliseconds / 60000)
    milliseconds = milliseconds - (min * 60000)

    local sec = math.floor(milliseconds / 1000)
    milliseconds = milliseconds - (sec * 1000)

    local millisec = milliseconds

    local str = ''
    if (0 < day) then
        str = string.format('%.2d:%.2d:%.2d:%.2d:%.3d', day, hour, min, sec, millisec)

    elseif (0 < hour) then
        str = string.format('%.2d:%.2d:%.2d:%.3d',  hour, min, sec, millisec)

    elseif (0 < min) then
        str = string.format('%.2d:%.2d:%.3d',  min, sec, millisec)

    else
        str = string.format('%.2d:%.3d', sec, millisec)

    end

    return str
end

-- 01:09:09 (dd:hh:mm)
function datetime.makeTimeDesc_timer_filledByZero(milliseconds, from_day)
    local day = math.floor(milliseconds / 86400000)
    milliseconds = milliseconds - (day * 86400000)

    local hour = math.floor(milliseconds / 3600000)
    milliseconds = milliseconds - (hour * 3600000)

    local min = math.floor(milliseconds / 60000)
    milliseconds = milliseconds - (min * 60000)

    local sec = math.floor(milliseconds / 1000)
    milliseconds = milliseconds - (sec * 1000)

    local millisec = milliseconds

    local str = ''
    hour = day * 24 + hour
    str = string.format('%.2d:%.2d:%.2d', hour, min, sec)
    
    return str
end

function datetime.dayToSecond(day)
    -- 일 * 시 * 분 * 초
    local seconds = day * 24 * 60 * 60
    return seconds
end

function datetime.secondToDay(seconds)
    local day = seconds / (24 * 60 * 60)
    return day
end

function datetime.secondToHour(seconds)
    local hour = math_floor(seconds / (60 * 60))
    return hour
end

function datetime.strformat(t)
    return os.date('%Y-%m-%d %H:%M', t)
end

function datetime.getTimeUTCHourStr()
    -- h : UTC 기준 시각 (UTC+h)
	local h = Timer:getUTCHour()
    local utc = ''
    if h >= 0 then
        utc = Str('UTC+{1}', h)
    else
        utc = Str('UTC{1}', h)
    end

    -- t : 현재시간
    local utc_time = Timer:getServerTime() - datetime.getTimeZoneOffset() 
    local hour = Timer:getUTCHour()
    local t = os.date('*t', utc_time + (hour * 60 * 60))

	local function unit(value)
		if value < 10 then
			return  '0' .. tostring(value)
		else
			return tostring(value)
		end
	end

    return utc, t
end

function datetime.getTimeUTCDesc()
    -- h : UTC 기준 시각 (UTC+h)
	local h = Timer:getUTCHour()
    local utc = ''
    if h >= 0 then
        utc = Str('UTC+{1}', h)
    else
        utc = Str('UTC{1}', h)
    end

    -- t : 현재시간
    local utc_time = Timer:getServerTime() - datetime.getTimeZoneOffset() 
    local hour = Timer:getUTCHour()
    local t = os.date('*t', utc_time + (hour * 60 * 60))

	local function unit(value)
		if value < 10 then
			return  '0' .. tostring(value)
		else
			return tostring(value)
		end
	end

    local desc = Str('{1}/{2},{3}:{4}({5})', unit(t.month), unit(t.day), unit(t.hour), unit(t.min), utc)

    return desc
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


-------------------------------------
-- function checkMemberInMetatable
-- param name string
-------------------------------------
function checkMemberInMetatable(obj, name)
    local pObj = getmetatable(obj)

    while(pObj ~= nil) do
        if rawget(pObj, name) ~= nil then
            return true
        end
        pObj = rawget(pObj, 'def') and rawget(pObj, 'def') or rawget(pObj, 'super')
    end

    return false
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

-------------------------------------
-- function isNullOrEmpty
-- 널이나 빈 스트링인지?
-------------------------------------
function isNullOrEmpty(v)
    if (not v or v == '') then
        return true
    end

    return false
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
	if (not id) then
		cclog('## trying to translate NIL // check it')
		return
	end

    local str = formatMessage(Translate:get(id), ...)

    -- 한글이라면 조사 선택 처리
    if string.match(str, '[가-힣]') then
        str = SetKrJosa(str)
    end

    return str
end

-------------------------------------
-- function StrForDev
-- @brief 개발시에만 사용되는 텍스트 (번역 추출대상 X)
-- @example MakeSimplePopup(POPUP_TYPE.OK, StrForDev('프롤로그 영상은 android, iOS에서만 재생됩니다.'))
-------------------------------------
function StrForDev(str, ...)
    local ret_str = formatMessage(Translate:get(str), ...)
    return ret_str
end


-------------------------------------
-- function isValidMail
-- @brief 해당 이메일이 올바른 이메일인지 판단 (참고 https://ohdoylerules.com/snippets/validate-email-with-lua/)
-------------------------------------
function isValidMail(str)
    local _,nAt = str:gsub('@','@') -- Counts the number of '@' symbol
	if nAt > 1 or nAt == 0 or str:len() > 254 or str:find('%s') then return false end
    
    local delimeter_at = str:find('@')
    local localPart = str:sub(1, math_max(0, (delimeter_at - 1))) -- Returns the substring before '@' symbol
    local domainPart = str:sub(delimeter_at, #str) -- Returns the substring after '@' symbol
	if not localPart or not domainPart then return false end

	if not localPart:match("[%w!#%$%%&'%*%+%-/=%?^_`{|}~]+") or (localPart:len() > 64) then return false end
	if localPart:match('^%.+') or localPart:match('%.+$') or localPart:find('%.%.+') then return false end

	if not domainPart:match('[%w%-_]+%.%a%a+$') or domainPart:len() > 253 then return false end
	local delimeter_at = domainPart:find('%.')
    local fDomain = domainPart:sub(1, math_max(0, (delimeter_at - 1))) -- Returns the substring in the domain-part before the last (dot) character
	if fDomain:match('^[_%-%.]+') or fDomain:match('[_%-%.]+$') or fDomain:find('%.%.+') then return false end

	return true
end

-------------------------------------
-- function formatMessage
-------------------------------------
function formatMessage(str, ...)
    local args = {...}
    local value
    for i = 1, #args do
        --[[
        value = args[i]
        if (type(value) == 'string') then
            value = Translate:get(value)
        end
        str = str:gsub('{'..(i)..'}', value)
        --]]
        str = str:gsub('{'..(i)..'}', tostring(args[i]))
    end
    return str
end

-------------------------------------
-- function SetKrJosa
-- @brief 앞 단어 받침에 따른 조사 선택
-------------------------------------
function SetKrJosa(str)
    -- 구분되는 조사 리스트
    -- idx 1 : 받침 있을 때, idx 2 : 받침 없을 때
    -- ex : {'이', '가'} -> 받침 있을 때는 '이', 없을 때는 '가' 로 선택
    local l_josa_set_list = {{'이', '가'}, {'은', '는'}, {'을', '를'}, {'과', '와'}}
    
    -- 텍스트에 해당 조사 키워드가 감싸지는 방법
    -- idx 1 : prefix, idx 2 : middle, idx 3 : postfix
    -- ex: 을(를), (을)를
    local l_deco_list = {{'', '(', ')'}, {'(', ')', ''}}

    local l_find_josa_list = {}

    -- 해당 조사에 대해 찾고 값 변환
    local function find_and_change(str, josa_set, deco)
        local find_josa = deco[1] .. josa_set[1] .. deco[2] .. josa_set[2] .. deco[3]
        local josa_byte = string.len(find_josa)
        
        -- 만약 해당 조사를 찾았는데 조사를 선택하기 애매한 경우 조사를 선택하지 않음
        -- 그런데 그와 같은 조사가 뒷 문장에 더 있었고, 그 조사에 대해서는 선택이 가능할 때
        -- replace 함수를 이용하면 왼 쪽의 조사부터 바뀜, 따라서 선택이 불가능했던 조사에 대해서는
        -- ^josa1^ 등으로 변환해서 가지고 있다가 마지막에 다시 변환시킴 
        table.insert(l_find_josa_list, find_josa)
        local replace_nochoice_josa = '^josa'.. tostring(#l_find_josa_list) ..'^'

        --cclog(find_josa)

        -- josa_idx는 바이트 수로 계산이 됨 (한글 = 3byte)
        local josa_idx = pl.stringx.lfind(str, find_josa)
        local search_idx = 1

        while (josa_idx ~= nil) do
            --cclog('josa idx : ' .. josa_idx)
            -- 찾은 인덱스 바로 이전의 문자 찾기
            local find_char_idx = 0 -- start idx
            local find_char_byte = 0 -- byte len
            while (search_idx < josa_idx) do
                --cclog('search idx : ' .. search_idx)

                -- 현재 문자의 byte
                local char_byte = 0
                if (str:byte(search_idx) >= 0 and str:byte(search_idx) <= 127) then
                    char_byte = 1
                elseif (str:byte(search_idx) >= 194 and str:byte(search_idx) <= 223) then
                    char_byte = 2
                elseif (str:byte(search_idx) >= 224 and str:byte(search_idx) <= 239) then
                    char_byte = 3
                elseif (str:byte(search_idx) >= 240 and str:byte(search_idx) <= 244) then
                    char_byte = 4
                else
                    break
                end

                -- 현재 문자의 마지막 byte index가 조사의 byte index을 넘어설 경우 stop
                if (josa_idx <= search_idx + (char_byte - 1)) then
                    break
                end
                
                -- 만약 '{@' 이라면 리치 텍스트 관련된 부분 넘어가도록 하기
                if (string.sub(str, search_idx, search_idx + 1) == '{@') then
                    -- 가장 처음 나오는 } 찾아 search_idx 다음으로 넘기기
                    local last_idx = pl.stringx.lfind(str, '}', search_idx)
                    search_idx = last_idx + 1
                else
                    local char = string.sub(str, search_idx, search_idx + (char_byte - 1))
                    -- 문자인 경우에만
                    -- %s : space, %c : control character(\n, \t, ...), %z : character with representation 0, 
                    -- 추가로 괄호들 무시 []{}()
                    if (not string.match(char, '[%s%c%z%[%]{}%(%)]')) then
                        find_char_idx = search_idx
                        find_char_byte = char_byte
                    end
                    
                    search_idx = search_idx + char_byte
                end
            end

            --cclog('search idx : ' .. search_idx)


            -- 가장 근처 문자
            if (find_char_idx > 0) then
                local last_char = string.sub(str, find_char_idx, find_char_idx + (find_char_byte - 1))
         
                --cclog('last char : ' .. last_char)
         
                -- 조사 선택 가능
                if (string.match(last_char, '[가-힣]')) then
                    -- 받침이 있는지
                    local last_char_code =  ((str:byte(find_char_idx) - 224) * 64 * 64) + ((str:byte(find_char_idx + 1) - 128) * 64) + (str:byte(find_char_idx + 2) - 128)
                    local b_has_bottom_word = (((last_char_code - 0xAC00) % 28) > 0)          
                    
                    if (b_has_bottom_word) then
                        str = pl.stringx.replace(str, find_josa, josa_set[1], 1)
                    else
                        str = pl.stringx.replace(str, find_josa, josa_set[2], 1)
                    end
                    
                    search_idx = josa_idx + 3

                else
                    str = pl.stringx.replace(str, find_josa, replace_nochoice_josa, 1)
                    search_idx = josa_idx + string.len(replace_nochoice_josa)
                end

            -- 조사 앞에 문자가 없는 경우
            else
                -- 해당 조사를 데코가 없는 조사 버전으로 찾을 때 또 찾음 방지
                str = pl.stringx.replace(str, find_josa, replace_nochoice_josa, 1)
                search_idx = josa_idx + string.len(replace_nochoice_josa)
            end

            --cclog('find char idx : ' .. find_char_idx)
            -- 다음 조사 인덱스 찾기
            -- 만약 조사가 모종의 이유로 선택되지 않은 경우에 
            josa_idx = pl.stringx.lfind(str, find_josa, search_idx)
        end

        return str    
    end

    -- 각 조사 선택지로 문장 검사
    for _, josa_set in ipairs(l_josa_set_list) do
        for _, deco in ipairs(l_deco_list) do
            str = find_and_change(str, josa_set, deco)
        end
    end

    -- 선택하지 못한 조사들 다시 치환
    for idx, find_josa in ipairs(l_find_josa_list) do
        local replace_nochoice_josa = '^josa'.. tostring(idx) ..'^'
        str = pl.stringx.replace(str, replace_nochoice_josa, find_josa)
    end

    -- cclog('finish : ' .. str)

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

    return (table.find(args, value) ~= nil)
end

-------------------------------------
-- function isContainValue
-- @breif value를 포함하는 테이블인지 여부
-------------------------------------
function isContainValue(value, t)

    return (table.find(t, value) ~= nil)
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
-- function getSortPosListReverse
-- @brief 리스트를 가운데 정렬 시킬 때 사용
-------------------------------------
function getSortPosListReverse(interval, count)

    local start_pos = 0

    if ((count % 2) == 0) then
        start_pos = ((count / 2) - 0.5) * interval
    else
        start_pos = ((count - 1) / 2) * interval
    end

    local l_pos = {}
    for i=1, count do
        table.insert(l_pos, start_pos)
        start_pos = start_pos - interval
    end

    return l_pos
end

-------------------------------------
-- function getPosXForCenterSortting
-- @brief 리스트를 background 크기 내에서 가운데로 정렬한 (x_pos) 리스트 반환
-------------------------------------
function getPosXForCenterSortting(background_width, start_pos, count, list_item_width)
 
 local dis = (background_width-(list_item_width*(count)))/2
 local l_pos_x = {}
 for i=1,count do
    local pos_x = start_pos + dis + list_item_width*(i-1)
    table.insert(l_pos_x, pos_x)
 end
 return l_pos_x
end

-------------------------------------
-- function IsNull
-- @brief tolua 모듈 이용하여 들어온 값이 nullptr인지 판단
-------------------------------------
function IsNull(x)
    return tolua.isnull(x)
end

-------------------------------------
-- function PrintMemory
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
-- function listToString
-- @brief 리스트 항목을 sep으로 구분된 문자열로 변환
-------------------------------------
function listToString(list, sep)
    local str = nil

    for i,v in ipairs(list) do
        if (str == nil) then
            str = tostring(v)
        else
            str = str .. sep .. tostring(v)
        end
    end

    return str
end

-------------------------------------
-- function listToCsv
-- @brief 리스트 항목을 comma separated value 형태의 문자열로 변환
-------------------------------------
function listToCsv(list)
    return listToString(list, ',')
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

-------------------------------------
-- function conditionalOperator
-- @brief 3항 연산자 (삼항 연산자)
-------------------------------------
function conditionalOperator(condition, expression1, expression2)
    if condition then
        return expression1
    else
        return expression2
    end
end

-------------------------------------
-- function toboolean
-- @brief 문자열을 boolean타입으로 변환
-------------------------------------
function toboolean(value)
    if (value == 'true') then
        return true
    end

    if (value == 'TRUE') then
        return true
    end

    if (value == 'True') then
        return true
    end

    if (value == 'false') then
        return false
    end

    if (value == 'FALSE') then
        return false
    end

    if (value == 'False') then
        return false
    end

    return nil
end

-------------------------------------
-- function descBlank
-- @brief 값이 없거나 0일 때 -로 표시 (comma_value까지 처리)
-------------------------------------
function descBlank(number)
    local number = tonumber(number)
    
    if (not number or number <= 0) then
        number = '-'
        return number
    end
    
    return comma_value(number)
end

-------------------------------------
-- function descChangedValue
-- @brief 값이 마이너스라면 ▼10, 0 이라면 -, 플러스라면 ▲10
-------------------------------------
function descChangedValue(number)
    -- 숫자만 취급
    if (type(number) ~= 'number') then
       number = tonumber(number)
    end

    if (not number) then
        return ''
    end
    
    local desc = ''
    if (number < 0) then
        desc = string.format('{@rank_down}▼{@default}%d', math.abs(number))
    elseif (number > 0) then
        desc = string.format('{@rank_up}▲{@default}%d', math.abs(number))
    else
       desc = ''
    end

    return desc
end

-------------------------------------
-- function descTimeByTimeStemp
-------------------------------------
function descTimeByTimeStemp(timestemp)
    local date = pl.Date()
    date:set(timestemp)
    local date_format = pl.Date.Format('yyyy.mm.dd.HH.MM')
	local text_time = date_format:tostring(date)
    return text_time
end


-------------------------------------
-- function checkTimeValid
-- param string date_format 'yyyy-mm-dd HH:MM:SS'
-------------------------------------
function checkTimeValid(start_date, end_date, date_format)
    local start_time
    local end_time
    local curr_time = Timer:getServerTime()

    local parser = pl.Date.Format(date_format)

    local local_timezone = datetime.getTimeZoneOffset() -- 단말기(local) 타임존 (unit : sec)
    local server_timezone = Timer:getServerTimeZoneOffset() -- 서버(server) 타임존 (unit : sec)

    local timezone_offset = (local_timezone - server_timezone)

    if start_date and (start_date ~= '' ) then
        local temp = parser:parse(start_date)

        if temp and temp['time'] then
            start_time = temp['time'] + timezone_offset
        end
    end

    if end_date and (end_date ~= '') then
        local temp = parser:parse(end_date)

        if temp and temp['time'] then
            end_time = temp['time'] + timezone_offset
        end
    end

    local is_start_time_valid = true
    local is_end_time_valid = true

    if start_time then
        is_start_time_valid = (start_time < curr_time) 
    end

    if end_time then
        is_end_time_valid = (curr_time < end_time)
    end

    return is_start_time_valid and is_end_time_valid
end

-------------------------------------
-- function AlignUIPos
-- @brief 같은 계층의 자식들을 정렬시킴
-- @comment 사이즈를 계산할 때 라벨은 content size 그대로 사용, 나머지는 스케일 값 곱해서 사용
-- @param l_ui_list : ui 리스트, 리스트 순서대로 정렬, {vars['XXXIcon'], vars['XXXLabel']}
-- @param direction : ui 나열 방향 ('HORIZONTAL', 'VERTICAL'), 기본값 : HORIZONTAL
-- @param align : 정렬 기준 ('HEAD', 'CENTER', 'TAIL'), 기본값 : CENTER
-- @param offset : ui 사이 띄우는 길이, 기본값 : 0
-- TODO : 라벨의 경우 align 까지 계산되도록 구현 추가 필요(현재 코드는 가운데 정렬이라고 가정하고 짜여있음)
-------------------------------------
function AlignUIPos(l_ui_list, direction, align, offset)
    local ui_count = table.count(l_ui_list)
    
    if (ui_count == 0) then
        return
    end

    local direction = direction or 'HORIZONTAL'
    local align = align or 'CENTER'
    local offset = offset or 0
    
    local size_crit = 'width'
    local add_sign = 1 -- 다음 위치 계산할 때 더해야하는지 빼야하는지 결정
    if (direction == 'VERTICAL') then
        size_crit = 'height'
        add_sign = -1
    end
    
    local total_content_size = 0
    local l_content_size = {}
    local l_anchor_value = {}
     
    for idx, v in ipairs(l_ui_list) do
        local content_size = 0 
        local anchor_value
        
        -- 라벨의 경우 스케일 계산 X
        if ((isInstanceOf(v, UIC_LabelTTF)) or (isInstanceOf(v, UIC_RichLabel))) then
            content_size = v:getStringWidth()
            if (direction == 'VERTICAL') then 
                content_size = v:getTotalHeight()
            end
        
        else
            local scale = 1
            if (direction == 'VERTICAL') then
                scale = v:getScaleY()
            else
                scale = v:getScaleX()
            end

            local normal_size = v:getContentSize()[size_crit]
            content_size = normal_size * scale
        end
       
        local anchor_point = v:getAnchorPoint()
        local anchor_value = anchor_point.x
        
        if (direction == 'VERTICAL') then
            anchor_value = (1 - anchor_point.y)
        end
        
        table.insert(l_content_size, content_size)
        table.insert(l_anchor_value, anchor_value)
        total_content_size = total_content_size + content_size
    end 

    total_content_size = total_content_size + (offset * (ui_count - 1))

    local curr_position = -(total_content_size / 2)
    if (align == 'HEAD') then
        local parent_ui = l_ui_list[1]:getParent()
        local parent_size = parent_ui:getContentSize()[size_crit]
        
        curr_position = -(parent_size / 2)
    
    elseif (align == 'TAIL') then
        local parent_ui = l_ui_list[1]:getParent()
        local parent_size = parent_ui:getContentSize()[size_crit]
        
        curr_position = (parent_size / 2) - (total_content_size)
    end

    -- 수직과 수평은 부호가 반대로 처리됨
    curr_position = add_sign * curr_position

    for idx, v in ipairs(l_ui_list) do
        local position = curr_position + (add_sign * (l_content_size[idx] * l_anchor_value[idx]))

        if (idx > 1) then
            -- 이전 UI의 앵커 값에 따른 추가적인 위치 값 조정
            local before_rest_size = (l_content_size[idx - 1] * (1 - l_anchor_value[idx - 1]))
            
            position = position + (add_sign * (offset + before_rest_size))
        end

        if (direction == 'VERTICAL') then
            v:setPositionY(position)

        else
            v:setPositionX(position)
        end

        curr_position = position
    end
end

-- base64Encode, base64Decode

function lsh(value,shift)
	return math.mod((value*(2^shift)), 256)
end

-- shift right
function rsh(value,shift)
	return math.mod(math.floor(value/2^shift), 256)
end

-- return single bit (for OR)
function bit(x,b)
	return (math.mod(x, 2^b) - math.mod(x, 2^(b-1)) > 0)
end

-- logic OR for number values
function lor(x,y)
	result = 0
	for p=1,8 do result = result + (((bit(x,p) or bit(y,p)) == true) and 2^(p-1) or 0) end
	return result
end

-- function encode
-- encodes input string to base64.
function base64Encode(data)
    -- encryption table
    local base64chars = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='I',[9]='J',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='S',[19]='T',[20]='U',[21]='V',[22]='W',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='g',[33]='h',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='q',[43]='r',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}

	local bytes = {}
	local result = ""
	for spos=0,string.len(data)-1,3 do
		for byte=1,3 do bytes[byte] = string.byte(string.sub(data,(spos+byte))) or 0 end
		result = string.format('%s%s%s%s%s',
			result,
			base64chars[rsh(bytes[1],2)],
			base64chars[lor(lsh((math.mod(bytes[1], 4)),4), rsh(bytes[2],4))] or "=",
			((string.len(data)-spos) > 1) and base64chars[lor(lsh(
				math.mod(bytes[2], 16)
			,2), rsh(bytes[3],6))] or "=",
			((string.len(data)-spos) > 2) and base64chars[(math.mod(bytes[3], 64))] or "="
		)
	end
	return result
end

-- function decode
-- decode base64 input to string
function base64Decode(data)
    -- decryption table
    local base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}

	local chars = {}
	local result=""
	for dpos=0,string.len(data)-1,4 do
		for char=1,4 do chars[char] = base64bytes[(string.sub(data,(dpos+char),(dpos+char)) or "=")] end
		result = string.format('%s%s%s%s',
			result,
			string.char(lor(lsh(chars[1],2), rsh(chars[2],4))),
			(chars[3] ~= nil) and string.char(lor(lsh(chars[2],4), rsh(chars[3],2))) or "",
			(chars[4] ~= nil) and string.char(lor(math.mod(lsh(chars[3],6), 192), (chars[4]))) or ""
		)
	end
	return result
end