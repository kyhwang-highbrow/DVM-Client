-------------------------------------
---@class ServerData_LobbyNotice
-- @instance g_lobbyNoticeData
---@return ServerData_LobbyNotice
-------------------------------------
ServerData_LobbyNotice = class({
        m_serverData = 'ServerData',
        m_lStructLobbyNotice = 'list[StructLobbyNotice]',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_LobbyNotice:init(server_data)
    self.m_serverData = server_data
    self.m_lStructLobbyNotice = {}
end

-------------------------------------
-- function applyLobbyNoticeListData
-- @brief /users/lobby에서 lobby_notice_list로 받음
-- @param t_data 리스트 형태
-------------------------------------
function ServerData_LobbyNotice:applyLobbyNoticeListData(l_lobby_notice_data)

    local l_lobby_notice_data = (l_lobby_notice_data or {})
    
    -- 테스트 데이터 추가
    --table.insert(l_lobby_notice_data, StructLobbyNotice:makeSampleData())
    
    self.m_lStructLobbyNotice = {}

    for i,v in ipairs(l_lobby_notice_data) do
        local struct_lobby_notice = StructLobbyNotice(v)
        table.insert(self.m_lStructLobbyNotice, struct_lobby_notice)
    end
end

-------------------------------------
-- function getStructLobbyNoticeList
-- @return
-------------------------------------
function ServerData_LobbyNotice:getStructLobbyNoticeList()
    return self.m_lStructLobbyNotice or {}
end

-------------------------------------
-- function request_getLobbyNoticeReward
-- @brief 마을 알림 보상 받기
-- @param lobby_notice_id string
-------------------------------------
function ServerData_LobbyNotice:request_getLobbyNoticeReward(lobby_notice_id, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
        local error_str = string.format('%s\n[Error code = %d]', Str('오류가 발생했습니다.'), ret['status'])
        MakeNetworkPopup(POPUP_TYPE.OK, error_str, function()
            if finish_cb then
                finish_cb(ret)
            end
        end)
    end

    -- 에러코드 처리
    local function response_status_cb(ret)
        -- not exist reward
        if (ret['status'] == -1152) then
            local error_str = string.format('%s\n[Error code = %d]', Str('오류가 발생했습니다.'), ret['status'])
            MakeNetworkPopup(POPUP_TYPE.OK, error_str, function()
                if finish_cb then
                    finish_cb(ret)
                end
            end)
            return true

        -- already receive reward
        elseif (ret['status'] == -3352) then
            MakeNetworkPopup(POPUP_TYPE.OK, Str('이미 획득한 보상입니다.'), function()
                if finish_cb then
                    finish_cb(ret)
                end
            end)
            return true

        end

        return false
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_lobby_notice_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('notice_id', lobby_notice_id)
    ui_network:setParam('is_delete', true) -- 보상 수령과 동시에 삭제하라는 의미
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end