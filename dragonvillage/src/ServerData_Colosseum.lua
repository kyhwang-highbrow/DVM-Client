-------------------------------------
-- class ServerData_Colosseum
-------------------------------------
ServerData_Colosseum = class({
        m_serverData = 'ServerData',

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
			UIManager:toastNotificationGreen('콜로세움 오픈 전입니다.\n오픈까지 ' .. self:getWeekTimeText())
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

    --[[
    ret['histraight']
    ret['hitier']
    ret['hirank']
    
    ret['straight']
    ret['tier']
    ret['rank']
    ret['rp']
    --]]

    self.m_startTime = ret['start_time']
    self.m_startTime = ret['endtime']
end

-------------------------------------
-- function isOpenColosseum
-- @breif 콜로세움 오픈 여부
-------------------------------------
function ServerData_Colosseum:isOpenColosseum()
    local server_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
	
	return (start_time > server_time)
end

-------------------------------------
-- function getWeekTimeText
-- @breif 주차의 남은 시간
-------------------------------------
function ServerData_Colosseum:getWeekTimeText()
    local server_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    -- 콜로세움 오픈 전
    if (start_time < server_time) then
        local showSeconds = true
        local time_text = datetime.makeTimeDesc((server_time - start_time), showSeconds)
        local text = Str('{1} 후 열림', time_text)
        return text
    -- 콜로세움 오픈 후
    else
        local showSeconds = true
        local time_text = datetime.makeTimeDesc((start_time - server_time), showSeconds)
        local text = Str('{1} 남음', time_text)
        return text
    end
end