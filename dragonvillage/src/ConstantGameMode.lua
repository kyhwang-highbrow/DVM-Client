--------------------------------------------
-- 각종 게임 모드
--------------------------------------------
-- 게임 모드
GAME_MODE_ADVENTURE = 11
GAME_MODE_NEST_DUNGEON = 12
GAME_MODE_SECRET_DUNGEON = 13
GAME_MODE_ANCIENT_TOWER = 14
GAME_MODE_COLOSSEUM = 19

-- 네스트 던전 하위 던전 모드
NEST_DUNGEON_DRAGON = 1
NEST_DUNGEON_NIGHTMARE = 2
NEST_DUNGEON_TREE = 3
NEST_DUNGEON_GOLD = 4

-- 비밀 던전 하위 던전 모드
SECRET_DUNGEON_GOLD = 1
SECRET_DUNGEON_RELATION = 2

--------------------------------------------
-- constant.json 과 GAME_MODE 의 bridge
--------------------------------------------
IN_GAME_MODE = {}
IN_GAME_MODE[11] = "ADVENTURE"
IN_GAME_MODE[12] = "NEST_DUNGEON"
IN_GAME_MODE[13] = "SECRET"
IN_GAME_MODE[14] = "ANCIENT_TOWER"
IN_GAME_MODE[19] = "COLOSSEUM"

NEST_MODE = {}
NEST_MODE[1] = "DRAGON"
NEST_MODE[2] = "NIGHTMARE"
NEST_MODE[3] = "TREE"
NEST_MODE[4] = "GOLD"

SECRET_MODE = {}
SECRET_MODE[1] = "GOLD"
SECRET_MODE[2] = "RELATION"

-------------------------------------
-- function getInGameConstant
-------------------------------------
function getInGameConstant(type)
    local ret = 0

    local gameMode = GAME_MODE_ADVENTURE
    local stageID = makeAdventureID(1, 1, 1)
	local t_game_mode_constant = g_constant:get('MODE_DIRECTING')

    if (g_gameScene) then
        gameMode = g_gameScene.m_gameMode
        stageID = g_gameScene.m_stageID
    end
	
	local game_mode_str = IN_GAME_MODE[gameMode]

    -- 모험모드
    if gameMode == GAME_MODE_ADVENTURE then
        local difficulty, chapter, stage = parseAdventureID(stageID)
		local chapter_str = tostring(chapter)

        ret = t_game_mode_constant[game_mode_str][chapter_str][type]

    -- 네스트 던전
    elseif gameMode == GAME_MODE_NEST_DUNGEON then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stageID)
        local dungeonMode = t_dungeon['dungeon_mode']
		local dungeon_str = NEST_MODE[dungeonMode]

        ret = t_game_mode_constant[game_mode_str][dungeon_str][type]

    -- 비밀 던전
    elseif gameMode == GAME_MODE_SECRET_DUNGEON then
        local t_dungeon = g_secretDungeonData:parseSecretDungeonID(stageID)
        local dungeonMode = t_dungeon['dungeon_mode']
		local dungeon_str = SECRET_MODE[dungeonMode]

        ret = t_game_mode_constant[game_mode_str][dungeon_str][type]

    -- 콜로세움
    elseif gameMode == GAME_MODE_COLOSSEUM then
		
        ret = t_game_mode_constant[game_mode_str][type]
    end
    
    return ret
end
