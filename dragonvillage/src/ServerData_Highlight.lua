-------------------------------------
-- class ServerData_Highlight
-------------------------------------
ServerData_Highlight = class({
        m_serverData = 'ServerData',

        -- 서버에서 넘겨받는 값
        ----------------------------------------------
        attendance_reward = '',
        attendance_event_reward = '',
        quest_reward = '',
        explore_reward = '',
        summon_free = '',
        ----------------------------------------------
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Highlight:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_adventureInfo
-------------------------------------
function ServerData_Highlight:request_adventureInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        for key,value in pairs(ret) do
            if (not isExistValue(key, 'message', 'status')) then
                self[key] = value
            end
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/status')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end