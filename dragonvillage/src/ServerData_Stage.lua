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
-- function getGameMode
-------------------------------------
function ServerData_Stage:getGameMode(stage_id)
    local game_mode = getDigit(stage_id, 10000, 1)
    return game_mode
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_Stage:getStageName(stage_id)
    local game_mode = self:getGameMode(stage_id)

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
    -- 콜로세움 모드
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        name = Str('콜로세움')
    end

    return name
end

-------------------------------------
-- function isOpenStage
-------------------------------------
function ServerData_Stage:isOpenStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = false

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:isOpenStage(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:isOpenStage(stage_id)
    end

    return ret
end

-------------------------------------
-- function getNextStage
-------------------------------------
function ServerData_Stage:getNextStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getNextStageID(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getNextStageID(stage_id)
    end

    return ret
end

-------------------------------------
-- function setFocusStage
-------------------------------------
function ServerData_Stage:setFocusStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        g_adventureData:setFocusStage(stage_id)
    end
end


-------------------------------------
-- function requestGameStart
-------------------------------------
function ServerData_Stage:requestGameStart(stage_id, finish_cb)
    -- 활동력 체크
    local can_play, deficiency = g_staminasData:checkStageStamina(stage_id)
    if (not can_play) then
        MakeSimplePopup(POPUP_TYPE.YES_NO, '{@BLACK}' .. Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), openShopPopup)
    end

    local uid = g_userData:get('uid')

    -- 모드별 API 주소 분기처리
    local api_url = ''
    local game_mode = g_stageData:getGameMode(stage_id)
    if (game_mode == GAME_MODE_ADVENTURE) then
        api_url = '/game/stage/start'
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        api_url = '/game/nest/start'
    end

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)
    end

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()

end