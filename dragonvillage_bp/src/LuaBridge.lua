-------------------------------------
-- table LuaBridge
-- @breif cocos2d-x엔진상에서의 lua와
--        windows에서 개발용 stand alone lua.exe에서
--        각기 다르게 동작해야 하는 함수들을 정의
-------------------------------------
LuaBridge = {}

cc.FileUtils:getInstance():setPopupNotify(false)

-------------------------------------
-- function isFileExist
-------------------------------------
function LuaBridge:isFileExist(path)
    return cc.FileUtils:getInstance():isFileExist(path)
end

-------------------------------------
-- function fullPathForFilename
-------------------------------------
function LuaBridge:fullPathForFilename(path)
    return cc.FileUtils:getInstance():fullPathForFilename(path)
end

-------------------------------------
-- function getStringFromFile
-------------------------------------
function LuaBridge:getStringFromFile(path)
    return cc.FileUtils:getInstance():getStringFromFile(path)
end