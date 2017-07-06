-------------------------------------
-- class ServerData_MasterRoad
-------------------------------------
ServerData_MasterRoad = class({
        m_serverData = 'ServerData',
        m_focusRoad = 'number',
        m_tRewardInfo = 'table',

        m_bDirtyMasterRoad = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_MasterRoad:init(server_data)
    self.m_serverData = server_data
    self.m_tRewardInfo = {}
end

-------------------------------------
-- function applyInfo
-- @brief 정보 갱신하기
-------------------------------------
function ServerData_MasterRoad:applyInfo(ret)
    if (ret['reward_info']) then
        self.m_tRewardInfo = ret['reward_info']
    end
    if (ret['focus_road']) then
        self.m_focusRoad = ret['focus_road']
    end
end

-------------------------------------
-- function getFocusRoad
-------------------------------------
function ServerData_MasterRoad:getFocusRoad()
    local road = self.m_focusRoad
    local last_road = TableMasterRoad:getLastRoad()

    return math_min(road, last_road)
end

-------------------------------------
-- function getFocusRoad
-------------------------------------
function ServerData_MasterRoad:checkFocusRoadClear()
    local rid = self:getFocusRoad()
    local t_road = TableMasterRoad():get(rid)
    
    local clear_type = t_road['clear_type']
    local clear_cond = t_road['clear_value']

    local is_clear = self:checkClear(clear_type, clear_cond)
    return is_clear
end

-------------------------------------
-- function getFocusRoad
-------------------------------------
function ServerData_MasterRoad:checkClear(clear_type, clear_cond)
    if (not clear_type) then
        return false
    end

    if (clear_type == 'clr_stg') then
        local stage_id = clear_cond
        local stage_info = g_adventureData:getStageInfo(stage_id)
        return (stage_info['clear_cnt'] > 0)

    elseif (clear_type == 'ply_tower') then
    elseif (clear_type == 'ply_ev') then
    elseif (clear_type == 'ply_tree') then

    elseif (clear_type == 'ply_nm') then
    elseif (clear_type == 'ply_clsm') then
    elseif (clear_type == 'r_eq') then
    elseif (clear_type == 'r_enc') then
    elseif (clear_type == 'd_lvup') then
    elseif (clear_type == 'd_grup') then

    elseif (clear_type == 'd_evup') then
    
    elseif (clear_type == 'd_sklvup') then
    elseif (clear_type == 't_get') then

    elseif (clear_type == 't_sklvup') then

    elseif (clear_type == 'u_lv') then

    elseif (clear_type == 'egg') then

    elseif (clear_type == 'fruit') then

    elseif (clear_type == 'make_frd') then

    end

    return false
end


















-------------------------------------
-- function getRewardState
-- @brief 해당 road의 보상 현황 리턴

-------------------------------------
function ServerData_MasterRoad:getRewardState(rid)
    local reward_state
    local reward_info = self.m_tRewardInfo[tostring(rid)]

    -- 보상 있음
    if (reward_info == 1) then
        reward_state = 'has_reward'
    
    -- 정보가 없다면
    elseif (reward_info == nil) then
        -- 현재 road보다 후순의 road라면 아직 클리어하지 않은것
        if (self.m_focusRoad <= rid) then
            reward_state = 'not_yet'

        -- 현재 road 이전의 road라면 이미 클리어한 것
        else
            reward_state = 'already_done'
        end
    end

    return reward_state 
end

-------------------------------------
-- function hasRewardRoad
-- @brief 보상 여부 판별
-------------------------------------
function ServerData_MasterRoad:hasRewardRoad()
    for rid, is_reward in pairs(self.m_tRewardInfo) do
        if (is_reward == 1) then
            return true
        end
    end
    return false
end

-------------------------------------
-- function updateMasterRoad
-- @brief 매프레임 도는 것이 아님
-------------------------------------
function ServerData_MasterRoad:updateMasterRoad(cb_func)
    -- 클리어 체크
    if (self:checkFocusRoadClear()) then
        self:request_roadClear(self.m_focusRoad, cb_func)
        return true
    end
    return false
end









-------------------------------------
-- function request_roadInfo
-- @brief 전체 정보 받아오기
-------------------------------------
function ServerData_MasterRoad:request_roadInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:applyInfo(ret)


        if (finish_cb) then
            finish_cb()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/master_road/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
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
        self:applyInfo(ret)

        if (finish_cb) then
            finish_cb()
        end
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
        self:applyInfo(ret)

        -- 재화 수령 처리
        self.m_serverData:networkCommonRespone(ret)
		
		-- 탑바 갱신
		g_topUserInfo:refreshData()

        if (finish_cb) then
            finish_cb()
        end
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