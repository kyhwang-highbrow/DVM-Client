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
   
    -- 외부에서 정보 갱신 필요할 경우 사용
    g_masterRoadData.m_bDirtyMasterRoad = true
end

-------------------------------------
-- function getFocusRoad
-- @brief 현재 진행중인 퀘스트
-------------------------------------
function ServerData_MasterRoad:getFocusRoad()
    local road = self.m_focusRoad
    local last_road = TableMasterRoad:getLastRoad()

    return math_min(road, last_road)
end

-------------------------------------
-- function getDisplayRoad
-- @brief 보상 여부에 따라 바뀌는 UI 노출위한 road 반환
-------------------------------------
function ServerData_MasterRoad:getDisplayRoad()
    local has_reward, rid = self:hasRewardRoad()
    if (has_reward) then
        return rid
    else
        return self:getFocusRoad()
    end
end

-------------------------------------
-- function getRoadIdx
-------------------------------------
function ServerData_MasterRoad:getRoadIdx(rid)
    return math_max(1, rid - 10000)
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
    local last_rid = 0
    for rid, is_reward in pairs(self.m_tRewardInfo) do
        if (is_reward == 1) then
            rid = tonumber(rid)
            if (rid > last_rid) then
                last_rid = rid
            end
        end
    end

    -- 위의 계산을 통해서 last_rid가 0이라면 보상이 하나도 없는 것을 알 수 있다.
    return (last_rid ~= 0), last_rid
end

-------------------------------------
-- function updateMasterRoad
-- @brief 매프레임 도는 것이 아님
-------------------------------------
function ServerData_MasterRoad:updateMasterRoad(t_data, cb_func)
    -- 클리어 체크
    if (self:checkFocusRoadClear(t_data)) then
        local function open_ui()
            UI_MasterRoadPopup()
        end
        self:request_roadClear(self.m_focusRoad, open_ui)
        return true
    end
    return false
end

-------------------------------------
-- function checkFocusRoadClear
-------------------------------------
function ServerData_MasterRoad:checkFocusRoadClear(t_data)
    local rid = self:getFocusRoad()
    local t_road = TableMasterRoad():get(rid)
    
    local clear_type = t_road['clear_type']
    local clear_cond = t_road['clear_value']
    ccdump({t_road, t_data})
    local is_clear = self:checkClear(clear_type, clear_cond, t_data)
    return is_clear
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
-- @brief 클리어 요청
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
-- @brief 보상 요청
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




-------------------------------------
-- function checkClear
-------------------------------------
function ServerData_MasterRoad:checkClear(clear_type, clear_cond, t_data)
    if (not clear_type) then
        return false
    end

    -- stage clear
    if (clear_type == 'clr_stg') then
        local stage_id = clear_cond
        local stage_info = g_adventureData:getStageInfo(stage_id)
        return (stage_info['clear_cnt'] > 0)

    -- 고대의 탑 플레이
    elseif (clear_type == 'ply_tower') then
        local game_mode = t_data['game_mode']
        return (game_mode == GAME_MODE_ANCIENT_TOWER)

    -- 콜로세움 플레이
    elseif (clear_type == 'ply_clsm') then
        local game_mode = t_data['game_mode']
        return (game_mode == GAME_MODE_COLOSSEUM)

    -- 공통 진화 던전 플레이
    elseif (clear_type == 'ply_ev') then
        local dungeon_mode = t_data['dungeon_mode']
        return (game_mode == NEST_DUNGEON_EVO_STONE)

    -- 거목 던전 플레이
    elseif (clear_type == 'ply_tree') then
        local dungeon_mode = t_data['dungeon_mode']
        return (game_mode == NEST_DUNGEON_TREE)

    -- 악몽 던전 플레이
    elseif (clear_type == 'ply_nm') then
        local dungeon_mode = t_data['dungeon_mode']
        return (game_mode == NEST_DUNGEON_NIGHTMARE)

    -- 룬 강화
    elseif (clear_type == 'r_enc') then
        local rune_lv = clear_cond
        return (clear_type == t_data['road_key']) and (rune_lv <= t_data['road_value'])

    --[[

    -- 유저 레벨 달성
    elseif (clear_type == 'u_lv') then

    -- 친구 n명 달성
    elseif (clear_type == 'make_frd') then

    -- 드래곤 진화
    elseif (clear_type == 'd_evup') then
    
    -- 드래곤 스킬 레벨 업
    elseif (clear_type == 'd_sklvup') then

    -- 테이머 겟
    elseif (clear_type == 't_get') then

    -- 테이머 스킬 레벨 업
    elseif (clear_type == 't_sklvup') then
    ]]

    -- 룬 장착
    -- 알 부화
    -- 친밀도 과일 먹임
        -- 드래곤 레벨업
        -- 드래곤 등급업

    else
        return (clear_type == t_data['road_key'])

    end

    return false
end

