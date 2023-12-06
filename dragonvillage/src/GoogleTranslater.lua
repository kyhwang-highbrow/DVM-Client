-------------------------------------
---@class GoogleTranslater
---Google Cloud Translate API v2
---@field m_apiKey string
---@field m_cachedTranslatedMap {string : string}
---@field m_cachedDetectedLangMap {string : string}
-------------------------------------
GoogleTranslater = class({
    m_apiKey = 'string',
    m_cachedTranslatedMap = '{string : string}',
    m_cachedDetectedLangMap = '{string : string}',
})

---@type GoogleTranslater
local instance = nil

-------------------------------------
---@function init
-------------------------------------
function GoogleTranslater:init()
    if (CppFunctions:isIos() == true) then
        self.m_apiKey = "AIzaSyBlkzvs8yz7s56tGQnSWBJMPjrinlDdgqE" -- iOS & Translation API만 허용
    elseif (CppFunctionsClass:isAndroid() == true) then
        self.m_apiKey = "AIzaSyCEHGL5Ks21LHlKcSYkzeOFAzQmAgSyhgQ" -- Android & Translation API만 허용
    else
        self.m_apiKey = "AIzaSyCNoX1UWvU2nM3HY5X1newk3rIgAjY8K6k" -- 본사 사무실 IP만 허용
    end
    self.m_cachedTranslatedMap = {}
    self.m_cachedDetectedLangMap = {}
end

-------------------------------------
---@function getInstance
---@return GoogleTranslater
-------------------------------------
function GoogleTranslater:getInstance()
    if (instance == nil) then
        instance = GoogleTranslater()
    end
    return instance
end

-------------------------------------
---@function _getHeader
---@private
-------------------------------------
function GoogleTranslater:_getHeader()
    local t_header = {}
    if (CppFunctionsClass:isAndroid() == true) then
        t_header['X-Android-Package'] = 'com.perplelab.dragonvillagem.kr'
        --t_header['X-Android-Cert'] = 'C88F42356784723168ECA33C803C4D1CAA0DACE7'
    elseif (CppFunctions:isIos() == true) then
        t_header['x-ios-bundle-identifier'] = 'com.perplelab.dragonvillagem.kr'
    end
    return t_header
end

-------------------------------------
---@function request_translate
---언어 번역
---@param text string
---@param success_cb fun(translated_text : string, detected_lang : string):nil
---@param fail_cb? fun():nil
---@return string|nil
-------------------------------------
function GoogleTranslater:request_translate(text, success_cb, fail_cb)
    -- 캐싱된 데이터가 있다면 바로 반환
    if (self.m_cachedTranslatedMap[text] ~= nil) then
        SafeFuncCall(success_cb, self.m_cachedTranslatedMap[text], self.m_cachedDetectedLangMap[text])
        return
    end

    local ui_loading = UI_Loading()

    local api_url = 'https://translation.googleapis.com/language/translate/v2?key=' .. self.m_apiKey

    -- 파라미터 셋팅
    local t_data = {}
    t_data['q'] = text -- 번역할 메세지
    t_data['source'] = nil -- 번역할 메세지의 언어
    t_data['target'] = Translate:getGameLang() -- 목표 언어
    t_data['format'] = 'text'

    -- header
    local t_header = self:_getHeader()

    -- 요청 정보 설정
    local t_request = {}
    t_request['full_url'] = api_url
    t_request['method'] = 'POST'
    t_request['data'] = t_data
    t_request['header'] = t_header

    -- 성공 시 콜백 함수
    t_request['success'] = function(ret)
        -- {
        --     ['data']={
        --         ['translations']={
        --             {
        --                 ['detectedSourceLanguage']='ko';
        --                 ['translatedText']='Nice to meet you.';
        --             };
        --         };
        --     };
        -- }
        local detected_lang = nil
        local translated_text = text
        if (ret['data'] ~= nil) then
            ccdump(ret['data'])
            if (ret['data']['translations'] ~= nil) then
                local t_data = table.getFirst(ret['data']['translations'])
                if (t_data ~= nil) then
                    translated_text = t_data['translatedText']
                    detected_lang = t_data['detectedSourceLanguage']
                end
            end
        end

        -- 들고 있는 번역 데이터가 너무 커지는 경우는 방지
        local cur_count = table.count(self.m_cachedTranslatedMap)
        if (cur_count >= 1000) then
            -- 1000개 이상 저장중인 경우 500개 날려버리기
            local over_count = (cur_count - 500)
            local cur_key_list = table.MapKeyToList(self.m_cachedTranslatedMap)
            local remove_key_list = table.getRandomList(cur_key_list, over_count)
            for _, remove_key in ipairs(remove_key_list) do
                self.m_cachedTranslatedMap[remove_key] = nil
                self.m_cachedDetectedLangMap[remove_key] = nil
            end
        end

        -- 캐싱
        self.m_cachedTranslatedMap[text] = translated_text
        self.m_cachedDetectedLangMap[text] = detected_lang

        -- 매개 변수로 받은 success_cb 호출
        SafeFuncCall(success_cb, translated_text, detected_lang)
        
        ui_loading:close()
    end

    -- 실패했을때 처리
    local function _fail_cb(ret)
        SafeFuncCall(fail_cb, ret)
        ui_loading:close()
    end

    -- 실패 시 콜백 함수
    t_request['fail'] = _fail_cb

    -- 네트워크 통신
    local code = Network:SimpleRequest(t_request)
end

-- -------------------------------------
-- ---@function request_detectLang
-- ---언어 코드 파악 (현재 사용되는 곳 없음, 참고만 할 것)
-- ---@param text string
-- ---@param success_cb fun(lang_code : string):nil
-- ---@param fail_cb? fun():nil
-- ---@return string|nil
-- -------------------------------------
-- function GoogleTranslater:request_detectLang(text, success_cb, fail_cb)
--     local api_url = 'https://translation.googleapis.com/language/translate/v2/detect?key=' .. self.m_apiKey

--     -- 파라미터 셋팅
--     local t_data = {}
--     t_data['q'] = text -- 번역할 메세지

--     -- header
--     local t_header = self:_getHeader()

--     -- 요청 정보 설정
--     local t_request = {}
--     t_request['full_url'] = api_url
--     t_request['method'] = 'POST'
--     t_request['data'] = t_data
--     t_request['header'] = t_header

--     -- 성공 시 콜백 함수
--     t_request['success'] = function(ret)
--         -- {
--         --     ['data']={
--         --         ['detections']={
--         --             {
--         --                 {
--         --                     ['isReliable']=false;
--         --                     ['confidence']=1;
--         --                     ['language']='en';
--         --                 };
--         --             };
--         --         };
--         --     };
--         -- }
--         local detected_lang = nil
--         if (ret['data'] ~= nil) then
--             if (ret['data']['detections'] ~= nil) then
--                 local t_data = table.getFirst(ret['data']['detections'])
--                 if (t_data ~= nil) then
--                     detected_lang = t_data['language']
--                 end
--             end
--         end
--         SafeFuncCall(success_cb, detected_lang)
--     end

--     -- 실패 시 콜백 함수
--     t_request['fail'] = fail_cb

--     -- 네트워크 통신
--     Network:SimpleRequest(t_request)
-- end