require 'LuaStandAlone'
require 'LuaGlobal'

require 'TableDrop'
require 'IEventDispatcher'
require 'WaveMgr'
require 'DynamicWave'
require 'lib/math'

-------------------------------------
-- class CsvToLuaTableStr
-------------------------------------
CsvToLuaTableStr = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function CsvToLuaTableStr:init()
end

-------------------------------------
-- function run
-------------------------------------
function CsvToLuaTableStr:run()
    cclog('##### CsvToLuaTableStr:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    self:work()

    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function encodeString
-------------------------------------
function CsvToLuaTableStr:encodeString(s)
    s = string.gsub(s,'\\','\\\\')
    s = string.gsub(s,'"','\\"')
    s = string.gsub(s,"'","\\'")
    s = string.gsub(s,'\n','\\n')
    s = string.gsub(s,'\t','\\t')
    return s 
end

-------------------------------------
-- function luadump_old
-------------------------------------
function CsvToLuaTableStr:luadump_old(value, depth)
    local t = type(value)
    if t == 'table' then
        depth = depth or ''
        local newdepth = depth .. '\t'

        local s = '{\n'
        local n = #value

        for k, v in pairs(value) do
            -- key타입이 숫자일 경우 그냥 숫자로 사용
            if type(k) == 'number' then
                s = s .. newdepth .. "[" .. k .. "]=" .. self:luadump(value[k], newdepth) .. ';\n'
            elseif type(k) ~= 'number' or k <= 0 or k > n then
                s = s .. newdepth .. "['" .. k .. "']=" .. self:luadump(value[k], newdepth) .. ';\n'
            end
        end
        return s .. depth .. '}'

    elseif t == 'string' then
        -- 개행 처리를 '\n'으로 저장히가 위한 처리
        value = self:encodeString(value)
        return "'" .. value .. "'"
    else
        return tostring(value)
    end
end

-------------------------------------
-- function luadump
-------------------------------------
function CsvToLuaTableStr:luadump(value, depth)
    local t = type(value)
    if t == 'table' then
        depth = depth or ''
        local newdepth = depth

        local s = '{'--\n'
        local n = #value

        for k, v in pairs(value) do
            -- key타입이 숫자일 경우 그냥 숫자로 사용
            if type(k) == 'number' then
                s = s .. newdepth .. "[" .. k .. "]=" .. self:luadump(value[k], newdepth) .. ';'--\n'
            elseif type(k) ~= 'number' or k <= 0 or k > n then
                s = s .. newdepth .. "['" .. k .. "']=" .. self:luadump(value[k], newdepth) .. ';'--\n'
            end
        end
        return s .. depth .. '}'

    elseif t == 'string' then
        -- 개행 처리를 '\n'으로 저장히가 위한 처리
        value = self:encodeString(value)
        return "'" .. value .. "'"
    else
        return tostring(value)
    end
end

-------------------------------------
-- function test1
-------------------------------------
function CsvToLuaTableStr:work()

    local t_table_info = TABLE:getTableInfo()

    local total_cnt = table.count(t_table_info)
    local done_cnt = 0

    -- 1. 폴더 삭제
    --    src/table

    -- 2. 폴더 생성
    --    src/table
    --    src/table/scenario

    io.write('\n\n')
    cclog('#### START')

    for i,v in pairs(t_table_info) do

        done_cnt = done_cnt + 1
        local percent_str = string.format('(%d/%d, %d%%)', done_cnt, total_cnt, done_cnt / total_cnt * 100)

        io.write('\t\t\t\t\t\t\t\t\t\t', '\r') -- 이전 라인을 지우가 위함
        io.write(percent_str .. ' Working : ' .. v[1], '\r')

        local t_table = TABLE:get(i)
        self:dietTable(t_table)
        local table_str = self:luadump(t_table)
        local content = 'return ' .. table_str

        local file_name = v[1] .. '.lua'
        pl.file.write('../src/table/' .. file_name, content)
    end

    io.write('', '\n')
    cclog('#### END')
    cclog('output : ' .. 'src/table/')
end

-------------------------------------
-- function dietTable
-------------------------------------
function CsvToLuaTableStr:dietTable(t_table)
    for _,t_line in pairs(t_table) do
        for key,value in pairs(t_line) do
            if pl.stringx.startswith(key, 's_') or pl.stringx.startswith(key, 'r_') then
                t_line[key] = nil
            end
        end
    end
    
    return t_table
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
local function main()
    if (arg[1] == 'run') then
        CsvToLuaTableStr():run()
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)