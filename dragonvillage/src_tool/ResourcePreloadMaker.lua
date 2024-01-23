require 'LuaStandAlone'

require 'TableStageDesc'
require 'TableDragon'
require 'TableDragonSkill'
require 'TableMonster'
require 'TableMonsterSkill'
require 'TableStageData'
require 'TableStatusEffect'
require 'AnimatorHelper'
require 'EquationHelper'

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

EQUATION_FUNC = {}
local table_dragon = TableDragon()
local table_monster = TableMonster()
local table_monster_skill = TableMonsterSkill()
local table_status_effect = TableStatusEffect()

-------------------------------------
-- function makePreloadFile
-------------------------------------
function ResourcePreloadMaker:makePreloadFile()
    -- 초기화
    local l_preload_list = {}

    -- 공용 리소스 리스트 삽입
    print("# make common list")
    l_preload_list['common'] = self:getPreloadList_Common()

    -- 인트로 스테이지 리소스 생성
    local intro_stage_id = 1010001
    print("# make intro stage")
    l_preload_list[intro_stage_id] = self:getPreloadList_Stage(intro_stage_id)
    local l_stage = TableStageDesc:getPreloadStageList()
    -- 스테이지 별 리소스 생성
    print("# make all stage")
    for _,stage_id in ipairs(l_stage) do
        l_preload_list[stage_id] = self:getPreloadList_Stage(stage_id)
    end
    
    -- 총 프리로드 리소스 카운트
    local count = 0
    for i, v in pairs(l_preload_list) do
        for j, k in pairs(v) do
            count = count + 1
        end
    end
    cclog('RES PRELOAD COUNT .. ' .. count)

    -- 파일로 저장    
    local contents = util.makeLuaTableStr(l_preload_list)
    local preload_file_path = '../src/table/preload.lua'
    pl.file.write(preload_file_path, 'return ' .. contents)
end

-------------------------------------
-- function getPreloadList_Stage
-------------------------------------
function ResourcePreloadMaker:getPreloadList_Common()
    return {
        -- plist
        'res/effect/effect_skillcut_dragon/effect_skillcut_dragon.plist',
        'res/effect/effect_monsterdragon/effect_monsterdragon.plist',

        -- vrp
        'res/effect/effect_attack_ready/effect_attack_ready.vrp',
        'res/effect/effect_melee_charge/effect_melee_charge.vrp',
        'res/effect/effect_hit_01/effect_hit_01.vrp',
        'res/effect/effect_passive_common/effect_passive_common.vrp',
        'res/indicator/indicator_effect_target/indicator_effect_target.vrp',
        'res/ui/a2d/enemy_skill_speech/enemy_skill_speech.vrp',
        'res/ui/a2d/ingame_cha_info/ingame_cha_info.vrp',
        'res/effect/effect_missile_charge/effect_missile_charge.vrp',
        'res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.vrp',
        'res/effect/effect_skillcasting/effect_skillcasting.vrp',
        
        -- 인게임에서 높은 확률로 사용되거나 확실히 사용되는 작은 크기의 리소스들 프리로드.
        'res/effect/effect_melee_charge/effect_melee_charge.vrp',
        'res/effect/tamer_magic_1/tamer_magic_1.vrp',
        'res/effect/effect_tamer_shield/effect_tamer_shield.vrp',
        'res/effect/effect_attack_ready/effect_attack_ready.vrp',
        'res/effect/effect_passive_common/effect_passive_common.vrp',
        'res/ui/a2d/enemy_skill_speech/enemy_skill_speech.vrp',
        'res/ui/a2d/card/card.vrp',
        'res/item/item_marble/item_marble.vrp',
        'res/effect/effect_skillcasting/effect_skillcasting.vrp',
        'res/effect/effect_hit_01/effect_hit_01.vrp',
        'res/effect/effect_hit_melee/effect_hit_melee.vrp',
        'res/effect/effect_appear/effect_appear.json',
        'res/ui/a2d/ingame_status_effect/ingame_status_effect.plist',

        -- 테이머 기본 리소스
        'res/effect/tamer_magic_1/tamer_magic_1.plist',
        'res/effect/effect_tamer_shield/effect_tamer_shield.plist',
        'res/effect/cutscene_tamer_a_type/cutscene_tamer_a_type_t.plist',

        -- 결과 UI
        'res/ui/a2d/result_box/result_box.vrp',
        'res/ui/a2d/result/result.vrp',
        'res/ui/a2d/result_level_up/result_level_up.vrp',
        'res/ui/a2d/loading/loading.vrp',
        'res/ui/a2d/rarity_light/rarity_light.vrp',
    }
