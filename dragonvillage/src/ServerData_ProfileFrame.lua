-------------------------------------
--- @class ServerData_ProfileFrame
-------------------------------------
ServerData_ProfileFrame = class({
    m_profileFramesMap = 'Table<number, number>',
    m_profileFrame = 'number',
})

-------------------------------------
--- @function init
-------------------------------------
function ServerData_ProfileFrame:init(server_data)
    self.m_profileFramesMap = {}
    self.m_profileFrame = 0
end

-------------------------------------
--- @function getSelectedProfileFrame
--- @brief 현재 착용한 프로필 프레임 아이디
-------------------------------------
function ServerData_ProfileFrame:getSelectedProfileFrame()
    if self:isExpiredProfileFrame(self.m_profileFrame) == true then
        return 0
    end

    return self.m_profileFrame
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
--- @function isOwnedProfileFrame
--- @brief 보유여부
-------------------------------------
function ServerData_ProfileFrame:isOwnedProfileFrame(profile_frame_id)
    local expired_at = self.m_profileFramesMap[profile_frame_id] or 0
    if expired_at == 0 then
        return false
    end

    return not self:isExpiredProfileFrame(profile_frame_id)
end

-------------------------------------
--- @function response_info
-------------------------------------
function ServerData_ProfileFrame:response_info(ret)
    if ret['profile_frames'] ~= nil then
        self.m_profileFramesMap = ret['profile_frames']
    end

    if ret['profile_frame'] ~= nil then
        self.m_profileFrame = ret['profile_frame']
    end

end

-------------------------------------
--- @function request_equip
--- @brief 착용하기
-------------------------------------
function ServerData_ProfileFrame:request_equip(profile_frame, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        self:response_info(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/profile_frame_set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('id', profile_frame)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end