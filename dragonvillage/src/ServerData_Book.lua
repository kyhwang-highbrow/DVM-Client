-------------------------------------
-- class ServerData_Book
-- @comment 최초 1회만 book/info를 호출하고 이후에는 드래곤이 추가되는 경우에 클라에서 수정
-------------------------------------
ServerData_Book = class({
        m_serverData = 'ServerData',

        -- 드래곤 콜렉션 데이터(실제 도감 정보)
        m_mBookData = 'map',

		-- 드래곤 보상 정보
		m_tBookReward = 'map',
        --"120483":{
          --"evo_1":2,  -- 2는 보상 기 수령
          --"evo_2":1   -- 1은 보상 수령 가능
                        -- 없는 것은 획득하지 않은 것
        --},

        m_lastChangeTimeStamp = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Book:init(server_data)
    self.m_serverData = server_data
    self.m_mBookData = {}
	self.m_tBookReward = {}
end

-------------------------------------
-- function getBookList
-------------------------------------
function ServerData_Book:getBookList(role_type, attr_type, only_hatch)
    local role_type = (role_type or 'all')
    local attr_type = (attr_type or 'all')
    local only_hatch = (only_hatch or false) -- 해치 정보만 받음 (도감 묶음 UI에 필요)

    local l_ret = {}

    local table_dragon = TableDragon()
    for i, v in pairs(table_dragon.m_orgTable) do
        -- 개발 중인 드래곤은 도감에 나타내지 않는다.
        if (not g_dragonsData:isReleasedDragon(v['did'])) then
		
        -- 직업군, 속성 걸러내기
		elseif (role_type ~= 'all') and (role_type ~= v['role']) then
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
                t_dragon['lv'] = 1
				t_dragon['bookType'] = 'dragon'

				l_ret[key] = t_dragon

			-- 진화도를 만들어준다.
			else
                local max_cnt = only_hatch and 1 or 3
				for i = 1, max_cnt do
					local t_dragon = clone(v)
					local grade_factor = (i == 3) and 1 or 0
					t_dragon['evolution'] = i
					t_dragon['grade'] = t_dragon['birthgrade'] + grade_factor
					t_dragon['bookType'] = 'dragon'
                    t_dragon['lv'] = 1

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
        elseif (129215 == v['slime']) then -- 스킬 슬라임이 등급별(129235, 129245, 129255)로 개편되면서 기존 스슬은 도감에서 노출되지 않도록 변경

        -- 위 조건들에 해당하지 않은 경우만 추가
        else
			local key = v['slime']
			local t_slime = clone(v)
			t_slime['did'] = key		-- 도감 did 정렬을 위해..
			t_slime['evolution'] = 1
			t_slime['grade'] = t_slime['birthgrade']
			t_slime['bookType'] = 'slime'
            t_slime['lv'] = 1

			l_ret[key] = t_slime
		end
	end
    return l_ret
end

-------------------------------------
-- function getSameTypeSlimeList
-- @brief 같은 타입 슬라임 도감 데이터로 반환
-------------------------------------
function ServerData_Book:getSameTypeSlimeList(slime_id)
    local table_slime = TableSlime()
    local attr_key = tostring(getDigit(slime_id, 10, 2))
    local l_ret = {}

    for i, v in pairs(table_slime.m_orgTable) do
        local did = v['slime']
        local key = tostring(getDigit(did, 10, 2))

        if (attr_key == key) then
            local t_slime = clone(v)
			t_slime['did'] = did		
			t_slime['evolution'] = 1
			t_slime['grade'] = t_slime['birthgrade']
			t_slime['bookType'] = 'slime'

			l_ret[did] = t_slime
        end
	end
    
    return l_ret
end

-------------------------------------
-- function request_bookInfo
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

	do -- 드래곤 도감 보상 정보
		self:setBookRewardData(ret['reward_info'])
	end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function setBookRewardData
-------------------------------------
function ServerData_Book:setBookRewardData(t_reward_info)
    self.m_tBookReward = t_reward_info

    -- 전설 스킬 슬라임을 희귀도별로 나누면서 129255로 변경하여 사용
    -- 도감에 노출되지 않는 129215번 전설 스킬 슬라임은 정보에서 제거
    self.m_tBookReward['129215'] = nil
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
    local evolution = t_dragon_data['evolution']
    local ret_val = self:isExist_byDidAndEvolution(did, evolution)
	return ret_val
end

-------------------------------------
-- function isExist_byDidAndEvolution
-- @brief 도감에 표시 여부 .. reward_info 를 활용한다.
-------------------------------------
function ServerData_Book:isExist_byDidAndEvolution(did, evolution)
	local t_info = self.m_tBookReward[tostring(did)]

	if (not t_info) then
		return false
	end

    -- 0 or nil : 획득하지 않은 드래곤
    -- 1 : 보상 수령 가능한 드래곤
    -- 2 : 보상까지 수령한 드래곤
	local reward_type = t_info['evo_' .. evolution] or 0
	return (reward_type >= 1)
end

-------------------------------------
-- function isExist_all
-- @brief 모든 진화 단계를 다 수집했는지 여부
-------------------------------------
function ServerData_Book:isExist_all(did)
	local t_info = self.m_tBookReward[tostring(did)]

	if (not t_info) then
		return false
	end

    local max_evolution = MAX_DRAGON_EVOLUTION
    if TableDragon:isUnderling(did) then
        max_evolution = 1
    end

    for i=1, max_evolution do

        -- 0 or nil : 획득하지 않은 드래곤
        -- 1 : 보상 수령 가능한 드래곤
        -- 2 : 보상까지 수령한 드래곤
        local state_num = t_info['evo_' .. i]
        if (not state_num) or (state_num <= 0) then
            return false
        end
    end

    return true
end

-------------------------------------
-- function setDragonBook
-- @brief 도감에 드래곤 등록
-------------------------------------
function ServerData_Book:setDragonBook(t_dragon_data)
    local did = t_dragon_data['did']
    local evolution = t_dragon_data['evolution']
    if (not did) or (not evolution) then
        return false
    end

    -- 도감 데이터 등록
    self:getBookData(did)

    -- 획득 및 보상 여부 판단
    do
        did = tostring(did)
        if (not self.m_tBookReward[did]) then
            self.m_tBookReward[did] = {}
        end
        -- 보상 수령 가능 상태로 설정
        if (not self.m_tBookReward[did]['evo_' .. evolution]) then
            self.m_tBookReward[did]['evo_' .. evolution] = 1
        end
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function setSlimeBook
-- @brief 도감에 슬라임 등록
-------------------------------------
function ServerData_Book:setSlimeBook(slime_id)
    if (not slime_id) or (slime_id == 129215) then
        return false
    end

    -- 도감 데이터 등록
    self:getBookData(slime_id)

    -- 획득 및 보상 여부 판단
    do
        slime_id = tostring(slime_id)
        if (not self.m_tBookReward[slime_id]) then
            self.m_tBookReward[slime_id] = {}
        end
        -- 보상 수령 가능 상태로 설정
        if (not self.m_tBookReward[slime_id]['evo_1']) then
            self.m_tBookReward[slime_id]['evo_1'] = 1
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
-- function request_bookReward
-------------------------------------
function ServerData_Book:request_bookReward(did, evolution, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:trackGetGoodsWithRet(ret, '도감 보상')
        Analytics:firstTimeExperience('Book_Rewrad')

		-- 들어온 재화 적용
		g_serverData:networkCommonRespone(ret)

        -- 보상 수령한 정보 처리
        self:setBookRewardData(ret['reward_info'])

		-- 시간 갱신        
		self:setLastChangeTimeStamp()

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        if finish_cb then
            finish_cb(ret['cash'])
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
-- function request_bookRewardAll
-------------------------------------
function ServerData_Book:request_bookRewardAll(finish_cb)
	-- 유저 ID
    local uid = g_userData:get('uid')
    -- 성공 콜백
    local function success_cb(ret)
		-- @analytics
        -- Analytics:trackGetGoodsWithRet(ret, '도감 보상')
        -- Analytics:firstTimeExperience('Book_Rewrad')

		-- 들어온 재화 적용
		g_serverData:networkCommonRespone(ret)

        -- 보상 수령한 정보 처리
        self:setBookRewardData(ret['reward_info'])

		-- 시간 갱신        
		self:setLastChangeTimeStamp()

		-- 로비 노티 갱신
		g_highlightData:setDirty(true)

        if finish_cb then
            finish_cb(ret['cash'])
        end
	end

	-- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/book/reward_all')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function hasReward
-- @brief 하나라도 보상받을 도감 드래곤이 있는지 확인
-------------------------------------
function ServerData_Book:hasReward()
	local table_dragon = TableDragon()
    local table_slime = TableSlime()

	for did, t_info in pairs(self.m_tBookReward) do
		-- did의 보상이 있는지 검사	
		have_reward = false
		for _, reward in pairs(t_info) do
			if (reward == 1) then
				return true
			end
		end
	end

	return false
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
		-- 골드 갱신
		self.m_serverData:networkCommonRespone(ret)

        -- 인연포인트 (전체 갱신)
		if (ret['relation']) then
			g_bookData:applyRelationPoints(ret['relation'])
		end
		
		-- 드래곤 추가
        if (ret['dragon']) then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- 마지막으로 데이터가 변경된 시간 갱신
        self:setLastChangeTimeStamp()

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

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
    local table_slime = TableSlime()
	
	local attr, role
	local t_dragon
	local have_reward
	local t_ret = {}
	
	for did, t_info in pairs(self.m_tBookReward) do
		-- did의 보상이 있는지 검사	
		have_reward = false
		for _, reward in pairs(t_info) do
			if (reward == 1) then
				have_reward = true
				break
			end
		end

		-- 노티 세팅 (속성만 표시)
		if (have_reward) then
            local did_num = tonumber(did)
			t_dragon = table_dragon:get(did_num)

            if (not t_dragon) then
                t_dragon = table_slime:get(did_num)

                if (not t_dragon) then
                    --cclog('정의되지 않은 슬라임 id :: ' .. tostring(did_num))
                elseif (t_dragon['slime'] == 129215) then
                    t_dragon = nil
                end
            end

			if (t_dragon) then
				attr = t_dragon['attr']
				--role = t_dragon['role']

				t_ret[attr] = true
				--t_ret[role] = true
			end
		end
	end

	return t_ret
end


-------------------------------------
-- function isHighlightBook
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