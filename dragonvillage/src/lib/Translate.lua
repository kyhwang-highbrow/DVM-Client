-------------------------------------
-- table Translate
-------------------------------------
Translate = {
    m_mLangMap = nil,
    m_stdLang = nil,
    m_deviceLang = nil,
    m_gameLang = nil,
}

-- key는 영어 정식 명칭, value 는 ISO 639의 Alpha-2 표기를 따른다.
local LANG = {
	['KOREAN'] = 'ko',
	['JAPANESE'] = 'ja',
	['CHINESE'] = 'zh',
	['ENGLISH'] = 'en',
	['THAI'] = 'th',
	['SPANISH'] = 'es',
}
-------------------------------------
-- function init
-------------------------------------
function Translate:init()

    -- getDeviceLang을 하면 중국어에서 zh-cn 으로 들어오고
	-- 엔진에 있는 languageCode가 의도한대로 값이 들어와
	-- getCurrentLanguageCode 함수를 사용하기로 함

	-- 디바이스 언어
    self.m_deviceLang = cc.Application:sharedApplication():getCurrentLanguageCode()
	
	-- 기준 언어
	self.m_stdLang = LANG['KOREAN']

	-- 게임 언어 (유저의 선택)
	self.m_gameLang = g_localData:getLang()
	
	-- 신규 유저의 경우 
	if (not self.m_gameLang) then
		-- 정의된 언어는 디바이스 언어를 따름
		if (table.find(LANG, self.m_deviceLang) ~= nil) then
			self.m_gameLang = self.m_deviceLang
		-- 정의되지 않은 언어는 영어로 처리
		else
			self.m_gameLang = 'en'
		end
		g_localData:setLang(self.m_gameLang)
	end

	-- 한국어가 아닌 경우 언어 모듈 로드
	if (self.m_gameLang ~= self.m_stdLang) then
		self:load(self.m_gameLang)
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
	self.m_gameLang = lang

    -- 한국어가 아니라면 m_mLangMap 호출
    if (lang == LANG['ENGLISH']) then
        self.m_mLangMap = require 'translate/lang_en'

    elseif (lang == LANG['JAPANESE']) then
        self.m_mLangMap = require 'translate/lang_jp'

	elseif (lang == LANG['CHINESE']) then
        self.m_mLangMap = require 'translate/lang_zhtw'

	elseif (lang == LANG['THAI']) then
        self.m_mLangMap = require 'translate/lang_th'

	elseif (lang == LANG['SPANISH']) then
        self.m_mLangMap = require 'translate/lang_es'

	-- 한국어는 m_mLangMap을 생성하지 않는다
	elseif (lang == LANG['KOREAN']) then
		-- nothing to do

	-- 정의 되지 않은 언어는 '영어'로 일괄 처리
	else
		self.m_gameLang = LANG['ENGLISH']
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
    else
        if isWin32() and CppFunctionsClass:isTestMode() and string.match(id, '[가-힣]+') then
            if self.m_mLangMap then                
                cclog("----------------------------------------")
                cclog("미번역: " .. id .. "\n")
                --cclog(debug.traceback())
                cclog("----------------------------------------")
            end
        end
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
    local game_lang = self:getGameLang()
    
    -- 예외 처리
    if (not game_lang) then
        return
    end
    if (not full_path) then
        return
    end

    local path, file_name, extension = self:getFileNameInfo(full_path)
    path = string.gsub(path,'res/','')
    path = string.gsub(path,'res\\','')
    local typo_plist_path = string.format('res/%stypo/%s/%s.plist', path, game_lang, file_name)

    -- 번역본 텍스트가 없을 경우 ko버전으로 나오도록 처리
    if (not LuaBridge:isFileExist(typo_plist_path)) then
        typo_plist_path = string.format('res/%stypo/ko/%s.plist', path, file_name)
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
	local game_lang = self:getGameLang()
	local translated_path = string.gsub(full_path, 'typo/ko', 'typo/' .. game_lang)

    -- 해당 경로에 파일이 없다면 기존 경로를 반환
	if (not LuaBridge:isFileExist('res/' .. translated_path)) then
        cclog('do not exist translated png : ' .. full_path)
        cclog('translated_path : ' .. translated_path )
		return full_path
	end
    
	return translated_path
end

-------------------------------------
-- function getLangStrTable
-------------------------------------
function Translate:getLangStrTable()
    return {
		['ko'] = '한국어', 
		['en'] = 'English', 
		['ja'] = '日本語', 
		['zh'] = '中文(繁體)',
		['th'] = 'ภาษาไทย',
		['es'] = 'español',
	}
end

-------------------------------------
-- function getFontName
-------------------------------------
function Translate:getFontName()
    local game_lang = self:getGameLang()
    local ret = 'common_font_01.ttf'

    if (game_lang == LANG['JAPANESE']) then
        ret = 'common_font_01_ja.ttf'
    elseif (game_lang == LANG['CHINESE']) then
        ret = 'common_font_01_cn.ttc'
	elseif (game_lang == LANG['THAI']) then
        ret = 'common_font_01_th.ttf'
	elseif (game_lang == LANG['SPANISH']) then
        ret = 'common_font_01_ja.ttf'
    end

    return ret
end

-------------------------------------
-- function getFontPath
-------------------------------------
function Translate:getFontPath()
    return 'res/font/' .. self:getFontName()
end

-------------------------------------
-- function getFontScaleRate
-------------------------------------
function Translate:getFontScaleRate()
    local retX = 1
    local retY = 1
    local game_lang = self:getGameLang()

    if (game_lang == LANG['JAPANESE']) then
        retX = 0.88
    elseif (game_lang == LANG['CHINESE']) then
        retX = 0.88
        retY = 0.98
	elseif (game_lang == LANG['THAI']) then
        retX = 0.8
		retY = 0.8
	elseif (game_lang == LANG['SPANISH']) then
        retX = 0.75
		retY = 0.82
    end

    return retX, retY
end

-------------------------------------
-- function getGameLangTable
-- @breif
-------------------------------------
function Translate:getGameLangTable()
    return LANG
end