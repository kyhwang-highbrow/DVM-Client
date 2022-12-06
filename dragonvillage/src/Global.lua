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

    local local_test_mode = g_settingData and g_settingData:get('test_mode')

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
-- function IS_ARENA_OPEN
-- @brief 신규 콜로세움 적용 여부를 리턴
-------------------------------------
function IS_ARENA_OPEN()
    if g_seasonData then
        return g_seasonData.m_bArenaOpen
    end

    return false
end

-------------------------------------
-- function IS_ARENA_NEW_SEASON
-- @brief 개편 후 콜로세움 적용 여부를 리턴
-------------------------------------
function IS_ARENA_NEW_OPEN()
    if g_seasonData then
        return g_seasonData.m_ArenaNewSeason > 0
    end

    return false
end

-------------------------------------
-- function IS_ARENA_NEW_SEASON
-- @brief 개편 후 콜로세움 적용 여부를 리턴
-------------------------------------
function HAS_ARENA_NEW_SEASON()
    if g_seasonData then
        return g_seasonData.m_ArenaNewSeason > 0
    end

    return false
end

-------------------------------------
-- function IS_ARENA_AUTOPLAY
-- @brief 신규 콜로세움 연속전투 적용 여부를 리턴
-------------------------------------
function IS_ARENA_AUTOPLAY()
    return true
end

-------------------------------------
-- function IS_LIVE_SERVER
-------------------------------------
function IS_LIVE_SERVER()
    local target_server = CppFunctions:getTargetServer()
    return (target_server == 'LIVE')
end

-------------------------------------
-- function IS_QA_SERVER
-------------------------------------
function IS_QA_SERVER()
    local target_server = CppFunctions:getTargetServer()
    return (target_server == 'QA')
end

-------------------------------------
-- function IS_DEV_SERVER
-------------------------------------
function IS_DEV_SERVER()
    local target_server = CppFunctions:getTargetServer()
    return (target_server == 'DEV')
end

-------------------------------------
-- function IS_ENABLE_ANALYTICS
-- @brief 지표 수집 활성화 (true면 활성화, win32에서는 활성화할 경우 PerpleSDK 오류남)
-------------------------------------
function IS_ENABLE_ANALYTICS()
    if (isWin32()) then 
        return false
    end

    return IS_LIVE_SERVER() and Analytics:getEnable()
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
-- function CheckNickName
-- @brief 닉네임 검사
-------------------------------------
function CheckNickName(str, proceed_func, cancel_func, is_clan)
	local t_ban_word = TABLE:get('table_ban_word_chat')
	if (not t_ban_word) then
		if (proceed_func) then
			proceed_func()
		end
        return false
    end

	local len = uc_len(str)
	local MIN_NICK = 2
	local MAX_NICK = 10

	-- 한글, 영어, 가나, 한자만 포함되었는지 확인
	-- 글자수 확인
	if (len < MIN_NICK) or (len > MAX_NICK) or (not ValidStrUtils:checkNickName_forGsp(str)) then
		if (cancel_func) then
			cancel_func()
		end
	
		local msg
		if (is_clan) then
			msg = Str('클랜 이름은 한글, 영어, 숫자를 사용하여 최소{1}자부터 최대 {2}자까지 생성할 수 있습니다. \n \n 특수문자, 한자, 비속어는 사용할 수 없으며, 중간에 띄어쓰기를 할 수 없습니다.', MIN_NICK, MAX_NICK)
		else    
	        msg = Str('닉네임은 한글, 영어, 숫자를 사용하여 최소{1}자부터 최대 {2}자까지 생성할 수 있습니다. \n \n 특수문자, 한자, 비속어는 사용할 수 없으며, 중간에 띄어쓰기를 할 수 없습니다.', MIN_NICK, MAX_NICK)
		end
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
	end

    -- 모두 소문자로 변경
    local lower_str = string.lower(str)

    -- 금칙어 추출
    local l_match_list = {}
    local word = nil
    for _, t_word in ipairs(t_ban_word) do
        word = string.lower(t_word['word'])
        if string.match(lower_str, word) then
            table.insert(l_match_list, word)
            lower_str = string.gsub(lower_str, word, '')
            
            if (lower_str == '') then
                break
            end
        end
        
	end

    -- match
    if (table.count(l_match_list) == 0) then
        if (proceed_func) then
            proceed_func()
        end
        return true
    else
        -- 금칙어 강조된 문장 생성 (영어는 일단 소문자로 표현)
		local ret_str = string.lower(str)
        for _, word in ipairs(l_match_list) do
            ret_str = string.gsub(ret_str, word, '{@RED}' .. word .. '{@WHITE}')
        end
        ret_str = '{@WHITE}' .. ret_str
        local warning = '{@DESC}' .. Str('금칙어가 포함되었습니다. 입력을 계속하시겠습니까?\n(욕설이나 부적절한 단어 사용이 확인되었을 시 제재를 받을 수 있습니다.)')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, ret_str, warning, proceed_func, cancel_func)
    end
