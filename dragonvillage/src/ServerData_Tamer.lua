-------------------------------------
-- class ServerData_Tamer
-------------------------------------
ServerData_Tamer = class({
        m_serverData = 'ServerData',
		m_mTamerMap = 'map<tamer_id>'
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Tamer:init(server_data)
    self.m_serverData = server_data
	self:reMappingTamerInfo()
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_Tamer:getTamerList()
    return self.m_serverData:getRef('tamers')
end

-------------------------------------
-- function reMappingTamerInfo
-------------------------------------
function ServerData_Tamer:reMappingTamerInfo(t_info)
	local t_info = t_info or self:getTamerList()
	if (t_info) then
		self.m_mTamerMap = table.listToMap(t_info, 'tid')
	else
		self.m_mTamerMap = {}
	end
end

-------------------------------------
-- function applyTamerInfo
-------------------------------------
function ServerData_Tamer:applyTamerInfo(t_tamer)
	local tamer_list = self:getTamerList()

	for i, v in pairs(tamer_list) do
		if (v['tid'] == t_tamer['tid']) then
			tamer_list[i] = t_tamer
			break
		end
	end
end

-------------------------------------
-- function getCurrTamerID
-- @brief 현재 테이머 ID
-- @return number
-- 2017-07-05 sgkim
-- table_tamer.csv테이블의 tid
-- 110001	goni	고니
-- 110002	nuri	누리
-- 110003	dede	데데
-- 110004	kesath	케사스
-- 110005	durun	두른
-- 110006	mokoji	모코지
-------------------------------------
function ServerData_Tamer:getCurrTamerID()
    local tamer_id = self.m_serverData:getRef('user', 'tamer')

	-- 예전 테이머 개발 전 데이터 커버리지 코드
	if (tamer_id == 0) then
		tamer_id = g_constant:get('INGAME', 'TAMER_ID')

	-- @ intro : 인트로 전투 시작 시 테이머 고니로 고정
	elseif (not tamer_id) then
		tamer_id = 110001
	end

    return tamer_id
end

-------------------------------------
-- function getCurrTamerTable
-- @brief 현재 테이머 정보
-- @param key - 있으면 해당 필드의 값을 반환하고 없다면 전체 테이블 반환
-- @return table or value
-------------------------------------
function ServerData_Tamer:getCurrTamerTable(key)
	local tamer_id = self:getCurrTamerID()

    local table_tamer = TableTamer()
	local t_tamer = table_tamer:get(tamer_id)
	if (key) then
		return t_tamer[key]
	else
		return t_tamer
	end
end

-------------------------------------
-- function getTamerServerInfo
-- @brief 테이머 스킬 레벨 정보 반환
-------------------------------------
function ServerData_Tamer:getTamerServerInfo(tamer_id)
	local tamer_id = tamer_id
	if (not tamer_id) then
		tamer_id = self.m_serverData:getRef('user', 'tamer')
	end
	return self.m_mTamerMap[tamer_id] or {tid = tamer_id}
end

-------------------------------------
-- function hasTamer
-- @brief 테이머 존재 여부 체크
-------------------------------------
function ServerData_Tamer:hasTamer(tamer_id)
	if (self.m_mTamerMap[tamer_id]) then
		return true
	end 

	return false
end

-------------------------------------
-- function getTamerCount
-- @brief 테이머 존재 여부 체크
-------------------------------------
function ServerData_Tamer:getTamerCount()
	return table.count(self.m_mTamerMap)
end

-------------------------------------
-- function getObtainableTamer
-- @brief 획득 가능한 테이머 테이블 반환
-------------------------------------
function ServerData_Tamer:getObtainableTamer()
	local t_ret = {}
	for tid, t_tamer in pairs(TableTamer().m_orgTable) do
		if not (self:hasTamer(tid)) then
			local is_ok = self:checkTamerObtainCondition(t_tamer['obtain_condition'])
			if (is_ok) then
				t_ret[tid] = true
			end
		end
	end

	if (cb_func) then
		cb_func()
	end

	return t_ret
end

-------------------------------------
-- function checkTamerObtaining
-- @brief 조건별 테이머 획득 가능 체크
-------------------------------------
function ServerData_Tamer:checkTamerObtainCondition(condition)
	local is_clear = false
	if (not condition) then
		return is_clear
	end

    if (condition == 'clr_tutorial') then
		is_clear = true

	elseif (string.find(condition, 'clr_adv_')) then
		local raw_str = string.gsub(condition, 'clr_adv_', '')

		raw_str = seperate(raw_str, '_')

		local difficulty = (raw_str[1] == 'normal') and 1 or 2
		local chapter = raw_str[2]
		local stage = raw_str[3]
		if (stage) then
			local stage_id = makeAdventureID(difficulty, chapter, stage)
			is_clear = g_adventureData:isClearStage(stage_id)
		else
			is_clear = g_adventureData:isClearChapter(difficulty, chapter)
		end
	end

	return is_clear
end

-------------------------------------
-- function isHighlightTamer
-------------------------------------
function ServerData_Tamer:isHighlightTamer()
	local t_obtainable_tamer = self:getObtainableTamer()
	if (table.count(t_obtainable_tamer) > 0) then
        -- @sgkim 2019.08.28 테이머를 골드로 구매 가능한 상태가 빨간 느낌표를 띄울 정도로 중요하지 않아서 비활성화 처리
		--return true
        return false
	end

	return false
end

-------------------------------------
-- function isObtainable
-------------------------------------
function ServerData_Tamer:isObtainable(tid)
	local t_obtainable_tamer = self:getObtainableTamer()
	if (t_obtainable_tamer[tid]) then
		return true
	end

	return false
end


-------------------------------------
-- function request_setTamer
-------------------------------------
function ServerData_Tamer:request_setTamer(tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid

    -- 콜백 함수
    local function success_cb()
        -- @analytics
        Analytics:firstTimeExperience('Change_Tamer')
        local t_tamer = TableTamer():get(tid)
        if (t_tamer) then
            Analytics:trackEvent(CUS_CATEGORY.GROWTH, CUS_EVENT.TMR_SEL, 1, t_tamer['t_name'])
        end

        -- 바뀐 테이머 저장
        self.m_serverData:applyServerData(tid, 'user', 'tamer')

        -- 채팅 서버에 변경사항 적용
        g_lobbyChangeMgr:globalUpdatePlayerUserInfo()

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/set/tamer')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', tid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_getTamer
-------------------------------------
function ServerData_Tamer:request_getTamer(tid, type, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '테이머 구매')
        local t_tamer = TableTamer():get(tid)
        if (t_tamer) then
            Analytics:trackEvent(CUS_CATEGORY.GROWTH, CUS_EVENT.TMR_GET, 1, t_tamer['t_name'])
        end

		-- 테이머 정보 갱신
		table.insert(self:getTamerList(), ret['tamer'])
		self:reMappingTamerInfo()
		
        -- 재화 갱신
        self.m_serverData:networkCommonRespone(ret)

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        -- @ MASTER ROAD
        local t_data = {clear_key = 't_get', clear_value = self:getTamerCount()}
        g_masterRoadData:updateMasterRoad(t_data)
        
        -- @ GOOGLE ACHIEVEMENT
        GoogleHelper.updateAchievement(t_data)

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get/tamer')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', tid)
    ui_network:setParam('type', type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_tamerSkillEnhance
-------------------------------------
function ServerData_Tamer:request_tamerSkillEnhance(tid, skill_idx, enhance_level, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid
	local skill_idx = skill_idx + 1 -- 서버 인덱스는 1번부터 시작
	local level = enhance_level

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '테이머 스킬 레벨업')

		-- 테이머 정보 갱신
		self:applyTamerInfo(ret['tamer'])
		self:reMappingTamerInfo()

		-- 갱신
        g_serverData:networkCommonRespone(ret)

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/lvup/tamer')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tid', tid)
    ui_network:setParam('skill', skill_idx)
	ui_network:setParam('level', level)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end