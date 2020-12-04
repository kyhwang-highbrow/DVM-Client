UINavigator = {}

-------------------------------------
-- function goTo
-- @brief UI 이동
-- @param location_name string
-------------------------------------
function UINavigator:goTo(location_name, ...)
    return UINavigatorDefinition:goTo(location_name, ...)
end

-------------------------------------
-- function closeClanUI
-- @brief UI 닫기
-------------------------------------
function UINavigator:closeClanUI()
    local self = UINavigatorDefinition

    local is_opend, idx, ui = self:findOpendUI('UI_Clan')
    if (is_opend == true) then
        self:closeUIList(idx, true)
    end

    local is_opend, idx, ui = self:findOpendUI('UI_ClanGuest')
    if (is_opend == true) then
        self:closeUIList(idx, true)
    end
end


-- 사용 설명 CONTENT
if false then
    -- @brief 로비로 이동
    UINavigator:goTo('lobby')

    -- @brief 모험으로 이동
    -- @param optional stage_id(number) (e.g. stage_id = 1010001)
    UINavigator:goTo('adventure', stage_id)

    -- @brief 탐험 이동
    UINavigator:goTo('exploration')

    -- @brief 콜로세움으로 이동
    UINavigator:goTo('colosseum')

    -- @brief 고대의 탑으로 이동
    -- @param optional stage_id(number) 
    UINavigator:goTo('ancient', stage_id)

    -- @brief 시험의 탑으로 이동
    -- @param optional attr(string) 
    -- @param optional stage_id(number) 
    UINavigator:goTo('attr_tower', attr, stage_id)

    -- @brief 네스트 던전으로 이동
    -- @param optional stage_id(number) (e.g. stage_id = 1210101)
    -- @param optional dungeon_type(number) (e.g. dungeon_type = NEST_DUNGEON_EVO_STONE)
    UINavigator:goTo('nestdungeon', stage_id, dungeon_type)

    -- @brief 거대용 던전으로 이동
    -- @param optional stage_id(number) 
    UINavigator:goTo('nest_evo_stone', stage_id)

    -- @brief 거목 던전으로 이동
    -- @param optional stage_id(number) 
    UINavigator:goTo('nest_tree', stage_id)

    -- @brief 악몽 던전으로 이동
    -- @param optional stage_id(number) 
    UINavigator:goTo('nest_nightmare', stage_id)

    -- @brief 인연 던전으로 이동
    -- @param optional stage_id(number) 
    UINavigator:goTo('secret_relation', stage_id)

    -- @brief 전투 메뉴로 이동
    -- @param optional tab_name(string) 'adventure', 'dungeon', 'competition'
    UINavigator:goTo('battle_menu', tab_name)

    -- @brief 황금 던전으로 이동
    UINavigator:goTo('gold_dungeon')

    -- @brief 챌린지 모드로 이동
    UINavigator:goTo('challenge_mode')

    -- @brief 그랜드 콜로세움으로 이동
    UINavigator:goTo('grand_arena')

    -- @brief 룬 수호자 던전으로 이동
    UINavigator:goTo('rune_guardian')
end


-- 사용 설명 UI
if false then
    -- @brief 드래곤 관리로 이동
    UINavigator:goTo('dragon')

    -- @brief 부화소로 이동
    -- @param optional tab  (summon, combine, incubate, relation)
    UINavigator:goTo('hatchery', tab)

    -- @brief 룬 세공소로 이동
    -- @param optional tab  (info, manage, combine, gacha, reinforce, grind)
    UINavigator:goTo('rune_forge', tab)

    -- @brief 친구 관리로 이동
    UINavigator:goTo('friend')

    -- @brief 드래곤 관리로 이동
    -- @param optional sub_menu (level_up, grade, evolution, friendship, skill_enc, rune, reinforce, mastery)
    UINavigator:goTo('dragon_manage', sub_menu)

    -- @brief 테이머 코스튬 상점으로 이동 (테이머 관리와 통합)
    UINavigator:goTo('tamer', sel_tamer_id)

    -- @brief 드래곤의 숲으로 이동
    UINavigator:goTo('forest')

    -- @brief 클랜 UI로 이동
    UINavigator:goTo('clan')

    -- @brief 클랜 던전 UI로 이동
    UINavigator:goTo('clan_raid')

    -- @brief 패키지 팝업 UI로 이동
    UINavigator:goTo('package_shop')
end