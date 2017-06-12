require 'perpleLib/StringUtils'
-------------------------------------
-- class UnusedFileExtractor
-------------------------------------
UnusedFileExtractor = class({
    
    m_target_ext = 'string',
    m_src_ext = 'string',
    m_tResRoot = 'table',
    m_tSrcRoot = 'table',
    

    t_resFileName = 'table',     -- key = 타겟 파일 이름, value = 테이블(key = src 파일 이름, value = line)
    t_srcFileName = 'table',     -- key = src 파일 이름, value = 테이블(key = 타겟 파일 이름, value = 출현 line)

    t_unusedFileName = 'table',
    t_usedFileName = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UnusedFileExtractor:init()
    self.m_tSrcRoot = {}
    self.m_tResRoot = {}
    self.t_resFileName = {}
    self.t_srcFileName = {}
    self.t_unusedFileName = {}
    self.t_usedFileName = {}
    self.m_target_ext = ''
    self.m_src_ext = ''
end


-------------------------------------
-- function getRelPath
-- @param   t       - key : number, value : 절대경로
-- @return  _table  - key : number, value : 상대경로(root : dragonvillage 폴더) 
-------------------------------------
function UnusedFileExtractor:getRelPath(t)
    local _table = {}
    for _, v in ipairs(t) do
        table.insert(_table, pl.path.relpath(v, lfs.currentdir() .. '..\\'))
    end
    return _table
    
end

-------------------------------------
-- function extractUnusedFile
-- @brief 쓰이지 않는 파일을 찾아낸다.
-- @return 쓰이지 않는 파일들의 이름이 담겨있는 table
-------------------------------------
function UnusedFileExtractor:extractUnusedFile() 
    self.m_tResRoot, self.m_tSrcRoot, self.m_target_ext, self.m_src_ext = self:getUserInput()

    self.m_tResRoot = self:getRelPath(self.m_tResRoot)
    self.m_tSrcRoot = self:getRelPath(self.m_tSrcRoot)

    self:initializeTables(self.m_target_ext, self.m_src_ext)
    
    print ('\'' .. self.m_src_ext .. '\'' ..' 에서 사용되지 않는 ' .. '\'' .. self.m_target_ext .. '\'' .. ' 을 추출합니다.\n')
    print('\'' .. self.m_target_ext .. '\'' .. ' 찾는 중.. \n')

    -- 1. 전체 소스파일에서 모든 target파일을 검색하여 테이블에 저장.
    for k, _ in pairs(self.t_srcFileName) do
        
        self.t_srcFileName[k] = self:findUsedFiles(k, self.m_target_ext)
    end
    print('\'' .. self.m_src_ext .. '\'' .. ' 검사 중.. \n')

    -- 2. 전체 res파일의 이름을 1.에서 만든 테이블 안에서 검색/분류한다.
    for file_name in pairs(self.t_resFileName) do

         -- 파일 이름만 추출
        local name_with_no_path = pl.stringx.split(file_name, '\\')
        name_with_no_path = name_with_no_path[#name_with_no_path]     

        -- 타겟 파일이 한 곳에라도 쓰이면 set.
        local flag = false               
        -- 소스파일 테이블(key = target 파일 이름, value = 등장 line)에서
        for src_file_name, v in pairs(self.t_srcFileName) do    
            -- 소스파일 테이블의 value테이블 안에서  
            for file_name_in_table, _ in pairs(v) do
                -- 타겟 파일 이름이 실제로 사용되는 것이라면


                if(name_with_no_path == file_name_in_table) then      
                    self.t_usedFileName[file_name] = {}
                    -- 타겟 파일 테이블의 value가 nil이면
                    if(nil == self.t_usedFileName[file_name][src_file_name]) then      
                                          
                        -- 초기화 
                        self.t_usedFileName[file_name][src_file_name] = {}                               
                    end
                    for i = 1, #v[name_with_no_path] do 

                        -- 타겟 파일 테이블의 value테이블에 몇번째 라인에서 쓰이는지 추가.
                        table.insert(self.t_usedFileName[file_name][src_file_name], v[name_with_no_path][i])
                    end

                    -- 쓰이니까 flag set
                    flag = true                                                 
                end 
            end
        end

        -- 해당 타겟 파일이 쓰이지 않은 경우.
        if(not flag) then                                                           
            table.insert(self.t_unusedFileName, file_name)
        end
    end

    
    self:makeOutputFile(self.m_target_ext)
    return self.t_unusedFileName
end


-------------------------------------
-- function initializeTables
-- @brief res파일 테이블과 src파일 테이블의 값(file path)을 설정한다.
-------------------------------------
function UnusedFileExtractor:initializeTables(target_files_ext, src_files_ext)
    target_files_ext = '*' .. target_files_ext
    src_files_ext = '*' .. src_files_ext
    local t_res_files = self:getAllFilePathByKey(self.m_tResRoot, true, target_files_ext)
    self.t_resFileName = t_res_files

    local t_src_files = self:getAllFilePathByKey(self.m_tSrcRoot, true, src_files_ext)
    self.t_srcFileName = t_src_files
end

-------------------------------------
-- function getAllFilePathByKey
-- @brief   경로 아래에 있는 모든 파일의 경로를 반환
-- @param   root : 기준이 될 경로(상대, 절대 둘 다 가능)
--          RETURN_FULL_PATH : optional(default false), 상대경로로써 반환할것인지, 이름만 반환할것인지. 
--          shell_pattern : optional(반환할 파일 패턴(확장자))
-- @return  파일 경로를 가진 테이블(key : 파일 경로, value : 빈 테이블)
-------------------------------------
function UnusedFileExtractor:getAllFilePathByKey(roots, CONTAIN_PATH, shell_pattern)
    local t = {}
    CONTAIN_PATH = CONTAIN_PATH or false
    for i = 1, #roots do
        for _, dirs in ipairs(pl.dir.getallfiles(roots[i], shell_pattern)) do
            if(not CONTAIN_PATH) then
                local str = pl.stringx.split(dirs, '\\')

                -- 파일 이름만 추출
                dirs = str[#str]                            
            end
            t[dirs] = {}
        end
    end

    return t
   
end


-------------------------------------
-- function findUsedFiles
-- @brief   한 소스 파일에 등장한 타겟 파일들을 전부 찾는다.
-- @param   src_file_path       : 검사할 src파일
--          target_ext          : 찾을 파일의 extension 형식.
--          is_contain_comment  : 주석도 포함해서 검사할건지.. lua만 지원 예정. 미구현.
-- @return  테이블(key : 타겟 파일 이름, value : 등장 line number)
-------------------------------------
function UnusedFileExtractor:findUsedFiles(src_file_path, target_ext, is_contain_comment)
    local t_appeared_line = {}
    local all_contents = pl.file.read(src_file_path)
    local t_src_file_contents = pl.stringx.splitlines(all_contents)
    local string_to_match = '.*' .. target_ext
    local is_comment = nil
    for i, v in ipairs(t_src_file_contents) do
        local strip_line = pl.stringx.lstrip(v)
        --주석 제거는 구현하려면 LuaSrcDiet library 참고
        self:inspectTargetString(strip_line, string_to_match, i, t_appeared_line)
    end
    if(t_appeared_line == '') then return nil end
    return t_appeared_line
end


-------------------------------------
-- function inspectTargetString
-- @brief   소스파일의 한 line에 특정 string이 있는지 검사하여, 있으면 t_appeared_line에 insert.
-- @param   target_string            : 검사할 src line
--          string_to_match          : 찾을 string
--          line_number             
--          t_appeared_line          : 포함 정보를 가진 테이블.
-------------------------------------
function UnusedFileExtractor:inspectTargetString(target_string, string_to_match, line_number, t_appeared_line)
    -- 이름 찾기 ( 이름들의 포함관계 때문에 이름의 작은따옴표까지 검사
    string_to_match = '\'' .. string_to_match .. '\'' 
    local target_file_name = string.match(target_string, string_to_match)

    if(target_file_name ~= nil) then          
        -- 검사 후 저장시에는 작은 따옴표 분리
        target_file_name = string.sub(target_file_name, 2, -2)
        local str = pl.stringx.split(target_file_name, '/')
        target_file_name = str[#str]
        if(nil == t_appeared_line[target_file_name]) then
            t_appeared_line[target_file_name] = {}
        end
        table.insert(t_appeared_line[target_file_name], tostring(line_number))
    end
end



-------------------------------------
-- function makeOututFile
-- @brief   사용되지 않는 파일, 사용되는 파일을 xml 파일로 추출한다.
--          사용되는 파일의 경우 어느 소스파일의 몇 번째 줄에서 사용되는지까지
--          실행 파일 경로에 생성
-------------------------------------
function UnusedFileExtractor:makeOutputFile(target_ext)
    pl.utils.writefile('output//unused' .. target_ext .. 'Files.xml', self:makeXMLString())
    print('\n "' .. lfs.currentdir() .. '\\unused' .. target_ext .. 'Files.xml"' .. ' 생성 완료\n\n\n\n')
end


-------------------------------------
-- function makeXMLString
-- @brief   테이블의 데이터들을 xml문법에 맞춰 스트링화한다.
-- @param   unusedFileNameTable     : 사용되지 않는 파일 이름이 적힌 테이블.
--          resFileNameTable        : 사용되는 파일 이름이 적힌 테이블.
-- @return  테이블 데이터들로 만든 xml string
-------------------------------------
function UnusedFileExtractor:makeXMLString(unusedFileNameTable, resFileNameTable)
    local xml_lib = require 'pl.xml'
    local d =   xml_lib.new('Files')

    unusedFileNameTable = unusedFileNameTable or self.t_unusedFileName
    resFileNameTable = resFileNameTable or self.t_usedFileName
    table.sort(unusedFileNameTable)
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
        ccdump(resFileNameTable)
        for file_name, v in pairsByKeys(resFileNameTable) do
        -- v = table : {src file relative path, line numbers table}
            d:addtag('Name')
            d:text(file_name)

           
            for src_file_path, line_numbers in pairs(v) do 
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
    local idn = ' '         -- an initial indent (indents are all strings)
    local indent = '    '   -- an indent for each level
    local attr_indent = nil -- if given, indent each attribute pair and put on a separate line
    local xml = nil         -- force prefacing with default or custom <?xml…>

    return (xml_lib.tostring(d, idn, indent))
end



-------------------------------------
-- function UnusedFileExtractor_Sample
-------------------------------------
function UnusedFileExtractor_Sample()

    local extractor = UnusedFileExtractor()

    -- init 함수의 parameter는 2개이며 optional입니다. 
    -- 지정하지 않는 경우 아래의 parameter가 default로 설정됩니다.
    -- 첫 번째 parameter의 경우 검사할 소스파일이 있는 폴더입니다.
    -- 두 번째 parameter의 경우 검색할 이름이 될 타겟 파일들이 있는 폴더입니다.
    -- parameter는 상대경로, 절대경로 두가지 다 가능합니다.
    -- 상대경로 : 실행 위치 (현재는 bat 폴더)에서 상대경로

    extractor:init( {'..\\src', '..\\src_tool'} , '..\\res\\')
    
    ccdump(extractor:extractUnusedFile())

end

-------------------------------------
-- function pairsByKeys
-- @brief   key로써 table을 순회하는 iterator를 반환
-- @param   t       : table
--          f       : An optional parameter f allows the specification of an alternative order.
-- @return iter     : iterator
-------------------------------------
function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end -- key를 가진 배열
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else 
            return a[i], t[a[i]] -- key, value
        end
    end
    return iter
end

    
-------------------------------------
-- function getUserInput
-- @brief   user가 제어할 수 있는 input을 command line을 통해 받는다.
-- @return  t_res_root  : resource의 root
--          t_src_root  : src의 root
--          res_ext     : res의 확장자
--          src_ext     : ext의 확장자 
-------------------------------------
function UnusedFileExtractor:getUserInput()
    local t_res_root = {}
    local t_src_root = {}
    local flag = true
    repeat 
        print('res root directory : ')
        io.flush()
        table.insert(t_res_root, io.read())
        io.flush()
        print('insert more directory?(y/other) : ')
        if('y' ~= io.read()) then
            flag = false
        end
    until flag ~= true

        
    flag = true
    repeat 
        print('src root directory : ')
        io.flush()
        table.insert(t_src_root, io.read())
        io.flush()
        print('insert more directory?(y/other) : ')
        if('y' ~= io.read()) then
            flag = false
        end
    until flag ~= true

    print('res file extension : ')
    io.flush()
    local res_ext = io.read()

    print('src file extension : ')
    io.flush()
    local src_ext = io.read()

    return t_res_root, t_src_root, res_ext, src_ext

end