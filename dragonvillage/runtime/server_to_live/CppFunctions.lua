-------------------------------------
-- class CppFunctionsClass
-- C++ function(AppDelegate_Custom.cpp에 구현되어 있음)
-------------------------------------
CppFunctionsClass = class({
    })

-------------------------------------
-- function init
-------------------------------------
function CppFunctionsClass:init()
end

-------------------------------------
-- function restart
-------------------------------------
function CppFunctionsClass:restart()
    return restart()
end

-------------------------------------
-- function finishPatch
-------------------------------------
function CppFunctionsClass:finishPatch()
    return finishPatch()
end

-------------------------------------
-- function isWin32
-------------------------------------
function CppFunctionsClass:isWin32()
    return isWin32()
end

-------------------------------------
-- function isMac
-------------------------------------
function CppFunctionsClass:isMac()
    return isMac()
end

-------------------------------------
-- function isAndroid
-------------------------------------
function CppFunctionsClass:isAndroid()
    return isAndroid()
end

-------------------------------------
-- function isIos
-------------------------------------
function CppFunctionsClass:isIos()
    return isIos()
end

-------------------------------------
-- function isTestMode
-------------------------------------
function CppFunctionsClass:isTestMode()
    return isTestMode()
end

-------------------------------------
-- function getAppVer
-------------------------------------
function CppFunctionsClass:getAppVer()
    return getAppVer()
end

-------------------------------------
-- function getTargetServer
-- @return string 'DEV', 'QA', 'LIVE'
-------------------------------------
function CppFunctionsClass:getTargetServer()
	-- if (LIVE_SERVER_TARGET) then
	-- 	return LIVE_SERVER_TARGET
	-- end

    -- return getTargetServer()
    return 'LIVE'
end

-------------------------------------
-- function useObb
-- @return bool true : APK Expansion 파일 다운로드 사용
--              false : APK Expansion 파일 다운로드 사용하지 않음
-------------------------------------
function CppFunctionsClass:useObb()
    return useObb()
end

-------------------------------------
-- function getMd5
-- @param string file path
-- @return string md5
-------------------------------------
function CppFunctionsClass:getMd5(path)
    return getMd5(path)
end

-------------------------------------
-- function getDeviceLanguage
-- @return string
-------------------------------------
function CppFunctionsClass:getDeviceLanguage()
    return getDeviceLanguage()
end

-------------------------------------
-- function getLocale
-- @return string
-------------------------------------
function CppFunctionsClass:getLocale()
    return getLocale()
end

-------------------------------------
-- function openUrl
-- @param string
-------------------------------------
function CppFunctionsClass:openUrl(url)
    openUrl(url)
end

-------------------------------------
-- function isCafeBazaarBuild
-- @brief Cafe Bazaar빌드 전용인지 여부
--        이란(중동) 마켓 android만 출시
-- @return boolean
-------------------------------------
function CppFunctionsClass:isCafeBazaarBuild()
    if (not isCafeBazaarBuild) then
        return false
    end

    local ret_bool = isCafeBazaarBuild()
    return ret_bool
end

-- instance 생성
CppFunctions = CppFunctionsClass()