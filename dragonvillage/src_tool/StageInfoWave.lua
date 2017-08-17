require 'LuaTool'
require 'LuaGlobal'

require 'TableDrop'
require 'IEventDispatcher'
require 'WaveMgr'
require 'DynamicWave'
require 'lib/math'

-------------------------------------
-- class StageInfoWave
-------------------------------------
StageInfoWave = class({     
    })

-------------------------------------
-- function init
-------------------------------------
function StageInfoWave:init()
end

-------------------------------------
-- function run
-------------------------------------
function StageInfoWave:run()
    cclog('##### StageInfoWave:run')
    
    local stopwatch = Stopwatch()
    stopwatch:start()

    self:test1()

    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function test1
-------------------------------------
function StageInfoWave:test1()
    local table_drop = TableDrop()

    local table_info = {}
    local table_info_include_regen = {}
    
    local total_cnt = table.count(table_drop.m_orgTable)
    local done_cnt = 0

    io.write('\n\n')
    cclog('#### START')
    local max_wave = 10
    for stage_id,v in pairs(table_drop.m_orgTable) do
        done_cnt = done_cnt + 1
        local percent_str = string.format('(%d/%d, %d%%)', done_cnt, total_cnt, done_cnt / total_cnt * 100)

        io.write(percent_str .. ' 작업 중 : stage_' .. stage_id, '\r')
        local t_row, t_row_include_regen, _max_wave = self:individualStageInfoWave(stage_id)
        table.insert(table_info, t_row)
        table.insert(table_info_include_regen, t_row_include_regen)

        max_wave = math_max(max_wave, _max_wave)
    end
    io.write('', '\n')
    cclog('#### END')

    self:makeStageInfoCsvFile(table_info_include_regen, max_wave)
end

-------------------------------------
-- function addMonsterInfo
-------------------------------------
function StageInfoWave:addMonsterInfo(target_table, wave_idx, monster_id, lv)
    -- target_table[wave_idx][monster_id][lv] = count

    -- 웨이브 공간 생성
    if (not target_table[wave_idx]) then
        target_table[wave_idx] = {}
    end

    -- 몬스터 아이디 공간 생성
    if (not target_table[wave_idx][monster_id]) then
        target_table[wave_idx][monster_id] = {}
    end

    -- 몬스터 아이디 공간 생성
    if (not target_table[wave_idx][monster_id][lv]) then
        target_table[wave_idx][monster_id][lv] = 0
    end

    target_table[wave_idx][monster_id][lv] = target_table[wave_idx][monster_id][lv] + 1
end

