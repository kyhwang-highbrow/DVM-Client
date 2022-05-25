-------------------------------------
-- 2017-07-06 sgkim
-- 탐험 메인 UI   UI_Exploration                (exploration_map.ui)
-- 탐험 지역 버튼 UI_ExplorationLocationButton
-- 탐험 준비 UI   UI_ExplorationReady           (exploration_ready.ui)
-- 탐험 중 UI     UI_ExplorationIng             (exploration_ing.ui)
-- 탐험 결과 UI   UI_ExplorationResultPopup     (exploration_result.ui)
-------------------------------------

-------------------------------------
-- class ServerData_Exploration
-------------------------------------
ServerData_Exploration = class({
        m_serverData = 'ServerData',
        m_bDirtyExplorationInfo = 'boolean',
        
        -- 유저의 탐험 정보
        m_myExplorationList = 'table', -- 나의 진행 중인 탐험 정보

        -- 탐험에 사용 중인 드래곤들 object id 저장
        m_mExploredDragonOid = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Exploration:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyExplorationInfo = true
    self.m_mExploredDragonOid = {}
end

-------------------------------------
-- function setDirty
-- @brief
-------------------------------------
function ServerData_Exploration:setDirty()
    self.m_bDirtyExplorationInfo = true
end

-------------------------------------
-- function ckechUpdateExplorationInfo
-- @brief 탐험 정보가 갱신되어야하는지 여부를 확인
-------------------------------------
function ServerData_Exploration:ckechUpdateExplorationInfo()
    if self.m_bDirtyExplorationInfo then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    self:setDirty()
end


-------------------------------------
-- function request_explorationInfo
-------------------------------------
function ServerData_Exploration:request_explorationInfo(finish_cb, fail_cb)
    -- 탐험 정보가 갱신되어야하는지 여부를 확인
    self:ckechUpdateExplorationInfo()

    -- 갱신할 필요가 없으면 즉시 리턴
    if (self.m_bDirtyExplorationInfo == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:organizeData(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/explore/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function organizeData
-------------------------------------
function ServerData_Exploration:organizeData(ret)
    -- 유저의 탐험 정보
    self.m_myExplorationList = {}
    self.m_mExploredDragonOid = {}

    if ret['epr_my_info']['explor_list'] then    
        for i,v in ipairs(ret['epr_my_info']['explor_list']) do
            local epr_id = v['epr_id']
            self.m_myExplorationList[epr_id] = v

            -- 탐험에 사용 중인 드래곤들 object id 저장
            for _,doid in ipairs(v['doid_list']) do
                self.m_mExploredDragonOid[doid] = true
            end
        end
    end

    self.m_bDirtyExplorationInfo = false
end

-------------------------------------
-- function getExplorationLocationInfo
-------------------------------------
function ServerData_Exploration:getExplorationLocationInfo(epr_id)
    local table_exploration_list = TableExplorationList()

    local location_info = table_exploration_list:get(epr_id)
    local my_location_info = self.m_myExplorationList[epr_id]

    local status
    local tamer_level = g_userData:get('lv')
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 잠금 상태
    if (tamer_level < location_info['open_condition']) then
        status = 'exploration_lock'

    -- 진행 중인 탐험일 경우
    elseif my_location_info then
        -- 탐험 완료
        if (my_location_info['end_time']/1000 <= server_time) then
            status = 'exploration_complete'
        -- 진행 중
        else
            status = 'exploration_ing'
        end
    -- 대기 상태
    else
        status = 'exploration_idle'
    end
    


    return location_info, my_location_info, status
end

-------------------------------------
-- function getDragonList
-------------------------------------
function ServerData_Exploration:getDragonList()
    local l_dragon_list = g_dragonsData:getDragonsList()
    return l_dragon_list
end

-------------------------------------
-- function isExplorationUsedDragon
-------------------------------------
function ServerData_Exploration:isExplorationUsedDragon(doid)
    local ret = self.m_mExploredDragonOid[doid]
    return ret
end

-------------------------------------
-- function request_explorationStart
-------------------------------------
function ServerData_Exploration:request_explorationStart(epr_id, doids, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        local desc = TableExplorationList():get(epr_id)['t_name']
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_EXP, 1, desc)

        self:organizeData(ret)

        -- 추후에 드래곤의 lock값이 필요해질때 사용
        -- ret['modified_dragons']

        -- @ MASTER ROAD
        local t_data = {clear_key = 'ply_epl'}
        g_masterRoadData:updateMasterRoad(t_data)
        
        -- @ GOOGLE ACHIEVEMENT
        GoogleHelper.updateAchievement(t_data)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/explore/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
    ui_network:setParam('epr_id', epr_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_explorationCancel
-------------------------------------
function ServerData_Exploration:request_explorationCancel(epr_id, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:organizeData(ret)

        -- 추후에 드래곤의 lock값이 필요해질때 사용
        -- ret['modified_dragons']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/explore/cancel')
    ui_network:setParam('uid', uid)
    ui_network:setParam('epr_id', epr_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_explorationImmediatelyComplete
-- @brief 즉시 완료
-------------------------------------
function ServerData_Exploration:request_explorationImmediatelyComplete(epr_id, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '탐험 즉시 완료')

        local desc = TableExplorationList():get(epr_id)['t_name']
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.CLR_EXP, 1, desc)

        local before_dragons = {}
        for i,v in pairs(ret['modified_dragons']) do
            local doid = v['id']
            table.insert(before_dragons, g_dragonsData:getDragonDataFromUid(doid))
        end
        ret['before_dragons'] = before_dragons

        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData_list(ret['modified_dragons'])

        self:organizeData(ret)

        -- 추후에 드래곤의 lock값이 필요해질때 사용
        -- ret['modified_dragons'] b

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/explore/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('epr_id', epr_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_explorationReward
-- @brief 탐험 보상 받기
-------------------------------------
function ServerData_Exploration:request_explorationReward(epr_id, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '탐험 완료')

        local before_dragons = {}
        for i,v in pairs(ret['modified_dragons']) do
            local doid = v['id']
            table.insert(before_dragons, g_dragonsData:getDragonDataFromUid(doid))
        end
        ret['before_dragons'] = before_dragons

        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData_list(ret['modified_dragons'])

        self:organizeData(ret)

        -- 추후에 드래곤의 lock값이 필요해질때 사용
        -- ret['modified_dragons']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/explore/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('epr_id', epr_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getPushTimeList
-------------------------------------
function ServerData_Exploration:getPushTimeList()
    local t_ret = {}
    
    if (self.m_myExplorationList) then
        local table_exploration_list = TableExplorationList()
        for i, t_epr in pairs(self.m_myExplorationList) do
            local left_sec = math_floor(t_epr['end_time']/1000 - ServerTime:getInstance():getCurrentTimestampSeconds())
            local name = table_exploration_list:get(t_epr['epr_id'])['t_name']
            table.insert(t_ret, {time = left_sec, name = name})
        end
    end

    return t_ret
end

-------------------------------------
-- function isExploring
-- @brief 탐험중인 지역이 있다면 true
-------------------------------------
function ServerData_Exploration:isExploring()
    -- 아예 탐험 중인게 하나도 없음
    if (table.count(self.m_myExplorationList) == 0) then
        return false
    end

    local end_time
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    for i, t_epr in pairs(self.m_myExplorationList) do
        end_time = (t_epr['end_time'] / 1000)
        if (end_time - server_time) > 0 then
            -- 탐험 중이고 하나라도 남은 시간이 있는 경우
            return true
        end
    end

    -- 탐험 중이지만 하나도 남은 시간이 없는 경우
    return false
end