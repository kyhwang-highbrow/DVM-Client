require 'LuaStandAlone'

require 'TableStageDesc'
require 'TableDragon'
require 'TableMonster'
require 'TableStatusEffect'
require 'AnimatorHelper'

-------------------------------------
-- class StageAnalysis
-------------------------------------
ResourcePreloadMaker = class({
    })

-------------------------------------
-- function init
-------------------------------------
function ResourcePreloadMaker:init()
end

-------------------------------------
-- function run
-------------------------------------
function ResourcePreloadMaker:run()
    cclog('##### ResourcePreloadMaker:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    self:makePreloadFile()

    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function makePreloadFile
-------------------------------------
function ResourcePreloadMaker:makePreloadFile()
    --cclog('savePreloadFile')
    
    -- 1. 스테이지별 리스트를 생성
    local l_preload_list = {}
    local table_stage_desc = TableStageDesc()

    for stage_id, _ in pairs(table_stage_desc.m_orgTable) do
        l_preload_list[stage_id] = self:getPreloadList_Stage(stage_id)
    end

    -- 2. 파일로 저장
    local preload_file_path = '../data/preload.lua'
    local contents = util.makeLuaTableStr(l_preload_list)

    local count = 0
    for i, v in pairs(l_preload_list) do
        for j, k in pairs(v) do
            count = count + 1
        end
    end

    cclog('RES COUNT .. ' .. count)
    pl.file.write(preload_file_path, contents)
end

-------------------------------------
-- function getPreloadList_Stage
-------------------------------------
function ResourcePreloadMaker:getPreloadList_Stage(stage_id)
    local ret = {}

    local t_skill_list = {'skill_basic'}
    for i = 1, 9 do
        table.insert(t_skill_list, 'skill_' .. i)
    end

    -- 스테이지 공통 리소스
    table.insert(ret, 'res/effect/effect_attack_ready/effect_attack_ready.plist')

    local script = TABLE:loadStageScript('stage_' .. stage_id)
    if script and script['wave'] then
        for _, v in pairs(script['wave']) do
            if v['wave'] then
                for _, a in pairs(v['wave']) do
                    for _, data in pairs(a) do
                        local l_str = seperate(data, ';')
                        local enemy_id = tonumber(l_str[1])   -- 적군 ID

                        local t_enemy
                        if enemy_id then
                            if isDragon(enemy_id) then
                                t_enemy = TableDragon():get(enemy_id)
                            else
                                t_enemy = TableMonster():get(enemy_id)
                            end
                        end

                        if t_enemy then
                            -- 적군
                            local attr = t_enemy['attr']

                            local res_name

                            if isDragon(enemy_id) then
                                -- 스테이지에서 등장하는 적 드래곤은 모두 성룡이라고 가정(고대의 탑)
                                res_name = AnimatorHelper:getDragonResName(t_enemy['res'], 3, attr)
                            else
                                res_name = AnimatorHelper:getMonsterResName(t_enemy['res'], attr)
                            end
                            table.insert(ret, res_name)

                            -- 스킬
                            for _, k in pairs(t_skill_list) do
                                local t_skill = TABLE:get('monster_skill')[t_enemy[k]]
                                if t_skill then
                                    if t_skill['skill_form'] == 'script' then
                                        self:countSkillResListFromScript(ret, t_skill['skill_type'], attr)
                                    else
                                        for i = 1, 3 do
                                            if (t_skill['res_' .. i] ~= 'x') then
                                                local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                                                table.insert(ret, res_name)
                                            end
                                        end
                                    end

                                    -- 상태효과
                                    for i = 1, 2 do
                                        local type = t_skill['add_option_type_' .. i]
                                        if (type ~= '') then
                                            local t_status_effect = TableStatusEffect():get(type)
                                            if (t_status_effect) then
                                                if (t_status_effect['res'] ~= '') then
                                                    local res_name = t_status_effect['res']
                                                    table.insert(ret, res_name)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return ret
end

-------------------------------------
-- function countSkillResListFromScript
-- @brief 해당 스킬 타입의 스크립트에 포함된 리소스명을 list의 테이블에 포함시킴
-------------------------------------
function ResourcePreloadMaker:countSkillResListFromScript(list, skill_type, attr)
    local filename = 'skill/' .. skill_type
    local script = TABLE:loadJsonTable(filename)
    if (not list or not script) then return end

    local script_data = script[type]
    if (not script_data) then return end
    
    local tAttackValueBase = script_data['attack_value']
    local count = 1

    while (tAttackValueBase[count]) do
        local res = tAttackValueBase[count]['res']
        if (res) then
            local res_name = string.gsub(res, '@', attr)
            table.insert(list, res_name)
        end

        count = count + 1
    end
end

-------------------------------------
-- function isDragon
-- @brief id를 가지고 dragon인지 판별
-------------------------------------
function isDragon(id)
    return (math.floor(id / 10000) == 12)
end

-------------------------------------
-- function loadSkillScript
-------------------------------------
function LoadSkillScript(filename, extention, remove_comment)
    local filename = 'skill/' .. filename
    return ScriptCache:get(filename, extention, remove_comment)
    --return self:loadJsonTable(filename, extention, remove_comment)
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    ResourcePreloadMaker():run()
end