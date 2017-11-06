-------------------------------------
-- class ServerData_ClanRank
-------------------------------------
ServerData_ClanRank = class({
        m_serverData = 'ServerData',

		m_mRankingMap = 'Map<string, List<table> >', -- rank_type : ancient, colosseum
        m_mMyRankingMap = 'Map<string, table>',
        m_mOffsetMap = 'Map<string, number>',
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
    local struct_clan = g_clanData:getClanStruct()
    local my_clan_id = 'not_exist'
    if (struct_clan) then
        my_clan_id = struct_clan:getClanObjectID()
    end

    for i, t_data in ipairs(rank_data) do
        t_data['isMyClan'] = (t_data['id'] == my_clan_id)
        table.insert(self.m_mRankingMap[rank_type], StructClanRank(t_data))
    end
end

-------------------------------------
-- function setMyRankData
-------------------------------------
function ServerData_ClanRank:setMyRankData(rank_type, rank_data)
    if (not rank_data) then
        return
    end

    rank_data['isMyClan'] = true
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
-- function request_getRank
-------------------------------------
function ServerData_ClanRank:request_getRank(rank_type, offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local rank_type = rank_type
	local offset = offset

    self.m_mRankingMap[rank_type] = {}
    self.m_mOffsetMap[rank_type] = offset

    -- 콜백 함수
    local function success_cb(ret)
		-- 한번 본 랭킹은 맵 형태로 저장
		self:setRankData(rank_type, ret['list'])
        self:setMyRankData(rank_type, ret['my_claninfo'])

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
