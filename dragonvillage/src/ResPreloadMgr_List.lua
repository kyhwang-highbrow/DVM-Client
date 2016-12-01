-------------------------------------
-- function getPreloadList_Common
-------------------------------------
function ResPreloadMgr:getPreloadList_Common()
    local ret = {
        'res/effect/effect_melee_charge/effect_melee_charge.plist',
        'res/effect/effect_missile_charge/effect_missile_charge.plist',
        'res/effect/effect_fever/effect_fever.plist',
        'res/effect/effect_hit_01/effect_hit_01.plist',
        'res/effect/effect_skillcasting_dragon/effect_skillcasting_dragon.plist',
        'res/effect/effect_skillcasting/effect_skillcasting.plist',
        'res/effect/effect_passive_common/effect_passive_common.plist',

        'res/indicator/indicator_effect_target/indicator_effect_target.plist',
        'res/ui/a2d/ingame_combo_text/ingame_combo_text.plist',
        'res/ui/a2d/enemy_skill_speech/enemy_skill_speech.plist',
        'res/ui/a2d/ingame_enemy/ingame_enemy.plist'
    }
    return ret
end

-------------------------------------
-- function getPreloadList_Tamer
-------------------------------------
function ResPreloadMgr:getPreloadList_Tamer()
    -- TODO: 현재 테이머는 고니로 고정이므로 차후 수정
    --local t_tamer = TABLE:get('tamer')[TAMER_ID]

    local ret = {
        'res/character/tamer/goni_i/goni_i.spine',
        'res/effect/effect_skillcut_goni/effect_skillcut_goni.vrp'
    }
    
    return ret
end

-------------------------------------
-- function getPreloadList_Hero
-------------------------------------
function ResPreloadMgr:getPreloadList_Hero()
    local ret = {}

    local t_skillList = { 'skill_basic', 'skill_active', 'skill_1', 'skill_3' }

    local l_deck = g_deckData:getDeck('1')
    for _, v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if t_dragon_data then
            local t_dragon = TABLE:get('dragon')[t_dragon_data['did']]
            if t_dragon then
                -- 영웅
                local evolution = t_dragon_data['evolution']
	            local attr = t_dragon['attr']

                local res_name = AnimatorHelper:getDragonResName(t_dragon['res'], evolution, attr)
                table.insert(ret, res_name)
                
                -- 스킬
                for _, k in pairs(t_skillList) do
                    local t_skill = TABLE:get('dragon_skill')[t_dragon[k]]
                    if t_skill then

                        for i = 1, 3 do
                            if (t_skill['res_' .. i] ~= 'x') then
                                local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                                table.insert(ret, res_name)
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
-- function getPreloadList_Stage
-------------------------------------
function ResPreloadMgr:getPreloadList_Stage(stageName)
    local ret = {}

    local t_skillList = { 'skill_basic' }
    for i = 1, 9 do
        table.insert(t_skillList, 'skill_' .. i)
    end

    local script = TABLE:loadJsonTable(stageName)
    if script then
        for _, v in pairs(script['wave']) do
            if v['wave'] then
                for _, a in pairs(v['wave']) do
                    for _, data in pairs(a) do
                        local l_str = seperate(data, ';')
                        local enemy_id = tonumber(l_str[1])   -- 적군 ID

                        local t_enemy = TABLE:get('enemy')[enemy_id]
                        if t_enemy then
                            -- 적군
                            local attr = t_enemy['attr']

                            local res_name = AnimatorHelper:getMonsterResName(t_enemy['res'], attr)
                            table.insert(ret, res_name)

                            -- 스킬
                            for _, k in pairs(t_skillList) do
                                local t_skill = TABLE:get('enemy_skill')[t_enemy[k]]
                                if t_skill then

                                    for i = 1, 3 do
                                        if (t_skill['res_' .. i] ~= 'x') then
                                            local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
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

    return ret
end