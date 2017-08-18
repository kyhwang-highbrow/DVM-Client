require 'TableLoadingGuide'
require 'TableDragon'

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
-- function makeDirectory
-- @brief 디렉토리 및 하위 파일 전부 삭제
-------------------------------------
function util.makeDirectory(dir)
    lfs.mkdir(dir)
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
-- function makeGuideDragonTable
-- @brief 패치 시 필요한 드래곤 리소스 추출
-------------------------------------
function util.makeGuideDragonTable()
    cclog('## makeGuideDragonTable')
    local l_loading_dragon = {}
    
    -- loading table에서 필요한 드래곤 id 가져온다.
    local table_loading = TableLoadingGuide()
    for i, t_loading in pairs(table_loading.m_orgTable) do
        if (t_loading['did'] ~= '') then
            table.insert(l_loading_dragon, t_loading['did'])
        end
    end

    -- 해당 리소스 네임 추출하여 저장
    local t_res = {}
    local table_dragon = TableDragon()
    local t_dragon, res, dragon_name, attr, evolution, complete_res
    for i, did in pairs(l_loading_dragon) do
        t_dragon = table_dragon:get(did)
        dragon_name = t_dragon['type']
        attr = t_dragon['attr']
        evolution = 3

        res = string.format('%s_%s_%02d', dragon_name, attr, evolution)
        t_res[res] = true
    end

    return t_res
end