end

-------------------------------------
-- function CheckBlockStr
-- @brief 금칙어 검사
-------------------------------------
function CheckBlockStr(str, proceed_func, cancel_func)
    -- 긴 문자열 순으로 나열된 테이블    
    local t_ban_word = TableBanWord.getInstance():getStrictBanWordList_Lower()
    if (not t_ban_word) then
        if (proceed_func) then
            proceed_func()
        end
        return
    end

    -- 모두 소문자로 변경
    local lower_str = string.lower(str)

    -- 금칙어 추출
    local l_match_list = {}
    local word = nil
    for _, word in ipairs(t_ban_word) do
        if string.find(lower_str, word, nil, true) then
            table.insert(l_match_list, word)
            lower_str = string.gsub(lower_str, word, '')
            
            if (lower_str == '') then
                break
            end
        end
        
	end
    
    -- match
    if (table.count(l_match_list) == 0) then
        if (proceed_func) then
            proceed_func()
        end
        return true
    else
        -- 금칙어 강조된 문장 생성 (영어는 일단 소문자로 표현)
		local ret_str = string.lower(str)
        for _, word in ipairs(l_match_list) do
            ret_str = string.gsub(ret_str, word, '{@RED}' .. word .. '{@WHITE}')
        end
        ret_str = '{@WHITE}' .. ret_str
        local warning = '{@DESC}' .. Str('금칙어가 포함되었습니다. 입력을 계속하시겠습니까?\n(욕설이나 부적절한 단어 사용이 확인되었을 시 제재를 받을 수 있습니다.)')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, ret_str, warning, proceed_func, cancel_func)
    end
end

