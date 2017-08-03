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
    local game_mode = getDigit(stage_id, 100000, 2)
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
        name = g_nestDungeonData:getStageName(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        local id = t_dungeon_info['id']
        name = g_secretDungeonData:getStageName(id)

    -- 고대의 탑
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        name = g_ancientTowerData:getStageName(stage_id)

    -- 콜로세움 모드
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        name = Str('콜로세움')

    -- 인트로 전투
    elseif (game_mode == GAME_MODE_INTRO) then
        name = Str('시나리오 전투')
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

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:isOpenStage(stage_id)

    -- 고대의 탑 모드
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        ret = g_ancientTowerData:isOpenStage(stage_id)

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

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getNextStageID(stage_id)

    -- 고대의 탑 모드
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        ret = g_ancientTowerData:getNextStageID(stage_id)
    end

    return ret
end

-------------------------------------
-- function getSimpleNextStage
-- @brief 같은 챕터 안에서 다음 스테이지
-------------------------------------
function ServerData_Stage:getSimpleNextStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getSimpleNextStageID(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getSimpleNextStageID(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getSimpleNextStageID(stage_id)
    end

    return ret
end

-------------------------------------
-- function getSimplePrevStage
-- @brief 같은 챕터 안에서 이전 스테이지
-------------------------------------
function ServerData_Stage:getSimplePrevStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getSimplePrevStageID(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getSimplePrevStageID(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getSimplePrevStageID(stage_id)

    -- 고대의 탑 모드
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        ret = g_ancientTowerData:getSimplePrevStageID(stage_id)

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
function ServerData_Stage:requestGameStart(stage_id, deck_name, combat_power, finish_cb)
    local uid = g_userData:get('uid')
    local oid

    -- 모드별 API 주소 분기처리
    local api_url = ''
    local game_mode = g_stageData:getGameMode(stage_id)
    if (game_mode == GAME_MODE_ADVENTURE) then
        api_url = '/game/stage/start'
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        api_url = '/game/nest/start'
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        api_url = '/game/secret/start'

        -- 던전 objectId
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        oid = t_dungeon_info['id']
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        api_url = '/game/ancient/start'
    end

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)

        -- 핫타임 정보 저장
        g_hotTimeData:setIngameHotTimeList(game_key, ret['hottime'])
    end

    local friend_uid = nil
    if g_friendData.m_selectedShareFriendData then
        friend_uid = g_friendData.m_selectedShareFriendData.m_uid
    end

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('deck_name', deck_name)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('friend', friend_uid)
    ui_network:setParam('oid', oid)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function requestStageInfo
-------------------------------------
function ServerData_Stage:requestStageInfo(stage_id, finish_cb)
    local uid = g_userData:get('uid')
    
	local api_url = '/game/stage/info'

    local function success_cb(ret)
		if (finish_cb) then
			finish_cb(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function getStageCategoryStr
-- @brief
-------------------------------------
function ServerData_Stage:getStageCategoryStr(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getStageCategoryStr(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getStageCategoryStr(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getStageCategoryStr(stage_id)
    end

    return ret
end

-------------------------------------
-- function getMonsterIDList
-- @brief
-------------------------------------
function ServerData_Stage:getMonsterIDList(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 비밀 던전 모드
    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        -- 현재는 이전에 선택된 스테이지의 정보를 리턴함
        -- 던전 고유 아이디값이 필요
        ret = g_secretDungeonData:getMonsterIDList(stage_id)

    else
        local table_stage_desc = TableStageDesc()
        if (not table_stage_desc:get(stage_id)) then
            return {}
        end

        ret = table_stage_desc:getMonsterIDList(stage_id)
    end

    return ret
end

-------------------------------------
-- function goToStage
-------------------------------------
function ServerData_Stage:goToStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    if (self:isOpenStage(stage_id) == false) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('아직은 진입할 수 없습니다.'))
        return
    end

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        g_adventureData:goToAdventureScene(stage_id)
        
    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        g_nestDungeonData:goToNestDungeonScene(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        g_secretDungeonData:goToSecretDungeonScene(stage_id)
    end
end

-------------------------------------
-- function getNumOfStarsAchieved
-------------------------------------
function ServerData_Stage:getNumOfStarsAchieved(stage_id)
    local game_mode = self:getGameMode(stage_id)


end