-------------------------------------
-- class ServerData_DragonPickRate
-------------------------------------
ServerData_DragonPickRate = class({
        m_serverData = 'ServerData',
		m_mRankingMap = 'rank'
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonPickRate:init(server_data)
    self.m_serverData = server_data
	self.m_mRankingMap = {}
end

-------------------------------------
-- function getDragonMythReturnDidList
-- @brief   신화 드래곤 소환 복각 풀 팝업 자동화
--          처음으로 부화소에 편입되는 신화 드래곤 리스트
-------------------------------------
function ServerData_DragonPickRate:getDragonMythReturnDidList()
    local t_map = TABLE:get('table_pickup_schedule')
    local curr_time_millisec = ServerTime:getInstance():getCurrentTimestampSeconds()
    local secs_7days = 7*(60*60*24) -- 노출 기간 7일
    local did_list = {}

    for _, v in pairs(t_map) do
        local t_dragon = TableDragon():get(v['did'])
        local summon_start_date = t_dragon['summon_add']
        if summon_start_date ~= '' then
            if (string.find(summon_start_date, ':') == nil) then
                summon_start_date = summon_start_date .. ' 00:00:00'
            end

            local start_timestamp_sec = ServerTime:getInstance():datestrToTimestampSec(summon_start_date)
            local secs = curr_time_millisec - start_timestamp_sec

            if secs > 0 and secs < secs_7days then
                table.insert(did_list, v['did'])
            end
        end
    end

    return did_list
end


-------------------------------------
-- function request_getPickRate
-------------------------------------
function ServerData_DragonPickRate:request_getPickRate(data, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local category = data['category']
	local group = data['group']
	local stage = data['stage']

    -- 데이터가 빌 수도 있다고 함
    if (not group) or (not tonumber(group)) or group <= 0 then
        group = 3010000
    end

    if (not stage) or (not tonumber(stage)) or stage <= 0 then
        stage = 3011001
    end

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        --Analytics:firstTimeExperience('TotalRanking_Confirm')

		if (cb_func) then
			cb_func(ret)
		end
    end
    
    -- 응답 상태 처리 함수
    local t_error = {
        [-1190] = Str('오류가 발생했습니다.'), -- 테이블이 없는 경우?
        [-9999] = Str('오류가 발생했습니다.'), -- unknown
    }

    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/use_percent_info')
    ui_network:setParam('uid', uid)
	ui_network:setParam('category', category)
	ui_network:setParam('group', group)
    ui_network:setParam('stage', stage)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end
