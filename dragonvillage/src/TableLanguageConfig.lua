---@inherit TableClass
local PARENT = TableClass

-------------------------------------
---@class TableLanguageConfig : TableClass
---언어 정보 테이블
---@link https://docs.google.com/spreadsheets/d/1_qVBQUkn-qwwdj8AfcoGjAErRvUkbzTnRF5CloRgKIc
---@field m_languageMap { string : Language } k : 언어 코드, v : Language
---@field m_langSquareChannelIdMap { number : Language } k : 채널 ID, v : Language
---@field m_langSquareChannelIdList number[] 언어 채널 ID 리스트
-------------------------------------
TableLanguageConfig = class(PARENT, {
    m_languageMap = '{ string : Language }', 
    m_langSquareChannelIdMap = '{ number : string }',
    m_langSquareChannelIdList = 'number[]',
})

local instance = nil
-------------------------------------
---@function init
-------------------------------------
function TableLanguageConfig:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_language_config'
    self.m_orgTable = TABLE:get(self.m_tableName)
    self.m_languageMap = nil
end

-------------------------------------
---@function getInstance
-------------------------------------
function TableLanguageConfig.getInstance()
    if (instance == nil) then
        instance = TableLanguageConfig()
    end
    return instance
end

-------------------------------------
---@function _makeStructLanguage
-------------------------------------
function TableLanguageConfig:_makeStructLanguage(lang_code)
    local struct = StructLanguage()

    struct.m_nameAlpha2 = lang_code -- ISO 639-1 언어 코드
    --struct.m_hiveCode = self:getValue(lang_code, 'hive_code') -- ISO 639-1 언어 코드
    struct.m_name = self:getValue(lang_code, 'en_name') -- 영어 이름
    struct.m_displayName = self:getValue(lang_code, 'display_name') -- 유저에게 UI에서 노출되는 이름, 해당 데이터는 의도적으로 번역하지 않는다.
    struct.m_bActive = toboolean(self:getValue(lang_code, 'active')) -- 활성화 여부
    struct.m_translateFile = self:getValue(lang_code, 'translate_file') -- 번역 파일 경로
    struct.m_fontRes = self:getValue(lang_code, 'font_res') -- 폰트 리소스 경로
    struct.m_fontSizeScale = self:getValue(lang_code, 'font_size_scale') -- 폰트 사이즈 스케일링
    struct.m_fontScaleRateX = self:getValue(lang_code, 'font_scale_rate_x') -- 폰트 사이즈 스케일링에서 X축 비율
    struct.m_fontScaleRateY = self:getValue(lang_code, 'font_scale_rate_y') -- 폰트 사이즈 스케일링에서 Y축 비율
    struct.m_isRTL = toboolean(self:getValue(lang_code, 'is_rtl')) -- 언어의 RTL(오른쪽에서 왼쪽으로 쓰는지) 여부
    struct.m_priority = self:getValue(lang_code, 'ui_priority') -- UI 노출 우선 순위, 클수록 먼저 노출됨

    return struct
end

-------------------------------------
---@function _initData
-------------------------------------
function TableLanguageConfig:_initData()
    local language_map = {}
    local lang_square_id_map = {}
    local lang_code_list = self:getTableKeyList()
    for _, lang_code in ipairs(lang_code_list) do
        local struct_lang = self:_makeStructLanguage(lang_code)
        -- 언어 구조체 맵
        language_map[lang_code] = struct_lang      
        -- 언어 채널 ID별 구조체 맵
--[[         local lang_square_id = tonumber(self:getValue(lang_code, 'lang_square'))
        if (lang_square_id ~= nil) then
            lang_square_id_map[lang_square_id] = struct_lang
        end ]]
    end
    self.m_languageMap = language_map
    self.m_langSquareChannelIdMap = lang_square_id_map
end

-------------------------------------
---@function getStructLanguageMap
-------------------------------------
function TableLanguageConfig:getStructLanguageMap()
    -- 아직 데이터 초기화가 안된 경우
    if (self.m_languageMap == nil) then
        self:_initData()
    end
    return self.m_languageMap
end

-------------------------------------
---@function getUniqueFontNameList
-------------------------------------
function TableLanguageConfig:getUniqueFontNameList()
    return self:getUniqueValueList('font_res', true)
end

-------------------------------------
---@function getLanguageDisplayNameFromSquareChannelId
---@param lang_square_id number
---@return string 유저에게 노출되어야 하는 이름
-------------------------------------
function TableLanguageConfig:getLanguageDisplayNameFromSquareChannelId(lang_square_id)
    if (lang_square_id == CONST.SQUARE.CHANNEL.LANG_GLOBAL_ID) then
        return Str('글로벌')
    end 

    -- 아직 데이터 초기화가 안된 경우
    if (self.m_langSquareChannelIdMap == nil) then
        self:_initData()
    end

    local struct_lang = self.m_langSquareChannelIdMap[lang_square_id]
    -- 무언가 잘못되었다..
    if (struct_lang == nil) then
        return ccex.STR.EMPTY
    end

    return struct_lang:getLanguageSimpleDisplayName()
end

-------------------------------------
---@function getLanguagegetLanguageCodeForHiveFromSquareChannelId
---@param lang_square_id number
---@return string 서버 및 하이브 전달용 언어 코드
-------------------------------------
function TableLanguageConfig:getLanguagegetLanguageCodeForHiveFromSquareChannelId(lang_square_id)
    -- 글로벌인 경우
    if (lang_square_id == CONST.SQUARE.CHANNEL.LANG_GLOBAL_ID) then
        return 'global'
    end 

    -- 아직 데이터 초기화가 안된 경우
    if (self.m_langSquareChannelIdMap == nil) then
        self:_initData()
    end

    local struct_lang = self.m_langSquareChannelIdMap[lang_square_id]
    -- 무언가 잘못되었다..
    if (struct_lang == nil) then
        return ccex.STR.EMPTY
    end

    return struct_lang:getLanguageCodeForHive()
end

-------------------------------------
---@function getLanguageSquareChannelIdList
---@return number[]
-------------------------------------
function TableLanguageConfig:getLanguageSquareChannelIdList()
    if (self.m_langSquareChannelIdList == nil) then
        if (self.m_langSquareChannelIdMap == nil) then
            self:_initData()
        end
        local id_list = table.MapKeyToList(self.m_langSquareChannelIdMap) -- 언어 채널 ID 맵 -> 리스트 변환
        table.insert(id_list, 1, CONST.SQUARE.CHANNEL.LANG_GLOBAL_ID) -- 글로벌 ID 추가
        table.sort(id_list, function(a, b) return a < b end)
        self.m_langSquareChannelIdList = id_list
    end

    return clone(self.m_langSquareChannelIdList)
end