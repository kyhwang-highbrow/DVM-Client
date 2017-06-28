-------------------------------------
-- class ServerData_Colosseum
-------------------------------------
ServerData_Colosseum = class({
        m_serverData = 'ServerData',

        m_playerUserInfo = 'StructUserInfoColosseum',
        m_playerUserInfoHighRecord = 'StructUserInfoColosseum',

        m_startTime = 'timestamp', -- 콜로세움 오픈 시간
        m_endTime = 'timestamp', -- 콜로세움 종료 시간

        m_matchList = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Colosseum:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function goToColosseum
-------------------------------------
function ServerData_Colosseum:goToColosseum()
    local function cb()
		if (self:isOpenColosseum()) then
            UI_Colosseum()
		else
			UIManager:toastNotificationGreen('콜로세움 오픈 전입니다.\n오픈까지 ' .. self:getColosseumStatusText())
		end
    end

    self:request_colosseumInfo(cb)
end

-------------------------------------
-- function request_colosseumInfo
-------------------------------------
function ServerData_Colosseum:request_colosseumInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_colosseumInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_colosseumInfo
-------------------------------------
function ServerData_Colosseum:response_colosseumInfo(ret)
    self.m_matchList = ret['matchlist']

    self.m_startTime = ret['start_time']
    self.m_endTime = ret['endtime']

    self:refresh_playerUserInfo(ret)
    self:refresh_playerUserInfo_highRecord(t_data)
end

-------------------------------------
-- function isOpenColosseum
-- @breif 콜로세움 오픈 여부
-------------------------------------
function ServerData_Colosseum:isOpenColosseum()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function refresh_playerUserInfo
-------------------------------------
function ServerData_Colosseum:refresh_playerUserInfo(t_data)
    if (not self.m_playerUserInfo) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoColosseum()
        struct_user_info.m_uid = g_userData:get('uid')
        self.m_playerUserInfo = struct_user_info
    end

    self:_refresh_playerUserInfo(self.m_playerUserInfo, t_data)
end

-------------------------------------
-- function refresh_playerUserInfo_highRecord
-- @brief 최고 기록 당시 데이터
-------------------------------------
function ServerData_Colosseum:refresh_playerUserInfo_highRecord(t_data)
    if (not self.m_playerUserInfoHighRecord) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoColosseum()
        struct_user_info.m_uid = g_userData:get('uid')
        self.m_playerUserInfoHighRecord = struct_user_info
    end

    local t_data_new = {}
    t_data_new['win'] = t_data_new['hiwin']
    t_data_new['lose'] = t_data_new['hilose']
    t_data_new['rp'] = t_data_new['hirp']
    t_data_new['tier'] = t_data_new['hitier']
    t_data_new['straight'] = t_data_new['histraight']

    self:_refresh_playerUserInfo(self.m_playerUserInfoHighRecord, t_data_new)
end

-------------------------------------
-- function _refresh_playerUserInfo
-------------------------------------
function ServerData_Colosseum:_refresh_playerUserInfo(struct_user_info, t_data)
    -- 최신 정보로 갱신
    struct_user_info.m_nickname = g_userData:get('nick')
    struct_user_info.m_lv = g_userData:get('lv')

    do -- 콜로세움 정보 갱신
        if t_data['win'] then
            struct_user_info.m_winCnt = t_data['win']
        end

        if t_data['lose'] then
            struct_user_info.m_loseCnt = t_data['lose']
        end

        if t_data['rp'] then
            struct_user_info.m_rp = t_data['rp']
        end

        if t_data['tier'] then
            struct_user_info.m_tier = t_data['tier']
        end

        if t_data['straight'] then
            struct_user_info.m_straight = t_data['straight']
        end
    end
end

-------------------------------------
-- function getPlayerColosseumUserInfo
-------------------------------------
function ServerData_Colosseum:getPlayerColosseumUserInfo()
    return self.m_playerUserInfo
end

-------------------------------------
-- function getPlayerColosseumUserInfoHighRecord
-------------------------------------
function ServerData_Colosseum:getPlayerColosseumUserInfoHighRecord()
    return self.m_playerUserInfoHighRecord
end

-------------------------------------
-- function getColosseumStatusText
-------------------------------------
function ServerData_Colosseum:getColosseumStatusText()
    local curr_time = Timer:getServerTime()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    local str = ''
    if (curr_time < start_time) then
        --str = Str('시즌이 종료되었습니다.')
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))

    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))

    else
        str = Str('시즌이 종료되었습니다.')
    end

    return str
end