-- 전역 함수들을 모아놓는 위치

-------------------------------------
-- function IS_TEST_MODE
-- @brief 테스트 모드 여부를 리턴
-------------------------------------
function IS_TEST_MODE()
    -- 빌드 자체에서 test_mode가 아니면 무조건 false를 리턴
    if (not CppFunctions:isTestMode()) then
        return false
    end

    local local_test_mode = g_localData and g_localData:get('test_mode')

    -- 설정이 되어있지 않을 경우 test_mode로 간주
    if (local_test_mode == nil) then
        return true

    elseif (local_test_mode == true) then
        return true

    elseif (local_test_mode == false) then
        return false
    end
end

-------------------------------------
-- function IS_LIVE_SERVER
-------------------------------------
function IS_LIVE_SERVER()
    local target_server = CppFunctions:getTargetServer()
    return (target_server == 'LIVE')
end

-------------------------------------
-- function IS_ENABLE_ANALYTICS
-- @brief 지표 수집 활성화 (true면 활성화, win32에서는 활성화할 경우 PerpleSDK 오류남)
-------------------------------------
function IS_ENABLE_ANALYTICS()
    if (isWin32()) then 
        return false
    end

    return IS_LIVE_SERVER()
end

-------------------------------------
-- function PrintClassName
-- @brief instance의 클래스명을 리턴
--        클래스명을 찍기 위해 instance는 m_className 변수를 가지고 있어야 한다.
-------------------------------------
function PrintClassName(instance)
    ccdump(instance)
    cclog('#########################################')
    cclog('## class name : ' .. tostring(instance.m_className))
    cclog('#########################################')
end

-------------------------------------
-- function IsValidText
-- @brief 문자열 필터링
-- @return bool true이면 유효한 text
--              false이면 사용할 수 없는 text
-------------------------------------
function IsValidText(str, is_name)
	local t_word = TABLE:get('table_ban_word_naming')
	if (not t_word) then
        return false
    end

	local temp = string.gsub(str, '[%s%.,:;|/]', '')

	local words = {}
	for _, v in pairs(t_word) do
		local word = tostring(v.word)
		local match = string.match(string.lower(temp), string.lower(word))
		if match and (string.lower(match) == string.lower(word)) then
			--cclog('IsValidText1 = ' .. word)
			return false
		end
	end

	if is_name then
		if (not ValidStrUtils:checkNickName_forGsp(str)) then
            return false
		end
	end

	return true
end

-------------------------------------
-- function FilterMsg
-- @brief 문자열 필터링
-- @return bool true이면 유효한 text
-------------------------------------
function FilterMsg(str)
    local t_ban_word = TABLE:get('table_ban_word_chat')
    if (not t_ban_word) then
        return false
    end

    -- 모두 소문자로 변경
    local lower_str = string.lower(str)

    -- 금칙어 리스트에 포함되어있는지 확인
    for _, v in pairs(t_ban_word) do
		if string.match(lower_str, string.lower(v['word'])) then
			return false, Str('사용할 수 없는 표현이 포함되어 있습니다.')
		end
	end

    return true
end

-------------------------------------
-- function KeepOrderOfArrival
-- @brief ZOrder가 같은 Node들이 뒤죽박죽 섞이는 것을 방지
-------------------------------------
function KeepOrderOfArrival(node)
    if (not node) then
        return
    end

    if (type(node) == 'table') then
        node = node.m_node
    end

    local l_children = node:getChildren()
    for i,child in ipairs(l_children) do
        --node:reorderChild(child, child:getLocalZOrder())
        child:setOrderOfArrival(i)
    end
    node:sortAllChildren()
end

