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
require 'io'
require 'socket.core'
require 'StopWatch'

require 'Table'
require 'TableClass'

require 'LuaGlobal'
require 'LuaUtility'

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