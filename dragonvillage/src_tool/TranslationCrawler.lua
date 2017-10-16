require 'LuaStandAlone'

-------------------------------------
-- class TranslationCrawler
-------------------------------------
TranslationCrawler = class({
    })

-------------------------------------
-- local vars
-------------------------------------  
local T_STR = {}
local T_UI_STR = {}
local T_LUA_STR = {}
local T_DATA_STR = {}

local CURR_DIR = lfs.currentdir()
local RESULT_DIR = '../translate/'

local T_EXCEPT_FILE = 
{
    ['table_ban_word_chat.csv'] = true,
    ['table_ban_word_naming.csv'] = true,
}

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

    self:printDebug()

    self:saveTraslation()

    -- Stopwatch stop
    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function insertData
-------------------------------------
function TranslationCrawler:insertData(t, kr_str, file)
    if not (t[kr_str]) then
        t[kr_str] = {
            ['src'] = {},
            ['tr'] = {
                ['en'] = nil,
                ['jp'] = nil,
            }
        }
    end
    t[kr_str]['src'][file] = true
end

-------------------------------------
-- function crawler_src
-------------------------------------
function TranslationCrawler:crawler_src()
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
                self:insertData(T_LUA_STR, kr_str, file)
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
                self:insertData(T_UI_STR, kr_str, file)
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
                        self:insertData(T_DATA_STR, value, file)
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
-- function saveTraslation
-------------------------------------
function TranslationCrawler:saveTraslation()

end

-------------------------------------
-- function saveTraslation
-------------------------------------
function TranslationCrawler:saveTraslation()

end

-------------------------------------
-- function saveTraslation
-------------------------------------
function TranslationCrawler:saveTraslation()
    local json_str = json.encode(T_STR)

    local f = io.open(RESULT_DIR .. 'full_translation.json','w')
    f:write(json_str)
    f:close()
end

-------------------------------------
-- function printDebug
-------------------------------------
function TranslationCrawler:printDebug()
    cclog('==================================================')
    cclog('src string cnt: ' .. table.count(T_LUA_STR))
    cclog('ui string cnt: ' .. table.count(T_UI_STR))
    cclog('data string cnt: ' .. table.count(T_DATA_STR))
    cclog('total : ' .. table.count(T_STR))
    cclog('==================================================')
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    TranslationCrawler():run()
end
