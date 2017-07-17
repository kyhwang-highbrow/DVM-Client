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
require 'TableGradeInfo'
require 'io'
-------------------------------------
-- function main
-- @brief
-------------------------------------
function main()
    lapp = require 'pl.lapp'
    local args = lapp( [[
    Args
        -n, --_name     (string)         extract
                                        validate
                                      uigenerate
     ]])
    
    if (args['_name'] == 'extract') then
        require 'UnusedFileExtractor'
        
        extractor = UnusedFileExtractor()
        extractor:extractUnusedFile()

    elseif (args['_name'] == 'validate') then
        require 'DataTableValidator'
        validator = DataTableValidator()
        validator:validateData()
    
    elseif (args['_name'] == 'uigenerate') then
        require 'UISourceCodeGenerator'
        generator = UISourceCodeGenerator()
        generator:makeFile()
    end
end

-------------------------------------
-- function __G__TRACKBACK__
-- @brief for CCLuaEngine traceback
-------------------------------------
function __G__TRACKBACK__(msg)
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
-- UTIL
-------------------------------------

-------------------------------------
-- RemoveDirectory
-- @brief 디렉토리 및 하위 파일 전부 삭제
-------------------------------------
function RemoveDirectory(dir)
    for file in lfs.dir(dir) do
        local file_path = dir..'/'..file
        if (file ~= ".") and (file ~= "..") then

            if (lfs.attributes(file_path, 'mode') == 'file') then
                os.remove(file_path)
                print('remove file', file_path)

            elseif (lfs.attributes(file_path, 'mode') == 'directory') then
                RemoveDirectory(file_path)
                lfs.rmdir(file_path)
                print('dir', file_path)

            end
        end
    end

    lfs.rmdir(dir)
    print('remove dir', dir)
end