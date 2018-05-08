--------------------------------------------
-- 각종 게임 모드
--------------------------------------------
-- 게임 모드
GAME_MODE_INTRO = 10
GAME_MODE_ADVENTURE = 11
GAME_MODE_NEST_DUNGEON = 12
GAME_MODE_SECRET_DUNGEON = 13
GAME_MODE_ANCIENT_TOWER = 14
GAME_MODE_CLAN_RAID = 15
GAME_MODE_ANCIENT_RUIN = 16
GAME_MODE_EVENT_GOLD = 19
GAME_MODE_COLOSSEUM = 20
GAME_MODE_ARENA = 21

-- 네스트 던전 하위 던전 모드
NEST_DUNGEON_EVO_STONE = 1
NEST_DUNGEON_NIGHTMARE = 2
NEST_DUNGEON_TREE = 3
NEST_DUNGEON_GOLD = 4
NEST_DUNGEON_ANCIENT_RUIN = 5

-- NEST_DUNGEON_SUB_MODE 속성과 일치한다. 보석용 0번만 체크해주면 됨 나중에 필요하면 추가
NEST_DUNGEON_SUB_MODE_JEWEL = 0

-- 비밀 던전 하위 던전 모드
SECRET_DUNGEON_GOLD = 1
SECRET_DUNGEON_RELATION = 2

--------------------------------------------
-- constant.json 과 GAME_MODE 의 bridge
--------------------------------------------
IN_GAME_MODE = {}
IN_GAME_MODE[GAME_MODE_ADVENTURE] = "ADVENTURE"
IN_GAME_MODE[GAME_MODE_NEST_DUNGEON] = "NEST_DUNGEON"
IN_GAME_MODE[GAME_MODE_SECRET_DUNGEON] = "SECRET"
IN_GAME_MODE[GAME_MODE_ANCIENT_TOWER] = "ANCIENT_TOWER"
IN_GAME_MODE[GAME_MODE_COLOSSEUM] = "COLOSSEUM"
IN_GAME_MODE[GAME_MODE_ARENA] = "ARENA"
IN_GAME_MODE[GAME_MODE_INTRO] = "INTRO"
IN_GAME_MODE[GAME_MODE_EVENT_GOLD] = "EVENT_GOLD"
IN_GAME_MODE[GAME_MODE_CLAN_RAID] = "CLAN_RAID"
IN_GAME_MODE[GAME_MODE_ANCIENT_RUIN] = "ANCIENT_RUIN"

NEST_MODE = {}
NEST_MODE[NEST_DUNGEON_EVO_STONE] = "EVOLUTION_STONE"
NEST_MODE[NEST_DUNGEON_NIGHTMARE] = "NIGHTMARE"
NEST_MODE[NEST_DUNGEON_TREE] = "TREE"
NEST_MODE[NEST_DUNGEON_GOLD] = "GOLD"

SECRET_MODE = {}
SECRET_MODE[SECRET_DUNGEON_GOLD] = "GOLD"
SECRET_MODE[SECRET_DUNGEON_RELATION] = "RELATION"

--------------------------------------------
-- skill에서 발동 조건으로 검색할 수 있게.
-- 0이거나 값이 없으면 전체 모드, 1은 PvE, 2는 PvP
--------------------------------------------
PLAYER_VERSUS_MODE = {}
PLAYER_VERSUS_MODE[GAME_MODE_ADVENTURE] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_NEST_DUNGEON] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_SECRET_DUNGEON] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_ANCIENT_TOWER] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_COLOSSEUM] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_ARENA] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_EVENT_GOLD] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_CLAN_RAID] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_ANCIENT_RUIN] = 'pve'

-------------------------------------
-- function getInGameConstant
-------------------------------------
function getInGameConstant(type)
    if (not g_constant) then return end

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

    --
    elseif (t_game_mode_constant[game_mode_str] and t_game_mode_constant[game_mode_str][type]) then
		
        ret = t_game_mode_constant[game_mode_str][type]

    else
        ret = t_game_mode_constant["ANCIENT_TOWER"][type]

    end
    
    return ret
end