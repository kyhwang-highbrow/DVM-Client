-------------------------------------
-- class ServerData_User
-------------------------------------
ServerData_User = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_User:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_User:get(...)
    return self.m_serverData:get('user', ...)
end

-------------------------------------
-- function getRef
-------------------------------------
function ServerData_User:getRef(...)
    return self.m_serverData:getRef('user', ...)
end

-------------------------------------
-- function applyServerData
-------------------------------------
function ServerData_User:applyServerData(data, ...)
    return self.m_serverData:applyServerData(data, 'user', ...)
end

-------------------------------------
-- function getFruitList
-- @brief 보유중인 열매 리스트 리턴(인벤토리에서 사용)
-------------------------------------
function ServerData_User:getFruitList()
    local l_fruis = self:getRef('fruits')

    -- key가 item_id(=fruit_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_fruis) do
        local fruit_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['fid'] = fruit_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function getFruitCount
-- @brief 보유중인 열매 갯수 리턴
-------------------------------------
function ServerData_User:getFruitCount(fruit_id)
    local fruit_id = tostring(fruit_id)
    local count = self:get('fruits', fruit_id) or 0
    return count
end

-------------------------------------
-- function getResetFruitCount
-- @brief 망각의 열매 갯수 리턴
-------------------------------------
function ServerData_User:getResetFruitCount()
    local fruit_id = self:getResetFruitID()
    return self:getFruitCount(fruit_id)
end

-------------------------------------
-- function getResetFruitID
-- @brief 망각의 열매 ID
-------------------------------------
function ServerData_User:getResetFruitID()
    -- 망각의 열매 id : 702009
    return 702009
end

-------------------------------------
-- function getEvolutionStoneList
-- @brief 보유중인 진화석 리스트 리턴(인벤토리에서 사용)
-------------------------------------
function ServerData_User:getEvolutionStoneList()
    local l_evolution_stone = self:getRef('evolution_stones')

    -- key가 item_id(=esid)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_evolution_stone) do
        local evolution_stone_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['esid'] = evolution_stone_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function getEvolutionStoneCount
-- @brief 보유중인 진화재료 갯수 리턴
-------------------------------------
function ServerData_User:getEvolutionStoneCount(evolution_stone_id)
    local evolution_stone_id = tostring(evolution_stone_id)
    local count = self:get('evolution_stones', evolution_stone_id) or 0
    return count
end

-------------------------------------
-- function getUserLevelInfo
-- @brief
-------------------------------------
function ServerData_User:getUserLevelInfo()
    local table_user_level = TableUserLevel()

    local lv = g_userData:get('lv')
    local exp = g_userData:get('exp')
    local percentage = table_user_level:getUserLevelExpPercentage(lv, exp)

    return lv, exp, percentage
end

-------------------------------------
-- function getFruitPackCount
-- @brief 인벤에서 슬롯을 차지하는 열매 갯수
-------------------------------------
function ServerData_User:getFruitPackCount()
    local l_evolution_stone = self:getRef('fruits')

    local count = 0
    for i,v in pairs(l_evolution_stone) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function getEvolutionStonePackCount
-- @brief 인벤에서 슬롯을 차지하는 진화석 갯수
-------------------------------------
function ServerData_User:getEvolutionStonePackCount()
    local l_evolution_stone = self:getRef('evolution_stones')

    local count = 0
    for i,v in pairs(l_evolution_stone) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function getTamerInfo
-- @brief 테이머 정보
-- @param key - 있으면 해당 필드의 값을 반환하고 없다면 전체 테이블 반환
-------------------------------------
function ServerData_User:getTamerInfo(key)
	local tamer_idx = self:getRef('tamer')
	if (tamer_idx == 0) then
		tamer_idx = g_constant:get('INGAME', 'TAMER_VALUE') + 1
	end

	local t_tamer = TableTamer():get(tamer_idx)
	if (key) then
		return t_tamer[key]
	else
		return t_tamer
	end
end

-------------------------------------
-- function request_setTamer
-------------------------------------
function ServerData_User:request_setTamer(tid, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
	local tid = tid or (g_constant:get('INGAME', 'TAMER_VALUE') + 1)

    -- 콜백 함수
    local function success_cb()
        self:applyServerData(tid, 'tamer')
		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/set/tamer')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', tid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getTicketList
-- @brief 보유중인 티켓 리스트 리턴(인벤토리에서 사용)
-------------------------------------
function ServerData_User:getTicketList()
    local l_tickets = self:getRef('tickets')

    -- key가 item_id(=ticket_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for i,v in pairs(l_tickets) do
        local ticket_id = tonumber(i)
        local count = v

        local t_data = {}
        t_data['ticket_id'] = ticket_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function getTicketCOunt
-- @brief 보유 중인 티켓 갯수 리턴
-------------------------------------
function ServerData_User:getTicketCOunt(ticket_id)
    local ticket_id = tostring(ticket_id)
    local count = self:get('tickets', ticket_id) or 0
    return count
end

-------------------------------------
-- function getTicketPackCount
-- @brief 인벤에서 슬롯을 차지하는 티켓 갯수
-------------------------------------
function ServerData_User:getTicketPackCount()
    local l_tickets = self:getRef('tickets')

    local count = 0
    for i,v in pairs(l_tickets) do
        if (0 < v) then
            count = (count + 1)
        end
    end

    return count
end

-------------------------------------
-- function request_ticketUse
-------------------------------------
function ServerData_User:request_ticketUse(ticket_id, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 받은 아이템 처리
        g_serverData:networkCommonRespone_addedItems(ret)

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/ticket/use')
    ui_network:setParam('uid', uid)
	ui_network:setParam('tid', ticket_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end