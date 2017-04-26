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
-- function getTamerInfo
-- @brief 테이머 정보
-- @param key - 있으면 해당 필드의 값을 반환하고 없다면 전체 테이블 반환
-------------------------------------
function ServerData_User:getTamerInfo(key)
	local tamer_idx = self:getRef('tamer')
	if (tamer_idx == 0) then
		tamer_idx = g_constant:get('INGAME', 'TAMER_VALUE') + 1
	end

	local t_tamer = TableTamer():get(tamer_idx)
	if (key) then
		return t_tamer[key]
	else
		return t_tamer
	end
end

-------------------------------------
-- function request_setTamer
-------------------------------------
function ServerData_User:request_setTamer(tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid or (g_constant:get('INGAME', 'TAMER_VALUE') + 1)

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