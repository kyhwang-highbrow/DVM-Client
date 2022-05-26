--Network
Network = {
    uid = nil,
    t_req = {},
}

HEX			= crypto['hex']
HEX2BIN		= crypto['hex2bin']
AES_Encrypt = crypto['aes128']['encrypt']
AES_Decrypt = crypto['aes128']['decrypt']
HMAC		= crypto['hmac']['digest']

-- 암호화 키
CONSTANT = {}
CONSTANT['HMAC_KEY'] = 'Vjpmgg6MhKSBkSj4k36MQNyUwqS68qJCzRaXmID+45RQO07myxHJakFYY4i7Af6B'
CONSTANT['MD5_KEY'] = 'bd09b49ad742473a9663b0df11521927'
CONSTANT['AES_KEY'] = '809AF879E5A3CEAC82FF7E4584939E8D'


-- !! '\n'이 혹시 있어서 문제가 발생한다면 '%0A'로 인코딩하자
--function urlencode(s) return s and (s:gsub("[^a-zA-Z0-9.~_-]", function (c) return format("%%%02x", c:byte()); end)); end
function urlencode(s) return s and (s:gsub("[&=+%%%c]", function (c) return format("%%%02x", c:byte()); end)); end
function urldecode(s) return s and (s:gsub("%%(%x%x)", function (c) return char(tonumber(c,16)); end)); end

local function _formencodepart(s)
	return s and (s:gsub("%W", function (c)
		if c ~= " " then
			return string.format("%%%02x", c:byte());
		else
			return "+";
		end
	end));
end

function formencode(form)
	local result = {};
	if form[1] then -- Array of ordered { name, value }
		for _, field in ipairs(form) do
			--table.insert(result, _formencodepart(field.name).."=".._formencodepart(field.value));
			table.insert(result, _formencodepart(field.name).."=".._formencodepart(tostring(field.value)));
		end
	else -- Unordered map of name -> value
		for name, value in pairs(form) do
			--table.insert(result, _formencodepart(name).."=".._formencodepart(value));
			table.insert(result, _formencodepart(name).."=".._formencodepart(tostring(value)));
		end
	end
	return table.concat(result, "&");
end

--[[
--네트워크
--post 방식
httpclient = cc.XMLHttpRequest:new()
httpclient:registerScriptHandler(function()
	cclog('statusText = %s', statusText)
	cclog('response text: status=%d, responseText=%s', httpclient.status, httpclient.responseText)
	httpclient:unregisterScriptHandler()
end)
httpclient:open('post', 'localhost:9000/users/login2')
local form = formencode({uid='88225861668289904', market='win32'})
httpclient:setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
httpclient:setRequestHeader("Content-Length", tostring(string.len(form)))
httpclient:setRequestHeader("sessionkey", "1234-5678")
httpclient:send(form)

--get 방식
httpclient2 = cc.XMLHttpRequest:new()
httpclient2:registerScriptHandler(function(msg)
	cclog('msg = %s', msg)
	cclog('response text = %s', httpclient2.responseText)
end)
httpclient2:open('get', 'localhost:9000/get_broadcast')
--httpclient:open('get', 'localhost:9000/get_event_page?os=android')
httpclient2:send()
--]]

function Network:setUid(uid)
    self.uid = uid
end

function Network:request(url, data, method, encode_type)
	local req = {}
	local method = method or 'GET'
	local data = data or {}

    -- cclog( url, luadump( data ) )

    req.url = url
	req.method = method
	req.data = data

	if method == 'GET' then
		local count = 0
		for k,v in pairs(data) do
			if count == 0 then req.url = req.url .. '?'
			else req.url = req.url .. '&' end

			if encode_type then
				req.url = req.url .. k .. '=' .. urlencode(tostring(v))
			else
				req.url = req.url .. k .. '=' .. urlEncode(tostring(v))
			end
						
			count = count + 1
		end
	end
	return req
end

