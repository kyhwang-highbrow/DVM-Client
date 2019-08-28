-------------------------------------
-- class ServerData_Ranking
-------------------------------------
ServerData_Ranking = class({
        m_serverData = 'ServerData',
		m_mRankingMap = 'rank'
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Ranking:init(server_data)
    self.m_serverData = server_data
	self.m_mRankingMap = {}
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Ranking:getRankData(rank_type)
	local rank_type = rank_type or 0
	
	if (self.m_mRankingMap[rank_type]) then
		return self.m_mRankingMap[rank_type]
	end
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Ranking:setRankData(rank_type, rank_data)
	local rank_type = rank_type or 0
    self.m_mRankingMap[rank_type] = rank_data
end

-------------------------------------
-- function request_getRank
-------------------------------------
function ServerData_Ranking:request_getRank(rank_type, offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local rank_type = rank_type or 0
	local offset = offset or nil

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:firstTimeExperience('TotalRanking_Confirm')

		-- 한번 본 랭킹은 맵 형태로 저장
		self:setRankData(rank_type, ret)

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get/rank')
    ui_network:setParam('uid', uid)
	ui_network:setParam('type', rank_type)
	ui_network:setParam('offset', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_HallOfFameRank
-------------------------------------
function ServerData_Ranking:request_HallOfFameRank(type, limit, offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local offset = offset or nil

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:firstTimeExperience('TotalRanking_Confirm')
        --Analytics:firstTimeExperience('HallOfFameRanking_Confirm')

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/halloffame/rank')
    ui_network:setParam('uid', uid)
	ui_network:setParam('type', type)
	ui_network:setParam('offset', offset)
    ui_network:setParam('limit', rank_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end
