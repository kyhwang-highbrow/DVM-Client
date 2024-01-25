--------------------------------------------
-- 각종 게임 모드
--------------------------------------------
-- 게임 모드
GAME_MODE_INTRO = 10
GAME_MODE_ADVENTURE = 11
GAME_MODE_NEST_DUNGEON = 12
GAME_MODE_SECRET_DUNGEON = 13
GAME_MODE_ANCIENT_TOWER = 14 -- 고대의 탑 (시험의 탑 포함)
GAME_MODE_CLAN_RAID = 15
GAME_MODE_ANCIENT_RUIN = 16
GAME_MODE_RUNE_GUARDIAN = 17
GAME_MODE_LEAGUE_RAID = 18
GAME_MODE_EVENT_GOLD = 19
GAME_MODE_COLOSSEUM = 20
GAME_MODE_ARENA = 21
GAME_MODE_EVENT_ARENA = 22
GAME_MODE_CHALLENGE_MODE = 23
GAME_MODE_EVENT_ILLUSION_DUNSEON = 191
GAME_MODE_CLAN_WAR = 24
GAME_MODE_ARENA_NEW = 25
GAME_MODE_DIMENSION_GATE = 30
GAME_MODE_EVENT_DEALKING = 31 -- 딜킹 이벤트
GAME_MODE_WORLD_RAID = 32 -- 월드 레이드
GAME_MODE_STORY_DUNGEON = 42 -- 스토리 던전


-- 모험 모드 챕터 상수값
SPECIAL_CHAPTER = {
    ['RUNE_FESTIVAL'] = 98,
    ['ADVENT'] = 99
}

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

-- 시련 던전 하위 던전 모드
DIMENSION_GATE_ANGRA = 1
DIMENSION_GATE_MANUS = 2

-- 월드 레이드 하위 모드
WORLD_RAID_NORMAL = 1 -- 월드 레이드(일반)
WORLD_RAID_COOPERATION = 2 -- 월드 레이드(협동)
WORLD_RAID_LINGER = 3 -- 월드 레이드(정예)



--------------------------------------------
-- constant.json 과 GAME_MODE 의 bridge
--------------------------------------------
IN_GAME_MODE = {}
IN_GAME_MODE[GAME_MODE_ADVENTURE] = "ADVENTURE"
IN_GAME_MODE[GAME_MODE_NEST_DUNGEON] = "NEST_DUNGEON"
IN_GAME_MODE[GAME_MODE_RUNE_GUARDIAN] = "RUNE_GUARDIAN"
IN_GAME_MODE[GAME_MODE_SECRET_DUNGEON] = "SECRET"
IN_GAME_MODE[GAME_MODE_ANCIENT_TOWER] = "ANCIENT_TOWER"
IN_GAME_MODE[GAME_MODE_COLOSSEUM] = "COLOSSEUM"
IN_GAME_MODE[GAME_MODE_ARENA] = "ARENA"
IN_GAME_MODE[GAME_MODE_EVENT_ARENA] = "ARENA"
IN_GAME_MODE[GAME_MODE_CHALLENGE_MODE] = "ARENA"
IN_GAME_MODE[GAME_MODE_INTRO] = "INTRO"
IN_GAME_MODE[GAME_MODE_EVENT_GOLD] = "EVENT_GOLD"
IN_GAME_MODE[GAME_MODE_CLAN_RAID] = "CLAN_RAID"
IN_GAME_MODE[GAME_MODE_EVENT_ILLUSION_DUNSEON] = "EVENT_GOLD"
IN_GAME_MODE[GAME_MODE_ANCIENT_RUIN] = "ANCIENT_RUIN"
IN_GAME_MODE[GAME_MODE_CLAN_WAR] = "ARENA"
IN_GAME_MODE[GAME_MODE_ARENA_NEW] = "ARENA_NEW"
IN_GAME_MODE[GAME_MODE_DIMENSION_GATE] = "DIMENSION_GATE"
IN_GAME_MODE[GAME_MODE_STORY_DUNGEON] = "STORY_DUNGEON"
IN_GAME_MODE[GAME_MODE_EVENT_DEALKING] = "EVENT_DEALKING"

NEST_MODE = {}
NEST_MODE[NEST_DUNGEON_EVO_STONE] = "EVOLUTION_STONE"
NEST_MODE[NEST_DUNGEON_NIGHTMARE] = "NIGHTMARE"
NEST_MODE[NEST_DUNGEON_TREE] = "TREE"
NEST_MODE[NEST_DUNGEON_GOLD] = "GOLD"

SECRET_MODE = {}
SECRET_MODE[SECRET_DUNGEON_GOLD] = "GOLD"
SECRET_MODE[SECRET_DUNGEON_RELATION] = "RELATION"

DIMENSION_GATE_MODE = {}
DIMENSION_GATE_MODE[DIMENSION_GATE_ANGRA] = "ANGRA"
DIMENSION_GATE_MODE[DIMENSION_GATE_MANUS] = "MANUS"

WORLD_RAID_MODE = {}
WORLD_RAID_MODE[WORLD_RAID_NORMAL] = "WORLD_RAID_NORMAL"
WORLD_RAID_MODE[WORLD_RAID_LINGER] = "WORLD_RAID_LINGER"
WORLD_RAID_MODE[WORLD_RAID_COOPERATION] = "WORLD_RAID_COOPERATION"

--------------------------------------------
-- skill에서 발동 조건으로 검색할 수 있게.
-- 0이거나 값이 없으면 전체 모드, 1은 PvE, 2는 PvP
--------------------------------------------
PLAYER_VERSUS_MODE = {}
PLAYER_VERSUS_MODE[GAME_MODE_ADVENTURE] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_NEST_DUNGEON] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_RUNE_GUARDIAN] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_SECRET_DUNGEON] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_ANCIENT_TOWER] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_COLOSSEUM] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_ARENA] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_ARENA_NEW] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_EVENT_ARENA] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_CHALLENGE_MODE] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_EVENT_GOLD] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_CLAN_RAID] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_ANCIENT_RUIN] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_EVENT_ILLUSION_DUNSEON] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_CLAN_WAR] = 'pvp'
PLAYER_VERSUS_MODE[GAME_MODE_DIMENSION_GATE] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_LEAGUE_RAID] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_STORY_DUNGEON] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_EVENT_DEALKING] = 'pve'
PLAYER_VERSUS_MODE[GAME_MODE_WORLD_RAID] = 'pve'

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

    -- 룬 수호자 던전
    elseif gameMode == GAME_MODE_RUNE_GUARDIAN then
        ret = t_game_mode_constant[game_mode_str][type]

    -- 비밀 던전
    elseif gameMode == GAME_MODE_SECRET_DUNGEON then
        local t_dungeon = g_secretDungeonData:parseSecretDungeonID(stageID)
        local dungeonMode = t_dungeon['dungeon_mode']
		local dungeon_str = SECRET_MODE[dungeonMode]

        ret = t_game_mode_constant[game_mode_str][dungeon_str][type]
    -- 차원문
    elseif gameMode == GAME_MODE_DIMENSION_GATE then
        local dungeonMode = g_dmgateData:getModeID(stageID)
        local dungeon_str = DIMENSION_GATE_MODE[dungeonMode]

        ret = t_game_mode_constant[game_mode_str][dungeon_str][type]
    --
    elseif (t_game_mode_constant[game_mode_str] and t_game_mode_constant[game_mode_str][type]) then
		
        ret = t_game_mode_constant[game_mode_str][type]
    
    else
        ret = t_game_mode_constant["ANCIENT_TOWER"][type]

    end
    
    return ret
end