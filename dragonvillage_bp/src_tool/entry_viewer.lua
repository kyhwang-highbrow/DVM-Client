-- luajit 기능 비활성화. luajit을 off하는게 퍼포먼스가 향상됨. (기본 설정 ios는 off, android는 on)
if (jit ~= nil) then
	jit.off()
end

print('################################################################')
print('[Lua Start!!!]')
print('################################################################')

require 'require'
loadModule()
require 'src_tool/SceneViewer'

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
-- function main
-------------------------------------
local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    cc.Director:getInstance():setDisplayStats(true)

    local seed = os.time()
    math.randomseed(seed)

    --[[
    TABLE:init()

    local logoScene = SceneLogo()
	logoScene:setFinishCB(function()
            local scene = SceneLobby()
            --local scene = SceneGame()
	        scene:runScene()
        end)
	logoScene:runScene()
    --]]

    ShaderCache:init()

    local scene = SceneViewer()
    scene:runScene()
    
    cclog('START!!! ##')
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
