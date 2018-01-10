-------------------------------------
-- table Translate
-------------------------------------
Translate = {
    m_mLangMap = nil,
    m_stdLang = nil,
    m_deviceLang = nil,
    m_gameLang = nil,
}

-------------------------------------
-- function init
-------------------------------------
function Translate:init()
    self.m_stdLang = 'ko'
    self.m_gameLang = LocalData:getInstance():getLang()

	-- @mskim 1/15일에만 동작 시킬 예정
	-- 현재 한국 라이브 유저들의 설정 일괄 변환 의도
	if (self.m_gameLang == 'kr') then
		LocalData:getInstance():setLang('ko')
		self.m_gameLang = 'ko'
	end

    -- getDeviceLang을 하면 중국어에서 zh-cn 으로 들어오고
	-- 엔진에 있는 languageCode가 의도한대로 값이 들어와
	-- getCurrentLanguageCode 함수를 사용하기로 함
    self.m_deviceLang = cc.Application:sharedApplication():getCurrentLanguageCode()

	-- 한국어가 아닌 경우 언어 모듈 로드
	if (self.m_gameLang ~= self.m_stdLang) then
		-- @mskim 해외 빌드 분기 처리
		if (CppFunctionsClass:getAppVer() == '1.0.8') then
			-- nothing to do
		else
			self:load(self.m_gameLang)
		end
    end

	cclog()
	cclog('******* device language : ' .. tostring(self.m_deviceLang))
	cclog('******* game language : ' .. tostring(self.m_gameLang))
	cclog()
end

-------------------------------------
-- function load
-------------------------------------
function Translate:load(lang)
    self.m_mLangMap = nil
    if (lang == self.m_stdLang) then
        return
    end

	self.m_gameLang = lang

    -- 한국어가 아니라면 m_mLangMap 호출
    if (lang == 'en') then
        self.m_mLangMap = require 'translate/lang_en'
    elseif (lang == 'ja') then
        self.m_mLangMap = require 'translate/lang_jp'
	elseif (lang == 'zh') then
        self.m_mLangMap = require 'translate/lang_en' --lang_zhtw

	-- 정의 되지 않은 언어는 '영어'로 일괄 처리
	else
		self.m_mLangMap = require 'translate/lang_en'
    end
end

-------------------------------------
-- function makeUsable
-- @brief LuaUtility.lua - util.encodeString() 함수의 역
-------------------------------------
function Translate:makeUsable(id)
    id = id:gsub('\\n', '\n')
    id = id:gsub('\\t', '\t')
    id = id:gsub("\'", "'")
    id = id:gsub('\"', '"')
    return id
end

-------------------------------------
-- function get
-------------------------------------
function Translate:get(id)
    id = self:makeUsable(id)
    if self.m_mLangMap and self.m_mLangMap[id] then
        return self.m_mLangMap[id]
    end
    return id
end

-------------------------------------
-- function getDeviceLang
-------------------------------------
function Translate:getDeviceLang()
    return self.m_deviceLang
end

-------------------------------------
-- function getGameLang
-------------------------------------
function Translate:getGameLang()
    return self.m_gameLang
end

-------------------------------------
-- function getStdLang
-------------------------------------
function Translate:getStdLang()
    return self.m_stdLang
end

-------------------------------------
-- function isNeedTranslate
-------------------------------------
function Translate:isNeedTranslate()
    return (self.m_gameLang ~= self.m_stdLang)
end

-------------------------------------
-- function getFileNameInfo
-- @brief 파일의 경로를 받아, 경로, 파일명, 확장자를 리턴
-- @return directory
-- @return file_name
-- @return extension
-------------------------------------
function Translate:getFileNameInfo(path)
    return string.match(path, "(.-)([^//]-)(%.[^%.]+)$")
end

-------------------------------------
-- function a2dTranslate
-- @brief a2d파일의 png(plist)파일을 해당하는 국가의 plist로 로드
-------------------------------------
function Translate:a2dTranslate(full_path)
    local game_lang = self.m_gameLang
    
    -- 예외 처리
    if (not game_lang) then
        return
    end
    if (not full_path) then
        return
    end

    local path, file_name, extension = self:getFileNameInfo(full_path)
    local typo_plist_path = string.format('res/%stypo/%s/%s.plist', path, game_lang, file_name)

    -- 번역본 텍스트가 없을 경우 kr버전으로 나오도록 처리
    if (not LuaBridge:isFileExist(typo_plist_path)) then
        typo_plist_path = string.format('res/%stypo/kr/%s.plist', path, file_name)
        if (not LuaBridge:isFileExist(typo_plist_path)) then
            return
        end
    end

    -- plist 등록
    cc.SpriteFrameCache:getInstance():addSpriteFrames(typo_plist_path)
end

-------------------------------------
-- function getTranslatedPath
-------------------------------------
function Translate:getTranslatedPath(full_path)
    -- 번역이 필요한 언어 사용중인지 체크
	if (not Translate:isNeedTranslate()) then
		return full_path
	end

    -- 쓰레기 값은 버림
	if (not full_path) or (full_path == '') then
		return full_path
	end

	-- typo경로의 파일인지 확인
	if (not string.find(full_path, 'typo/')) then
		return full_path
	end

    -- 대상 언어의 경로로 변환
	local game_lang = Translate:getGameLang()
	local translated_path = string.gsub(full_path, 'typo/kr', 'typo/' .. game_lang)

    -- 해당 경로에 파일이 없다면 기존 경로를 반환
	if (not LuaBridge:isFileExist('res/' .. translated_path)) then
        cclog('do not exist translated png : ' .. full_path)
		return full_path
	end
    
	return translated_path
end

-------------------------------------
-- function getLangStrTable
-------------------------------------
function Translate:getLangStrTable()
    return {
		['ko'] = Str('한국어'), 
		['en'] = Str('영어'), 
		['ja'] = Str('일본어'), 
		['zh'] = Str('중국어')
	}
end

-------------------------------------
-- function getFontName
-------------------------------------
function Translate:getFontName()
    local game_lang = self:getGameLang()
    local ret = 'common_font_01.ttf'

    if game_lang == 'ja' then
        ret = 'common_font_01_ja.ttf'
    elseif game_lang == 'zh' then
        ret = 'common_font_01_cn.ttf'
    end

    return ret
end

-------------------------------------
-- function getFontPath
-------------------------------------
function Translate:getFontPath()
    return 'res/font/' .. self:getFontName()
end