-------------------------------------
-- function individualStageInfoWave
-------------------------------------
function StageInfoWave:individualStageInfoWave(stage_id)
    local stage_name = 'stage_' .. stage_id
    local t_data = TABLE:loadStageScript(stage_name)
    if (not t_data) then
        return nil, nil, 0
    end

    local t_ret = {}
    t_ret['stage_id'] = stage_id
    local t_ret_include_regen = {}
    t_ret_include_regen['stage_id'] = stage_id

    local t_wave_monster = {}
    local t_wave_monster_include_regen = {}
    -- t_wave_monster['wave']['monster_id']['lv'] = count
    
    local t_monster_id_map = {}
    local t_regen_monster_id_map = {}

    -- 등장 몬스터 저장
    for wave_idx,t_wave in ipairs(t_data['wave']) do        
        -- 시간별 몬스터 정보가 있는 데이터 분석
        if t_wave['wave'] then
            for _,t_time_line in pairs(t_wave['wave']) do
                for _,monster_str in ipairs(t_time_line) do
                    --cclog(monster_str)

                    -- data_ ex : "300202;1;test;T7;R5"
                    local l_str = seperate(monster_str, ';')

                    local monster_id = l_str[1]   -- 적군 ID
                    local level = l_str[2]   -- 적군 레벨
                    local appearType = l_str[3]   -- 등장 타입
                    --cclog('monster_id : ' .. monster_id)
                    t_monster_id_map[monster_id] = true

                    --self:addMonsterInfo(t_wave_monster, wave_idx, monster_id, level)
                    self:addMonsterInfo(t_regen_monster_id_map, wave_idx, monster_id, level)
                end
            end
        end

        if t_wave['regen'] then
            for _,group_list in pairs(t_wave['regen']) do
                for _,t_time_line in pairs(group_list) do

                    if (type(t_time_line) ~= 'table') then
                        error(stage_name .. '의 regen 폼이 맞지 않습니다.')
                    else
                        for _,monster_str in ipairs(t_time_line) do
                            --cclog(monster_str)

                            -- data_ ex : "300202;1;test;T7;R5"
                            local l_str = seperate(monster_str, ';')

                            local monster_id = l_str[1]   -- 적군 ID
                            local level = l_str[2]   -- 적군 레벨
                            local appearType = l_str[3]   -- 등장 타입
                            --cclog('monster_id : ' .. monster_id)

                            self:addMonsterInfo(t_regen_monster_id_map, wave_idx, monster_id, level)
                        end
                    end
                end
            end
        end
    end

    local max_wave = 0
    for wave_idx,t_wave in pairs(t_wave_monster) do
        for monster_id,t_monster in pairs(t_wave) do

            local t_monster_list = {}
            for lv,count in pairs(t_monster) do
                table.insert(t_monster_list, {monster_id=monster_id, lv=lv, count=count})
            end
            table.sort(t_monster_list, function(a, b) return a['monster_id'] < b['monster_id'] end)

            for monster_idx,data in pairs(t_monster_list) do
                
                local id_key = string.format('w%d_m%d_id', wave_idx, monster_idx)
                t_ret[id_key] = data['monster_id']

                local lv_key = string.format('w%d_m%d_lv', wave_idx, monster_idx)
                t_ret[lv_key] = data['lv']

                local count_key = string.format('w%d_m%d_count', wave_idx, monster_idx)
                t_ret[count_key] = data['count']
            end
        end
        max_wave = math_max(max_wave, wave_idx)
    end

    for wave_idx,t_wave in pairs(t_regen_monster_id_map) do
        local monster_idx = 1
        for monster_id,t_monster in pairs(t_wave) do

            local t_monster_list = {}
            for lv,count in pairs(t_monster) do
                table.insert(t_monster_list, {monster_id=monster_id, lv=lv, count=count})
            end
            table.sort(t_monster_list, function(a, b) return a['monster_id'] < b['monster_id'] end)

            for _,data in pairs(t_monster_list) do
                
                local id_key = string.format('w%d_m%d_id', wave_idx, monster_idx)
                t_ret_include_regen[id_key] = data['monster_id']

                local lv_key = string.format('w%d_m%d_lv', wave_idx, monster_idx)
                t_ret_include_regen[lv_key] = data['lv']

                local count_key = string.format('w%d_m%d_count', wave_idx, monster_idx)
                t_ret_include_regen[count_key] = data['count']

                monster_idx = (monster_idx + 1)
            end
        end
    end

    return t_ret, t_ret_include_regen, max_wave
end

-------------------------------------
-- function makeDisplayMonsterIDStr
-- @brief table_stage_desc에서 사용하는 monster_id 문자열 생성
-------------------------------------
function StageInfoWave:makeDisplayMonsterIDStr(l_monster_id)
    local l_display_monster = {}
    local l_dragon_id = {}

    -- monster id가 높은 순서대로 뽑기위해 역순으로
    for i=#l_monster_id, 1, -1 do
        local monster_id = tonumber(l_monster_id[i])
                
        if monster_id then
            local identifier = getDigit(monster_id, 10000, 2)

            -- 드래곤 ID를 찾는다
            if (identifier == 12) then
                table.insert(l_dragon_id, monster_id)

            -- 몬스터
            elseif (#l_display_monster < 5) then
                table.insert(l_display_monster, 1, monster_id)
            end
        end
    end

    for i,v in pairs(l_dragon_id) do
        if (#l_display_monster == 5) then
            table.remove(l_display_monster, 1)
        end
        table.insert(l_display_monster, v)
    end

    local str = ''
    for i,v in ipairs(l_display_monster) do
        if (str == '') then
            str = (str .. v)
        else
            str = (str .. '; ' .. v)
        end
    end
    
    return str
end

-------------------------------------
-- function makeStageInfoCsvFile
-------------------------------------
function StageInfoWave:makeStageInfoCsvFile(table_info, max_wave)

    local max_monster = 10

    local l_header = {'stage_id'}

    for wave_idx=1, max_wave do
        for monster_idx=1, max_monster do
            local id_key = string.format('w%d_m%d_id', wave_idx, monster_idx)
            local lv_key = string.format('w%d_m%d_lv', wave_idx, monster_idx)
            local count_key = string.format('w%d_m%d_count', wave_idx, monster_idx)
            table.insert(l_header, id_key)
            table.insert(l_header, lv_key)
            table.insert(l_header, count_key)
        end
    end

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

    -- stage_id의 값으로 오름차순 정렬
    local table_list = {}
    for i,v in pairs(table_info) do
        table.insert(table_list, v)
    end
    table.sort(table_list, function(a, b) return a['stage_id'] < b['stage_id'] end)

    for _,v in ipairs(table_list) do
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


    local file_name = 'stage_info_wave.csv'
    pl.file.write('../bat/'.. file_name, csv_str)
    io.write('\n\n')
    cclog('output : ' .. file_name)
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
local function main()
    if (arg[1] == 'run') then
        StageInfoWave():run()
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)