-------------------------------------
-- function UnlinkBrokenPlatform
-- @brief 시스템 오류로 다중연동된 경우 현재 로그인된 플랫폼 이외에는 unlink 시킨다.
-------------------------------------
function UnlinkBrokenPlatform(info, platform_id)

    for idx = 1, #info.providerData do
        local providerId = info.providerData[idx].providerId
        if providerId ~= platform_id and providerId ~= 'firebase' then
            if providerId == 'google.com' then
                PerpleSDK:unlinkWithGoogle(function(ret, info)
                    if ret == 'success' then
                        cclog('Firebase unlink from Google was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Google failed.')
                    end
                end)
            end
            if providerId == 'facebook.com' then
                PerpleSDK:unlinkWithFacebook(function(ret, info)
                    if ret == 'success' then
                        cclog('Firebase unlink from Facebook was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Facebook failed.')
                    end
                end)
            end
        end
    end

end

-------------------------------------
-- function AppVer_strToNum
-- @brief 앱 버전 string을 number로 변경
--        '.'으로 구분되는 숫자는 최대 세자리를 사용
-- @ex AppVer_strToNum('1.8.13') -> 1008013
-------------------------------------
function AppVer_strToNum(app_ver_str)
    if (type(app_ver_str) == 'number') then
        return app_ver_str
    end

    local l_num = pl.stringx.split(app_ver_str, '.')
    l_num = table.reverse(l_num)

    local app_ver_num = 0
    for i,v in ipairs(l_num) do
        if (i == 1) then
            app_ver_num = (app_ver_num + v)
        else
            app_ver_num = (app_ver_num + (v * math_pow(1000, i-1)))
        end
    end

    return app_ver_num
end

-------------------------------------
-- function AppVer_numToStr
-- @brief 앱 버전 number를 string으로 변경
--        '.'으로 구분되는 숫자는 최대 세자리를 사용
-- @ex AppVer_numToStr(1008013) -> '1.8.13'
-------------------------------------
function AppVer_numToStr(app_ver_num)
    if (type(app_ver_num) == 'string') then
        return app_ver_num
    end

    local comma_app_ver_num = comma_value(app_ver_num)
    local l_num = pl.stringx.split(comma_app_ver_num, ',')

    local app_ver_str = ''
    for i,v in ipairs(l_num) do
        local num = tonumber(v)
        if (i == 1) then
            app_ver_str = (app_ver_str .. num)
        else
            app_ver_str = (app_ver_str .. '.' .. num)
        end
    end

    return app_ver_str
end

-------------------------------------
-- function getAppVerNum
-- @brief 앱 버전 number
-------------------------------------
function getAppVerNum()
    local app_ver = getAppVer()
    local app_ver_num = AppVer_strToNum(app_ver)
    return app_ver_num
end


-------------------------------------
-- function LoadLocalSaveJson
-- @brief 로컬에 저장하는 세이브 데이터 json으로 읽기
-------------------------------------
function LoadLocalSaveJson(filename)
    local f = io.open(filename, 'r')

    local success_load = false
    local ret_json = nil
    if f then
        local content = f:read('*all')
        f:close()

        if (#content > 0) then
            -- '{'와 '['로 시작되지 않으면 암호화된 파일로 간주
            if (not pl.stringx.startswith(content, '{')) and (not pl.stringx.startswith(content, '[')) then
                -- xor 복호화
                content = XorCipher:E(content)
            end

            -- json 데이터 생성
            ret_json = json_decode(content)
        end

        if (ret_json) then
            success_load = true
        end
    end

    return ret_json, success_load
end

-------------------------------------
-- function SaveLocalSaveJson
-- @brief
-------------------------------------
function SaveLocalSaveJson(filename, t_data)
    local f = io.open(filename,'w')
    if (not f) then
        return false
    end

    local content = dkjson.encode(t_data, {indent=true})

    -- 테스트 모드에서는 암호화 skip
    if (not IS_TEST_MODE()) then
        -- xor 암호화
        content = XorCipher:E(content)
    end

    f:write(content)
    f:close()
    return true
end

-------------------------------------
-- function MakeResponseCB
-- @brief 지정된 status가 들어올 경우 미리 정의된 문구 팝업 띄우는 공용 response cb 생성
-------------------------------------
function MakeResponseCB(t_error) 
    local function response_status_cb(ret)
        local msg = t_error[ret['status']]
        if (msg) then
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return true
        end
        return false
    end
    return response_status_cb
end