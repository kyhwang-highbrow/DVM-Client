-------------------------------------
-- class ServerData_Tamer
-------------------------------------
ServerData_Tamer = class({
        m_serverData = 'ServerData',

    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Tamer:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_Tamer:getRef(...)
    return self.m_serverData:getRef('tamers', ...)
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
-- function getTamerSkillLvList
-- @brief 테이머 스킬 레벨 정보 반환
-- @param key - 있으면 해당 필드의 값을 반환하고 없다면 전체 테이블 반환
-------------------------------------
function ServerData_Tamer:getTamerSkillLvList(tamer_id)
	local tamer_list = self:getRef()

	for _, t_tamer_info in pairs(tamer_list) do
		if (tamer_id == t_tamer_info['tid']) then
			return t_tamer_info

		end
	end
end

-------------------------------------
-- function request_setTamer
-------------------------------------
function ServerData_User:request_setTamer(tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid

    -- 콜백 함수
    local function success_cb()
        self:applyServerData(tid, 'tamer')
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
function ServerData_User:request_getTamer(tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid

    -- 콜백 함수
    local function success_cb()
        self:applyServerData(tid, 'tamer')
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
function ServerData_User:request_tamerLevelUp(tid, skill_idx, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid
	local skill_idx = skill_idx

    -- 콜백 함수
    local function success_cb()
        self:applyServerData(tid, 'tamer')
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