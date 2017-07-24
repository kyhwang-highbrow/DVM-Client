-------------------------------------
-- class ServerData_DragonBoard
-------------------------------------
ServerData_DragonBoard = class({
        m_serverData = 'ServerData',

		m_mBoardMap = 'Map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonBoard:init(server_data)
    self.m_serverData = server_data
	self.m_mBoardMap = {}
end

-------------------------------------
-- function getBoards
-------------------------------------
function ServerData_DragonBoard:getBoards(did)
	return self.m_mBoardMap[did]
end

-------------------------------------
-- function getRate
-------------------------------------
function ServerData_DragonBoard:getRate(did)
	return self.m_mBoardMap[did]['rate']
end

-------------------------------------
-- function makeDataPretty
-------------------------------------
function ServerData_DragonBoard:makeDataPretty(table_data, offset)
	local offset = offset or 0
	local t_ret = {}

	for i, t_data in ipairs(table_data) do
		local idx = i + offset
		t_data['idx'] = idx
		t_ret[idx] = t_data
	end

	return t_ret
end

-------------------------------------
-- function applyBoard
-------------------------------------
function ServerData_DragonBoard:applyBoard(did, t_data)
	if (did) then
		for i, t_board in pairs(self.m_mBoardMap[did]) do
			if (t_board['id'] == t_data['id']) then
				table.apply(self.m_mBoardMap[did][i], t_data)
			end
		end

	else
		for did, l_board_list in pairs(self.m_mBoardMap) do
			for i, t_board in pairs(l_board_list['boards']) do
				if (t_board['id'] == t_data['id']) then
					table.apply(self.m_mBoardMap[did]['boards'][i], t_data)
				end
			end
		end

	end
end

-------------------------------------
-- function request_dragonBoard
-------------------------------------
function ServerData_DragonBoard:request_dragonBoard(did, offset, order, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local did = did
	local offset = offset
	local order = order

    -- 콜백 함수
    local function success_cb(ret)
		local l_board_list = ret['boards']

		if (offset == 0) then
			-- 초기화
			self.m_mBoardMap[did] = nil

			-- 내 기록이 있는 경우 최상단에 넣음
			if (ret['myboard']) then
				local t_my_board = ret['myboard']
				for i, t_board in pairs(l_board_list) do
					if (t_board['id'] == t_my_board['id']) then
						table.remove(l_board_list, i)
						break
					end
				end
				table.insert(l_board_list, 1, t_my_board)
			end
		end

		-- idx를 부여
		l_board_list = self:makeDataPretty(l_board_list, offset)

		-- 멤버 변수에 저장
		if (self.m_mBoardMap[did]) then

			-- idx 관리를 위해 덮어씌운다.
			for i, t_board in pairs(l_board_list) do
				local idx = t_board['idx']
				self.m_mBoardMap[did]['boards'][idx] = t_board
			end
		else
			self.m_mBoardMap[did] = ret
		end

		-- 콜백 실행
		if (cb_func) then
			cb_func(l_board_list)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/board')
    ui_network:setParam('uid', uid)
	ui_network:setParam('did', did)
	ui_network:setParam('offset', offset)
	ui_network:setParam('order', order)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_dragonRate
-- @brief 드래곤 평점만을 받아옴.
-------------------------------------
function ServerData_DragonBoard:request_dragonRate(did, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/rate')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setSuccessCB(success_cb)
    ui_network:hideLoading()
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_writeBoard
-- @brief 리뷰를 남긴다.
-------------------------------------
function ServerData_DragonBoard:request_writeBoard(did, review_str, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local did = did
	local review_str = review_str

    -- 콜백 함수
    local function success_cb(ret)
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/board/rate')
    ui_network:setParam('uid', uid)
	ui_network:setParam('did', did)
	ui_network:setParam('review', review_str)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_rateBoard
-- @brief 평점을 매긴다.
-------------------------------------
function ServerData_DragonBoard:request_rateBoard(did, rate, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local did = did
	local rate = rate

    -- 콜백 함수
    local function success_cb(ret)
		-- 평균 평점 갱신
		self.m_mBoardMap[did]['rate'] = ret['rate']
		-- 나의 평점 갱신
		self.m_mBoardMap[did]['myrate'] = rate

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/board/rate')
    ui_network:setParam('uid', uid)
	ui_network:setParam('did', did)
	ui_network:setParam('rate', rate)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_likeBoard
-- @param did : map 접근용
-------------------------------------
function ServerData_DragonBoard:request_likeBoard(did, revid , cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local revid = revid

    -- 콜백 함수
    local function success_cb(ret)
		self:applyBoard(did, ret['board'])

		if (cb_func) then
			cb_func(ret['board'])
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/board/like')
    ui_network:setParam('uid', uid)
	ui_network:setParam('revid', revid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_deleteBoard
-------------------------------------
function ServerData_DragonBoard:request_deleteBoard(revid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local revid = revid

    -- 콜백 함수
    local function success_cb(ret)
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/board/del')
    ui_network:setParam('uid', uid)
	ui_network:setParam('revid', revid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

