-------------------------------------
-- class ServerData_StartTamer
-------------------------------------
ServerData_StartTamer = class({
        m_serverData = 'ServerData',

        m_lStartTamerInfo = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_StartTamer:init(server_data)
    self.m_serverData = server_data
    self.m_lStartTamerInfo = {}
end

-------------------------------------
-- function setData
-------------------------------------
function ServerData_StartTamer:setData(server_data)
    local tamer_info = server_data['newuser_info']
    if tamer_info then
        for _, v in ipairs(tamer_info) do
            -- new_user type 테이블에서 삭제되면 같이 삭제 
            if v['user_type'] ~= 'new_user' then
                table.insert(self.m_lStartTamerInfo, v)
            end     
        end
    end
end

-------------------------------------
-- function getData
-------------------------------------
function ServerData_StartTamer:getData()
    return self.m_lStartTamerInfo
end

-------------------------------------
-- function request_createAccount
-------------------------------------
function ServerData_StartTamer:request_createAccount(user_type, nick, finish_cb)
    -- 파라미터
    local uid = g_serverData:get('local', 'uid')

    -- 콜백 함수
    local function success_cb(ret)
        local nick = ret['nick']

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/newuser_set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('nick', nick)
    ui_network:setParam('user_type', user_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end