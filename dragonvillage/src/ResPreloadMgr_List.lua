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
    local ret = {}

    return ret
end

-------------------------------------
-- function getPreloadList_Hero
-------------------------------------
function ResPreloadMgr:getPreloadList_Hero()
    local ret = {}

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
                
                -- 스킬 및 스테이터스 이펙트
                for _, k in pairs({'skill_basic', 'skill_active', 'skill_1', 'skill_3'}) do
                    local t_skill = TABLE:get('dragon_skill')[t_dragon[k]]
                    if t_skill then

                        for i = 1, 3 do
                            if (t_skill['res_' .. i] ~= 'x') then
                                local res_name = string.gsub(t_skill['res_' .. i], '@', attr)
                                table.insert(ret, res_name)
                            end
                        end

                        for i = 1, 1 do
                            local effect_str = t_skill['status_effect_' .. i]
                            if effect_str then
                                local t_effect = stringSplit(effect_str, ';')
                                local type = t_effect[1]
                                local t_statusEffect = TABLE:get('status_effect')[type]
                                if (t_statusEffect and t_statusEffect['res'] ~= 'x') then
                                    table.insert(ret, t_statusEffect['res'])
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
-- function getPreloadList_Stage
-------------------------------------
function ResPreloadMgr:getPreloadList_Stage()
    local ret = {}

    return ret
end