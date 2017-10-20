-------------------------------------
-- LuaUtility
-------------------------------------
util = {}

-------------------------------------
-- function isFile
-- @brief 파일 여부
-------------------------------------
function util.isFile(file_path)
    return (lfs.attributes(file_path, 'mode') == 'file')
end

-------------------------------------
-- function isDirectory
-- @brief 폴더 여부
-------------------------------------
function util.isDirectory(file_path)
    return (lfs.attributes(file_path, 'mode') == 'directory')
end

-------------------------------------
-- function changeDir
-- @brief 커서 위치를 변경한다. 
-------------------------------------
function util.changeDir(dir)
    lfs.chdir(dir)
    cclog('## Current Diretory : ' .. lfs.currentdir())
end

-------------------------------------
-- function changeDirectory
-- @brief 커서 위치를 변경한다. 함수명의 통일을 위해 정의
-------------------------------------
function util.changeDirectory(dir)
    util.changeDir(dir)
end

-------------------------------------
-- function makeDirectory
-- @brief 디렉토리 및 하위 파일 전부 삭제
-------------------------------------
function util.makeDirectory(dir)
    lfs.mkdir(dir)
end

-------------------------------------
-- function iterateDirectory
-- @brief 폴더 내부 파일들을 순회
-------------------------------------
function util.iterateDirectory(root, iter_func)
    for path, dirs, files in pl.dir.walk(root) do
        for idx, file in pairs(files) do
            iter_func(path, file)
        end
    end       
end

-------------------------------------
-- local function _getDirectorySize
-- @brief 디렉토리 사이즈 계산 실 연산부
-------------------------------------
local function _getDirectorySize(dir, t_size)
    for file in lfs.dir(dir) do
        local file_path = dir..'\\'..file
        if (file ~= ".") and (file ~= "..") then
            -- 파일
            if util.isFile(file_path) then
                -- 파일 사이즈 가산
                t_size['size'] = t_size['size'] + lfs.attributes(file_path, 'size')

            -- 디렉토리
            elseif util.isDirectory(file_path) then
                -- 하위 파일을 위한 재귀적 호출
                _getDirectorySize(file_path, t_size)
            end
        end
    end
end

-------------------------------------
-- function getDirectorySize
-- @brief 디렉토리 사이즈를 계산한다.
-------------------------------------
function util.getDirectorySize(dir)
    local t_size = {['size'] = 0}
    _getDirectorySize(dir, t_size)
    return t_size['size']
end

-------------------------------------
-- function removeDirectory
-- @brief 디렉토리 및 하위 파일 전부 삭제
-------------------------------------
function util.removeDirectory(dir, leave_top_dir)
    for file in lfs.dir(dir) do
        local file_path = dir..'\\'..file
        if (file ~= ".") and (file ~= "..") then
            -- 파일
            if util.isFile(file_path) then
                -- 파일 삭제
                os.remove(file_path)

            -- 디렉토리
            elseif util.isDirectory(file_path) then
                -- 하위 파일 삭제를 위한 재귀적 호출
                util.removeDirectory(file_path)

                -- 디렉토리 삭제
                lfs.rmdir(file_path)

            end
        end
    end

    -- 최상위 디렉토리 삭제, 파일이 있다면 삭제가 되지 않는다.
    if (not leave_top_dir) then
        lfs.rmdir(dir)
    end
end

-------------------------------------
-- function moveDirectory
-- @brief 디렉토리 및 하위 파일 이동
-------------------------------------
function util.moveDirectory(src_dir, tar_dir)
    -- robocopy 원본경로 대상경로 [파일 ...] [옵션]
    
    -- /MOVE : 파일 및 디렉토리 이동. 복사한 후 원본 삭제
    -- /E : 하위 디렉토리 포함 복사
    
    -- /NFL : No File List - don't log file names.
    -- /NDL : No Directory List - don't log directory names.
    -- /NJH : No Job Header.
    -- /NJS : No Job Summary.
    -- /XD dirs : 지정된 이름/경로와 일치하는 디렉토리 제외 
    
    os.execute(string.format('robocopy "%s" "%s" /MOVE /E /NFL /NDL /NJH /NJS /XD .svn', src_dir, tar_dir))
end

-------------------------------------
-- function mirrorDirectory
-- @brief 디렉토리간 비교, 한쪽으로 완전히 동기화 시킴 (있으면 복사, 없으면 삭제)
-------------------------------------
function util.mirrorDirectory(src_dir, tar_dir)
    -- robocopy 원본경로 대상경로 [파일 ...] [옵션]
   
    -- /MIR : mirroring
   
    -- /NFL : No File List - don't log file names.
    -- /NDL : No Directory List - don't log directory names.
    -- /NJH : No Job Header.
    -- /NJS : No Job Summary.
    -- /XD dirs : 지정된 이름/경로와 일치하는 디렉토리 제외 
   
    os.execute(string.format('robocopy "%s" "%s" /MIR /NFL /NDL /NJH /NJS /XD .svn', src_dir, tar_dir))
end

-------------------------------------
-- function encodeString
-- @brief lua테이블로 표현가능한 수준으로 치환
-------------------------------------
function util.encodeString(s)
    s = string.gsub(s,'\n','\\n') -- 시트상의 alt + enter를 \n으로 변환해준다.
    s = string.gsub(s,'\t','\\t')
    s = string.gsub(s,'"','\\"')
    s = string.gsub(s,"'","\\'")
    return s 
end

-------------------------------------
-- function makeUsable
-------------------------------------
function util.makeUsable(id)
    id = id:gsub('\\n', '\n')
    id = id:gsub('\\t', '\t')
    id = id:gsub("\'", "'")
    id = id:gsub('\"', '"')
    return id
end

-------------------------------------
-- function makeLuaTableStr
-- @param delimiter : 인자간 구분자
-------------------------------------
function util.makeLuaTableStr(value, delimiter)
    local t = type(value)
    if (t == 'table') then
        local delimiter = delimiter or ''
        local s = '{'

        -- 테이블 순회
        local _key, _value
        for k, v in pairs(value) do
            _value = util.makeLuaTableStr(v)

            if (type(k) == 'number') then
                s = s .. delimiter .. "[" .. k .. "]=" .. _value .. ';'
            else
                _key = util.encodeString(k)--:gsub("'","\\'")   
                s = s .. delimiter .. "['" .. _key .. "']=" .. _value .. ';'
            end
        end

        return s .. delimiter .. '}'

    elseif (t == 'string') then
        value = util.encodeString(value)
        return "'" .. value .. "'"

    else
        return tostring(value)

    end
end

-------------------------------------
-- function makeCSVStr
-- @param l_data : data 리스트, 각 요소는 table 형태여야 한다.
-- @param l_header : header 리스트, 여기에 존재하는 필드만 추출된다.
-------------------------------------
function util.makeDSVStringFromLuaTable(l_data, l_header, sep)
    local l_str = {}
    local sep = sep or ','

    -- header 삽입
    local header_str = ''
    for i, header in ipairs(l_header) do
        header_str = string.format('%s%s%s', header_str, header, sep)
    end
    table.insert(l_str, header_str)

    -- 데이터 삽입
    for i, t in ipairs(l_data) do
        local row = ''
        local temp
        for i, header in ipairs(l_header) do
            temp = t[header] or ''
            temp = util.encodeString(temp)
            row = string.format('%s%s%s', row, temp, sep)
        end
        table.insert(l_str, row)
    end

    -- 하나의 문자열로 합칩
    local csv_str = ''
    for _, str in ipairs(l_str) do
        csv_str = string.format('%s%s\n', csv_str, str)
    end

    return csv_str
end