-------------------------------------
-- class ServerData_MasterRoad
-------------------------------------
ServerData_MasterRoad = class({
        m_serverData = 'ServerData',
        m_focusRoad = 'number',
        m_tRewardInfo = 'table',
        
        -- 서버 검증을 위한..
        m_tRawData = 'table',

        m_bDirtyMasterRoad = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_MasterRoad:init(server_data)
    self.m_serverData = server_data
    self.m_tRewardInfo = {}
    self.m_tRawData = {}
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
    if (ret['raw_data']) then
        self.m_tRawData = ret['raw_data']
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
    return math_max(1, rid - TableMasterRoad():getRoadIdxStandard(rid))
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

    -- 실제 마지막 미션과 비교
    local real_last_road = TableMasterRoad:getLastRoad()
    if (last_rid > real_last_road) then
		last_rid = 0
	end

    -- 위의 계산을 통해서 last_rid가 0이라면 보상이 하나도 없는 것을 알 수 있다.
    return (last_rid ~= 0), last_rid
end

-------------------------------------
-- function isClearedRoad
-- @brief 해당 마스터의길이 이미 클리어한건지 여부 (튜토리얼 사용)
-------------------------------------
function ServerData_MasterRoad:isClearedRoad(rid)	
	-- 보상이 있다면 클리어한 것
	if (self.m_tRewardInfo[tostring(rid)]) then
		return true
	end

	-- focus가 더 크다면 클리어한것
	local focus_road = self.m_focusRoad
	return (focus_road > rid) 
end

-------------------------------------
-- function isClearAllRoad
-- @brief 마지막 마스터의길까지 클리어했는지 여부
-------------------------------------
function ServerData_MasterRoad:isClearAllRoad()
    local last_road = TableMasterRoad:getLastRoad()
    local focus_road = self.m_focusRoad 

    return (last_road < focus_road)
end

-------------------------------------
-- function addRawData
-------------------------------------
function ServerData_MasterRoad:addRawData(raw_key)
    self.m_tRawData[raw_key] = self.m_tRawData[raw_key] + 1
end



-------------------------------------
-- function updateMasterRoad
-- @brief 매프레임 도는 것이 아님
-- @return bool, UI_Network
-------------------------------------
function ServerData_MasterRoad:updateMasterRoad(t_data, cb_func)
    -- 클리어 체크
    if (self:checkFocusRoadClear(t_data)) then
        local function after_func()
            if (cb_func) then   
                cb_func(true) -- UI_GameResultNew에서 클리어 여부를 받아간다
            else
                UI_MasterRoadPopup_Link()
            end
        end
        local ui_network = self:request_roadClear(self.m_focusRoad, after_func)
        return true, ui_network

	else
		if (cb_func) then
			cb_func(false)
		end
		return false, nil

    end
end

-------------------------------------
-- function updateMasterRoadAfterReward
-- @brief 보상 수령 후에 기본 항목 체크
-------------------------------------
function ServerData_MasterRoad:updateMasterRoadAfterReward(cb_func)
    for _, key in pairs({'t_get', 'make_frd', 'u_lv', 'd_evup', 'd_sklvup', 'd_grup', 'clr_stg'}) do

        local t_data = {['clear_key'] = key}
        if (self:checkFocusRoadClear(t_data)) then
            local ui_network = self:request_roadClear(self.m_focusRoad, cb_func)
            return true, ui_network
        end

    end

    if cb_func then
        cb_func()
    end

    return false, nil
end

-------------------------------------
-- function checkFocusRoadClear
-------------------------------------
function ServerData_MasterRoad:checkFocusRoadClear(t_data)
    -- 모두 클리어한 경우 
    if (self:isClearAllRoad()) then
        return false
    end

    local rid = self.m_focusRoad
    -- 이미 클리어하여 보상이 있는 경우
    if (self.m_tRewardInfo[tostring(rid)] == 1) then
        return false
    end
	-- focusRoad는 서버에서 테이블에 없는 값까지 주기 때문에 검증
	if (rid > TableMasterRoad:getLastRoad()) then
		return false
	end

    local t_road = TableMasterRoad():get(rid)
    
    local clear_type = t_road['clear_type']
    local clear_cond = t_road['clear_value']
    local raw_data = self.m_tRawData

    local is_clear = self.checkClear(clear_type, clear_cond, t_data, raw_data)
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

		-- 노티 정보를 갱신하기 위해서 호출
		g_highlightData:setDirty(true)

        if (finish_cb) then
            finish_cb()
        end 
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/master_road/clear')
    --ui_network:setLoadingMsg(Str('마스터의 길 확인 중...'))
	ui_network:hideLoading()
    ui_network:setParam('uid', uid)
    ui_network:setParam('rid', rid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
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
        self.m_serverData:networkCommonRespone_addedItems(ret)
		
		-- 노티 정보를 갱신하기 위해서 호출
		g_highlightData:setDirty(true)

        -- @analytics
        Analytics:firstTimeExperience('MasterRoad_Reward')
        Analytics:trackEvent(CUS_CATEGORY.FIRST, CUS_EVENT.MASTER_ROAD, 1, string.format('퀘스트 번호 : %d', rid))

        if (finish_cb) then
            finish_cb(ret)
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
function ServerData_MasterRoad.checkClear(clear_type, clear_cond, t_data, raw_data)
    if (not clear_type) then
        return false
    end
    if (not t_data) then
        return false
    end
    if (not raw_data) then
        return false
    end

    -- clear_key 사용
    if (clear_type == t_data['clear_key']) then
        -----------------------------------
        -- 전역 변수에 접근해 데이터 얻어옴
        -----------------------------------
        -- 유저 레벨 달성
        if (clear_type == 'u_lv') then
            local user_lv = clear_cond
            return (g_userData:get('lv') >= user_lv)

        -- 친구 n명 달성
        elseif (clear_type == 'make_frd') then
            local friend_cnt = clear_cond
            return (g_friendData:getFriendCount() >= friend_cnt)

        -- 테이머 겟
        elseif (clear_type == 't_get') then
            local tamer_cnt = clear_cond
            return (g_tamerData:getTamerCount() >= tamer_cnt)

        -----------------------------------
        -- 외부에서 넘긴 값 사용
        -----------------------------------
        -- 룬 강화
        elseif (clear_type == 'r_enc') then
            local rune_lv = clear_cond
            return (t_data['clear_value'] >= rune_lv)

        -----------------------------------
        -- 서버에서 준 값 사용
        -----------------------------------
        -- 드래곤 진화
        elseif (clear_type == 'd_evup') then
            local evup_cnt = clear_cond
            local raw_cnt = raw_data['d_evup']
            return (raw_cnt >= evup_cnt)

        -- 드래곤 스킬 레벨 업
        elseif (clear_type == 'd_sklvup') then
            local sklvup_cnt = clear_cond
            local raw_cnt = raw_data['d_sklvup']
            return (raw_cnt >= sklvup_cnt)

        -- 드래곤 등급업
        elseif (clear_type == 'd_grup') then
            local grup_cnt = clear_cond
            local raw_cnt = raw_data['d_grup']
            return (raw_cnt >= grup_cnt)

        -----------------------------------
		-- 로비나 마스터의 길 팝업에서 스테이지 정보 사용해서 판단
        -----------------------------------
        -- 스테이지 클리어 
        elseif (clear_type == 'clr_stg') then
            local clear_stage_id = tonumber(clear_cond)

            local stage_info = g_adventureData:getStageInfo(clear_stage_id)
            if (stage_info) then
                local clear_cnt = stage_info['clear_cnt']

                if (clear_cnt and clear_cnt > 0) then
                    return true
                end
            end
            return false

        -----------------------------------
        -- 별도의 비교값이 필요없는 타입
        -----------------------------------
        else
            -- 테이머 스킬 레벨 업 t_sklvup
            -- 룬 장착 r_eq
            -- 알 부화 egg
            -- 친밀도 과일 먹임 fruit
            -- 드래곤 레벨업 d_lvup
            -- 탐험 보내기 ply_epl
            -- 친구 신청 하기 invt_frd
            return true
        end

    -- clear_key를 넘기지 않음 -> 인게임 클리어 타입
    else
        -- stage clear
		-- 인게임 종료 후, 받은 정보로 판단 
        if (pl.stringx.startswith(clear_type, 'clr_')) and (t_data['is_success'] == true) then
            local stage_id = t_data['stage_id']
            return (stage_id == clear_cond)

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
            return (dungeon_mode == NEST_DUNGEON_EVO_STONE)

        -- 거목 던전 플레이
        elseif (clear_type == 'ply_tree') then
            local dungeon_mode = t_data['dungeon_mode']
            return (dungeon_mode == NEST_DUNGEON_TREE)

        -- 악몽 던전 플레이
        elseif (clear_type == 'ply_nm') then
            local dungeon_mode = t_data['dungeon_mode']
            return (dungeon_mode == NEST_DUNGEON_NIGHTMARE)

        end
    end

end