-------------------------------------
-- function ConvertBanWordOverlay
-- @brief 입력된 string에서 금지어에 해당하는 부분을 **로 변경하여 반환 ex 시발123 **123, 시 발123 ***123
-------------------------------------
function ConvertBanWordOverlay(str_origin)
    -- 모두 소문자로 변경
    local lower_str = string.lower(str_origin)

    -- 금칙어를 글자수에 맞춰 *로 변환
    local l_ban_word = TableBanWord.getInstance():getStrictBanWordList_Lower()
    for _, word in ipairs(l_ban_word) do
        local split_index = string.find(lower_str, word)

        --동굴 공지 최대 300자 가장 짧은 2글자 짜리 금지어라해도 150개 이상 같은 필터링이 반복 될 수 없다.
        for i = 1, 150 do
            if split_index == nil then
                break
            end

            local word_len = uc_len(word) --글자수 얻기
            local word_byte_len = string.len(word)
            local star_list = {}
            for i = 1, word_len do
                table.insert(star_list, '*')
            end
            local str_star = table.concat(star_list)

            --str_origin 계속해서 바뀌고 있다. 매번 길이를 새로 구해줘야 함.
            local str_len = string.len(str_origin)
            local split_head = string.sub(str_origin, 1, split_index - 1)
            local split_tail = string.sub(str_origin, split_index + word_byte_len, str_len)

            str_origin = table.concat({split_head, str_star, split_tail})
            lower_str = string.lower(str_origin)
            split_index = string.find(lower_str, word)
        end
    end
    return str_origin
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
			-- @google
            if providerId == 'google.com' then
                PerpleSDK:unlinkWithGoogle(function(ret, info)
                    if ret == 'success' then
                        cclog('Firebase unlink from Google was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Google failed.')
                    end
                end)
            end

			-- @facebook
            if providerId == 'facebook.com' then
                PerpleSDK:unlinkWithFacebook(function(ret, info)
                    if ret == 'success' then
                        cclog('Firebase unlink from Facebook was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Facebook failed.')
                    end
                end)
            end

			-- @twitter
            if providerId == 'twitter.com' then
                PerpleSDK:unlinkWithTwitter(function(ret, info)
                    if ret == 'success' then
                        cclog('Firebase unlink from Twitter was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Twitter failed.')
                    end
                end)
            end

            -- @apple
            if providerId == 'apple.com' then
                PerpleSDK:unlinkWithApple(function(ret, info)
                    if ret == 'success' then
                        cclog('Firebase unlink from Apple was successful.')
                    elseif ret == 'fail' then
                        cclog('Firebase unlink from Apple failed.')
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
-- function GetMarketAndOS
-- @return market(string), os(string)
-------------------------------------
function GetMarketAndOS()
    local os
	local market 
    if CppFunctions:isAndroid() then
        os = 'android'
		if (PerpleSdkManager:xsollaIsAvailable()) then
			market = 'xsolla'
        elseif (CppFunctions:isCafeBazaarBuild() == true) then
            market = 'cafebazaar'
		elseif (PerpleSdkManager:onestoreIsAvailable()) then
			market = 'onestore'
        else
			market = 'google'
		end
    elseif CppFunctions:isIos() then
        os = 'ios'
		market = 'apple'
    elseif CppFunctions:isWin32() then
        os = 'windows'
		market = 'windows'
	elseif CppFunctions:isMac() then
		os = 'mac'
		market = 'mac'
    end

	return market, os
end

-------------------------------------
-- function DelayedCall
-- @brief 지연 호출
-------------------------------------
function DelayedCall(parent, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence
    if (callback == nil) then
        sequence = delay
    else
        sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    end

    local node = cc.Node:create()
    parent:addChild(node)

    node:runAction(sequence)
    return sequence
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
function SaveLocalSaveJson(filename, t_data, skip_xor)
    local f = io.open(filename,'w')
    if (not f) then
        return false
    end

    local content = dkjson.encode(t_data, {indent=true})

    -- 테스트 모드에서는 암호화 skip
    if (not IS_TEST_MODE()) and (not skip_xor) then
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
function MakeResponseCB(t_error, confirm_cb) 
    local function response_status_cb(ret)
        local msg = t_error[ret['status']]
        if (msg) then
            MakeSimplePopup(POPUP_TYPE.OK, msg, confirm_cb)
            return true
        end
        return false
    end
    return response_status_cb
end

-------------------------------------
-- function SetSleepMode
-- @brief 절전모드 설정 (일정시간 입력이 없으면 화면 꺼짐 기능)
-------------------------------------
function SetSleepMode(sleep_mode)

    if g_settingData then
        if (g_settingData:isSleepMode() == false) then
            
            -- 절전 모드를 사용하지 않는 설정에서만 사용
            -- 절전 모드를 사용하는 설정일 경우 다른 UI로 전환하거나 재시작 후 적용되어도 무방함
            cc.Director:getInstance():setIdleTimerDisabled(true)

            return
        end
    end

    if sleep_mode then
	    cc.Director:getInstance():setIdleTimerDisabled(false)
    else
        cc.Director:getInstance():setIdleTimerDisabled(true)
    end

    -- 1. patch중에는 절전모드를 사용하지 않음
    -- 2. title화면에서 '화면을 터치하세요.' 부분에서 다시 절전모드 활성화
end

-------------------------------------
-- function SetSleepMode_After
-- @brief 절전모드 설정 (일정시간 입력이 없으면 화면 꺼짐 기능)
-------------------------------------
function SetSleepMode_After(parent, seconds)
    local parent = parent
    local seconds = (seconds or 5)

    if (not parent) then
        return
    end

    local delegate = cc.Node:create()
    parent:addChild(delegate)

    local function func(node)
        if IS_TEST_MODE() then
            cclog('#############################################')
            cclog('## 절전모드 활성화!! (5초 후)')
            cclog('#############################################')
        end
        SetSleepMode(true)
        node:removeFromParent(true)
    end

    if IS_TEST_MODE() then
        cclog('#############################################')
        cclog('## 절전모드 활성화!! 호출')
        cclog('#############################################')
    end
    local action = cc.Sequence:create(cc.DelayTime:create(seconds), cc.CallFunc:create(func))
    delegate:runAction(action)
end