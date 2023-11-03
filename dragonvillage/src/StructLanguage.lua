-------------------------------------
-- class StructLanguage
-- @brief 게임에서 제공하는 언어별 설정을 관리하는 구조체
-------------------------------------
StructLanguage = class({
        m_name = 'string',
        m_nameAlpha2 = 'string',
        m_displayName = 'string',
        m_bActive = 'bool', -- 언어 활성화 여부
        m_translateFile = 'string',
        m_fontRes = 'string', -- TTF 폰트명
        m_fontSizeScale = 'number',
        m_fontScaleRateX = 'number',
        m_fontScaleRateY = 'number',
        m_isRTL = 'boolean',
        m_priority = 'number',
        m_langCode = 'string',
    })

local THIS = StructLanguage

-------------------------------------
-- function init
-------------------------------------
function StructLanguage:init()
    -- 기본값은 영어로 설정
    self.m_name = 'ENGLISH'
    self.m_nameAlpha2 = 'en'    
    self.m_displayName = 'English'
    self.m_bActive = true
    self.m_translateFile = 'translate/lang_en'
    self.m_fontRes = 'common_font_01.ttf'
    self.m_fontSizeScale = 1
    self.m_fontScaleRateX = 1
    self.m_fontScaleRateY = 1
    self.m_isRTL = false
    self.m_priority = 0
end

-------------------------------------
-- function loadLanguageMap
-- @brief lua파일로 변환된 번역 파일 읽기
-------------------------------------
function StructLanguage:loadLanguageMap()
    local stop_watch = Stopwatch()
	local language_map = nil

    language_map = self:patchLanguageMap() -- require 'translate/lang_en' 

    return language_map
end

-------------------------------------
-- function patchLanguageMap
-- @brief 델타 번역파일까지 반영한 번역파일을 반환
-------------------------------------
function StructLanguage:patchLanguageMap()
    local function getPatchTable(patch_path)
        return require(patch_path)
    end

    local language_map = nil
    if self.m_translateFile then
        -- 개발 환경에서는 _temp 폴더에서 언어 리소스를 가져옴(언어 패치 시스템 변경으로 인해 잠시동안 폴더를 분리해서 관리)
        if CppFunctions:isWin32() == true then
            --local path = string.format('%s.lua', self.m_translateFile)
            local path_new = string.format('%s.lua', string.gsub(self.m_translateFile, 'translate/', 'translate_temp/'))
            if (cc.FileUtils:getInstance():isFileExist(path_new) == true) then
                self.m_translateFile = string.gsub(self.m_translateFile, 'translate/', 'translate_temp/')
            end
        end

        language_map = require(self.m_translateFile) -- require 'translate/lang_en' 
        local patch_name = self.m_translateFile .. '_patch' -- require 'translate/lang_en_patch'
        local b_result, patch_language_map = pcall(getPatchTable, patch_name)
        
        if b_result then
            for k, v in pairs(patch_language_map) do
                if language_map[k] ~= v then
                    language_map[k] = v
                end
            end
        else
            if CppFunctions:isWin32() == true then
                local path = string.format('%s.lua', patch_name)
                if (cc.FileUtils:getInstance():isFileExist(path) == true) then
                    error(string.format('%s.lua 파일에 텍스트 오류가 있습니다.', patch_name))
                end
            end
        end
    end

    return language_map
end

-------------------------------------
---@function getLanguageSimpleDisplayName
---@brief 유저에게 표시될 이름 반환 (자국어로만 표기)
---@return string 표시 이름
-------------------------------------
function StructLanguage:getLanguageSimpleDisplayName()
    return self.m_displayName
end

-------------------------------------
---@function getLanguageEnglishDisplayName
---@brief 유저에게 표시될 이름 반환 (영어로만 표기)
---@return string 표시 이름
-------------------------------------
function StructLanguage:getLanguageEnglishDisplayName()
    return self.m_name
end

-------------------------------------
---@function getLanguageCode
---@brief ISO 639-1 코드 반환 
---@return string ISO 639-1 코드
-------------------------------------
function StructLanguage:getLanguageCode()
    return self.m_nameAlpha2
end

-------------------------------------
---@function getLanguageFullDisplayName
---@brief 유저에게 표시될 이름 반환 (자국어 + 영어로 표기)
---@return string 표시 이름
-------------------------------------
function StructLanguage:getLanguageFullDisplayName()
    local simple_name = self:getLanguageSimpleDisplayName()
    local en_name = self:getLanguageEnglishDisplayName()
    return string.format('%s (%s)', simple_name, en_name)
end








