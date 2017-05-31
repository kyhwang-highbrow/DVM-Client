-------------------------------------
-- table LuaBridge
-- @breif cocos2d-x�����󿡼��� lua��
--        windows���� ���߿� stand alone lua.exe����
--        ���� �ٸ��� �����ؾ� �ϴ� �Լ����� ����
-------------------------------------
LuaBridge = {}

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