--Network
Network = {
    uid = nil,
    t_req = {},
    server_type = nil,
}

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

function Network:request(url, data, method)
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
			--req.url = req.url .. k .. '=' .. urlencode(tostring(v))
			req.url = req.url .. k .. '=' .. urlEncode(tostring(v))
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
	request.responseType = 5
	request.timeoutForConnect = 2 --10 테섭이 회사 내부만 접속이 가능하므로 임시로 타임아웃을 2초로 변경 @TODO 향후 원복할 것!
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

		if req.hmac then
			request:setRequestHeader("hmac", tostring(req.hmac))
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

function Network:SimpleRequest(t, do_decode)
	if not t['url'] then
        --return
    end

    local full_url = t['full_url']
	local url = full_url or (self:getApiUrl() .. t['url'])
	local data = t['data'] or {}
	local method = t['method'] or 'GET'
	local success = t['success'] or function(ret) end
	local fail = t['fail'] or function(ret) end
	local do_decode = do_decode or false

    -- 모든 요청은 파라미터로 uid가 들어간다.
    if self['uid'] then
        data['uid'] = self['uid']
    end

    -- 패치 정보 삽입
    g_patchChecker:addPatchInfo(data)

	local r = Network:request(url, data, method)
	r['finishHandler'] = function(data)
		local jsondata
		if do_decode then
			local plain = AES_Decrypt(HEX2BIN(CONSTANT['AES_KEY']), HEX2BIN(data))
			jsondata = Network:decodeResult(plain)
		else
			jsondata = Network:decodeResult(data)
		end
        Network:saveDump(t, jsondata)

        -- 패치 업데이트 검사
        if (g_patchChecker:isUpdated(jsondata)) then return end

        if (jsondata['status'] and (jsondata['status'] == -9999)) then
            fail(jsondata)
        else
            success(jsondata)
        end
	end
	r['failHandler'] = function()
		fail()
	end
	Network:start(r)
end

