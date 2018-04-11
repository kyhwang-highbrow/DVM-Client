-------------------------------------
-- class ServerData_NaverEvent
-------------------------------------
ServerData_NaverEvent = class({
        m_serverData = 'ServerData',
        m_lDoneList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_NaverEvent:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function isAlreadyDone
-------------------------------------
function ServerData_NaverEvent:isAlreadyDone(event_key)
    return table.find(self.m_lDoneList, event_key)
end

-------------------------------------
-- function request_naverEventInfo
-------------------------------------
function ServerData_NaverEvent:request_naverEventInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_naverEventInfo(ret)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/event/naver_info')
    ui_network:setLoadingMsg(Str('이벤트 정보 받는 중...' .. '.'))
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    --ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_naverEventInfo
-------------------------------------
function ServerData_NaverEvent:response_naverEventInfo(ret)
    self.m_lDoneList = ret['done_list']
end

-------------------------------------
-- function request_naverEventReward
-------------------------------------
function ServerData_NaverEvent:request_naverEventReward(event_key, event_type, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        ItemObtainResult(ret, true)
        self.m_lDoneList = ret['done_list']

        if (finish_cb) then
            finish_cb()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/event/naver_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('event_key', event_key)
    ui_network:setParam('event_type', event_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end