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
-- function init
-------------------------------------
function ServerData_DragonBoard:getBoards(did)
	return self.m_mBoardMap[did]
end

-------------------------------------
-- function applyBoard
-------------------------------------
function ServerData_DragonBoard:applyBoard(did, t_data)
	if (did) then
		for i, t_board in pairs(self.m_mBoardMap[did]) do
			if (t_board['id'] == t_data['id']) then
				self.m_mBoardMap[did][i] = t_data
			end
		end

	else
		for did, l_board_list in pairs(self.m_mBoardMap) do
			for i, t_board in pairs(l_board_list['boards']) do
				if (t_board['id'] == t_data['id']) then
					self.m_mBoardMap[did]['boards'][i] = t_data
				end
			end
		end

	end
end

-------------------------------------
-- function applyData
-------------------------------------
function ServerData_DragonBoard:applyData(did, column, data)
	self.m_mBoardMap[did][column] = data
end

-------------------------------------
-- function request_dragonBoard
-------------------------------------
function ServerData_DragonBoard:request_dragonBoard(did, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local did = did

    -- 콜백 함수
    local function success_cb(ret)
		self.m_mBoardMap[did] = ret
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/board')
    ui_network:setParam('uid', uid)
	ui_network:setParam('did', did)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
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
    ui_network:setRevocable(false)
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
		self:applyData(did, 'rate', data)

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
    ui_network:setRevocable(false)
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
    ui_network:setRevocable(false)
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
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

