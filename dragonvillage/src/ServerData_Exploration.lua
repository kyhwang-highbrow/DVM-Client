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
-- function ckechUpdateExplorationInfo
-- @brief 탐험 정보가 갱신되어야하는지 여부를 확인
-------------------------------------
function ServerData_Exploration:ckechUpdateExplorationInfo()
    if self.m_bDirtyExplorationInfo then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    -- self.m_bDirtyExplorationInfo = true
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
        self.m_bDirtyExplorationInfo = false

        local ret = TABLE:loadJsonTable('temp_exploration_info')

        -- 탐험 각종 설정 정보
        self.m_explorationServerInfo = ret['exploration_server_info']

        -- 탐험 정보 리스트
        if ret['exploration_list'] then
            self.m_explorationList = {}
            for i,v in ipairs(ret['exploration_list']) do
                local epr_id = v['epr_id']
                self.m_explorationList[epr_id] = v
            end
        end

        -- 유저의 탐험 정보
        self.m_immediatelyCompleteCnt = ret['exploration_my_info']['immediately_complete_cnt']
        if ret['exploration_my_info']['explorationing_list'] then
            self.m_myExplorationList = {}
            self.m_mExploredDragonOid = {}
            for i,v in ipairs(ret['exploration_my_info']['explorationing_list']) do
                local epr_id = v['epr_id']
                self.m_myExplorationList[epr_id] = v

                -- 탐험에 사용 중인 드래곤들 object id 저장
                for _,doid in ipairs(v['doid_list']) do
                    self.m_mExploredDragonOid[doid] = true
                end
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/get_patch_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('app_ver', '0.0.0')
    ui_network:setMethod('GET') -- 임시로 패치 인포 통신을 사용하기 위해 get으로 설정
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
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
        status = 'lock'

    -- 진행 중인 탐험일 경우
    elseif my_location_info then
        -- 보상 받기
        if (my_location_info['end_time']/1000 <= server_time) then
            status = 'reward'
        -- 진행 중
        else
            status = 'ing'
        end
    -- 대기 상태
    else
        status = 'idle'
    end
    


    return location_info, my_location_info, status
end