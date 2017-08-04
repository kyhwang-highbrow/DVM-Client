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

    local stopwatch = Stopwatch()
    stopwatch:start()

    self:test1()
    --self:checkTheRegenform()

    stopwatch:stop()
    stopwatch:print()
end

-------------------------------------
-- function test1
-------------------------------------
function StageAnalysis:test1()
    local table_drop = TableDrop()

    local table_info = {}

    for stage_id,v in pairs(table_drop.m_orgTable) do
        local t_data = self:individualStageAnalysis(stage_id)
        table.insert(table_info, t_data)
    end

    self:makeStageInfoCsvFile(table_info)
end

-------------------------------------
-- function checkTheRegenform
-------------------------------------
function StageAnalysis:checkTheRegenform()
    local table_drop = TableDrop()
    for stage_id,v in pairs(table_drop.m_orgTable) do
        
        local stage_name = 'stage_' .. stage_id
        local t_data = TABLE:loadStageScript(stage_name)

        if t_data then

        -- 등장 몬스터 저장
        for _,t_wave in ipairs(t_data['wave']) do

            if t_wave['regen'] then
                for _,group_list in pairs(t_wave['regen']) do
                    for _,t_time_line in pairs(group_list) do

                        if (type(t_time_line) == 'string') then
                            cclog(stage_name)
                        end

                    end
                end
            end
        end

        end
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

                    if (type(t_time_line) == 'table') then
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
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    StageAnalysis():run()
end