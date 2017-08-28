require 'LuaStandAlone'
require 'LuaGlobal'

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
    cclog('##### StageAnalysis:run')

    local stopwatch = Stopwatch()
    stopwatch:start()

    self:makePreloadFile()

    stopwatch:stop()
    io.write('\n\n')

    stopwatch:print()
end

-------------------------------------
-- function countSkillResListFromScript
-- @brief 해당 스킬 타입의 스크립트에 포함된 리소스명을 list의 테이블에 포함시킴
-------------------------------------
function ResourcePreloadMaker:countSkillResListFromScript(list, type, attr)
    local script = TABLE:loadSkillScript(type)
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
-- function makePreloadFile
-------------------------------------
function ResourcePreloadMaker:makePreloadFile()
    --cclog('savePreloadFile')
    
    -- 1. 스테이지별 리스트를 생성
    local preloadList = {}
    local t_stage_desc = TABLE:get('stage_desc')

    for stageID, _ in pairs(t_stage_desc) do
        local stageName = string.format('stage_%s', stageID)
        preloadList[stageName] = makeResListForGame(stageName, true)
    end

    -- 2. 파일로 저장
    local path = cc.FileUtils:getInstance():fullPathForFilename(PRELOAD_FILE_NAME)
    local f = io.open(path, 'wb')
    local contents = dkjson.encode(preloadList, {indent=true})
    f:write(contents)
    f:close()
end

-------------------------------------
-- function getPreloadList_Stage
-------------------------------------
function ResourcePreloadMaker:getPreloadList_Stage(stageName)
    local ret = {}

    local t_skillList = { 'skill_basic' }
    for i = 1, 9 do
        table.insert(t_skillList, 'skill_' .. i)
    end

    -- 스테이지 공통 리소스
    table.insert(ret, 'res/effect/effect_attack_ready/effect_attack_ready.plist')

    local script = TABLE:loadStageScript(stageName)
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
                            for _, k in pairs(t_skillList) do
                                local t_skill = TABLE:get('monster_skill')[t_enemy[k]]
                                if t_skill then
                                    if t_skill['skill_form'] == 'script' then
                                        countSkillResListFromScript(ret, t_skill['skill_type'], attr)
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
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    AssetMaker():run()
end