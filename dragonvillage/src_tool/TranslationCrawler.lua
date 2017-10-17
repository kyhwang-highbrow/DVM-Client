-------------------------------------
-- summary
-------------------------------------
--[[
실행 시 프로젝트 내 src, res, data 폴더를 순회하며 한국어 텍스트를 수집합니다.
수집된 텍스트는 프로젝트 폴더 내 translate 폴더에 work_xx, full_xx, total_translation 언어별 3가지 형태로 추출됩니다.
번역작업자에게 work_xx를 보내고 작업이 완료된 파일은 파일명 그대로 translate 폴더에 넣은 후
다시 해당 파일을 실행하면 번역이 적용됩니다. (full_xx에 들어감)
work_xx는 번역 대상 텍스트가 없는 경우 생성되지 않습니다.
]]

-------------------------------------
-- Terminology
-------------------------------------
--[[

0. tr = translate

1. work : 미번역된 텍스트 리스트로 작업 대상을 의미, 텍스트의 출처를 병기하지 않는다.
    ex)
        [work_en.json]
        {
            "org":"번역"
            "tr":"translation"
        }

2. full translation : 번역 + 미번역 테스트를 포괄하여 언어별로 생성한 리스트. 출처를 병기.
    ex)
        [full_en.json]
        {
            "org":"번역",
            "tr":"translation", 
            "src":{
                "Translate.lua":1,
                "translate.ui":1,
                "table_translation.csv":1
            }
        }

3. total translation : 모든 언어의 번역 + 미번역 테스트를 포괄한 리스트. 출처 및 모든 언어 병기
    ex)
        [total_translation.json]
        {
            "org":"번역",
            "tr":{
                "en":"translation",
                "jp":"飜譯"
            }
            "src":{
                "Translate.lua":1,
                "translate.ui":1,
                "table_translation.csv":1
            }
        }

]]

-------------------------------------
-- require
-------------------------------------
require 'LuaStandAlone'

-------------------------------------
-- class TranslationCrawler
-------------------------------------
TranslationCrawler = class({
    })

-------------------------------------
-- local vars
------------------------------------- 
local L_LANG = {'en', 'jp'}

-- 추출할 결과 저장 영역
local T_LANG_LIST = {}
local T_WORK = {}

-- 작업용 임시 저장 영역
local T_STR = {}
local T_STR_UI = {}
local T_STR_LUA = {}
local T_STR_DATA = {}

-- 사용할 디렉토리
local CURR_DIR = lfs.currentdir()
local RESULT_DIR = '../translate'

-- 제외할 파일 목록 .. 현재는 csv에만 적용
local T_EXCEPT_FILE = 
{
    ['table_ban_word_chat.csv'] = 1,
    ['table_ban_word_naming.csv'] = 1,
}

-------------------------------------
-- local utillity functions
------------------------------------- 
-- function isKorean
local function isKorean(str)
    return string.match(str, '[가-힣]+')
end

-- function dietTable
local function dietTable(t_table)
    for _,t_line in pairs(t_table) do
        for key,value in pairs(t_line) do
            if pl.stringx.startswith(key, 's_') or pl.stringx.startswith(key, 'r_') then
                t_line[key] = nil
            end
        end
    end
    return t_table
end

-- function readTranslation
local function readTranslation(lang, prefix)
    local t_temp = {}
    local path = string.format('%s/%s_%s.json', RESULT_DIR, prefix, lang)
    local content = LuaBridge:getStringFromFile(path)
    if (content) then
        for i, t_info in ipairs(dkjson.decode(content)) do
            t_temp[t_info['org']] = t_info
        end
        if (prefix == 'work') then
            os.remove(path)
        end
    else
        cclog(string.format('## not exist file : %s_%s', prefix, lang))
    end
    return t_temp
end

-- function makeJsonString
local function makeJsonString(t)
    return dkjson.encode(t, {indent = true, keyorder = {'org', 'tr', 'src'}})
end

-------------------------------------
-- function init
-------------------------------------
function TranslationCrawler:init()
end

-------------------------------------
-- function run
-------------------------------------
function TranslationCrawler:run()
    cclog('##### TranslationCrawler:run')

    -- Stopwatch start
    local stopwatch = Stopwatch()
    stopwatch:start()

    -- 번역 대상 수집
    self:crawler_src()
    self:crawler_ui()
    self:crawler_data()
    
    -- 언어별로 풀스크립트 및 번역안된텍스트파일 생성
    for _, lang in ipairs(L_LANG) do
        self:compareWithFullTranslation(lang)
        self:saveUntranslatedStr(lang)
        self:saveFullTranslation(lang)
        self:saveLuaTranslation(lang)
    end

    self:saveTotalTranslation()

    -- 작업 결과 출력
    self:printResult()

    -- Stopwatch stop
    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function insertData
