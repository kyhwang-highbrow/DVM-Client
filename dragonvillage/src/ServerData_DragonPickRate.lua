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
-- function request_getPickRate
-------------------------------------
function ServerData_DragonPickRate:request_getPickRate(data, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local category = data['category']
	local group = data['group']
	local stage = data['stage']

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        --Analytics:firstTimeExperience('TotalRanking_Confirm')

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/use_percent_info')
    ui_network:setParam('uid', uid)
	ui_network:setParam('category', category)
	ui_network:setParam('group', group)
    ui_network:setParam('stage', stage)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end
