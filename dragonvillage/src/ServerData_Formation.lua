-------------------------------------
-- class ServerData_Formation
-------------------------------------
ServerData_Formation = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Formation:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Formation:getRankData(rank_type)
	local rank_type = rank_type or 0
	
	if (self.m_mRankingMap[rank_type]) then
		return self.m_mRankingMap[rank_type]
	end
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Formation:setRankData(rank_type, rank_data)
	local rank_type = rank_type or 0
    self.m_mRankingMap[rank_type] = rank_data
end

-------------------------------------
-- function request_getRank
-------------------------------------
function ServerData_Formation:request_getRank(cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

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
    ui_network:setUrl('/users/get/rank')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end
