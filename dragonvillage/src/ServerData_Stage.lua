GAME_MODE_ADVENTURE = 1
GAME_MODE_NEST_DUNGEON = 2


-------------------------------------
-- class ServerData_Stage
-------------------------------------
ServerData_Stage = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Stage:init(server_data)
    self.m_serverData = server_data
end


-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_Stage:getStageName(stage_id)
    local game_mode = getDigit(stage_id, 10000, 1)

    local name = ''

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local chapter_name = chapterName(chapter)
        name = chapter_name .. Str(' {1}-{2}', chapter, stage)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        local table_drop = TableDrop()
        local t_drop = table_drop:get(stage_id)
        name = Str(t_drop['t_name'])
    end

    return name
end

-------------------------------------
-- function isOpenStage
-------------------------------------
function ServerData_Stage:isOpenStage(stage_id)
    local game_mode = getDigit(stage_id, 10000, 1)

    local ret = false

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:isOpenStage(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = true
    end

    return ret
end