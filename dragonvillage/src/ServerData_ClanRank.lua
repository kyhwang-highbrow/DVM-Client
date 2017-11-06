-------------------------------------
-- class ServerData_ClanRank
-------------------------------------
ServerData_ClanRank = class({
        m_serverData = 'ServerData',
		m_mRankingMap = 'rank' -- rank_type : ancient, colosseum
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRank:init(server_data)
    self.m_serverData = server_data
	self.m_mRankingMap = {}
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRank:getRankData(rank_type)
	local rank_type = rank_type or 0
	
	if (self.m_mRankingMap[rank_type]) then
		return self.m_mRankingMap[rank_type]
	end
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRank:setRankData(rank_type, rank_data)
	local rank_type = rank_type or 0
    self.m_mRankingMap[rank_type] = rank_data
end

-------------------------------------
-- function request_getRank
-------------------------------------
function ServerData_ClanRank:request_getRank(rank_type, offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local rank_type = rank_type or 0
	local offset = offset or nil

    -- 콜백 함수
    local function success_cb(ret)
		-- 한번 본 랭킹은 맵 형태로 저장
		self:setRankData(rank_type, ret)

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/clan/rank')
    ui_network:setParam('uid', uid)
	ui_network:setParam('rank_type', rank_type)
	ui_network:setParam('offset', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end
