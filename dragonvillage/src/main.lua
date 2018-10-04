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

-------------------------------------
-- function __G__TRACKBACK__
-- @brief for CCLuaEngine traceback
-------------------------------------
function __G__TRACKBACK__(msg)
	local error_msg = "LUA ERROR: " .. tostring(msg) .. "\n\n" .. debug.traceback()

    cclog("----------------------------------------")
    cclog(error_msg)
    cclog("----------------------------------------")

    if (ErrorTracker:getInstance()) then
        ErrorTracker:getInstance():openErrorPopup(error_msg)
    end

    return msg
end

local GAME_RESTART_TIME = 0
local BACKGROUND_TIME = 0

-------------------------------------
-- function applicationDidEnterBackground
-------------------------------------
function applicationDidEnterBackground()
    cclog('applicationDidEnterBackground')
	LocalPushMgr():applyLocalPush()

    -- 백그라운드에서 30분간 있을 경우 재시작
    GAME_RESTART_TIME = os.time() + 1800
    BACKGROUND_TIME = os.time() + 1

    if (g_accessTimeData) then
        g_accessTimeData:setRecordTime(false)
    end

    if (g_gameScene) then
        g_gameScene:applicationDidEnterBackground()
    end
end

-------------------------------------
-- function applicationWillEnterForeground
-------------------------------------
function applicationWillEnterForeground()
    cclog('applicationWillEnterForeground')
    
    -- IOS 간헐적으로 Foreground 진입시 BGM 재생안될때 있음. resume처리
    if (isIos()) then
        SoundMgr:resumeBGM()
    end
    
    -- 백그라운드에서 일정 시간이 지난 후 들어오면 재시작
    if (0 < GAME_RESTART_TIME) and (GAME_RESTART_TIME < os.time()) then
        -- 2018-04-24 sgkim 절전모드 활성화를 작업하면서 프로그램팀과 논의하여
        --                  일정시간(30분) 동안 앱이 백그라운드로 지난 후 돌아왔을 때 재시작 기능 off
        --                   최신 단말의 메모리양이 늘어서 크게 문제가 되지 않는다고 판단함
        --CppFunctions:restart()
        return
    end

    if (g_accessTimeData) then
        g_accessTimeData:setRecordTime(true)
    end

    if (g_gameScene) then
        -- 1초 이내에 돌아왔을 경우 skip
        if (0 < BACKGROUND_TIME) and (os.time() < BACKGROUND_TIME) then
            g_gameScene:applicationWillEnterForeground()
        end
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
    LocalPushMgr():applyLocalPush()
    
    -- @perpelsdk
    if isAndroid() or isIos() then
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

    local seed = os.time()
    math.randomseed(seed)
	
    require('socket.core')
    require('lib/class')
    require('Stopwatch')
    local stopwatch = Stopwatch()
    stopwatch:start()

    require 'require'
    loadModule()
    stopwatch:record('loadModule()')

    -- @perpelsdk 루아 파일이 require된 후에 동작해야 함
    if isAndroid() or isIos() then
        PerpleSDK:resetLuaBinding()
        StartPerpleSDKScheduler()
        PerpleSDK:setPlatformServerSecretKey(CONSTANT['MD5_KEY'], 'HmacMD5')
    end

    ErrorTracker:getInstance():callDeviceInfo()
    stopwatch:record('ErrorTracker:getInstance()')

    PatchChecker:getInstance()
    stopwatch:record('PatchChecker:getInstance()')

    -- 설정 언어를 가져오기 위해 localData 불러옴
    LocalData:getInstance()
    stopwatch:record('LocalData:getInstance()')

    -- 번역
    Translate:init()
    stopwatch:record('Translate:init()')

    -- 각종 설정 데이터
    local setting_data_instance = SettingData:getInstance()
    setting_data_instance:migration(LocalData:getInstance())
    LobbyGuideData:getInstance()
    LobbyPopupData:getInstance()
    ChatMacroData:getInstance()
    
    stopwatch:stop()
    stopwatch:print()
        
	-- fallback font 설정
	--cc.Label:setDefaultFallbackFontTTF('res/font/common_font_01.ttf', 'res/font/common_font_01_cn.ttc')
    cc.Label:setDefaultFallbackFontTTF('res/font/common_font_01_ja.ttf', 'res/font/common_font_01.ttf')
    cc.Label:setDefaultFallbackFontTTF('res/font/common_font_01_cn.ttc', 'res/font/common_font_01.ttf')
    cc.Label:setDefaultFallbackFontTTF('res/font/common_font_01_th.ttf', 'res/font/common_font_01.ttf')

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
    SettingData:getInstance():clearSettingDataFile()
    LobbyGuideData:getInstance():clearLobbyGuideDataFile()
    LobbyPopupData:getInstance():clearLobbyPopupDataFile()

    -- 채팅 차단
    ChatIgnoreList:clearChatIgnoreListFile()

    -- 시나리오 보기 설정
    ScenarioViewingHistory:clearScenarioViewingHistoryFile()

	-- 신규 룬, 드래곤 로컬 파일 삭제
	g_highlightData:clearNewOidMapFile()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
