-------------------------------------
-- class ServerData_AncientRuin
-------------------------------------
ServerData_AncientRuin = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AncientRuin:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function isOpenAncientRuin
-- @brief 고대 유적 던전의 경우 서버에서 받은 값으로 오픈 처리
-------------------------------------
function ServerData_AncientRuin:isOpenAncientRuin()
    local mode_id = 1650100
    local t_dungeon = g_nestDungeonData:getNestDungeonInfoIndividual(mode_id)
    if (not t_dungeon) then
        return false
    end

    local is_open = (t_dungeon['is_open'] == 1) and true or false
    return is_open
end

-------------------------------------
-- function isOpenStage
-- @brief
-------------------------------------
function ServerData_AncientRuin:isOpenStage(stage_id)
    return g_nestDungeonData:isOpenStage(stage_id)
end
-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_AncientRuin:getStageName(stage_id)
    return g_nestDungeonData:getStageName(stage_id)
end

-------------------------------------
-- function getSimplePrevStageID
-------------------------------------
function ServerData_AncientRuin:getSimplePrevStageID(stage_id)
    return g_nestDungeonData:getSimplePrevStageID(stage_id)
end

-------------------------------------
-- function getNextStageID
-------------------------------------
function ServerData_AncientRuin:getNextStageID(stage_id)
    return g_nestDungeonData:getNextStageID(stage_id)
end

-------------------------------------
-- function requestGameStart
-------------------------------------
function ServerData_AncientRuin:requestGameStart(stage_id, deck_name, combat_power, finish_cb)
    local uid = g_userData:get('uid')
    local api_url = '/game/ruin/start'

    -- 응답 상태 처리 함수
    local t_error = {
        [-1371] = Str('유효하지 않은 던전입니다.'), 
    }
    local response_status_cb = MakeResponseCB(t_error)

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)

        -- 스피드핵 방지 실제 플레이 시간 기록
        g_accessTimeData:startCheckTimer()

        -- 온전한 연속 전투 검사
        g_autoPlaySetting:setSequenceAutoPlay()
    end

    local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN)
    local deck_name1 = multi_deck_mgr:getDeckName('up')
    local deck_name2 = multi_deck_mgr:getDeckName('down')
    local token1 = g_stageData:makeDragonToken(deck_name1)
    local token2 = g_stageData:makeDragonToken(deck_name2)
    local teambonus1 = g_stageData:getTeamBonusIds(deck_name1)
    local teambonus2 = g_stageData:getTeamBonusIds(deck_name2)

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('deck_name1', deck_name1)
    ui_network:setParam('deck_name2', deck_name2)
    ui_network:setParam('token1', token1)
    ui_network:setParam('token2', token2)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('team_bonus1', teambonus1)
    ui_network:setParam('team_bonus2', teambonus2)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end