-------------------------------------
-- class ServerData_EventArenaPlay
-------------------------------------
ServerData_EventArenaPlay = class({
        m_serverData = 'ServerData',
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
        -- server_info 정보를 갱신

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


