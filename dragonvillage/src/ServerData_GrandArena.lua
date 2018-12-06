-------------------------------------
-- class ServerData_GrandArena
-- @instance g_grandArena
-------------------------------------
ServerData_GrandArena = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_GrandArena:init(server_data)
end


-------------------------------------
-- function isActive_grandArena
-- @brief 그랜드 콜로세움 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_GrandArena:isActive_grandArena()
    return true
end

-------------------------------------
-- function request_grandArenaInfo
-- @brief 그랜드 콜로세움 이벤트 요청
-------------------------------------
function ServerData_GrandArena:request_grandArenaInfo(finish_cb, fail_cb, include_reward)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 동기화
        g_serverData:networkCommonRespone(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- -1351 invalid time (오픈 시간이 아님)
        if (ret['status'] == -1351) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'))
            return true
        end

        return false
    end

    -- 서버에서 테이블 정보를 받아옴
        --[[
    local include_tables = false
    if (self.m_challengeRewardTable == nil) or (self.m_challengeManageTable == nil) then
        include_tables = true
    end
    --]]
    
    -- 시즌 보상을 받을지 여부 (타이틀 화면에서 정보 요청을 위해 호출될때는 제외하기 위함)
    local include_reward = (include_reward or false)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('include_infos', include_infos)
    --ui_network:setParam('include_tables', include_tables)
    ui_network:setParam('reward', include_reward) -- true면 시즌 보상을 지금, false면 시즌 보상을 미지급
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end