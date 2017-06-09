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
require 'UnusedFileExtractor'
require 'os'
-------------------------------------
-- function main
-- @brief
-------------------------------------
function main()
    TABLE:init()
    --extractor = UnusedFileExtractor()
    --extractor:init()
    local path = lfs.currentdir()
    local t = {}
    local pfile = pl.dir.getallfiles('D:\\dragonvillage\\src\\frameworks\\dragonvillage\\src')

    for _, dir in ipairs(pfile) do
        table.insert(t, dir)  
    end
    
    print(#t)
    for i = 1, #t do
        os.execute('C:\\Users\\MS\\Downloads\\LuaSrcDiet-win32-bin-0.9.1\\LuaSrcDiet-win32-bin-0.9.1\\LuaSrcDiet.exe '.. t[i])
        print(i)
    end



    --extractor:extractUnusedFile('.ui', '.lua')

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