-- @brief 공통된 form으로 데이터 구성하도록 함
-------------------------------------
function TranslationCrawler:insertData(t, kr_str, file)
    if not (t[kr_str]) then
        t[kr_str] = {
            ['src'] = {},
            ['tr'] = {},
            ['org'] = kr_str,
        }
    end
    t[kr_str]['src'][file] = 1
end

-------------------------------------
-- function crawler_src
-------------------------------------
function TranslationCrawler:crawler_src()
    cclog('#### crawler_src')

    -- @dir, @iter_func
    local root_dir = CURR_DIR .. '/../src'
    local function iter_func(path, file)

        -- 하나의 파일에 해당하는 string
        local content = pl.file.read(path .. '/' .. file)
        
        -- 라인으로 분리되어 있지 않음에 주의하여 정규식 작성
        -- Str('') 제거를 위해 캡쳐 사용
        -- Str(""), Str( ''), Str( "") 등 다양한 오류가 존재할 수 있으므로 최대한 포괄적으로 구성
        for kr_str in string.gmatch(content, 'Str%(%s*[\"\']([^\n]-)[\"\']') do
            if (isKorean(kr_str)) then
                self:insertData(T_STR_LUA, kr_str, file)
                self:insertData(T_STR, kr_str, file)
            end
        end
    end

    -- src 폴더 탐색
    util.iterateDirectory(root_dir, iter_func)
end

-------------------------------------
-- function crawler_ui
-------------------------------------
function TranslationCrawler:crawler_ui()
    cclog('#### crawler_ui')

    -- @dir, @iter_func
    local root_dir = CURR_DIR .. '/../res'
    local function iter_func(path, file)
        if not (pl.stringx.endswith(file, '.ui')) then
            return
        end

        -- 하나의 파일에 해당하는 string
        local content = pl.file.read(path .. '/' .. file)

        -- 라인으로 분리되어 있지 않음에 주의하여 정규식 작성, 
        -- text = '' 또는 placeholder = '' 제거를 위해 캡쳐 사용
        -- ui에서 더미 파일을 걸러야 하는데.. 일차적으로는 {n} 이 포함된 것은 더미로 판단
        for kr_str in string.gmatch(content, '[(text)||(placeholder)] = \'([^\n{]-)\'') do
            if (isKorean(kr_str)) then
                self:insertData(T_STR_UI, kr_str, file)
                self:insertData(T_STR, kr_str, file)
            end
        end
    end

    -- res 폴더 탐색
    util.iterateDirectory(root_dir, iter_func)
end

-------------------------------------
-- function crawler_data
-------------------------------------
function TranslationCrawler:crawler_data()
    cclog('#### crawler_data')

    -- @dir, @iter_func
    local root_dir = CURR_DIR .. '/../data'
    local function iter_func(path, file)
        if (not pl.stringx.endswith(file, '.csv')) then
            return    
        end
        if (T_EXCEPT_FILE[file]) then
            return
        end

        -- 파일명 구성 (서브 폴더 명을 찾아서 붙여준다.)
        local file_name = file:gsub('.csv', '')
        local sub_folder = path:gsub(root_dir, '')
        if (sub_folder ~= '') then
            file_name = sub_folder .. '/' .. file_name
        end
        
        -- csv 파일을 루아 테이블로 변환
        local t_csv = TABLE:loadCSVTable(file_name)
        if (not t_csv) then
            cclog('규약에 맞지 않는 csv파일이 생성되었을 수 있습니다. 개발팀에 문의해주세요')
        end

        -- 테이블을 순회 하며 한글 텍스트를 모조리 찾는다
        -- r_ 또는 s_ 컬럼은 제외한다.
        for _, t_row in pairs(t_csv) do
            for key, value in pairs(t_row) do
                if (pl.stringx.startswith(key, 's_') or pl.stringx.startswith(key, 'r_')) then
                    -- nothing to do
                else
                    if (isKorean(value)) then
                        self:insertData(T_STR_DATA, value, file)
                        self:insertData(T_STR, value, file)
                    end
                end
            end
        end

    end

    -- data 폴더 탐색
    util.iterateDirectory(root_dir, iter_func)
end
    
