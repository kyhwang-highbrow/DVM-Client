MAX_DRAGON_RESEARCH_LV = 10

-------------------------------------
-- class ServerData_Book
-------------------------------------
ServerData_Book = class({
        m_serverData = 'ServerData',

        -- 드래곤 콜렉션 데이터(실제 도감 정보)
        m_mBookData = 'map',

        -- 드래곤 원종별 도감
        m_mDragonTypeBookData = 'map',
        -- {
        --   'pinkbell':true,
        --   'jaryong':true,
        --   'powerdragon':true
        -- }

		-- 드래곤 보상 정보
		m_tBookReward = 'map',

        m_lastChangeTimeStamp = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Book:init(server_data)
    self.m_serverData = server_data
    self.m_mBookData = {}
    self.m_mDragonTypeBookData = {}
	self.m_tBookReward = {}
end

-------------------------------------
-- function getBookList
-------------------------------------
function ServerData_Book:getBookList(role_type, attr_type)
    local role_type = (role_type or 'all')
    local attr_type = (attr_type or 'all')

    local l_ret = {}

    local table_dragon = TableDragon()
    for i, v in pairs(table_dragon.m_orgTable) do
		-- 직업군, 속성 걸러내기
		if (role_type ~= 'all') and (role_type ~= v['role']) then
        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then

        -- 위 조건들에 해당하지 않은 경우만 추가
        else
            local did = v['did']
			local key = did
			
			-- 자코는 진화하지 않으므로 evolution 1 만 담는다.
			if (table_dragon:isUnderling(did)) then
				local t_dragon = clone(v)
				t_dragon['evolution'] = 1
				t_dragon['grade'] = t_dragon['birthgrade']
				t_dragon['bookType'] = 'dragon'

				l_ret[key] = t_dragon

			-- 진화도를 만들어준다.
			else
				for i = 1, 3 do
					local t_dragon = clone(v)
					local grade_factor = (i == 3) and 1 or 0
					t_dragon['evolution'] = i
					t_dragon['grade'] = t_dragon['birthgrade'] + grade_factor
					t_dragon['bookType'] = 'dragon'

					l_ret[key + (i * 1000000)] = t_dragon
				end
			end
        end
    end

	-- 슬라임도 추가..!
	local table_slime = TableSlime()
    for i, v in pairs(table_slime.m_orgTable) do
		-- 직업군, 속성 걸러내기
		if (role_type ~= 'all') and (role_type ~= v['role']) then
        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then

        -- 위 조건들에 해당하지 않은 경우만 추가
        else
			local key = v['slime']
			local t_slime = clone(v)
			t_slime['did'] = key		-- 도감 did 정렬을 위해..
			t_slime['evolution'] = 1
			t_slime['grade'] = t_slime['birthgrade']
			t_slime['bookType'] = 'slime'

			l_ret[key] = t_slime
		end
	end
    return l_ret
end

-------------------------------------
-- function request_BookInfo
-------------------------------------
function ServerData_Book:request_bookInfo(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self:response_bookInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/book/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_bookInfo
-------------------------------------
function ServerData_Book:response_bookInfo(ret)
    do -- 드래곤 도감
        for i,v in pairs(ret['book']) do
            local did = tonumber(i)
            local struct_book_data = StructBookData(v)
            struct_book_data:setDragonID(did)

            self.m_mBookData[did] = struct_book_data
        end
    end

    do -- 드래곤 원종별 도감
        self.m_mDragonTypeBookData = ret['dragon_type']
    end

	do -- 드래곤 도감 보상 정보
		self.m_tBookReward = ret['reward_info']
	end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function openBookPopup
-------------------------------------
function ServerData_Book:openBookPopup(close_cb)
    local function cb()
        local ui = UI_Book()
        ui:setCloseCB(close_cb)
    end

    self:request_bookInfo(cb)
end

-------------------------------------
-- function getBookData
-- @brief
-------------------------------------
function ServerData_Book:getBookData(did)
    -- 정보가 없는 경우 생성
    if (not self.m_mBookData[did]) then
        local struct_book_data = StructBookData()
        struct_book_data:setDragonID(did)
        self.m_mBookData[did] = struct_book_data
    end

    return self.m_mBookData[did]
end

-------------------------------------
-- function isExist
-- @brief 도감에 표시 여부 .. reward_info 를 활용한다.
-------------------------------------
function ServerData_Book:isExist(t_dragon_data)
	local did = t_dragon_data['did']
	local t_info = self.m_tBookReward[tostring(did)]

	if (not t_info) then
		return false
	end
	local evolution = t_dragon_data['evolution']
	local reward_type = t_info['evo_' .. evolution] or 0
	return (reward_type >= 1)
end

-------------------------------------
-- function isExistDragonType
-- @brief 도감에 표시 여부
-------------------------------------
function ServerData_Book:isExistDragonType(dragon_type)
    if self.m_mDragonTypeBookData[dragon_type] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function setDragonBook
-- @brief 도감에 드래곤 등록
-------------------------------------
function ServerData_Book:setDragonBook(did)
    local struct_book_data = self:getBookData(did)

    do -- 드래곤 원종의 도감 정보
        local dragon_type = TableDragon():getValue(tonumber(did), 'type')
        if (not self.m_mDragonTypeBookData[dragon_type]) then
            self.m_mDragonTypeBookData[dragon_type] = 0
        end
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function getCollectCount
-- @brief 수집한 드래곤 수
-- @param t_dragon_book - 도감 테이블뷰에서 가져온 아이템 리스트
-------------------------------------
function ServerData_Book:getCollectCount(t_dragon_book)
	local cnt = 0
	local t_dragon_data

	for did, t_reward in pairs(self.m_tBookReward) do
		for _, v in pairs(t_reward) do
			if (v > 0) then
				cnt = cnt + 1
			end
		end
	end

	return cnt
end





-------------------------------------
-- function haveBookReward
-- @brief 수집한 드래곤 수
-------------------------------------
function ServerData_Book:haveBookReward(did, evolution)
	local t_info = self.m_tBookReward[tostring(did)]

	if (not t_info) then
		return false
	end
	local reward_type = t_info['evo_' .. evolution]
	return (reward_type == 1)
end

-------------------------------------
-- function request_useRelationPoint
-------------------------------------
function ServerData_Book:request_bookReward(did, evolution, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
		-- 들어온 재화 적용
		g_serverData:networkCommonRespone(ret)
		
		-- 탑바 갱신
		g_topUserInfo:refreshData()

		-- 보상 수령한 정보 처리
		--self.m_tBookReward[tostring(did)]['evo_' .. evolution] = nil
		self.m_tBookReward = ret['reward_info']

		-- 시간 갱신        
		self:setLastChangeTimeStamp()

        if finish_cb then
            finish_cb()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/book/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setParam('evo', evolution)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end





-------------------------------------
-- function getRelationPoint
-- @brief 인연포인트
-------------------------------------
function ServerData_Book:getRelationPoint(did)
    local struct_book_data = self:getBookData(did)
    return struct_book_data:getRelation()
end

-------------------------------------
-- function applyRelationPoints
-- @brief 인연포인트
-------------------------------------
function ServerData_Book:applyRelationPoints(relation_point_map)
    for i,v in pairs(relation_point_map) do
        local did = tonumber(i)
        local relation = v

        local struct_book_data = self:getBookData(did)
        struct_book_data:setRelation(relation)
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function request_useRelationPoint
-------------------------------------
function ServerData_Book:request_useRelationPoint(did, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 마지막으로 데이터가 변경된 시간 갱신
        self:setLastChangeTimeStamp()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/relation')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setParam('cnt', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end








-------------------------------------
-- function setLastChangeTimeStamp
-- @breif 마지막으로 데이터가 변경된 시간 갱신
-------------------------------------
function ServerData_Book:setLastChangeTimeStamp()
    self.m_lastChangeTimeStamp = Timer:getServerTime()
end

-------------------------------------
-- function getLastChangeTimeStamp
-------------------------------------
function ServerData_Book:getLastChangeTimeStamp()
    return self.m_lastChangeTimeStamp
end

-------------------------------------
-- function checkChange
-------------------------------------
function ServerData_Book:checkChange(timestamp)
    if (self.m_lastChangeTimeStamp ~= timestamp) then
        return true
    end

    return false
end






-------------------------------------
-- function getBookNotiList
-- @brief 도감에서 noti를 표시해줘야할 탭 리스트
-------------------------------------
function ServerData_Book:getBookNotiList()
	local table_dragon = TableDragon()
	
	local attr, role
	local t_dragon
	local have_reward
	local t_ret = {}
	
	for did, t_info in pairs(self.m_tBookReward) do
		-- did의 보상이 있는지 검사	
		have_reward = false
		for i, reward in pairs(t_info) do
			if (reward == 1) then
				have_reward = true
				break
			end
		end

		-- 노티 세팅
		if (have_reward) then
			t_dragon = table_dragon:get(tonumber(did))
			if (t_dragon) then
				attr = t_dragon['attr']
				role = t_dragon['role']

				t_ret[attr] = true
				t_ret[role] = true
			end
		end
	end

	return t_ret
end


-------------------------------------
-- function getBookNotiList
-- @brief 하이라이트(노티) 여부
-------------------------------------
function ServerData_Book:isHighlightBook()
	for did, t_info in pairs(self.m_tBookReward) do
		for i, reward in pairs(t_info) do
			if (reward == 1) then
				return true
			end
		end
	end

	return false
end