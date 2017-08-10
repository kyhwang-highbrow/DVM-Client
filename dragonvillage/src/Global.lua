-- 전역 함수들을 모아놓는 위치

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