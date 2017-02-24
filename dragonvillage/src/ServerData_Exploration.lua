-------------------------------------
-- class ServerData_Exploration
-------------------------------------
ServerData_Exploration = class({
        m_serverData = 'ServerData',
        m_bDirtyExplorationInfo = 'boolean',

        m_explorationServerInfo = 'table', -- 탐험 각종 설정 정보
        m_explorationList = 'table', -- 탐험 정보 리스트
        
        -- 유저의 탐험 정보
        m_immediatelyCompleteCnt = 'cnumber', -- 오늘 즉시 완료를 한 숫자
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
function ServerData_Exploration:request_explorationInfo(finish_cb)
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
        -- 탐험 각종 설정 정보
        self.m_explorationServerInfo = ret['epr_server_info']

        -- 탐험 정보 리스트
        if ret['epr_list'] then
            local to_number_list = {}
            table.insert(to_number_list, 'epr_id')
            table.insert(to_number_list, 'order')
            table.insert(to_number_list, 'open_condition')
            table.insert(to_number_list, '1_hours_items_cnt')
            table.insert(to_number_list, '4_hours_items_cnt')
            table.insert(to_number_list, '6_hours_items_cnt')
            table.insert(to_number_list, '12_hours_items_cnt')
            table.insert(to_number_list, '1_hours_exp')
            table.insert(to_number_list, '4_hours_exp')
            table.insert(to_number_list, '6_hours_exp')
            table.insert(to_number_list, '12_hours_exp')
            ret['epr_list'] = table.toNumber(ret['epr_list'], to_number_list)

            self.m_explorationList = {}
            for i,v in ipairs(ret['epr_list']) do
                local epr_id = v['epr_id']
                self.m_explorationList[epr_id] = v
            end
        end

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
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function organizeData
-------------------------------------
function ServerData_Exploration:organizeData(ret)
    -- 유저의 탐험 정보
    self.m_immediatelyCompleteCnt = ret['epr_my_info']['immediately_complete_cnt']

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
    local location_info = self.m_explorationList[epr_id]
    local my_location_info = self.m_myExplorationList[epr_id]

    local status
    local tamer_level = g_userData:get('lv')
    local server_time = Timer:getServerTime()

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
function ServerData_Exploration:request_explorationStart(epr_id, doids, hours, finish_cb)
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
    ui_network:setUrl('/explore/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
    ui_network:setParam('hours', hours)
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
-- function getImmediatelyCompleteCash
-- @brief 즉시 완료에 필요한 자수정 (탐험 시간 별)
-------------------------------------
function ServerData_Exploration:getImmediatelyCompleteCash(hours)
    local key = tostring(hours) .. '_hours_Immediately_complete_cash'
    local cash = self.m_explorationServerInfo[key]
    return cash
end

-------------------------------------
-- function getImmediatelyCompleteDailyLimit
-- @brief 일일 즉시 완료 제한 횟수
-------------------------------------
function ServerData_Exploration:getImmediatelyCompleteDailyLimit()
    return self.m_explorationServerInfo['immediately_complete_daily_limit']
end

-------------------------------------
-- function getImmediatelyCompleteCnt
-- @brief 일일 즉시 완료 횟수
-------------------------------------
function ServerData_Exploration:getImmediatelyCompleteCnt()
    return self.m_immediatelyCompleteCnt
end