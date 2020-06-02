-------------------------------------
-- class ServerData_Fevertime
-- @brief 핫타임 (개발 코드 fevertime)
--        기존 핫타임이 있는 상태에서 개선된 핫타임
-- @instance g_fevertimeData
-------------------------------------
ServerData_Fevertime = class({
        m_serverData = 'ServerData',
        m_lFevertimeData = 'table',
        m_lFevertimeScheduleData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Fevertime:init(server_data)
    self.m_serverData = server_data
    self.m_lFevertimeData = {}
    self.m_lFevertimeScheduleData = {}
end


-------------------------------------
-- function request_fevertimeInfo
-------------------------------------
function ServerData_Fevertime:request_fevertimeInfo(finish_cb, fail_cb)
-- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)

        self:applyFevertimeData(ret['fevertime'])
        self:applyFevertimeScheduleData(ret['fevertime_schedule'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/fevertime/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function applyFevertimeData
-------------------------------------
function ServerData_Fevertime:applyFevertimeData(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertimeData = t_data
end

-------------------------------------
-- function applyFevertimeScheduleData
-------------------------------------
function ServerData_Fevertime:applyFevertimeScheduleData(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertimeScheduleData = t_data
end