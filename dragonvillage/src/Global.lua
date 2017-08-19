-- 전역 함수들을 모아놓는 위치

-------------------------------------
-- function IS_PERPLELAB_EVENT_MODE
-- @brief 퍼플랩 이벤트 모드
-------------------------------------
function IS_PERPLELAB_EVENT_MODE()

    -- 설정되지 않았을 경우 false로
    if (PERPLELAB_EVENT_MODE == nil) then
        PERPLELAB_EVENT_MODE = false
    end

    return (PERPLELAB_EVENT_MODE)
end

-------------------------------------
-- function OpenPerplelabEventPopup
-- @brief 퍼플랩 이벤트 모드
-------------------------------------
function OpenPerplelabEventPopup()
    local msg = Str('퍼플랩 이벤트 기간에 막아놓았지요~!!\n{@RED}열심히 노가다하세요.\n{@YELLOW}(2017년 8월 12일 ~\n2017년 8월 15일 10시 30분)')
    MakeSimplePopup(POPUP_TYPE.OK, msg)
end

-------------------------------------
-- function IS_TEST_MODE
-- @brief 테스트 모드 여부를 리턴
-------------------------------------
function IS_TEST_MODE()
    if (TEST_MODE_VER == nil) then
        TEST_MODE_VER = true
    end

    return (TEST_MODE_VER)
end

-------------------------------------
-- function IS_ENABLE_ANALYTICS
-- @brief 지표 수집 활성화 (true면 활성화, win32에서는 활성화할 경우 PerpleSDK 오류남)
-------------------------------------
function IS_ENABLE_ANALYTICS()
    if (getAppVer() ~= '0.2.6') then
        return false
    end

    if (isWin32()) then 
        return false
    end
    
    return true
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
        local APP_TARGET = 'KOREA' -- 드래곤히어로즈에서 사용하던 코드 그대로 쓰기위해 유지
		-- 국내 버전만 체크
		if (APP_TARGET == nil) or (APP_TARGET == 'KOREA') then
			if str ~= string.match(str, '[0-9|A-z|ㄱ-ㅎ|ㅏ-ㅣ|가-힣]*') then
				return false
			end

			if string.match(str, '\\') then
				return false
			end

			local koreanVanWord = {
				'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'ㄲ', 'ㄸ', 'ㅆ', 'ㅉ', 'ㅃ',
				'ㅏ', 'ㅓ', 'ㅑ', 'ㅕ', 'ㅗ', 'ㅛ', 'ㅜ', 'ㅠ', 'ㅡ', 'ㅣ', 'ㅚ', 'ㅟ', 'ㅐ', 'ㅒ', 'ㅖ', 'ㅔ', 'ㅙ', 'ㅞ',
			}
			-- 한국어 자음 이름 방지
			for _, c in pairs(koreanVanWord) do
				if string.match(str, c) then
					return false
				end
			end

			-- iOS, 특수문자 x
			if string.match(str, string.char(226, 157, 142)) then
				return false
			end

			-- iOS, 특수문자 v
			if string.match(str, string.char(226, 156, 133)) then
				return false
			end

			--[[
			for _, c in pairs({'~', '!', '@', '#', '%$', '%%', '%^', '&', '%*', '%?', '_', ' '}) do
				if string.match(str, c) then
					return false
				end
			end

			for _, c in pairs({'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'ㄲ', 'ㄸ', 'ㅆ', 'ㅉ', 'ㅃ'}) do
				if string.match(str, c) then
					return false
				end
			end
			for _, c in pairs({'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ', 'ㅖ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ', 'ㅠ', 'ㅜ', 'ㅡ'}) do
				if string.match(str, c) then
					return false
				end
			end
			for _, c in pairs({'a', 'b', 'c', 'd', 'e', 'f', 'g', 'f', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}) do
				if string.match(str, c) then
					return false
				end
			end
			]]--

		-- GSP, CHINA버전은 별도로 닉네임 체크
		elseif APP_TARGET == 'CHINA' then
			return ValidStrUtils:checkNickName_forChina(str)
		else
			return ValidStrUtils:checkNickName_forGsp(str)
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
-- function Is022Ver
-------------------------------------
function Is022Ver()
    return (getAppVer() == '0.2.2')
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