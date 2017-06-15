-- penlight 라이브러리 로드
pl = require 'pl.import_into'()

-- ../srs경로를 package.path에 추가
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
    TABLE:init()
    
   
    lapp = require 'pl.lapp'
    local args = lapp( [[
    Args
        -n, --_name     (string)         extract
                                        validate
                                      uigenerate
    ]] )

    
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

