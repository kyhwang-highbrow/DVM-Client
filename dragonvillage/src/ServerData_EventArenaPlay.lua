-------------------------------------
-- class ServerData_EventArenaPlay
-------------------------------------
ServerData_EventArenaPlay = class({
        m_serverData = 'ServerData',

        m_eventData = 'Table',


    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventArenaPlay:init(server_data)
        self.m_serverData = server_data
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventArenaPlay:request_eventData(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self.m_eventData = ret['event_arena_play_info']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/event_arena_play/info')
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
-- function initUI
-- @breif 초기화
-------------------------------------
function ServerData_EventArenaPlay:getRemainEventTimeStr()
    if not self.m_eventData then return '' end

    local expire_time = self.m_eventData['end']
    local server_time = Timer:getServerTime()
    local msg = ''
    time = (expire_time/1000 - server_time)

    if (time > 0) then
        enable = false
        local show_second = true
        local first_only = true
        msg = Str('{1} 남음', datetime.makeTimeDesc(time, show_second, first_only))
    end

    return msg
end