function Network:start(req, delay)
	if req.method ~= 'GET' and req.method ~= 'POST' then return end
	if self.t_req[tostring(req.url)] then
		cclog('duplicate request url : ' .. req.url)
		return
	end

	--cclog('url: ' .. req.url)
	--cclog('data: ' .. luadump(req.data))
	local request = cc.XMLHttpRequest:new()
	request.responseType = 5		-- ResponseType::JSON (lua_xml_http_request.h)
	request.timeoutForConnect = 10
    request.timeoutForRead = 60

	-- 다운로드 경로 설정 및 recv콜백 설정
	if req.path then
		request.downloadPath = req.path
        request.timeoutForRead = 0
		if req.recvHandler then
			request:registerProgressScriptHandler(req.recvHandler)
		end
	end
	request:registerScriptHandler(function(success)
		request:unregisterProgressScriptHandler()
		request:unregisterScriptHandler()

		self.t_req[tostring(req.url)].request = nil
		self.t_req[tostring(req.url)] = nil

        local error_text = request.errorText

		if success then
			local response = request.response
			local status = request.status
			local readyState = request.readyState

			if req.finishHandler then req.finishHandler(response) end
			--[[
			if status == 200 then
				if req.finishHandler then req.finishHandler(response) end
			else
				cclog('status = ' .. status)
				if req.failHandler then req.failHandler(response) end
			end
			]]--
		else
			-- 접속 오류
			if req.failHandler then
                req.failHandler(error_text)
            end
		end
	end)

	if req.method == 'GET' then
		request:open('get', req.url, true)
		request:send()
	elseif req.method == 'POST' then
		request:open('post', req.url, true)
		local form = formencode(req.data)
		request:setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=utf-8")
		request:setRequestHeader("Content-Length", tostring(string.len(form)))

		-- 중복 접속을 제어하기 위해서 게임서버로부터 받은 session_key를 해더에 추가해 검증함
        if g_userData and g_userData:get('session_key') then
            local session_key = g_userData:get('session_key')
		    request:setRequestHeader("sessionkey", session_key)
        end

        -- game server 암호화(HMAC SHA1)
		if req.hmac then
			request:setRequestHeader("hmac", tostring(req.hmac))
		end
        -- platform server 암호화(HMAC MD5)
        if req.hmac_md5 then
			request:setRequestHeader("HMAC", tostring(req.hmac_md5))
        end

		request:send(form)
	end

	req.request = request
	self.t_req[tostring(req.url)] = req
end

function Network:download(url, path, finish_cb, fail_cb, recv_cb)
	local finishHandler = finish_cb or (function() end)
	local failHandler = fail_cb or (function() end)
	local recvHandler = recv_cb or (function() end)

	local req = {
		method = 'GET'
		, url = url
		, data = {}
		, path = path
		, finishHandler = finishHandler
		, failHandler = failHandler
		, recvHandler = recvHandler
	}

	self:start(req)
end

function Network:decodeResult(ret)
	local err = {status=-9999, message='network_error'}
	if not ret then return err end

	local t = dkjson.decode(ret)
	if not t or type(t) ~='table' then return err end
	return t
end

function Network:SimpleRequest(t, do_decode, encode_type)
    local full_url = t['full_url']
	local url = full_url or (GetApiUrl() .. t['url'])
	local data = t['data'] or {}
	local method = t['method'] or 'GET'
	local success = t['success'] or function(ret) end
	local fail = t['fail'] or function(ret) end
	local do_decode = do_decode or false
    local skip_default_params = t['skip_default_params'] or false

	-- 클라이언트에서는 모든 통신에 hmac을 전달하는 것으로 결정
	-- 2017-08-23 sgkim (검증 여부는 서버에서 판단하기 때문)
    local check_hmac_md5 = t['check_hmac_md5'] or true

    if (skip_default_params == false) then
        -- 모든 요청은 파라미터로 uid가 들어간다.
        if self['uid'] then
            data['uid'] = self['uid']
        end

        -- 패치 정보 삽입
        g_patchChecker:addPatchInfo(data)
    end

    -- platform server 암호화
    local hmac_md5 = nil
    if check_hmac_md5 == true then

        -- 플랫폼 서버에서 json 엔코딩시 number를 모두 string 처리함,
        -- 따라서 data 의 number 를 모두 string으로 바꿔서 encrypt 해야 함
       	for k in pairs(data) do
            data[k] = tostring(data[k])
        end

        local text = dkjson.encode(data)
        hmac_md5 = HMAC('md5', text, CONSTANT['MD5_KEY'], false)
    end

	local r = Network:request(url, data, method, encode_type)
	r['finishHandler'] = function(data)
		local jsondata
		if do_decode then
			local plain = AES_Decrypt(HEX2BIN(CONSTANT['AES_KEY']), HEX2BIN(data))
			jsondata = Network:decodeResult(plain)
		else
			jsondata = Network:decodeResult(data)
		end
        Network:saveDump(t, jsondata)

        if (jsondata['status'] and (jsondata['status'] == -9999)) then
            fail(jsondata)

        -- 패치 업데이트 검사
        elseif (g_patchChecker:isUpdated(jsondata, success)) then 
            return

        else
            success(jsondata)
        end
	end
	r['failHandler'] = function(data)
		fail({['status'] = -9998, ['message'] = data})
	end

    -- platform server 암호화
    if hmac_md5 then
        r.hmac_md5 = hmac_md5
    end

	Network:start(r)
