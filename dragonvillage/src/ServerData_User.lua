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
-- @brief 보유중인 열매 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getFruitList(is_all)
    local is_all = is_all or false
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

    -- 소유하지 않은 열매도 count 0으로 만듬
    if (is_all) then    
        l_ret = self:makeEmptyData(l_ret, 'fruit')
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
-- @brief 보유중인 진화석 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getEvolutionStoneList(is_all)
    local is_all = is_all or false
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

    if (is_all) then
        l_ret = self:makeEmptyData(l_ret, 'evolution_stones')
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
-- function getTransformList
-- @brief 보유중인 외형 변환 리스트 리턴(가방에서 사용)
-------------------------------------
function ServerData_User:getTransformList(is_all)
    local is_all = is_all or false
    local l_transform = self:getRef('transform_materials')

    -- key가 item_id(=material_id)이고 value가 count인 리스트 생성
    local l_ret = {}
    for k,v in pairs(l_transform) do
        local material_id = tonumber(k)
        local count = v

        local t_data = {}
        t_data['mid'] = material_id
        t_data['count'] = count
        if (count > 0) then
            table.insert(l_ret, t_data)
        end
    end

    if (is_all) then
        l_ret = self:makeEmptyData(l_ret, 'transform')
    end

    return l_ret
end

-------------------------------------
-- function getTransformMaterialCount
-- @brief 보유중인 외형 변환 재료 갯수 리턴
-------------------------------------
function ServerData_User:getTransformMaterialCount(material_id)
    local material_id = tostring(material_id)
    local count = self:get('transform_materials', material_id) or 0
    return count
end

-------------------------------------
-- function makeEmptyData
-- @brief 보유하지 않은 아이템도 count 0으로 생성 (진화재료, 열매, 외형변환)
-------------------------------------
function ServerData_User:makeEmptyData(l_ret, type)
    local key
    local base_item_id
    local map_id = {}
      
    if (type == 'evolution_stones') then
        key = 'esid'
        base_item_id = 7011
        -- 진화재료는 속성별 아이템 말고 전체 아이템 따로 추가
        map_id['701011'] = 0
        map_id['701012'] = 0
        map_id['701013'] = 0
        map_id['701014'] = 0

    elseif (type == 'fruit') then
        key = 'fid'
        base_item_id = 7020

    elseif (type == 'transform') then
        key = 'mid'
        base_item_id = 7050
    end

    -- 속성별로 
    for attr_no = 1, 5 do
        -- 4단계
        for idx = 1, 4 do
            local tar_id = string.format('%d%d%d', base_item_id, idx, attr_no)
            map_id[tar_id] = 0
        end
    end

    for tar_id, _ in pairs(map_id) do
        local tar_id = tonumber(tar_id)
        local is_exist = false

        for i,v in ipairs(l_ret) do
            local check_id = v[key]
            if (check_id == tar_id) then
                is_exist = true
                break
            end
        end

        if (not is_exist) then
            local t_data = {}
            t_data[key] = tar_id
            t_data['count'] = 0
            table.insert(l_ret, t_data)
        end
    end

    return l_ret
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
-- function getDragonGiftTime
-- @brief 드래곤이 선물을 주는 시간
-------------------------------------
function ServerData_User:getDragonGiftTime()
    return self:get('lobby_gift_box_at') / 1000
end

-------------------------------------
-- function requestDragonGift
-- @brief 드래곤에게 선물을 요구
-------------------------------------
function ServerData_User:requestDragonGift(cb_func)
    -- 파라미터
    local uid = self:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 받은 아이템 처리
        g_serverData:networkCommonRespone_addedItems(ret)
		-- 선물 받을 수 있는 시간 갱신
		self:applyServerData(ret['lobby_gift_box_at'], 'lobby_gift_box_at')

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/lobby/gift')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	ui_network:hideLoading()
end

-------------------------------------
-- function getTicketList
-- @brief 보유중인 티켓 리스트 리턴(가방에서 사용)
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
-- function request_changeNick
-------------------------------------
function ServerData_User:request_changeNick(mid, code, nick, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 에러코드 처리
    local function result_cb(ret)
        if (ret['status'] == -1126) then
            local msg = Str('이미 존재하는 닉네임입니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return true -- 자체적으로 통신 처리를 완료했다는 뜻
        end
    end

    -- 콜백 함수
    local function success_cb(ret)
        -- nickname 적용
        self:applyServerData(nick, 'nick')

        -- 채팅 서버에 변경사항 적용
        if g_chatClientSocket then
            g_chatClientSocket:globalUpdatePlayerUserInfo()
        end

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/nick/change')
    ui_network:setParam('uid', uid)
	ui_network:setParam('nick', nick)
    ui_network:setParam('mid', mid)
    ui_network:setParam('code', code)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getTitleID
-- @biref 칭호 ID
-------------------------------------
function ServerData_User:getTitleID()
    return self:get('tamer_title')
end

-------------------------------------
-- function getTamerTitleStr
-- @biref 칭호 받아오기
-------------------------------------
function ServerData_User:getTamerTitleStr()
    local tamer_title_id = self:get('tamer_title')
    return TableTamerTitle:getTamerTitleStr(tamer_title_id)
end

-------------------------------------
-- function request_getTitleList
-------------------------------------
function ServerData_User:request_getTitleList(cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        if (cb_func) then
            cb_func(ret['tamer_title']) -- 이것은 리스트
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tamer_title_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_setTitle
-------------------------------------
function ServerData_User:request_setTitle(title_id, cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 바뀐 타이틀 저장
        self:applyServerData(ret['tamer_title'], 'tamer_title')

        -- 채팅 서버에 변경사항 적용
        if g_chatClientSocket then
            g_chatClientSocket:globalUpdatePlayerUserInfo()
        end

        if (cb_func) then
            cb_func()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tamer_title_set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('title_id', title_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end



-------------------------------------
-- function getReinforcePoint
-- @brief 강화포인트 갯수
-------------------------------------
function ServerData_User:getReinforcePoint(item_id)
	return self:get('reinforce_point')[tostring(item_id)] or 0
end