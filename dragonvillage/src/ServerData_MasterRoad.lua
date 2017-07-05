-------------------------------------
-- class ServerData_MasterRoad
-------------------------------------
ServerData_MasterRoad = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_MasterRoad:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_roadInfo
-- @brief 전체 정보 받아오기
-------------------------------------
function ServerData_MasterRoad:request_roadInfo(finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/master_road/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_roadClear
-- @brief 전체 정보 받아오기
-------------------------------------
function ServerData_MasterRoad:request_roadClear(rid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/master_road/clear')
    ui_network:setParam('uid', uid)
    ui_network:setParam('rid', rid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_roadReward
-- @brief 전체 정보 받아오기
-------------------------------------
function ServerData_MasterRoad:request_roadReward(rid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/master_road/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('rid', rid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end