require 'LuaTool'
require 'LuaGlobal'

require 'TableDrop'
require 'IEventDispatcher'
require 'WaveMgr'
require 'DynamicWave'

-------------------------------------
-- class StageAnalysis
-------------------------------------
StageAnalysis = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function StageAnalysis:init()
end

-------------------------------------
-- function run
-------------------------------------
function StageAnalysis:run()
    cclog('##### StageAnalysis:run')
    
    --[[
    cclog('counting start')
    for i=1,100 do 
        --io.flush()
        --io.write('', '\r')
        io.write('개발 중인 idx : ' .. i, '\r')  --os.execute"sleep 1"
        --io.flush()
        if i==50 then
            --error()
        end
        for z=1, 999999 do
        end
    end
    io.write('\n')
    cclog('counting end')
    --]]

    local stopwatch = Stopwatch()
    stopwatch:start()

    self:test1()
    --self:checkTheRegenform()

    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function test1
-------------------------------------
function StageAnalysis:test1()
    local table_drop = TableDrop()

    local table_info = {}
    
    local total_cnt = table.count(table_drop.m_orgTable)
    local done_cnt = 0

    io.write('\n\n')
    cclog('#### START')
    for stage_id,v in pairs(table_drop.m_orgTable) do
        done_cnt = done_cnt + 1
        local percent_str = string.format('(%d/%d, %d%%)', done_cnt, total_cnt, done_cnt / total_cnt * 100)

        io.write(percent_str .. ' 작업 중 : stage_' .. stage_id, '\r')
        local t_data = self:individualStageAnalysis(stage_id)
        table.insert(table_info, t_data)
    end
    io.write('', '\n')
    cclog('#### END')

    self:makeStageInfoCsvFile(table_info)
end

-------------------------------------
-- function checkTheRegenform
-------------------------------------
function StageAnalysis:checkTheRegenform()

    local function checkTheRegenform_(stage_id)
        local stage_name = 'stage_' .. stage_id
        local t_data = TABLE:loadStageScript(stage_name)

        if (not t_data) then
            return nil
        end

        if (not t_data['wave']) then
            return nil
        end
        
        for _,t_wave in ipairs(t_data['wave']) do
            if t_wave['regen'] then
                for _,group_list in ipairs(t_wave['regen']) do
                    for _,t_time_line in pairs(group_list) do
                        if (type(t_time_line) == 'string') then
                            cclog(stage_name)
                            --return true
                        end
                    end
                end
            end
        end
    end

    local table_drop = TableDrop()
    for stage_id,v in pairs(table_drop.m_orgTable) do
        checkTheRegenform_(stage_id)
    end
end

-------------------------------------
-- function individualStageAnalysis
-------------------------------------
function StageAnalysis:individualStageAnalysis(stage_id)
    local stage_name = 'stage_' .. stage_id
    local t_data = TABLE:loadStageScript(stage_name)
    if (not t_data) then
        return nil
    end

    local t_ret = {}
    t_ret['stage_id'] = stage_id
    t_ret['wave_number'] = #t_data['wave']
    
    local t_monster_id_map = {}
    local t_regen_monster_id_map = {}

    -- 등장 몬스터 저장
    for _,t_wave in ipairs(t_data['wave']) do
        if t_wave['wave'] then
            for _,t_time_line in pairs(t_wave['wave']) do
                for _,monster_str in ipairs(t_time_line) do
                    --cclog(monster_str)

                    -- data_ ex : "300202;1;test;T7;R5"
                    local l_str = seperate(monster_str, ';')

                    local enemy_id = l_str[1]   -- 적군 ID
                    local level = l_str[2]   -- 적군 레벨
                    local appearType = l_str[3]   -- 등장 타입
                    --cclog('enemy_id : ' .. enemy_id)
                    t_monster_id_map[enemy_id] = true
                end
            end
        end

        if t_wave['regen'] then
            for _,group_list in pairs(t_wave['regen']) do
                for _,t_time_line in pairs(group_list) do

                    if (type(t_time_line) ~= 'table') then
                        --error(stage_name .. '의 regen 폼이 맞지 않습니다.')
                    else

                    for _,monster_str in ipairs(t_time_line) do
                        --cclog(monster_str)

                        -- data_ ex : "300202;1;test;T7;R5"
                        local l_str = seperate(monster_str, ';')

                        local enemy_id = l_str[1]   -- 적군 ID
                        local level = l_str[2]   -- 적군 레벨
                        local appearType = l_str[3]   -- 등장 타입
                        --cclog('enemy_id : ' .. enemy_id)
                        t_regen_monster_id_map[enemy_id] = true
                    end
                    end
                end
            end
        end
    end

    
    do -- 웨이브 몬스터
        local l_monster_id = {}
        for monster_id,v in pairs(t_monster_id_map) do
            table.insert(l_monster_id, monster_id)
        end
    
        table.sort(l_monster_id, function(a, b) 
                return a<b
            end)

        local monster_list_str = ''
        for i,v in ipairs(l_monster_id) do
            if (monster_list_str == '') then
                monster_list_str = (monster_list_str .. v)
            else
                monster_list_str = (monster_list_str .. ',' .. v)
            end
        end

        t_ret['wave_monster'] = monster_list_str
        t_ret['wave_monster_number'] = #l_monster_id
    end

    do -- 리젠 몬스터
        local l_monster_id = {}
        for monster_id,v in pairs(t_regen_monster_id_map) do
            table.insert(l_monster_id, monster_id)
        end
    
        table.sort(l_monster_id, function(a, b) 
                return a<b
            end)

        local monster_list_str = ''
        for i,v in ipairs(l_monster_id) do
            if (monster_list_str == '') then
                monster_list_str = (monster_list_str .. v)
            else
                monster_list_str = (monster_list_str .. ',' .. v)
            end
        end

        t_ret['regen_monster'] = monster_list_str
        t_ret['regen_monster_number'] = #l_monster_id
    end

    return t_ret
end

-------------------------------------
-- function makeStageInfoCsvFile
-------------------------------------
function StageAnalysis:makeStageInfoCsvFile(table_info)

    local l_header = {'stage_id', 'wave_number', 'wave_monster', 'wave_monster_number', 'regen_monster', 'regen_monster_number'}
    local csv_str = ''

    local line_str = ''
    for i,v in ipairs(l_header) do
        if (line_str == '') then
            line_str = v
        else
            line_str = line_str .. ',' .. v
        end
    end
    csv_str = csv_str .. line_str

    for i,v in pairs(table_info) do
        local line_str = ''
        for i,key in ipairs(l_header) do

            local value = v[key] or ''

            if (type(value) == 'string') then
                if string.find(value, ',') then
                    value = '"' .. value .. '"'
                end
            end

            if (i==1) then
                line_str = value
            else
                line_str = line_str .. ',' .. value
            end
        end

        csv_str = csv_str .. '\n' .. line_str
    end


    pl.file.write('../bat/'.. 'stage_info.csv', csv_str)
    io.write('\n\n')
    cclog('output : ' .. 'stage_info.csv')
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
local function main()
    if (arg[1] == 'run') then
        StageAnalysis():run()
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)