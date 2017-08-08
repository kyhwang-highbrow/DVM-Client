-- penlight 라이브러리 로드
pl = require 'pl.import_into'()

-- ../src경로를 package.path에 추가
pl.app.require_here('../res')
pl.app.require_here('../src')
pl.app.require_here('..')
pl.app.require_here()

csv = require 'perpleLib/lua_csv'
require 'LuaBridgeWindows'
require 'lib/class'
require 'perpleLib/StringUtils'
require 'Table'
require 'TableClass'
require 'io'
require 'socket.core'
require 'StopWatch'

-------------------------------------
-- function main
-- @brief
-------------------------------------
function main()
end

-------------------------------------
-- function __G__TRACKBACK__
-- @brief for CCLuaEngine traceback
-------------------------------------
function __G__TRACKBACK__(msg)
    io.flush()
    io.write('\n')
	local error_msg = "LUA ERROR: " .. tostring(msg) .. "\n\n" .. debug.traceback()

    cclog("----------------------------------------")
    cclog(error_msg)
    cclog("----------------------------------------")


    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end


-------------------------------------
-- Utility
-------------------------------------

-------------------------------------
-- RemoveDirectory
-- @brief 디렉토리 및 하위 파일 전부 삭제
-------------------------------------
function RemoveDirectory(dir)
    for file in lfs.dir(dir) do
        local file_path = dir..'\\'..file
        if (file ~= ".") and (file ~= "..") then
            -- 파일
            if (lfs.attributes(file_path, 'mode') == 'file') then
                -- 파일 삭제
                os.remove(file_path)

            -- 디렉토리
            elseif (lfs.attributes(file_path, 'mode') == 'directory') then
                -- 하위 파일 삭제를 위한 재귀적 호출
                RemoveDirectory(file_path)

                -- 디렉토리 삭제
                lfs.rmdir(file_path)

            end
        end
    end

    -- 최상위 디렉토리 삭제, 파일이 있다면 삭제가 되지 않는다.
    lfs.rmdir(dir)
    print('remove dir', dir)
end

-------------------------------------
-- MirrorDirectory
-- @brief 디렉토리간 비교, 한쪽으로 완전히 동기화 시킴 (있으면 복사, 없으면 삭제)
-------------------------------------
function MirrorDirectory(src_dir, tar_dir)
    
    -- robocopy 원본경로 대상경로 [파일 ...] [옵션]

    -- /E : 하위 디렉토리 포함 복사
    -- /MIR : mirroring
    -- /NFL : No File List - don't log file names.
    -- /NDL : No Directory List - don't log directory names.

    os.execute(string.format('robocopy "%s" "%s" /MIR /NFL /NDL', src_dir, tar_dir))
end