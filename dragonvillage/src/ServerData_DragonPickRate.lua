-------------------------------------
-- class ServerData_DragonPickRate
-------------------------------------
ServerData_DragonPickRate = class({
        m_serverData = 'ServerData',
		m_mRankingMap = 'rank',

    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonPickRate:init(server_data)
    self.m_serverData = server_data
	self.m_mRankingMap = {}
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
