-- clan 랭크 종류 및 키 정의
CLAN_RANK = 
{
    ['ANCT'] = 'ancient',
    ['CLSM'] = 'colosseum',
    ['RAID'] = 'dungeon',
    ['AREN'] = 'arena',
    ['LEVEL'] = 'level',
}

-------------------------------------
-- class ServerData_ClanRank
-------------------------------------
ServerData_ClanRank = class({
        m_serverData = 'ServerData',

		m_mRankingMap = 'Map<string, List<table> >',
        m_mMyRankingMap = 'Map<string, table>',
        m_mOffsetMap = 'Map<string, number>',

        m_isSettlingDown = 'bool', -- 정산 여부
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ClanRank:init(server_data)
    self.m_serverData = server_data
	self.m_mRankingMap = {}
    self.m_mMyRankingMap = {}
    self.m_mOffsetMap = {}
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
    for i, t_data in ipairs(rank_data) do
        table.insert(self.m_mRankingMap[rank_type], StructClanRank(t_data))
    end
end

-------------------------------------
-- function setMyRankData
-- @brief 최초 한번만 받고 계속 저장하고 있는다
-------------------------------------
function ServerData_ClanRank:setMyRankData(rank_type, rank_data)
    if (not rank_data) then
        return
    end
    
    self.m_mMyRankingMap[rank_type] = StructClanRank(rank_data)
end

-------------------------------------
-- function getOffset
-------------------------------------
function ServerData_ClanRank:getOffset(rank_type)
    if (not rank_type) then
        return 1
    end
    return self.m_mOffsetMap[rank_type] or 1
end

-------------------------------------
-- function getOffset
-------------------------------------
function ServerData_ClanRank:isSettlingDown()
    return self.m_isSettlingDown
end

-------------------------------------
-- function initRankData
-------------------------------------
function ServerData_ClanRank:initRankData(rank_type)
    self.m_mRankingMap[rank_type] = {}
end

-------------------------------------
-- function request_getRank
-------------------------------------
function ServerData_ClanRank:request_getRank(rank_type, offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local rank_type = rank_type
	local offset = offset

    -- rank 호출할 때 해당 rank_type rank 초기화
    self:initRankData(rank_type)
    -- offset 저장 (주도적으로 쓰이지 않음)
    self.m_mOffsetMap[rank_type] = offset

    -- 콜백 함수
    local function success_cb(ret)
		self:setRankData(rank_type, ret['list'])
        self:setMyRankData(rank_type, ret['my_claninfo'])
        self.m_isSettlingDown = ret['settle_down']

		if (cb_func) then
			cb_func(ret)
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