end

-------------------------------------
-- function getPreloadList_Stage
-------------------------------------
function ResourcePreloadMaker:getPreloadList_Stage(stage_id)
    local t_ret = {}

    local t_skill_list = {'skill_basic'}
    for i = 1, 9 do
        table.insert(t_skill_list, 'skill_' .. i)
    end

    local game_mode = string.sub(tostring(stage_id), 1, 2)
    local script_name
    
    --[[
    if (game_mode == '15') then
        -- @jhakim 20190214 클랜던전 보스 이미지는 미리 PreLoad 하지 않음 (이 시점에서는 보스가 어떤 속성인지를 모름)
        -- 클랜 던전의 경우는 스테이지 속성에 따른 이름을 사용
         local attr = table_stage_data:getStageAttr(stage_id)
         script_name = string.format('stage_clanraid_%s', attr)
    else  
        script_name = 'stage_' .. stage_id
    end
    --]]

    script_name = 'stage_' .. stage_id

    local script = TABLE:loadStageScript(script_name)
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
                                t_enemy = table_dragon:get(enemy_id)
                            else
                                t_enemy = table_monster:get(enemy_id)
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
                            t_ret[res_name] = true

                            -- 스킬
                            for _, k in pairs(t_skill_list) do
                                local t_skill = table_monster_skill:get(t_enemy[k], 'skip')
                                if t_skill then
                                    if t_skill['skill_form'] == 'script' then
                                        self:countSkillResListFromScript(t_ret, t_skill['skill_type'], attr)
                                    else
                                        for i = 1, 3 do
                                            if (t_skill['res_' .. i] ~= '') then
                                                local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                                                t_ret[res_name] = true
                                            end
                                        end
                                    end

                                    -- 상태효과
                                    for i = 1, 5 do
                                        local type = t_skill['add_option_type_' .. i]
                                        if (type and type ~= '') then
                                            local t_status_effect = table_status_effect:get(type)
                                            if (t_status_effect) then
                                                if (t_status_effect['res'] ~= '') then
                                                    local res_name = t_status_effect['res']
                                                    t_ret[res_name] = true
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

    -- 인덱스 테이블
    local l_ret = {}
    for res_name, _ in pairs(t_ret) do
        local res, count = string.gsub(res_name, '\\', '/')        
        table.insert(l_ret, res)

        -- 역슬래시가 포함되었는지 체크 (경고로 끝냄)
        if count ~= nil and count > 0 then
            print('resource file name error .. file name is ', res_name)
        end
    end

    return l_ret
end

-------------------------------------
-- function countSkillResListFromScript
-- @brief 해당 스킬 타입의 스크립트에 포함된 리소스명을 list의 테이블에 포함시킴
-------------------------------------
function ResourcePreloadMaker:countSkillResListFromScript(t_ret, skill_type, attr)
    -- 스크립트 로드
    local filename = 'skill/' .. skill_type
    local script = TABLE:loadJsonTable(filename)
    if (not t_ret or not script) then return end

    -- 데이터 여부 확인
    local script_data = script[skill_type]
    if (not script_data) then return end
    
    -- 추출
    local t_attack_value = script_data['attack_value']
    local count = 1
    while (t_attack_value[count]) do
        local attack_value = t_attack_value[count]
        local res = attack_value['res']
        if (res) then
            local res_name = string.gsub(res, '@', attr)
            t_ret[res_name] = true
        end

        -- add_script 영역도 추출
        if (attack_value['add_script']) then
            local l_add_script = attack_value['add_script']
            for _, add_script in pairs(l_add_script) do
                if (type(add_script) == 'table') then
                    local res = add_script['res']
                    if (res) then
                        local res_name = string.gsub(res, '@', attr)
                        t_ret[res_name] = true
                    end
                end
            end
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
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    ResourcePreloadMaker():run()
end