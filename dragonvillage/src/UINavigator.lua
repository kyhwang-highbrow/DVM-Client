UINavigator = {}

-------------------------------------
-- function goTo
-- @brief UI 이동
-- @param location_name string
-------------------------------------
function UINavigator:goTo(location_name, ...)
    return UINavigatorDefinition:goTo(location_name, ...)
end

-- 사용 설명
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
end