end

-------------------------------------
-- function makeQueryStr
-- @brief
-------------------------------------
function Network:makeQueryStr(t_data)
    -- sort by key's name
	local t_key = {}
	for key,_ in pairs(t_data) do
        table.insert(t_key, key)
    end
	table.sort(t_key)

    local query_str = ''

    for i,k in ipairs(t_key) do
		local v = t_data[k]
		if (type(v) == 'table') then
			for j=1, #v do
				if (j == 1) then
					if (string.len(query_str) == 0) then
						query_str	= k .. '=' .. v[1]
					else
						query_str	= query_str .. '&' .. k .. '=' .. v[1]
					end
				else
					query_str	= query_str .. ',' .. v[j]
				end
			end
		else
            v = tostring(v)
			if (string.len(query_str) == 0) then
				query_str	= k .. '=' .. v
			else
				query_str	= query_str .. '&' .. k .. '=' .. v
			end
		end
	end

    return query_str
end

-------------------------------------
-- function HMacRequest
-- @brief
-------------------------------------
function Network:HMacRequest(t, do_decode)

    local full_url = t['full_url']
	local url = full_url or (GetApiUrl() .. t['url'])
	local data = t['data'] or {}
	local method = t['method'] or 'POST'
	local success = t['success'] or function(ret) end
	local fail = t['fail'] or function(ret) end
	local do_decode = do_decode or false
    local check_hmac_md5 = t['check_hmac_md5'] or false
    local skip_default_params = t['skip_default_params'] or false

    if (skip_default_params == false) then
        -- 모든 요청은 파라미터로 uid가 들어간다.
        if self['uid'] then
            data['uid'] = self['uid']
        end

        -- 패치 정보 삽입
        g_patchChecker:addPatchInfo(data)
    end

    -- 쿼리 문자열 생성
	local query_str = self:makeQueryStr(data)
	local text	= method .. '\n' .. (t['url'] or url) .. '\n' .. query_str
    
    local hmac	= HMAC('sha1', text, CONSTANT['HMAC_KEY'], false)
    local r		= Network:request(url, data, method)
    r['finishHandler'] = function(data)

        -- 통신 데이터 크기 테스트
        --UserData:saveLuadump('temp/'..string.gsub(url,'/','-')..'_'..string.len(data), {url, string.len(data), data})

        local jsondata
		if do_decode then
			local plain = AES_Decrypt(HEX2BIN(CONSTANT['AES_KEY']), HEX2BIN(data))
			jsondata = Network:decodeResult(plain)
		else
			jsondata = Network:decodeResult(data)
		end
        Network:saveDump(t, jsondata)

        if (jsondata['status'] and (jsondata['status'] == -9999)) then
            fail(jsondata)

        -- 패치 업데이트 검사
        elseif (g_patchChecker:isUpdated(jsondata, success)) then 
            return

        else
            success(jsondata)
        end
	end
	r['failHandler'] = function(data)
		fail({['status'] = -9998, ['message'] = data})
	end

	r.hmac = hmac

	Network:start(r)
end

-------------------------------------
-- function saveDump
-- @breif 
-------------------------------------
function Network:saveDump(t_request, ret)
    if (not isWin32()) then
        return
    end

    local file_name = t_request['url']

    if (not file_name) then
        if t_request['full_url'] then
            local l_str = plSplit(t_request['full_url'], '/')
            file_name = '/' .. l_str[#l_str]
        else
            file_name = '/none'
        end
    end

    -- '/'를 '#'으로 치환
    file_name = string.gsub(file_name, '/', '#')

    -- 첫 문자가 '#'이면 삭제
    if (string.find(file_name, '#') == 1) then
        file_name = string.gsub(file_name, '#', '', 1)
    end

    local path = cc.FileUtils:getInstance():getWritablePath() .. 'network_dump/'
    local full_path = string.format('%s%s.json', path, file_name)

    local f = io.open(full_path,'w')
    if (not f) then
        return
    end

    local time = os.date('%c', os.time())
    local request = dkjson.encode(t_request['data'], {indent=true})
    local response = dkjson.encode(ret, {indent=true})

    local full_url = t_request['full_url'] or (GetApiUrl() .. t_request['url'])
    local str = '# time(m/d/y h:m:s)\n' .. time .. '\n\n# url\n' .. full_url .. '\n\n# request\n' .. request .. '\n\n# response\n' .. response
    
    f:write(str)
    f:close()
end