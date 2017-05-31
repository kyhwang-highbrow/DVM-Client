-- penlight 라이브러리 로드
if (not pl) then
    pl = require 'pl.import_into'()
end

-------------------------------------
-- function cclog
-------------------------------------
function cclog(...)
    return print(...)
end

-------------------------------------
-- function luadump
-------------------------------------
function luadump(value, depth)
    local t = type(value)
    if t == 'table' then
        depth = depth or ''
        local newdepth = depth .. '\t'

        local s = '{\n'
        local n = #value
        for i = 1, n do
            s = s .. newdepth .. luadump(value[i], newdepth) .. ';\n'
        end
        for k, v in pairs(value) do
            if type(k) ~= 'number' or k <= 0 or k > n then
                s = s .. newdepth .. "['" .. k .. "']=" .. luadump(value[k], newdepth) .. ';\n'
            end
        end
        return s .. depth .. '}'

    elseif t == 'string' then
        return "'" .. value .. "'"
    else
        return tostring(value)
    end
end

-------------------------------------
-- function ccdump
-------------------------------------
function ccdump(value)
    local dump = luadump(value)
	print('==================DUMP=====================')
	print(dump)
	print('-------------------------------------------')
end

-------------------------------------
-- function isWin32
-------------------------------------
function isWin32()
    local platform = pl.app.platform()
    return (platform == 'Windows')
end

local search_path_list = pl.stringx.split(package.path, ';')
local SEARCH_PATH = pl.List()

for i,v in ipairs(search_path_list) do
    local dir = pl.path.dirname(v)
    if (pl.path.isdir(dir) == true) then
        local path = pl.path.abspath(dir)
        --cclog(path)
        --SEARCH_PATH:put(path)
        --SEARCH_PATH:insert(1, path)
        SEARCH_PATH:append(path)
    end
end

-------------------------------------
-- table LuaBridge
-- @breif cocos2d-x엔진상에서의 lua와
--        windows에서 개발용 stand alone lua.exe에서
--        각기 다르게 동작해야 하는 함수들을 정의
-------------------------------------
LuaBridge = {}

-------------------------------------
-- function isFileExist
-------------------------------------
function LuaBridge:isFileExist(path)
    for i,dir in ipairs(SEARCH_PATH) do
        local _path = pl.path.join(dir, path)

        -- 파일이 있으면 파일 경로를, 없으면 nil을 리턴
        if pl.path.exists(_path) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function fullPathForFilename
-------------------------------------
function LuaBridge:fullPathForFilename(path)
    local full_path = nil

    for i,dir in ipairs(SEARCH_PATH) do
        local _path = pl.path.join(dir, path)

        -- 파일이 있으면 파일 경로를, 없으면 nil을 리턴
        if pl.path.exists(_path) then
            full_path = pl.path.normpath(_path)
        end
    end

    return full_path
end

-------------------------------------
-- function getStringFromFile
-------------------------------------
function LuaBridge:getStringFromFile(path)
    return pl.file.read(path)
end