-------------------------------------
-- function compareWithFullTranslation
-- @brief 추출한 리스트를 언어별 이미 번역된 테스트들과 비교하여 작업대상을 구분하고 full translation을 새로이 생성
-- @param lang 언어키
-------------------------------------
function TranslationCrawler:compareWithFullTranslation(lang)
    cclog('## compare with full translation ' .. lang)

    -- 언어별 테이블 생성
    T_LANG_LIST[lang] = {}
    T_WORK[lang] = {}

    -- 이미 번역된 텍스트 불러옴
    local t_full = readTranslation(lang, 'full')

    -- 작업결과물 번역도 불러옴
    local t_work = readTranslation(lang, 'work')
    
    -- 이미 번역된 텍스트와 비교하여 해당 언어의 맵 생성
    local tr_str
    for str, t_info in pairs(T_STR) do
        -- full translation에 번역한 텍스트가 있음
        if (t_full[str]) and (t_full[str]['tr']) and (t_full[str]['tr'] ~= '') then
            tr_str = t_full[str]['tr']
            
            -- total translation 출력을 위해 저장 
            t_info['tr'][lang] = tr_str

        -- work translation에 번역한 텍스트가 있음
        elseif (t_work[str]) and (t_work[str]['tr']) and (t_work[str]['tr'] ~= '') then
            tr_str = t_work[str]['tr']
            
            -- total translation 출력을 위해 저장 
            t_info['tr'][lang] = tr_str

        -- 번역한 텍스트가 없음
        else
            tr_str = nil
            
            -- 작업 리스트에 추가
            table.insert(T_WORK[lang], {['org'] = str, ['tr'] = ''})
        end

        -- 언어별 full translation에 추가
        table.insert(T_LANG_LIST[lang], {['org'] = str, ['tr'] = tr_str, ['src'] = t_info['src']})
    end
end

-------------------------------------
-- function saveUntranslatedStr
-- @brief 번역 대상 리스트를 저장
-- @param lang 언어키
-------------------------------------
function TranslationCrawler:saveUntranslatedStr(lang)
    cclog('## extract untranslated string ' .. lang)

    -- 작업해야할 텍스트가 없다면 통과
    if (table.count(T_WORK[lang]) == 0) then
        cclog(lang .. ' is translated all')
        return
    end

    -- 가나다 순으로 정렬한다.
    table.sort(T_WORK[lang], function(a, b)
        return a['org'] < b['org']
    end)

    -- 해당 언어 테이블 json으로 변환
    local work_str = makeJsonString(T_WORK[lang])

    -- 저장
    local path = string.format('%s/work_%s.json', RESULT_DIR, lang)
    local f = io.open(path, 'w')
    f:write(work_str)
    f:close()
end

-------------------------------------
-- function saveFullTranslation
-- @brief full translation 을 저장한다.
-- @param lang 언어키
-------------------------------------
function TranslationCrawler:saveFullTranslation(lang)
    cclog('## save full translation ' .. lang)

    -- 가나다 순으로 정렬한다.
    table.sort(T_LANG_LIST[lang], function(a, b)
        return a['org'] < b['org']
    end)

    -- 해당 언어의 전체 파일 json으로 변환
    local json_str = makeJsonString(T_LANG_LIST[lang])

    -- 저장
    local path = string.format('%s/full_%s.json', RESULT_DIR, lang)
    local f = io.open(path,'w')
    f:write(json_str)
    f:close()
end

-------------------------------------
-- function saveLuaTranslation
-- @brief full translation 을 lua table로 변환하여 저장한다.
-- @param lang 언어키
-------------------------------------
function TranslationCrawler:saveLuaTranslation(lang)
    cclog('## save lua translation ' .. lang)

    -- lua table로 변환하기 위해 폼 변경
    local t_lua = {}
    for _, t_info in pairs(T_LANG_LIST[lang]) do
        t_lua[t_info['org']] = t_info['tr'] -- 번역 텍스트가 없다면 생성되지 않음
    end

    -- 해당 언어의 전체 파일 json으로 변환
    local lua_str = 'return ' .. util.makeLuaTableStr(t_lua)

    -- 저장
    local path = string.format('%s/%s.lua', RESULT_DIR, lang)
    local f = io.open(path,'w')
    f:write(lua_str)
    f:close()
end

-------------------------------------
-- function saveTotalTranslation
-- @brief 모든 언어를 통합한 total translation 을 저장한다.
-------------------------------------
function TranslationCrawler:saveTotalTranslation()
    cclog('## save total translation')

    -- 리스트로 변환
    local l_sort = {}
    for str, t_info in pairs(T_STR) do
        table.insert(l_sort, t_info)
    end

    -- 가나다 순으로 정렬한다.
    table.sort(l_sort, function(a, b)
        return a['org'] < b['org']
    end)

    -- json으로 변환
    local json_str = makeJsonString(l_sort)

    -- 저장
    local path = string.format('%s/total_translation.json', RESULT_DIR)
    local f = io.open(path,'w')
    f:write(json_str)
    f:close()
end

-------------------------------------
-- function printResult
-------------------------------------
function TranslationCrawler:printResult()
    cclog('RESULT ==========================================')
    cclog('src string cnt: ' .. table.count(T_STR_LUA))
    cclog('ui string cnt: ' .. table.count(T_STR_UI))
    cclog('data string cnt: ' .. table.count(T_STR_DATA))
    cclog('total : ' .. table.count(T_STR))
    for lang, t_str in pairs(T_WORK) do
        cclog(lang .. ' work out :' .. table.count(t_str))
    end
    cclog('==================================================')
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    TranslationCrawler():run()
end
