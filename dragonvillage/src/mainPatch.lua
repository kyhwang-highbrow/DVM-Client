-- luajit 기능 비활성화. luajit을 off하는게 퍼포먼스가 향상됨. (기본 설정 ios는 off, android는 on)
if (jit ~= nil) then
    jit.off()
end

print('################################################################')
print('[Lua Start!!!]')
print('################################################################')

-------------------------------------
-- function cclog
-------------------------------------
cclog = function(...)
    print(...)
end

-------------------------------------
-- function applicationDidEnterBackground
-------------------------------------
function applicationDidEnterBackground()
    cclog('applicationDidEnterBackground')

    if (g_accessTimeData) then
        g_accessTimeData:setRecordTime(false)
    end
end

-------------------------------------
-- function applicationWillEnterForeground
-------------------------------------
function applicationWillEnterForeground()
    cclog('applicationWillEnterForeground')

    if (g_accessTimeData) then
        g_accessTimeData:setRecordTime(true)
    end
end

-------------------------------------
-- function applicationDidChangeViewSize
-------------------------------------
function applicationDidChangeViewSize()
    cclog('applicationDidChangeViewSize')
    UIManager:invalidateUI()

    if g_currScene then
        g_currScene:sceneDidChangeViewSize()
    end
end

-------------------------------------
-- function __G__TRACKBACK__
-- @brief for CCLuaEngine traceback
-------------------------------------
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

-------------------------------------
-- function closeApplication
-------------------------------------
function closeApplication()
	cclog('CloseApplication')
	cc.Director:getInstance():endToLua()
end

-------------------------------------
-- function main
-------------------------------------
local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    cc.Director:getInstance():setDisplayStats(false)

    -- 절전모드 설정(동작하지 않도록)
    cc.Director:getInstance():setIdleTimerDisabled(true)

    local seed = os.time()
    math.randomseed(seed)

	-- 최소로 필요한 루아 모듈
	require 'require'
	require 'lib/class'
	require 'lib/utils'
	require 'perpleLib/dkjson'
	require 'perpleLib/PerpleScene'
	require 'socket.core'
	require 'XorCipher'
	require 'PatchChecker'
	require 'LocalData'
    require 'StructLanguage'
	require 'lib/Translate'
	require 'Global'
	require 'ErrorTracker'
	require 'CppFunctions'
	require 'Analytics'
	require 'SceneLogo'
	require 'ScenePatch'
	require 'Stopwatch'
	pl = require 'pl.import_into'()

	local stop_watch = Stopwatch()
	stop_watch:start()
	stop_watch:record('patch : start')

	-- 에러 안나도록..
	ErrorTracker:getInstance()
	stop_watch:record('ErrorTracker:getInstance()')
    PatchChecker:getInstance()
	stop_watch:record('PatchChecker:getInstance()')

    -- 설정 언어를 가져오기 위해 localData 불러옴
    LocalData:getInstance()
	stop_watch:record('LocalData:getInstance()')

	-- 일단 화면 띄우고 프리징 되도록 콜백으로 사용
	local function start_cb()
		-- lua module load
		loadModuleForPatchScene()

		-- 번역
		Translate:init()
		stop_watch:record('Translate:init()')
	
		-- @analytics
		Analytics:firstTimeExperience('StartApp')
	
		-- 대체 폰트 설정
		Translate:setDefaultFallbackFont()
		stop_watch:record('patch : load module')
	end
	-- 로고 후 패치 시작
	local function finish_cb()
		local scene = ScenePatch()
		scene:runScene()
		stop_watch:record('patch : end')
		stop_watch:stop()
		stop_watch:print()
	end

	-- 로고 띄움
	local scene = SceneLogo()
	scene:setStartCB(start_cb)
	scene:setFinishCB(finish_cb)
	scene:runScene()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
