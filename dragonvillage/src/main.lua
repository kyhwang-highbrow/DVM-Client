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
-- function isTestMode
-------------------------------------
function isTestMode()
    -- 라이브 전에는 명시해야함
    return (not DEVELOPMENT_SRC_VER)
end

-------------------------------------
-- @perplesdk
-------------------------------------
gPerpleSDKSchedulerID = 0

-- Call this function in entry point (ex. main())
function StartPerpleSDKScheduler()
    gPerpleSDKSchedulerID = scheduler.scheduleUpdateGlobal(function()
        PerpleSDK:updateLuaCallbacks()
    end)
end

-- Call this function in closing application
function EndPerpleSDKScheduler()
    scheduler.unscheduleGlobal(gPerpleSDKSchedulerID)
    gPerpleSDKSchedulerID = 0
end


UI_ErrorPopup = nil
IS_OPEN_ERROR_POPUP = false
-------------------------------------
-- function __G__TRACKBACK__
-- @brief for CCLuaEngine traceback
-------------------------------------
function __G__TRACKBACK__(msg)
	local error_msg = "LUA ERROR: " .. tostring(msg) .. "\n\n" .. debug.traceback()

    cclog("----------------------------------------")
    cclog(error_msg)
    cclog("----------------------------------------")
    	
	-- 에러를 팝업으로 띄워서 출력
	-- @TODO 디버깅 모드일 경우에만 출력되도록 수정해야함
	if (not IS_OPEN_ERROR_POPUP) and UI_ErrorPopup then
		UI_ErrorPopup(error_msg)
		IS_OPEN_ERROR_POPUP = true
	end

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
-- function closeApplication
-------------------------------------
function closeApplication()
	cclog('CloseApplication')
    --LocalPushMgr()
    
    -- @perpelsdk
    if isAndroid() then
        EndPerpleSDKScheduler()
    end

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
    cc.Director:getInstance():setAnimationInterval(1 / 50)
    
    -- 절전모드 설정(동작하지 않도록)
    cc.Director:getInstance():setIdleTimerDisabled(true)

    -- @perpelsdk
    if isAndroid() then
        StartPerpleSDKScheduler()
    end

    local seed = os.time()
    math.randomseed(seed)
	
    TABLE:init()
	ConstantData:getInstance()
    SoundMgr:entry()
    ShaderCache:init()
    TimeLib:initInstance()
    LocalData:getInstance()
    ChatIgnoreList:getInstance()
    ScenarioViewingHistory:getInstance()
    ServerData:getInstance():applySetting()
    UserData:getInstance()
	ErrorTracker:getInstance()

    if DV_SCENE_ACTIVE then
        SceneDV():runScene()
    else
        local scene = SceneTitle()
        scene:runScene()
    end

    -- 프리로드 파일 생성시
    --savePreloadFile()
end

-------------------------------------
-- function removeLocalFiles
-------------------------------------
function removeLocalFiles()
    LocalData:getInstance():clearLocalDataFile()
    ServerData:getInstance():clearServerDataFile()
    UserData:getInstance():clearServerDataFile()

    -- 채팅 차단
    ChatIgnoreList:clearChatIgnoreListFile()

    -- 시나리오 보기 설정
    ScenarioViewingHistory:clearScenarioViewingHistoryFile()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
