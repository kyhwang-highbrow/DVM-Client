-------------------------------------
--- @class ServerData_Research
-------------------------------------
ServerData_Research = class({
    m_serverData = 'ServerData',
})

-------------------------------------
--- @function init
-------------------------------------
function ServerData_Research:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
--- @function response_researchInfo
-------------------------------------
function ServerData_Research:response_researchInfo(ret)
end

-------------------------------------
--- @function request_researchInfo
--- @brief 정보 요청
-------------------------------------
function ServerData_Research:request_researchInfo(finish_cb, fail_cb)
    local uid = g_userData:get('uid')    

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self:response_researchInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/research/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end

-------------------------------------
--- @function request_researchUpgrade
--- @brief 연구하기
-------------------------------------
function ServerData_Research:request_researchUpgrade(research_id, finish_cb, fail_cb)
    local uid = g_userData:get('uid')    

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        --self:response_researchInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/research/buy')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end