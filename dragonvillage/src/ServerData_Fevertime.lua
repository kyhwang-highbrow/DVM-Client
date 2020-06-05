-------------------------------------
-- class ServerData_Fevertime
-- @brief 핫타임 (개발 코드 fevertime)
--        기존 핫타임이 있는 상태에서 개선된 핫타임
-- @instance g_fevertimeData
-------------------------------------
ServerData_Fevertime = class({
        m_serverData = 'ServerData',
        m_lFevertime = 'table',
        m_lFevertimeSchedule = 'table',
        m_lFevertimeGlobal = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Fevertime:init(server_data)
    self.m_serverData = server_data
    self.m_lFevertime = {}
    self.m_lFevertimeSchedule = {}
    self.m_lFevertimeGlobal = {}
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
        self:applyFevertimeSchedule(ret['fevertime_schedule'])
        self:applyFevertimeGlobal(ret['fevertime_global'])

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
-- function request_fevertimeActive
-- @brief 일일 핫타임 활성화
-------------------------------------
function ServerData_Fevertime:request_fevertimeActive(id, finish_cb, fail_cb)
-- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)

        self:applyFevertimeData(ret['fevertime'])
        self:applyFevertimeSchedule(ret['fevertime_schedule'])
        self:applyFevertimeGlobal(ret['fevertime_global'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/fevertime/active')
    ui_network:setParam('uid', uid)
    ui_network:setParam('id', id)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	--ui_network:hideBGLayerColor()
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

    self.m_lFevertime = {}
    for i,v in pairs(t_data) do
        local struct_fevertime = StructFevertime:create_forFevertime(v)
        table.insert(self.m_lFevertime, struct_fevertime)
    end

end

-------------------------------------
-- function applyFevertimeSchedule
-------------------------------------
function ServerData_Fevertime:applyFevertimeSchedule(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertimeSchedule = {}
    for i,v in pairs(t_data) do
        if (v['used'] == nil) or (v['used'] == false) then
            local struct_fevertime = StructFevertime:create_forFevertimeSchedule(v)
            table.insert(self.m_lFevertimeSchedule, struct_fevertime)
        end
    end
end

-------------------------------------
-- function applyFevertimeGlobal
-------------------------------------
function ServerData_Fevertime:applyFevertimeGlobal(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertimeGlobal = {}
    for i,v in pairs(t_data) do
        local struct_fevertime = StructFevertime:create_forFevertimeGlobal(v)
        table.insert(self.m_lFevertimeGlobal, struct_fevertime)
    end
end

-------------------------------------
-- function getAllStructFevertimeList
-------------------------------------
function ServerData_Fevertime:getAllStructFevertimeList()
    local l_ret = {}

    table.addList(l_ret, self.m_lFevertime)
    table.addList(l_ret, self.m_lFevertimeSchedule)
    table.addList(l_ret, self.m_lFevertimeGlobal)

    return l_ret
end

-------------------------------------
-- function isActiveDailyFevertimeByType
-- @brief 활성화된 일일 핫타임
-------------------------------------
function ServerData_Fevertime:isActiveDailyFevertimeByType(type)
    for i,struct_fevertime in pairs(self.m_lFevertime) do

        -- 일일 핫타임
        if (struct_fevertime:isDailyHottime() == true) then

            -- 활성화
            if (struct_fevertime:isActiveFevertime() == true) then
                
                -- 타입이 같을 경우
                if (struct_fevertime:getFevertimeType() == type) then
                    return true
                end
            end
        end
    end

    return false
end
