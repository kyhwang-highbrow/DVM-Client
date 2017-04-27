ANCIENT_TOWER_STAGE_ID_START = 1401000

-------------------------------------
-- class ServerData_AncientTower
-------------------------------------
ServerData_AncientTower = class({
        m_serverData = 'ServerData',

        m_floor     = 'number',     -- 현재 진행중인 층    
        m_stageID   = 'number',     -- 현재 진행중인 층의 스테이지 아이디
        m_failCount = 'number',     -- 현재 진행중인 층에서 실패 횟수
        m_sweepInfo = 'number',     -- 소탕사용시의 스테이지 아이디(0이라면 아직 소탕을 사용 안한 경우)
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_AncientTower:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function goToAncientTowerScene
-------------------------------------
function ServerData_AncientTower:goToAncientTowerScene()
    local function finish_cb()
        local scene = SceneAncientTower()
        scene:runScene()
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

        self.m_stageID = ret['ancient_stage']
        self.m_failCount = ret['fail_cnt']
        self.m_sweepInfo = ret['sweep_info']

        -- 현재 진행중인 층을 얻어서 저장
        self.m_floor = (self.m_stageID % ANCIENT_TOWER_STAGE_ID_START)

        --ccdump('request_ancientTowerInfo ret = ' .. luadump(ret))
        
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
-- function isOpenStage
-- @brief stage_id에 해당하는 스테이지가 입장 가능한지를 리턴
-------------------------------------
function ServerData_AncientTower:isOpenStage(stage_id)
    local is_open = (stage_id <= self.m_stageID)

    return is_open
end