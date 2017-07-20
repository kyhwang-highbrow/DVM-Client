-- 전역 함수들을 모아놓는 위치

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
			if str ~= string.match(str, '[0-9|A-Z|ㄱ-ㅎ|ㅏ-ㅣ|가-힣]*') then
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