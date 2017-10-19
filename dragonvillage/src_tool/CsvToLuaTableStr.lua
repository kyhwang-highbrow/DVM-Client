require 'LuaStandAlone'

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
-- function work
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
        local table_str = util.makeLuaTableStr(t_table)

        local l_header = self:makeHeaderLlist(t_table)
        local header_str = util.makeLuaTableStr(l_header)

        local content = "return {['__data']=" .. table_str .. ";['__header']=" .. header_str .. "}"

        local file_name = v[1] .. '.lua'
        pl.file.write('../src/table/' .. file_name, content)
    end

    io.write('', '\n')
    cclog('#### END')
    cclog('output : ' .. 'src/table/')
end

-------------------------------------
-- function makeHeaderLlist
-------------------------------------
function CsvToLuaTableStr:makeHeaderLlist(t_table)
    local first_data = nil

    for i,v in pairs(t_table) do
        first_data = v
        break
    end

    local l_header = {}
    for key,_ in pairs(first_data) do
        table.insert(l_header, key)
    end

    return l_header
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