function Network:HMacRequest(t, do_decode)

	if not t.url then return end
	local url		= t.url
	local data		= t.data or {}
	local method	= t.method or 'POST'
	local success	= t.success or function(ret) end
	local fail		= t.fail or function(ret) end
	local do_decode	= do_decode or false

    -- 모든 요청은 파라미터로 uid가 들어간다.
    if self.uid then
        data['uid'] = self.uid
        data['latest_app_ver'] = PatchData:get('latest_app_ver')
        data['patch_ver'] = PatchData:get('patch_ver')
    end

	local query_str = ''

	-- sort by key's name
	local t_key = {}
	for k in pairs(data) do t_key[#t_key + 1] = k end
	table.sort(t_key)

	-- make post data
	for i, k in ipairs(t_key) do
		local v = data[k]
		if type(v) == 'table' then
			for j = 1, #v do
				if j == 1 then
					if string.len(query_str) == 0 then
						query_str	= k .. '=' .. v[1]
					else
						query_str	= query_str .. '&' .. k .. '=' .. v[1]
					end
				else
					query_str	= query_str .. ',' .. v[j]
				end
			end
		else
			if string.len(query_str) == 0 then
				query_str	= k .. '=' .. v
			else
				query_str	= query_str .. '&' .. k .. '=' .. v
			end
		end
	end

	local text	= 'POST\n' .. url .. '\n' .. query_str
    local hmac	= HMAC('sha1', text, CONSTANT['HMAC_KEY'], false)
    local r		= Network:request(self:getApiUrl() .. url, data, method)
    r.finishHandler = function(data)

        -- 통신 데이터 크기 테스트
        --UserData:saveLuadump('temp/'..string.gsub(url,'/','-')..'_'..string.len(data), {url, string.len(data), data})

        local jsondata
		if do_decode then
			local plain = AES_Decrypt(HEX2BIN(CONSTANT['AES_KEY']), HEX2BIN(data))
			jsondata = Network:decodeResult(plain)
		else
			jsondata = Network:decodeResult(data)
		end

        -- 버전 체크
        if Network:appVersionCheck(jsondata) then
            Network:saveDump(t, jsondata)

            if (jsondata['status'] and (jsondata['status'] == -9999)) then
                fail(jsondata)
            else
                success(jsondata)
            end
        end
	end
	r.failHandler = function()
		fail()
	end

	r.hmac = hmac

	--cclog('header=' .. luadump(r.headers))

	Network:start(r)
end

-------------------------------------
-- function appVersionCheck
-- @brief 버전과 패치를 확인, 어플 재시작 유도
-------------------------------------
function Network:appVersionCheck(jsondata)
    if (not jsondata['status']) then
        return true
    end

    local msg = ''
    if jsondata['status'] == -9996 then
        msg = Str('새로운 패치가 있습니다. 게임이 종료됩니다. 자동으로 재시작된 후 패치가 적용됩니다.')
    elseif jsondata['status'] == -9997 then
        msg = Str('서버점검 중입니다.')
    else
        return true
    end

    -- 팝업
    HideLoading()
    MakeSimplePopup(POPUP_TYPE.OK, msg, RestartApplication)

    return false
end

-------------------------------------
-- function getApiUrl
-- @brief 서버 API URL
-------------------------------------
function Network:getApiUrl()
    if (not self.server_type) then
        self:resetServerType()
    end

    --[[
    -- @TODO
    local api_url = CONSTANT['API_URL']

    if self.server_type == 'korea' then
        api_url = CONSTANT['API_URL']
    elseif self.server_type == 'global' then
        api_url = CONSTANT['API_URL_GLOBAL']
    elseif self.server_type == 'kakao' then
        api_url = CONSTANT['API_URL_KAKAO']
    elseif self.server_type == 'china' then
        api_url = CONSTANT['API_URL_CHINA']
    end
    --]]

    local api_url = 'http://dv-test.perplelab.com:9003' --/get_patch_info?app_ver=0.0.0

    -- nil == default
    if (TARGET_SERVER == nil) then
        api_url = 'http://dv-test.perplelab.com:9003'
        --api_url = '192.168.1.42:9003' -- 이원기님 개발용 로컬 서버 (sgkim 2017-07-26)
    elseif (TARGET_SERVER == 'FGT') then
        api_url = 'http://dv-test.perplelab.com:9004'
	elseif (TARGET_SERVER == 'PUBLIC') then
        api_url = 'http://dv-test.perplelab.com:9005'
    else
        error('TARGET_SERVER : ' .. TARGET_SERVER)
    end

    return api_url
end

-------------------------------------
-- function getChatServerIP
-- @brief 채팅 서버 IP
-------------------------------------
function Network:getChatServerIP()
    if (not self.server_type) then
        self:resetServerType()
    end

    local ip = CONSTANT['CTSERVER_IP']

    if self.server_type == 'korea' then
        ip = CONSTANT['CTSERVER_IP']
    elseif self.server_type == 'global' then
        ip = CONSTANT['CTSERVER_IP_GLOBAL']
    elseif self.server_type == 'kakao' then
        ip = CONSTANT['CTSERVER_IP_KAKAO']
    elseif self.server_type == 'china' then
        ip = CONSTANT['CTSERVER_IP_CHINA']
    end

    return ip
end

-------------------------------------
-- function getChatServerPort
-- @brief 채팅 서버 Port
-------------------------------------
function Network:getChatServerPort()
    if (not self.server_type) then
        self:resetServerType()
    end

    local port = CONSTANT['CTSERVER_PORT']

    if self.server_type == 'korea' then
        port = CONSTANT['CTSERVER_PORT']
    elseif self.server_type == 'global' then
        port = CONSTANT['CTSERVER_PORT_GLOBAL']
    elseif self.server_type == 'kakao' then
        port = CONSTANT['CTSERVER_PORT_KAKAO']
    elseif self.server_type == 'china' then
        port = CONSTANT['CTSERVER_PORT_CHINA']
    end

    return port
end

-------------------------------------
-- function resetServerType
-- @brief 서버 타입 결정
-------------------------------------
function Network:resetServerType()
    self.server_type = 'korea'

    --[[
    -- 로그 출력 여부
    local log = false

    if log then
        cclog('#################################################')
        cclog('APP_TARGET = ' .. APP_TARGET)
        cclog('#################################################')
    end


    if (APP_TARGET == 'GSP') then
        -- 파티에 설정된 locale로 서버 지정
        if g_Pati and g_Pati.info and g_Pati.info['locale'] then
            if log then
                cclog("use g_Pati.info['locale']")
                cclog('locale = ' .. g_Pati.info['locale'])
            end

            if g_Pati.info['locale'] == 'KR' then
                self.server_type = 'korea'
            else
                self.server_type = 'global'
            end

        -- 세이브데이터에 설정된 locale로 서버 설정
        elseif UserData and UserData:get('locale') then
            if log then
                cclog("use UserData:get('locale')")
                cclog('locale = ' .. UserData:get('locale'))
            end
            if UserData:get('locale') == 'KR' then
                self.server_type = 'korea'
            else
                self.server_type = 'global'
            end

        -- 기기에 설정된 language로 서버 지정
        elseif getDeviceLanguage then
            local device_lan = getDeviceLanguage()
            if log then
                cclog("use getDeviceLanguage()")
                cclog('locale = ' .. getDeviceLanguage())
            end
            if string.starts(device_lan, 'ko') then
                self.server_type = 'korea'
            else
                self.server_type = 'global'
            end
        end
    elseif (APP_TARGET == 'KAKAO') then
        self.server_type = 'kakao'
    elseif (APP_TARGET == 'CHINA') then
        self.server_type = 'china'
    else
        self.server_type = 'korea'
    end

    if log then
        cclog('### Network:resetServerType()' .. self.server_type)
        cclog('#################################################')
        error()
    end
    --]]
end

-------------------------------------
-- function Network_saveDump
-- @breif 
-------------------------------------
function Network:saveDump(t_request, ret)
    if (not isWin32()) then
        return
    end

    local file_name = t_request['url']

    if (not file_name) then
        if t_request['full_url'] then
            local l_str = stringSplit(t_request['full_url'], '/')
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

    local full_url = t_request['full_url'] or (self:getApiUrl() .. t_request['url'])
    local str = '# time(m/d/y h:m:s)\n' .. time .. '\n\n# url\n' .. full_url .. '\n\n# request\n' .. request .. '\n\n# response\n' .. response
    
    f:write(str)
    f:close()
end