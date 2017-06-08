require 'perpleLib/StringUtils'
-------------------------------------
-- class UnusedUIFileExtractor
-------------------------------------
UnusedUIFileExtractor = class({
    m_resRoot = '',
    m_tSrcRoot = '',
    
    t_resFileName = 'table',     -- key = UI 파일 이름, value = 테이블(key = src 파일 이름, value = line)
    t_srcFileName = 'table',     -- key = number, value = 테이블(key = src 파일 이름, value = 테이블(key = UI 파일 이름, value = 출현 line))

    t_unusedFileName = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UnusedUIFileExtractor:init(m_tSrcRoot, m_resRoot)
    self.m_tSrcRoot = m_tSrcRoot or {'..\\src', '..\\src_tool',}
    self.m_resRoot = m_resRoot or '..\\res\\'

    self.t_resFileName = {}
    self.t_srcFileName = {}
    self.t_unusedFileName = {}
end


-------------------------------------
-- function extractUnusedUIFile
-- @brief 쓰이지 않는 ui resource 파일을 찾아낸다.
-- @return 쓰이지 않는 ui resource 파일들의 이름이 담겨있는 table
-------------------------------------
function UnusedUIFileExtractor:extractUnusedUIFile() 
    self:initializeTables()
    -- 1. 전체 소스파일에서 모든 .ui파일을 검색하여 테이블에 저장.
    for i = 1, #self.t_srcFileName do
        for k, _ in pairs(self.t_srcFileName[i]) do
            print(k .. ' 검사중.. \n')
            self.t_srcFileName[i][k] = self:findUsedUIFiles(k)
        end
    end
    print ( '\n\n\n 사용된 .ui 파일 추출 완료 \n\n\n\n' )

    -- 2. 전체 res파일의 이름을 1.에서 만든 테이블 안에서 검색/분류한다.
    for ui_file_name, value in pairs(self.t_resFileName) do
        print(ui_file_name .. ' 검사중.. \n')
        local flag = false                                                          -- .ui 파일이 한 곳에라도 쓰이면 set.
        for i = 1, #self.t_srcFileName do
            for src_file_name, v in pairs(self.t_srcFileName[i]) do                 -- 소스파일 테이블에서
                for ui_file_name_in_table, _ in pairs(v) do                         -- 소스파일 테이블의 value테이블 안에서
                   
                    if(ui_file_name == ui_file_name_in_table) then                  -- ui 파일 이름이 실제로 사용되는 것이라면
                        if(nil == value[src_file_name]) then                        -- ui 파일 테이블의 value가 nil이면 
                            value[src_file_name] = {}                               -- 초기화
                        end
                        for j = 1, #v[ui_file_name] do 
                            table.insert(value[src_file_name], v[ui_file_name][j])  -- UI파일 테이블의 value테이블에 몇번째 라인에서 쓰이는지 추가.
                        end
                        flag = true                                                 -- 쓰이니까 flag set
                    end 
                end
            end
        end
        if(not flag) then                                                           -- 해당 ui 파일이 쓰이지 않은 경우.
            table.insert(self.t_unusedFileName, ui_file_name)
        end
    end

    self:makeOutputFile()
    return self.t_unusedFileName
end


-------------------------------------
-- function initializeTables
-- @brief res파일 테이블과 src파일 테이블의 값(file path)을 설정한다.
-------------------------------------
function UnusedUIFileExtractor:initializeTables()
    self.t_resFileName = self:getAllFilePathByKey(self.m_resRoot, false, '*.ui')
    for _, value in ipairs(self.m_tSrcRoot) do
        table.insert(self.t_srcFileName, self:getAllFilePathByKey(value, true))
    end
end

-------------------------------------
-- function getAllFilePathByKey
-- @brief   경로 아래에 있는 모든 파일의 경로를 반환
-- @param   root : 기준이 될 경로(상대, 절대 둘 다 가능)
--          RETURN_FULL_PATH : optional(default false), 절대경로로써 반환할것인지, 상대경로로 반환할것인지. 
--          shell_pattern : optional(반환할 파일 패턴(확장자))
-- @return  파일 경로를 가진 테이블(key : 파일 경로, value : 빈 테이블)
-------------------------------------
function UnusedUIFileExtractor:getAllFilePathByKey(root, RETURN_FULL_PATH, shell_pattern) -- table의 key는 파일 이름, value는 빈 테이블로 하여 반환
   local t = {}
   RETURN_FULL_PATH = RETURN_FULL_PATH or false
   for _, dirs in ipairs(pl.dir.getallfiles(root, shell_pattern)) do
        if(not RETURN_FULL_PATH) then
            local str = pl.stringx.split(dirs, '\\')
            dirs = str[#str]                            -- 파일 이름
        end
        t[dirs] = {}
   end
   return t
end


-------------------------------------
-- function findUsedUIFiles
-- @brief   한 소스 파일에 등장한 .ui 파일들을 전부 찾는다.
-- @param   srcFIlePath : 검사할 src파일
-- @return  테이블(key : .ui 파일 이름, value : 등장 line number)
-------------------------------------
function UnusedUIFileExtractor:findUsedUIFiles(srcFilePath) -- 한 src 파일에서 등장한 UIFile 이름을 key로 하고 line number를 value로 하는 table 반환.
    local t_appeared_line = {}
    local t_src_file_contents = pl.stringx.splitlines(pl.file.read(srcFilePath))

    for i, v in ipairs(t_src_file_contents) do

        if(not (pl.stringx.startswith(v, '--'))) then -- 주석 라인 무시

            local ui_file_name = string.match(v, '\'.*.ui\'')
            if(ui_file_name ~= nil) then -- 이름 찾기 ( 이름들의 포함관계 때문에 이름의 작은따옴표까지 검사
                ui_file_name = string.sub(ui_file_name, 2, -2) -- 검사 후 저장시에는 작은 따옴표 분리
                if(nil == t_appeared_line[ui_file_name]) then
                    t_appeared_line[ui_file_name] = {}
                end
                table.insert(t_appeared_line[ui_file_name], tostring(i))
            end

        end

    end
    if(t_appeared_line == '') then return nil end
    return t_appeared_line
end

-------------------------------------
-- function makeOututFile
-- @brief   사용되지 않는 파일, 사용되는 파일을 xml 파일로 추출한다.
--          사용되는 파일의 경우 어느 소스파일의 몇 번째 줄에서 사용되는지까지
--          실행 파일 경로에 생성
-------------------------------------
function UnusedUIFileExtractor:makeOutputFile()
    pl.utils.writefile('unusedUIFiles.xml', self:makeXMLString())
    print('\n\n\n\n\n' .. lfs.currentdir() .. 'unusedUIFiles.xml' .. '생성 완료')
end


-------------------------------------
-- function makeXMLString
-- @brief   테이블의 데이터들을 xml문법에 맞춰 스트링화한다.
-- @param   unusedFileNameTable     : 사용되지 않는 파일 이름이 적힌 테이블.
--          resFileNameTable        : 사용되는 파일 이름이 적힌 테이블.
-- @return  테이블 데이터들로 만든 xml string
-------------------------------------
function UnusedUIFileExtractor:makeXMLString(unusedFileNameTable, resFileNameTable)
    local xml_lib = require 'pl.xml'
    local d =   xml_lib.new('UI_files')

    unusedFileNameTable = unusedFileNameTable or self.t_unusedFileName
    resFileNameTable = resFileNameTable or self.t_resFileName

    -- xml 형식으로 텍스트를 작성. pl.xml 참고.
    -- https://stevedonovan.github.io/Penlight/api/libraries/pl.xml.html

    do -- 사용되지 않은 파일 (d가 root를 바라봄)
        d:addtag('Un-used')
        for _, v in ipairs(unusedFileNameTable) do
            d:addtag('Name')
            d:text(v)
            d:up()
        end
        d:up()
    end

    do -- 사용된 파일들 (d가 root를 바라봄)
        d:addtag('Used')
        for ui_file_name, v in pairs(resFileNameTable) do
            d:addtag('Name')
            d:text(ui_file_name)

            for src_file_path, line_numbers in pairs(v) do -- v table = {src file relative path, line numbers table}
                d:addtag('Files')
                d:text(src_file_path)

                for _, line_number in pairs(line_numbers) do
                    d:addtag('LineNumber')
                        d:text(line_number)
                    d:up()
                end

                d:up()
            end

            d:up()
        end
        d:up()
    end


    -- pretty-print an XML document
    local idn = ' ' -- an initial indent (indents are all strings)
    local indent = '    ' -- an indent for each level
    local attr_indent = nil -- if given, indent each attribute pair and put on a separate line
    local xml = nil -- force prefacing with default or custom <?xml…>

    return (xml_lib.tostring(d, idn, indent))
end



-------------------------------------
-- function UnusedUIFileExtractor_Sample
-------------------------------------
function UnusedUIFileExtractor_Sample()

    local extractor = UnusedUIFileExtractor()

    -- init 함수의 parameter는 2개이며 optional입니다. 
    -- 지정하지 않는 경우 아래의 parameter가 default로 설정됩니다.
    -- 첫 번째 parameter의 경우 검사할 소스파일이 있는 폴더입니다.
    -- 두 번째 parameter의 경우 검색할 이름이 될 ui파일들이 있는 폴더입니다.
    -- parameter는 상대경로, 절대경로 두가지 다 가능합니다.
    -- 상대경로 : 실행 위치 (현재는 bat 폴더)에서 상대경로

    extractor:init( {'..\\src', '..\\src_tool'} , '..\\res\\')
    
    ccdump(extractor:extractUnusedUIFile())

end
