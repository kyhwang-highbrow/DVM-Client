-------------------------------------
-- class ServerData_DragonDiary
-------------------------------------
ServerData_DragonDiary = class({
        m_serverData = 'ServerData',
        m_focusRid = 'number',
        m_tClearInfo = 'table',

        m_bEnable = 'boolean',

        m_bDirty = 'boolean',

        m_isAfterCloseDiary = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonDiary:init(server_data)
    self.m_serverData = server_data
    self.m_bEnable = true
    self.m_tClearInfo = {}
end

-------------------------------------
-- function applyInfo
-- @brief 정보 갱신하기
-------------------------------------
function ServerData_DragonDiary:applyInfo(ret)
    -- 신규 유저들만 true로 옴
    if (ret['enable'] ~= nil) then
        self.m_bEnable = ret['enable']
    end
    
    -- 현재 진행중인 단계
    if (ret['current_rid']) then
        self.m_focusRid = ret['current_rid']
    end

    -- 클리어 여부 리스트
    if (ret['clear_rid']) then
        -- 서버에서 리스트로 옴, 체크하기 편하게 맵형태로 변환
        self.m_tClearInfo = {}
        for _, rid in ipairs(ret['clear_rid']) do
            
            -- 클리어한 현재 단계만 노출
            if (self.m_focusRid == rid) then
                self.m_tClearInfo[tostring(rid)] = 1
            else
                self.m_tClearInfo[tostring(rid)] = 2 
            end
        end
    end

    -- 외부에서 정보 갱신 필요할 경우 사용
    g_dragonDiaryData.m_bDirty = true
end

-------------------------------------
-- function isEnable
-- @brief 활성화
-- @brief 성장일지 컨텐츠 있을 때 계정 생성했는 지 여부
-------------------------------------
function ServerData_DragonDiary:isEnable()
	return self.m_bEnable
end

-------------------------------------
-- function getFocusRid
-- @brief 현재 진행중인 퀘스트
-------------------------------------
function ServerData_DragonDiary:getFocusRid()
    local rid = self.m_focusRid
    local last_rid = TableDragonDiary:getLastStep()

    return math_min(rid, last_rid)
end

-------------------------------------
-- function getFocusRids
-- @brief clear_type으로 검사할 rid list 
-------------------------------------
function ServerData_DragonDiary:getFocusRids(clear_type)
    local t_dragon_diary = TableDragonDiary()
    local t_rids = {}

    for rid, data in pairs(t_dragon_diary.m_orgTable) do
        if (data['clear_type'] == clear_type) then

            -- 클리어 목록에 없는 것들만 !!
            if (self.m_tClearInfo[tostring(rid)] == nil) then
                table.insert(t_rids, rid)
            end
        end
    end

    return t_rids
end

-------------------------------------
-- function getTitleText
-- @brief 시작 드래곤에 따라 타이틀 문구 달라짐 -> 드래곤 성장일지로 변경
-------------------------------------
function ServerData_DragonDiary:getTitleText()
    local title = Str('드래곤 성장일지')
    return title
end

-------------------------------------
-- function getStartDragonDid
-- @brief 시작 드래곤 did (시작 테이머만 정보만 있음. 하드코딩)
-------------------------------------
function ServerData_DragonDiary:getStartDragonDid()
    local tid = g_userData:get('start_tamer')
    local name = TableTamer():getTamerType(tid) or 'goni'
    local did = (name == 'goni') and 120223 or 120431
    return did
end

-------------------------------------
-- function getStartDragonName
-------------------------------------
function ServerData_DragonDiary:getStartDragonName()
    local did = self:getStartDragonDid()
    local name = TableDragon:getDragonName(did)
    return name
end

-------------------------------------
-- function getStartDragonData
-------------------------------------
function ServerData_DragonDiary:getStartDragonData(dragon_data)
    local start_dragon_doid = g_userData:get('start_dragon')
    if (not start_dragon_doid) then
        return nil
    end

    local start_dragon_data
    if (dragon_data and dragon_data['id'] == start_dragon_doid) then
        start_dragon_data = dragon_data
    else
        start_dragon_data = g_dragonsData:getDragonDataFromUid(start_dragon_doid)
    end
    
    return start_dragon_data
end

-------------------------------------
-- function getStartDragonFrameRes
-------------------------------------
function ServerData_DragonDiary:getStartDragonFrameRes()
    local tid = g_userData:get('start_tamer')
    local name = TableTamer():getTamerType(tid) or 'goni'
    local res = (name == 'goni') and 
                'res/ui/frames/lobby_dragon_diary_01.png' or 
                'res/ui/frames/lobby_dragon_diary_02.png'
    return res
end

-------------------------------------
-- function getStartDragonDataWithList
-------------------------------------
function ServerData_DragonDiary:getStartDragonDataWithList(dragon_list)
    local start_dragon_doid = g_userData:get('start_dragon')
    if (not start_dragon_doid) then
        return nil
    end

    local start_dragon_data
    for _, v in ipairs(dragon_list) do
        local user_data = v['user_data']

        if (user_data) then
            if (start_dragon_doid == user_data['id']) then
                start_dragon_data = user_data
                break
            end
        end
    end
    
    return start_dragon_data
end

-------------------------------------
-- function getDisplayRoad
-- @brief 보상 여부에 따라 바뀌는 UI 노출위한 road 반환
-------------------------------------
function ServerData_DragonDiary:getDisplayRoad()
    local has_reward, rid = self:hasRewardRoad()
    if (has_reward) then
        return rid
    else
        return self:getFocusRid()
    end
end

-------------------------------------
-- function getDiaryIdx
-------------------------------------
function ServerData_DragonDiary:getDiaryIdx(rid)
    return math_max(1, tonumber(rid) % 100)
end

-------------------------------------
-- function getRewardState
-- @brief 해당 road의 보상 현황 리턴
-------------------------------------
function ServerData_DragonDiary:getRewardState(rid)
    local reward_state
    local reward_info = self.m_tClearInfo[tostring(rid)]

    -- 보상 있음
    if (reward_info == 1) then
        reward_state = 'has_reward'
        
    -- 클리어했지만 현재 단계가 아님
    elseif (reward_info == 2) then
        -- 현재 road보다 후순의 road라면 아직 클리어하지 않은것
        if (self.m_focusRid <= rid) then
            reward_state = 'not_yet'

        -- 현재 road 이전의 road라면 이미 클리어한 것
        else
            reward_state = 'already_done'
        end

    -- 정보가 없다면
    elseif (reward_info == nil)  then
        -- 현재 road보다 후순의 road라면 아직 클리어하지 않은것
        if (self.m_focusRid <= rid) then
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
function ServerData_DragonDiary:hasRewardRoad()
    local last_rid = self.m_focusRid
   
    if (self.m_tClearInfo[tostring(last_rid)] == 1) then
        return true, self.m_focusRid
    end

    return false, nil
end

-------------------------------------
-- function isClearAll
-- @brief 마지막 마스터의길까지 클리어했는지 여부
-------------------------------------
function ServerData_DragonDiary:isClearAll()
    -- 이전 계정들은 모두 클리어 처리
    if (self.m_bEnable == false) then
        return true
    end

    local last_step = TableDragonDiary:getLastStep()
    local focus_step = self.m_focusRid

    return (last_step < focus_step)
end

-------------------------------------
-- function isSelectedDragonLock
-------------------------------------
function ServerData_DragonDiary:isSelectedDragonLock(doid)
	if (not doid) then
        return false
    end
    
    -- 선택한 드래곤 정보가 있는 계정의 경우
	-- 선택한 드래곤이 스타트 드래곤일 경우
	-- 성장일지 끝나지 않았을 경우 잠금 처리
	if (g_dragonDiaryData:isEnable()) then
		local start_dragon_doid = g_userData:get('start_dragon') 
		if (start_dragon_doid) then
			if (not self:isClearAll()) then
				if (start_dragon_doid == doid) then
					return true
				end
			end
		end

		return false
	end

	local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    if (not dragon_obj) then
        return false
    end

	-- 성장일지 없을 때 만들어진 계정인 경우 태생보다 낮은 등급이라면 잠금처리
	-- 3성을 작별했을 때 인연으로 5성 소환하는 것을 막기위해
	local did = dragon_obj:getDid()
	local birth_grade = TableDragon():getBirthGrade(did)
	local grade = dragon_obj:getGrade() 
	if (grade < birth_grade) then
		return true
	end

	return false
end

-------------------------------------
-- function checkAlreadyClear
-- @brief 통신 실패로 클리어한 퀘스트가 있는데 클리어 처리가 안된 경우 UI 진입시 다시 검사
-------------------------------------
function ServerData_DragonDiary:checkAlreadyClear(finish_cb)
    local finish_cb = finish_cb or function() end

    local start_dragon_data = g_dragonDiaryData:getStartDragonData()
    if (not start_dragon_data) then
        finish_cb()
    end
    
    local check_list = {}
    table.insert(check_list, 'd_lv') -- 레벨업 체크
    table.insert(check_list, 'd_grup_s') -- 승급 체크
    table.insert(check_list, 'd_evup_s') -- 진화 체크
    table.insert(check_list, 'check_d_stat') -- 능력치 체크
    table.insert(check_list, 'fr_lvup') -- 친밀도 체크

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        for _, key in ipairs(check_list) do
            co:work('check_key :'..key)
            local t_data = {clear_key = key, sub_data = start_dragon_data}
            g_dragonDiaryData:updateDragonDiary(t_data, co.NEXT)
            if co:waitWork() then return end
        end
        co:close()
        finish_cb()
    end

    Coroutine(coroutine_function, 'DragonDiary 코루틴')
end

-------------------------------------
-- function updateDragonDiary
-- @brief 클리어 키값에 해당하는 부분 클라이언트에서 검사
-------------------------------------
function ServerData_DragonDiary:updateDragonDiary(t_data, finish_cb)
    local finish_cb = finish_cb or function() end

    -- 모두 클리어한 경우 
    if (self:isClearAll()) then
        finish_cb()
        return
    end

    -- 해당 클리어 키값 rid 모두 가져옴 (클리어한 rid 제외)
    local clear_key = t_data['clear_key']
    local t_rids = self:getFocusRids(clear_key)
    local sub_data = t_data['sub_data']

    local t_clear_key = {}

    for _, rid in ipairs(t_rids) do
        local is_clear = self.checkClear(rid, sub_data)
        if (is_clear) then
            table.insert(t_clear_key, rid)
        end
    end

    -- 콤마로 구분하여 클리어한 퀘스트들 한번에 클리어 처리 (여러번 콜하지 않는다.)
    if (#t_clear_key > 0) then
        local param = ''
         for _, rid in ipairs(t_clear_key) do
            local str_rid = tostring(rid)
            param = (param == '') and 
                    str_rid or 
                    param .. ',' .. str_rid
         end

         self:request_diaryClear(param, finish_cb)
    else
        finish_cb()
    end
end

-------------------------------------
-- function request_diaryInfo
-- @brief 전체 정보 받아오기
-------------------------------------
function ServerData_DragonDiary:request_diaryInfo(finish_cb, fail_cb)
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
    ui_network:setUrl('/users/dragon_diary/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_diaryClear
-- @brief 클리어 요청
-------------------------------------
function ServerData_DragonDiary:request_diaryClear(rid, finish_cb)
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
    ui_network:setUrl('/users/dragon_diary/clear')
    ui_network:setLoadingMsg(Str('드래곤 성장일지 확인 중...'))
    ui_network:setParam('uid', uid)
    ui_network:setParam('rid', rid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_diaryReward
-- @brief 보상 요청
-------------------------------------
function ServerData_DragonDiary:request_diaryReward(rid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:applyInfo(ret)

        -- 재화 수령 처리
        self.m_serverData:networkCommonRespone_addedItems(ret)
		
		-- 노티 정보를 갱신하기 위해서 호출
		g_highlightData:setDirty(true)

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/dragon_diary/reward')
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
function ServerData_DragonDiary.checkClear(rid, sub_data)
    if (not rid) then
        return false
    end

    if (not sub_data) then
        return false
    end

    local t_diary = TableDragonDiary():get(rid)
    if (not t_diary) then
        return false
    end

    local clear_type = t_diary['clear_type']
    local clear_target = t_diary['clear_target']
    local clear_value = t_diary['clear_value']

    -- # 드래곤 해당 등급과 레벨 달성
    -- # 드래곤 관리 - 레벨업, 인게임 결과 에서 검사
    -- # clear_target - 등급 조건, clear_value - 레벨 조건
    if (clear_type == 'd_lv') then
        local grade = sub_data['grade']
        local lv = sub_data['lv']

        -- 등급이 높으면 무조건 클리어 처리
        if (clear_target < grade) then
            return true
        end

        if (clear_target == grade) and (clear_value <= lv) then
            return true
        end

    -- # 드래곤 친밀도
    -- # clear_value - flv
    elseif (clear_type == 'fr_lvup') then
        local flv = sub_data['friendship']['flv']
        if (clear_value <= flv) then
            return true
        end

    -- # 드래곤 승급
    -- # clear_target - 승급 조건
    elseif (clear_type == 'd_grup_s') then
        local grade = sub_data['grade']
        if (clear_target <= grade) then
            return true
        end

    -- # 드래곤 룬장착
    -- # clear_value - 세트 조건 (1:체력 세트, 8:쾌속 세트)
    elseif (clear_type == 'r_eq_s') then
        local doid = sub_data['id']
        local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
        local rune_set_obj = dragon_obj:getStructRuneSetObject()
        local active_set_list = rune_set_obj:getActiveRuneSetList()

        for _, set_num in ipairs(active_set_list) do
            if (clear_value == set_num) then
                return true
            end
        end

    -- # 드래곤 능력치 체크 (드래곤 스텟 계산시)
    -- # clear_target - 능력치, clear_value - 수치
    elseif (clear_type == 'check_d_stat') then
        local doid = sub_data['id']
        local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
        local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(dragon_obj)

        local curr_stat = status_calc:getFinalStat(clear_target)
        if (clear_value <= curr_stat) then
            return true
        end

    -- # 드래곤 진화
    -- # clear_target - 진화 조건
    elseif (clear_type == 'd_evup_s') then
        local evolution = sub_data['evolution']
        if (clear_target <= evolution) then
            return true
        end

    -- # 드래곤 콜로세움 출전
    elseif (clear_type == 'ply_clsm') then
        return true

    end

    return false
end

-------------------------------------
-- function applyIsAfterCloseDiaryUser
-- @brief 191010 성장일지 제거한 후부터 계정 생성한 유저들은 true 값을 받음
-------------------------------------
function ServerData_DragonDiary:applyIsAfterCloseDiaryUser(is_close)
    self.m_isAfterCloseDiary = is_close
end

-------------------------------------
-- function getIsAfterCloseDiaryUser
-------------------------------------
function ServerData_DragonDiary:getIsAfterCloseDiaryUser()
    return self.m_isAfterCloseDiary
end

