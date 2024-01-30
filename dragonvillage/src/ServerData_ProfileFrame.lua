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

end

-------------------------------------
--- @function getSelectedProfileFrame
--- @brief 현재 착용한 프로필 프레임 아이디
-------------------------------------
function ServerData_ProfileFrame:getSelectedProfileFrame()
    local profile_frame = g_userData:get('profile_frame') or 0
    if self:isExpiredProfileFrame(profile_frame) == true then
        return 0
    end

    return profile_frame
end

-------------------------------------
--- @function isExpiredProfileFrame
--- @brief 프로필 프레임 아이디 만료 기한
-------------------------------------
function ServerData_ProfileFrame:isExpiredProfileFrame(profile_frame_id)
    local profile_frame_map = g_userData:get('profile_frames') or {}
    local expired_at = profile_frame_map[tostring(profile_frame_id)] or 0
    if expired_at == 0 then
        return false, 0
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    return curr_time > expired_at, expired_at - curr_time
end

-------------------------------------
--- @function isExpiredProfileFrame
--- @brief 프로필 프레임 아이디 만료 기한
-------------------------------------
function ServerData_ProfileFrame:getRemainTimeStr(profile_frame_id)
    local _, remain_time_mil_sec = self:isExpiredProfileFrame(profile_frame_id)
    if remain_time_mil_sec > 0 then
        local remain_time_sec = remain_time_mil_sec/1000
        msg = Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(remain_time_sec))
        return msg
    end
    return ''
end

-------------------------------------
--- @function isOwnedProfileFrame
--- @brief 보유여부
-------------------------------------
function ServerData_ProfileFrame:isOwnedProfileFrame(profile_frame_id)
    local profile_frame_map = g_userData:get('profile_frames') or {}
    local expired_at = profile_frame_map[tostring(profile_frame_id)] or 0
    if expired_at == 0 then
        return false
    end

    return not self:isExpiredProfileFrame(profile_frame_id)
end

-------------------------------------
--- @function response_info
--- @brief 착용하기
-------------------------------------
function ServerData_ProfileFrame:response_info(ret)
    if ret['profile_frames'] ~= nil then
        g_userData:applyServerData(ret['profile_frames'], 'profile_frames')
    end

    if ret['profile_frame'] ~= nil then
        g_userData:applyServerData(ret['profile_frame'], 'profile_frame')
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
    ui_network:setParam('profile_frame', profile_frame)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()
end