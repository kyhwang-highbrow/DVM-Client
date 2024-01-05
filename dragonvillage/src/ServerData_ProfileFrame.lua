-------------------------------------
--- @class ServerData_ProfileFrame
-------------------------------------
ServerData_ProfileFrame = class({
    m_profileFramesMap = 'Table<number, number>',
})

-------------------------------------
--- @function init
-------------------------------------
function ServerData_ProfileFrame:init(server_data)
    self.m_profileFramesMap = {}
end

-------------------------------------
--- @function getSelectedProfileFrame
--- @brief 현재 착용한 프로필 프레임 아이디
-------------------------------------
function ServerData_ProfileFrame:getSelectedProfileFrame()
    return 0
end

-------------------------------------
--- @function isExpiredProfileFrame
--- @brief 프로필 프레임 아이디 만료 기한
-------------------------------------
function ServerData_ProfileFrame:isExpiredProfileFrame(profile_frame_id)
    local expired_at = self.m_profileFramesMap[profile_frame_id] or 0
    if expired_at == 0 then
        return false
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    return curr_time > expired_at
end

-------------------------------------
--- @function response_info
-------------------------------------
function ServerData_ProfileFrame:response_info(ret)
    if ret['profile_frames'] ~= nil then
        self.m_profileFramesMap = ret['profile_frames']
    end
end

-------------------------------------
--- @function request_researchUpgrade
--- @brief 연구하기
-------------------------------------
function ServerData_ProfileFrame:request_researchUpgrade(research_id, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/research/buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('id', research_id)
    ui_network:setParam('price', price)

    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end