ANCIENT_TOWER_STAGE_ID_START = 1401000

ANCIENT_TOWER_MAX_DEBUFF_LEVEL = 5

-------------------------------------
-- class ServerData_AncientTower
-------------------------------------
ServerData_AncientTower = class({
        m_serverData = 'ServerData',

        m_challengingInfo   = 'StructAncientTowerFloorData',
        m_challengingStageID= 'number',     -- 현재 진행중인 층의 스테이지 아이디
        m_challengingFloor  = 'number',     -- 현재 진행중인 층    
        m_challengingCount  = 'number',     -- 도전 횟수

        m_lStage            = 'table',
        m_nStage            = 'number',
        m_endTime           = 'number',

        m_lGlobalRank       = 'list',       -- 상위 20명 랭킹
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AncientTower:init(server_data)
    self.m_serverData = server_data
    self.m_lStage = nil
    self.m_nStage = 0
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_AncientTower:getNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        return stage_id + 1
    else
        return nil
    end
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_AncientTower:getStageName(stage_id)
    local floor = self:getFloorFromStageID(stage_id)

    local name = Str('고대의 탑 {1}층', floor)
    return name
end

-------------------------------------
-- function goToAncientTowerScene
-------------------------------------
function ServerData_AncientTower:goToAncientTowerScene()
    local function finish_cb()
        UI_AncientTowerScene()
        --local scene = SceneAncientTower()
        --scene:runScene()
    end

    local function fail_cb()

    end
    
    self:request_ancientTowerInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function request_ancientTowerInfo
-------------------------------------
function ServerData_AncientTower:request_ancientTowerInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        
        local t_challenging_info = ret['ancient_stage']

        self.m_challengingInfo = StructAncientTowerFloorData(t_challenging_info)
        self.m_challengingStageID = t_challenging_info['stage']
        self.m_challengingFloor = (self.m_challengingStageID % ANCIENT_TOWER_STAGE_ID_START)
        self.m_challengingCount = t_challenging_info['fail_cnt']
        self.m_endTime = ret['end_time']

        if (not self.m_lStage) then
            self.m_lStage = self:makeAcientTower_stageList()
            self.m_nStage = table.count(self.m_lStage)
        end

         if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_ancientTowerFloorInfo
-------------------------------------
function ServerData_AncientTower:request_ancientTowerFloorInfo(stage, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_ancientTowerRank
-------------------------------------
function ServerData_AncientTower:request_ancientTowerRank(offset, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 1

    -- 콜백 함수
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if (offset == 1) then
            self.m_lGlobalRank = ret['list']
        end

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/ancient/rank')
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function makeAcientTower_stageList
-------------------------------------
function ServerData_AncientTower:makeAcientTower_stageList()
    local table_drop = TableDrop()

    local function condition_func(t_table)
        local stage_id = t_table['stage']
        local game_mode = g_stageData:getGameMode(stage_id)
        return (game_mode == GAME_MODE_ANCIENT_TOWER)
    end

    -- 테이블에서 조건에 맞는 테이블만 리턴
    local l_stage_list = table_drop:filterTable_condition(condition_func)

    -- stage(stage_id) 순서로 정렬
    local function sort_func(a, b)
        return a['stage'] < b['stage']
    end
    table.sort(l_stage_list, sort_func)

    return l_stage_list
end

-------------------------------------
-- function getAcientTower_stageList
-------------------------------------
function ServerData_AncientTower:getAcientTower_stageList()
    return self.m_lStage
end

-------------------------------------
-- function getAcientTower_stageCount
-------------------------------------
function ServerData_AncientTower:getAcientTower_stageCount()
    return self.m_nStage
end

-------------------------------------
-- function getChallengingStageID
-- @brief 현재 도전중인 스테이지 아이디를 얻음
-------------------------------------
function ServerData_AncientTower:getChallengingStageID()
    return self.m_challengingStageID
end

-------------------------------------
-- function getTopStageID
-------------------------------------
function ServerData_AncientTower:getTopStageID()
    return (self.m_nStage + ANCIENT_TOWER_STAGE_ID_START)
end

-------------------------------------
-- function getChallengingFloor
-- @brief 현재 도전중인 층을 얻음
-------------------------------------
function ServerData_AncientTower:getChallengingFloor()
    return self.m_challengingFloor
end

-------------------------------------
-- function getChallengingCount
-- @brief 도전 횟수를 얻음
-------------------------------------
function ServerData_AncientTower:getChallengingCount()
    return self.m_challengingCount
end

-------------------------------------
-- function isOpenStage
-- @brief stage_id에 해당하는 스테이지가 입장 가능한지를 리턴
-------------------------------------
function ServerData_AncientTower:isOpenStage(stage_id)
    local is_open = (stage_id <= self.m_challengingStageID)
    return is_open
end

-------------------------------------
-- function getFloorFromStageID
-- @brief stage_id로부터 해당 층 수를 얻음
-------------------------------------
function ServerData_AncientTower:getFloorFromStageID(stage_id)
    return (stage_id % 1000)
end

-------------------------------------
-- function getStageIDFromFloor
-- @brief 층수로부터 stage_id를 얻음
-------------------------------------
function ServerData_AncientTower:getStageIDFromFloor(floor)
    return (ANCIENT_TOWER_STAGE_ID_START + floor)
end

-------------------------------------
-- function getEnemyDeBuffValue
-- @brief 현재 도전 횟수에 따른 적 디버프값을 얻음
-------------------------------------
function ServerData_AncientTower:getEnemyDeBuffValue()
    local count = self:getChallengingCount()
    
    local t_info = g_constant:get('INGAME', 'ANCIENT_TOWER_VALUE')

    for i = 5, 1, -1 do
        if (t_info['buff_' .. i .. '_count'] <= count) then
            return t_info['buff_' .. i .. '_rate']
        end
    end
    
    return 0
end

-------------------------------------
-- function getEndTimeText
-- @breif 시즌 남은 시간
-------------------------------------
function ServerData_AncientTower:getEndTimeText()
    local server_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local showSeconds = false
    local time_text = datetime.makeTimeDesc((end_time - server_time), showSeconds)
    local text = Str('{1} 후 초기화', time_text)
    return text
end
