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

__G__ERROR_POPUP = nil
IS_OPEN_ERROR_POPUP = false
-------------------------------------
-- function __G__TRACKBACK__
-- @brief for CCLuaEngine traceback
-------------------------------------
function __G__TRACKBACK__(msg)
	local error_msg = "LUA ERROR: " .. tostring(msg) .. "\n\n" .. debug.traceback()
	
	-- 에러를 팝업으로 띄워서 출력
	-- @TODO 디버깅 모드 처리해야함
	if (not IS_OPEN_ERROR_POPUP) and __G__ERROR_POPUP then
		__G__ERROR_POPUP(error_msg)
		IS_OPEN_ERROR_POPUP = true
	end

    cclog("----------------------------------------")
    cclog(error_msg)
    cclog("----------------------------------------")
    return msg
end

require 'require'
loadModule()

-------------------------------------
-- function applicationDidEnterBackground
-------------------------------------
function applicationDidEnterBackground()
    cclog('applicationDidEnterBackground')
	--LocalPushMgr()
end

-------------------------------------
-- function applicationWillEnterForeground
-------------------------------------
function applicationWillEnterForeground()
    cclog('applicationWillEnterForeground')
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
-- function closeApplication
-------------------------------------
function closeApplication()
	cclog('CloseApplication')
    --LocalPushMgr()
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

    TABLE:init()
    SoundMgr:entry()
    ShaderCache:init()
    TimeLib:initInstance()
    LocalData:getInstance()
    ServerData:getInstance():applySetting()
    ServerData:getInstance():developCache()
    UserData:getInstance()
	ConstantData:getInstance()

    if DV_SCENE_ACTIVE then
        SceneDV():runScene()
    else
        local scene = SceneTitle()
        scene:runScene()
    end

    -- 프리로드 파일 생성시
    --savePreloadFile()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
