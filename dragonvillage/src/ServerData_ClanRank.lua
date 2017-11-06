-------------------------------------
-- class ServerData_ClanRank
-------------------------------------
ServerData_ClanRank = class({
        m_serverData = 'ServerData',

		m_mRankingMap = 'Map<string, List<table> >', -- rank_type : ancient, colosseum
        m_mMyRankingMap = 'Map<string, table>',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRank:init(server_data)
    self.m_serverData = server_data
	self.m_mRankingMap = {}
    self.m_mMyRankingMap = {}
end

-------------------------------------
-- function getRankData
-------------------------------------
function ServerData_ClanRank:getRankData(rank_type)
	local rank_type = rank_type
	
	if (self.m_mRankingMap[rank_type]) then
		return self.m_mRankingMap[rank_type]
	end
end

-------------------------------------
-- function getMyRankData
-------------------------------------
function ServerData_ClanRank:getMyRankData(rank_type)
	local rank_type = rank_type
	
	if (self.m_mMyRankingMap[rank_type]) then
		return self.m_mMyRankingMap[rank_type]
	end
end

-------------------------------------
-- function setRankData
-------------------------------------
function ServerData_ClanRank:setRankData(rank_type, rank_data)
    if (not self.m_mRankingMap[rank_type]) then
        self.m_mRankingMap[rank_type] = {}
    end

    local rank
    for i, t_data in ipairs(rank_data) do
        rank = tonumber(t_data['rank'])
        table.insert(self.m_mRankingMap[rank_type], StructClanRank(t_data))
    end
end

-------------------------------------
-- function setMyRankData
-------------------------------------
function ServerData_ClanRank:setMyRankData(rank_type, rank_data)
    self.m_mMyRankingMap[rank_type] = StructClanRank(rank_data)
end

-------------------------------------
-- function request_getRank
-------------------------------------
function ServerData_ClanRank:request_getRank(rank_type, offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local rank_type = rank_type
	local offset = offset

    -- 콜백 함수
    local function success_cb(ret)
		-- 한번 본 랭킹은 맵 형태로 저장
		self:setRankData(rank_type, ret['list'])
        self:setMyRankData(rank_type, ret['my_info'])

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/rank')
    ui_network:setParam('uid', uid)
	ui_network:setParam('rank_type', rank_type)
	ui_network:setParam('offset', offset)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end
