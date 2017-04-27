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
	self:refreshTamerInfo(self:getRef())
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_Tamer:getRef(...)
    return self.m_serverData:getRef('tamers', ...)
end

-------------------------------------
-- function refreshTamerInfo
-------------------------------------
function ServerData_Tamer:refreshTamerInfo(t_info)
	if (t_info) then
		self.m_mTamerMap = table.listToMap(t_info, 'tid')
	else
		self.m_mTamerMap = {}
	end
end

-------------------------------------
-- function getTamerInfo
-- @brief 현재 테이머 정보
-- @param key - 있으면 해당 필드의 값을 반환하고 없다면 전체 테이블 반환
-------------------------------------
function ServerData_Tamer:getTamerInfo(key)
	local tamer_id = self.m_serverData:getRef('user', 'tamer')
	if (tamer_id == 0) then
		tamer_id = g_constant:get('INGAME', 'TAMER_ID')
	end

	local t_tamer = TableTamer():get(tamer_id)
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

	if (condition == 'clear_newbie_quest') then
		is_clear = g_questData:isAllClear('newbie')

	elseif (condition == 'clear_tutorial') then
		-- @TODO : 튜토리얼 체크

	elseif (string.find(condition, 'clear_adventure_')) then
		local raw_str = string.gsub(condition, 'clear_adventure_', '')
		raw_str = seperate(raw_str, '_')

		local difficulty = 1
		local chapter = raw_str[1]
		local stage = raw_str[2]
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
		return true
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
        self.m_serverData:applyServerData(tid, 'user', 'tamer')

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
function ServerData_Tamer:request_getTamer(tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid

    -- 콜백 함수
    local function success_cb(ret)
		table.insert(self:getRef(), ret['tamer'])
		
		self:refreshTamerInfo(self:getRef())
		
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get/tamer')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', tid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_tamerLevelUp
-------------------------------------
function ServerData_Tamer:request_tamerLevelUp(tid, skill_idx, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid
	local skill_idx = skill_idx

    -- 콜백 함수
    local function success_cb()
		--table.insert(self:getRef(), ret['tamer'])
		
		self:refreshTamerInfo(self:getRef())

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/set/tamer')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', tid)
	ui_network:setParam('skill', skill_idx)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end