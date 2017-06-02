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
require 'dataTableValidator'

-------------------------------------
-- function main
-- @brief
-------------------------------------
function main()
    TABLE:init()

    initGlobalVar()

    validateData()
    
    if( g_numOfInvalidData > 0 ) then
        ccdump(sendInvalidTableListBySlack())
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