-------------------------------------
-- function makeStructLanguageMap
-------------------------------------
function StructLanguage:makeStructLanguageMap()
    if Translate.use133Languages == true then
        local language_map = TableLanguageConfig:getInstance():getStructLanguageMap()
        return language_map
    end

    local l_lan = {
        'ko',
        'en',
        'zh',
        'ja',
        'th',
        'es',
        'fa',
    }

    local t_struct_lan = {}
    for _,lan in ipairs(l_lan) do
        local create_func = StructLanguage['create_' .. lan]
        if create_func then
            t_struct_lan[lan] = create_func()
        end
    end

    return t_struct_lan
end

-------------------------------------
-- function create_ko
-- @brief 한국어
-------------------------------------
function StructLanguage:create_ko()
    local struct = StructLanguage()

    struct.m_name = 'KOREAN'
    struct.m_nameAlpha2 = 'ko'
    struct.m_displayName = '한국어'
    struct.m_bActive = true
    struct.m_translateFile = nil
    struct.m_fontRes = 'common_font_01.ttf'
    struct.m_fontSizeScale = 1
    struct.m_fontScaleRateX = 1
    struct.m_fontScaleRateY = 1

    return struct
end

-------------------------------------
-- function create_en
-- @brief 영어
-------------------------------------
function StructLanguage:create_en()
    local struct = StructLanguage()

    struct.m_name = 'ENGLISH'
    struct.m_nameAlpha2 = 'en'
    struct.m_displayName = 'English'
    struct.m_bActive = true
    struct.m_translateFile = 'translate/lang_en'
    struct.m_fontRes = 'common_font_01.ttf'
    struct.m_fontSizeScale = 1
    struct.m_fontScaleRateX = 1
    struct.m_fontScaleRateY = 1

    return struct
end

-------------------------------------
-- function create_zh
-- @brief 중국어 번체
-------------------------------------
function StructLanguage:create_zh()
    local struct = StructLanguage()

    struct.m_name = 'CHINESE'
    struct.m_nameAlpha2 = 'zh'
    struct.m_displayName = '中文(繁體)'
    struct.m_bActive = true
    struct.m_translateFile = 'translate/lang_zhtw'
    struct.m_fontRes = 'common_font_01_cn.ttc'
    struct.m_fontSizeScale = 0.88
    struct.m_fontScaleRateX = 0.88
    struct.m_fontScaleRateY = 0.98

    return struct
end

-------------------------------------
-- function create_ja
-- @brief 일본어
-------------------------------------
function StructLanguage:create_ja()
    local struct = StructLanguage()

    struct.m_name = 'JAPANESE'
    struct.m_nameAlpha2 = 'ja'
    struct.m_displayName = '日本語'
    struct.m_bActive = true
    struct.m_translateFile = 'translate/lang_jp'
    struct.m_fontRes = 'common_font_01_ja.ttf'
    struct.m_fontSizeScale = 0.88
    struct.m_fontScaleRateX = 0.88
    struct.m_fontScaleRateY = 1

    return struct
end

-------------------------------------
-- function create_th
-- @brief 태국어
-------------------------------------
function StructLanguage:create_th()
    local struct = StructLanguage()

    struct.m_name = 'THAI'
    struct.m_nameAlpha2 = 'th'
    struct.m_displayName = 'ภาษาไทย'
    struct.m_bActive = true
    struct.m_translateFile = 'translate/lang_th'
    struct.m_fontRes = 'common_font_01_th.ttf'
    struct.m_fontSizeScale = 0.8
    struct.m_fontScaleRateX = 0.8
    struct.m_fontScaleRateY = 0.8

    return struct
end

-------------------------------------
-- function create_es
-- @brief 스페인어
-------------------------------------
function StructLanguage:create_es()
    local struct = StructLanguage()

    struct.m_name = 'SPANISH'
    struct.m_nameAlpha2 = 'es'
    struct.m_displayName = 'español'
    struct.m_bActive = true
    struct.m_translateFile = 'translate/lang_es'
    struct.m_fontRes = 'common_font_01_ja.ttf' -- 일본어 폰트 같이 사용 (히스토리는 모르겠음 sgkim)
    struct.m_fontSizeScale = 0.7
    struct.m_fontScaleRateX = 0.75
    struct.m_fontScaleRateY = 0.82

    return struct
end

-------------------------------------
-- function create_fa
-- @brief 페르시아어
-------------------------------------
function StructLanguage:create_fa()
    local struct = StructLanguage()

    struct.m_name = 'PERSIAN' -- 영어 명칭은 Persian, ISO_639 Alpha-2는 fa로 주의할 것
    struct.m_nameAlpha2 = 'fa'
    struct.m_displayName = 'فارسی'
    struct.m_bActive = false
    struct.m_translateFile = 'translate/lang_fa'
    struct.m_fontRes = 'iran.ttf'
    struct.m_fontSizeScale = 1
    struct.m_fontScaleRateX = 1
    struct.m_fontScaleRateY = 1

    -- 카페 바자르 빌드에서만 동작
    if (CppFunctions:isCafeBazaarBuild() == true) then
        struct.m_bActive = true
    end

    return struct
end