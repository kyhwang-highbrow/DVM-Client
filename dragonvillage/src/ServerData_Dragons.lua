-------------------------------------
---@class ServerData_Dragons
---@return ServerData_Dragons
-------------------------------------
ServerData_Dragons = class({
        m_serverData = 'ServerData',
        m_leaderDragonOdid = 'string', -- 리더 드래곤의 obejct id

        m_lSortData = 'list', -- doid를 key값으로 하고, 정렬에 필요한 데이터를 저장

        m_mNumOfDragonsByDid = 'map',
        m_bDirtyNumOfDragonsByDid = 'boolean',

        m_lastChangeTimeStamp = 'timestamp',
        m_dragonsCnt = 'number', -- 현재 드래곤 보유 갯수

        m_dragonBestCombatPower = 'number', -- 개별 드래곤 최고 전투력
        m_bUpdatePower = 'boolean',

        m_mSkillMovePrice = 'map',

        m_mReleasedDragonsByDid = 'map', -- 출시된 드래곤

        m_structRecallList = 'table', -- 리콜 대상인 드래곤의 did 리스트
        m_bRecallNoti = 'boolean',
    })

SKILL_MOVE_DRAGON_GRADE = 4 -- 스킬 이전 가능한 드래곤 태생 등급 (4등급 이상부터 가능)

-------------------------------------
-- function init
---@param server_data ServerData
-------------------------------------
function ServerData_Dragons:init(server_data)
    self.m_serverData = server_data
    self.m_lSortData = {}
    self.m_mNumOfDragonsByDid = {}
    self.m_mSkillMovePrice = {}
    self.m_mReleasedDragonsByDid = {}
    self.m_bDirtyNumOfDragonsByDid = true
    self.m_dragonsCnt = 0
    self.m_dragonBestCombatPower = 0
    self.m_bUpdatePower = false

    self.m_structRecallList = {}
    self.m_bRecallNoti = true
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Dragons:get(key)
    return self.m_serverData:get('dragons', key)
end

-------------------------------------
-- function getDragonsList
-------------------------------------
function ServerData_Dragons:getDragonsList()
    local l_dragons = self.m_serverData:getRef('dragons')
    return clone(l_dragons)
end

-------------------------------------
-- function getDragonsListRef
-------------------------------------
function ServerData_Dragons:getDragonsListRef()
    return self.m_serverData:getRef('dragons')
end

-------------------------------------
-- function getDragonListWithSlime
-------------------------------------
function ServerData_Dragons:getDragonListWithSlime()
    local dragon_dictionary = self:getDragonsListRef()
    local slime_dictionary = g_slimesData:getSlimeList()

    local ret_dictionary = {}

    for key,value in pairs(dragon_dictionary) do
        ret_dictionary[key] = value
    end

    for key,value in pairs(slime_dictionary) do
        ret_dictionary[key] = value
    end

    return ret_dictionary
end

-------------------------------------
-- function getDragonsListWithAttr
-- @brief 해당 속성 드래곤만 반환
-------------------------------------
function ServerData_Dragons:getDragonsListWithAttr(attr)
    local dragon_dictionary = self:getDragonsListRef()
    local ret_dictionary = {}

    for key,value in pairs(dragon_dictionary) do
        local did = value['did']
        local _attr = TableDragon:getDragonAttr(did)

        if (attr == _attr) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getDragonsListWithRole
-- @brief 해당 역할 드래곤만 반환
-------------------------------------
function ServerData_Dragons:getDragonsListWithRole(role)
    local dragon_dictionary = self:getDragonsListRef()
    local ret_dictionary = {}

    for key,value in pairs(dragon_dictionary) do
        local _role = value:getRole()

        if (role == _role) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getDragonsListWithRarity
-- @brief 해당 등급 드래곤만 반환
---@param rarity string
---@return table
-------------------------------------
function ServerData_Dragons:getDragonsListWithRarity(rarity)
    local dragon_dictionary = self:getDragonsListRef()
    local ret_dictionary = {}

    for key, value in pairs(dragon_dictionary) do
        if (value:getRarity() == rarity) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getDragonsListExceptTarget
-- @brief 해당 드래곤 제외하고 반환
-------------------------------------
function ServerData_Dragons:getDragonsListExceptTarget(map_except)
    local dragon_dictionary = self:getDragonsListRef()

    -- 해당 드래곤과 같은 종류 역시 제외하자
    local map_did = {}
    for key,value in pairs(map_except) do
        local dragon = dragon_dictionary[key]
        local did_key = tostring(dragon['did'])
        map_did[did_key] = true
    end

    local ret_dictionary = {}
    for key,value in pairs(dragon_dictionary) do
        local did_key = tostring(value['did'])
        if (not map_did[did_key] and not map_except[key]) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getDragonsListExceptTargetDids
-- @brief 해당 드래곤 did만 제외하고 반환
-- 레이드 덱에 포함되어 있는 드래곤 제외용
-------------------------------------
function ServerData_Dragons:getDragonsListExceptTargetDoids(map_doid)
    local dragon_dictionary = self:getDragonsListRef()

    local ret_dictionary = {}
    for key,value in pairs(dragon_dictionary) do
        local doid_key = tostring(value['doid'])
        if (not map_doid[doid_key] and not map_doid[key]) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end


-------------------------------------
-- function getDragonsListWithSkin
-- @brief 스킨 있는 드래곤들만 리스트에서 반환
-- @dhkim 23.02.17
-------------------------------------
function ServerData_Dragons:getDragonsListWithSkin()
    local dragon_dictionary = self:getDragonsListRef()
    local ret_dictionary = {}

    for key,value in pairs(dragon_dictionary) do
        local did = value['did']

        if (g_dragonSkinData:isDragonSkinExist(did) == true) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getMyDragonsListWithSkin
-- @brief 현재 스킨을 장착한 드래곤 리스트 가져옴
-- @dhkim 23.02.17
-------------------------------------
function ServerData_Dragons:getMyDragonsListWithSkin()
    local dragon_dictionary = self:getDragonsListRef()
    local ret_dictionary = {}

    for key,value in pairs(dragon_dictionary) do
        local skin_id = value['dragon_skin']

        if (skin_id ~= nil and skin_id ~= 0) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end



-------------------------------------
-- function getDragonSkillMoveList
-------------------------------------
function ServerData_Dragons:getDragonSkillMoveList(tar_doid)
    local dragon_dictionary = self:getDragonsListRef()
    local dragon_obj = self.m_serverData:getRef('dragons', tar_doid)
    local tar_birth_grade = TableDragon:getBirthGrade(dragon_obj['did'])

    local ret_dictionary = {}

    if (tar_birth_grade >= SKILL_MOVE_DRAGON_GRADE) then
        for doid,value in pairs(dragon_dictionary) do
            -- 태생 등급 같고 스킬 레벨업된 드래곤만 포함
            local birth_grade = TableDragon:getBirthGrade(value['did'])
            if (self:isSkillEnhanced(doid) and tar_birth_grade == birth_grade) then
                ret_dictionary[doid] = value
            end
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getDragonsList_specificDid
-------------------------------------
function ServerData_Dragons:getDragonsList_specificDid(did)
    local l_dragons = self.m_serverData:getRef('dragons')

    local l_ret = {}
    for _,v in pairs(l_dragons) do
        if (did == v['did']) then
            local unique_id = v['id']
            l_ret[unique_id] = clone(v)
        end
    end

    return l_ret
end

-------------------------------------
-- function getDragonDataFromUid
-- @brief doid 로 드래곤 정보를 얻음
-------------------------------------
function ServerData_Dragons:getDragonDataFromUid(doid)
    local dragon_obj = self.m_serverData:getRef('dragons', doid)

    if dragon_obj then
        return clone(dragon_obj)
    end
    
    -- 임시 친구 드래곤까지 검사
    local friend_dragon_obj = g_friendData:getDragonDataFromDoid(doid)

    if friend_dragon_obj then
        return clone(friend_dragon_obj)
    end

    return nil
end

-------------------------------------
-- function getDragonDataFromUidRef
-- @brief doid 로 드래곤 정보를 얻음
-------------------------------------
function ServerData_Dragons:getDragonDataFromUidRef(doid)
    local dragon_obj = self.m_serverData:getRef('dragons', doid)
    return dragon_obj
end

-------------------------------------
-- function applyDragonData_list
-- @brief 서버에서 넘어오는 드래곤의 정보 갱신
-------------------------------------
function ServerData_Dragons:applyDragonData_list(l_dragon_data)
    g_serverData:lockSaveData()
    for i,v in pairs(l_dragon_data) do
        local t_dragon_data = v
        self:applyDragonData(t_dragon_data)
    end

    g_serverData:unlockSaveData()
end

-------------------------------------
-- function applyDragonData
-- @brief
-------------------------------------
function ServerData_Dragons:applyDragonData(t_dragon_data)
    local doid = t_dragon_data['id']

    local dragon_obj = self.m_serverData:getRef('dragons', doid)

    if dragon_obj and (dragon_obj['updated_at'] == t_dragon_data['updated_at']) then
        return
    end

    if (not dragon_obj) then   
        self.m_dragonsCnt = self.m_dragonsCnt + 1
        local created_at = t_dragon_data['created_at'] or nil
        g_highlightData:addNewDoid(doid, created_at)
    end

    -- 룬 효과 체크
    if t_dragon_data then
        --t_dragon_data['rune_set'] = self:makeDragonRuneSetData(t_dragon_data)
        for i,roid in pairs(t_dragon_data['runes']) do
            if (roid ~= '') then
                g_runesData:applyEquippedRuneInfo(roid, doid)
            end
        end
        
        local grade = t_dragon_data['grade']
        local lv = t_dragon_data['lv']
        if (grade == 6) and (lv == 60) then
            Analytics:firstTimeExperience('DragonLevelUp_6_60')
        end
    end

    -- 드래곤 오브젝트 생성
    local dragon_obj = StructDragonObject(t_dragon_data)
    self.m_serverData:applyServerData(dragon_obj, 'dragons', doid)
    -- 드래곤 정렬 데이터 수정
    self:setDragonsSortData(doid)

    -- 드래곤 did별 갯수 갱신 필요
    self.m_bDirtyNumOfDragonsByDid = true

    -- 추가된 드래곤은 도감에 추가
    g_bookData:setDragonBook(t_dragon_data)

    -- 채팅 서버의 리더 드래곤 정보 갱신 체크용
    if self:isLeaderDragon(doid) then
        -- 채팅 서버에 변경사항 적용
        g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
    end

    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function makeDragonRuneSetData
-- @brief
-------------------------------------
function ServerData_Dragons:makeDragonRuneSetData(t_dragon_data)
    -- @delete_rune
    if true then
        return
    end
    local runes_map = t_dragon_data['runes']

    local runes_list = {}
    for i,v in pairs(runes_map) do
        local roid = v
        table.insert(runes_list, roid)
    end

    local t_rune_set = g_runesData:makeRuneSetData_usingRoid(runes_list[1], runes_list[2], runes_list[3])
    return t_rune_set
end

-------------------------------------
-- function delDragonData
-- @brief
-------------------------------------
function ServerData_Dragons:delDragonData(doid)
    if self.m_serverData:getRef('dragons', doid) then
        self.m_serverData:applyServerData(nil, 'dragons', doid)
        self.m_dragonsCnt = (self.m_dragonsCnt - 1)
    end

    -- 드래곤 did별 갯수 갱신 필요
    self.m_bDirtyNumOfDragonsByDid = true

    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function isLockDragon
-- @brief 잠금 여부 체크
-------------------------------------
function ServerData_Dragons:isLockDragon(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false
    end

    return t_dragon_data:getLock()
end

-------------------------------------
-- function getLeaderDragon
-- @brief 리더드래곤의 정보를 얻어옴
-------------------------------------
function ServerData_Dragons:getLeaderDragon(type)
    type = (type or 'lobby')
    local t_leaders = self.m_serverData:getRef('user', 'leaders')
    local doid = t_leaders[type]

    if (not doid) then
        return nil
    end

    local t_dragon_data = self:getDragonDataFromUid(doid)
    return t_dragon_data
end

-------------------------------------
-- function isLeaderDragon
-- @brief 리더드래곤으로 설정되어있는지 여부 체크
-------------------------------------
function ServerData_Dragons:isLeaderDragon(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false, {}
    end

    local cnt = table.count(t_dragon_data['leader'])
    local is_leader = (0 < cnt)
    return is_leader, t_dragon_data['leader']
end

-------------------------------------
-- function getChangeSkillLvSlot
-- @brief 스킬업이나 다운된 슬롯 반환
-------------------------------------
function ServerData_Dragons:getChangeSkillLvSlot(pre_drogon_data)
    if (not pre_drogon_data) then
        return 0
    end
    local doid = pre_drogon_data['id']
    local cur_dragon_data = self:getDragonDataFromUid(doid)
    local evolution = cur_dragon_data['evolution']
	
	-- active 부터 진화도까지
	for i = 0, evolution do
        local pre_lv = pre_drogon_data['skill_' .. i]
		local cur_lv = cur_dragon_data['skill_' .. i]

		if (cur_lv ~= pre_lv) then
            return i
        end
	end

    return 0
end

-------------------------------------
-- function request_setLeaderDragon
-- @brief 리더드래곤의 정보를 얻어옴
-------------------------------------
function ServerData_Dragons:request_setLeaderDragon(type, doid, cb_func)
	local uid = g_userData:get('uid')
	local type = type or 'lobby'
	local doid = doid

	 local function success_cb(ret)
		-- 서버에서 넘어온 드래곤 정보 저장
		if (ret['modified_dragons']) then
			for _,t_dragon in ipairs(ret['modified_dragons']) do
				self:applyDragonData(t_dragon)
			end
		end

		-- 서버레 리더 정보 저장
		if (ret['leaders']) then
			g_userData:applyServerData(ret['leaders'], 'leaders')

            -- 채팅 서버에 변경사항 적용
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
		end

		-- 개별 콜백 함수
		if (cb_func) then
			cb_func(ret)
		end
	end

    local ui_network = UI_Network()
    ui_network:setUrl('/users/set_leader_dragon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', 'lobby')
    ui_network:setParam('doid', doid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()

end

-------------------------------------
-- function isSameTypeDragon
-- @brief 드래곤들의 원종(dragon 테이블의 type컬럼)이 같은지 확인
-------------------------------------
function ServerData_Dragons:isSameTypeDragon(doid1, doid2)
    local table_dragon = TABLE:get('dragon')
    
    local t_dragon_data_1 = self:getDragonDataFromUid(doid1)
    local t_dragon_data_2 = self:getDragonDataFromUid(doid2)

    local did_1 = t_dragon_data_1['did']
    local did_2 = t_dragon_data_2['did']

    local t_dragon_1 = table_dragon[did_1]
    local t_dragon_2 = table_dragon[did_2]

    local is_same_type = (t_dragon_1['type'] == t_dragon_2['type'])

    return is_same_type
end

-------------------------------------
-- function isMaxEvolution
-- @brief 최대 진화도 드래곤인지 확인
-------------------------------------
function ServerData_Dragons:isMaxEvolution(dragon_object_id)
    local t_dragon_data = self:getDragonDataFromUid(dragon_object_id)
    local is_max_evolution = (t_dragon_data['evolution'] >= MAX_DRAGON_EVOLUTION)
    return is_max_evolution
end

-------------------------------------
-- function isMaxGrade
-- @brief 최대 등급 드래곤인지 확인
-------------------------------------
function ServerData_Dragons:isMaxGrade(dragon_object_id)
    local t_dragon_data = self:getDragonDataFromUid(dragon_object_id)
    local is_max_grade = (t_dragon_data['grade'] >= MAX_DRAGON_GRADE)
    return is_max_grade
end

-------------------------------------
-- function getDragonsSortData
-------------------------------------
function ServerData_Dragons:getDragonsSortData(doid)

    local struct_dragon_object = self:getDragonDataFromUid(doid)
    local t_sort_data = self.m_lSortData[doid]

	-- @mskim 간혹 kibana에 보고되는 에러, 예외처리함
	if (not struct_dragon_object) then
		if (not t_sort_data) then
			t_sort_data = self:setDragonsSortData(doid)
		end
	elseif (not t_sort_data) or (t_sort_data['updated_at'] ~= struct_dragon_object['updated_at']) then
        t_sort_data = self:setDragonsSortData(doid)
    end

    return t_sort_data
end

-------------------------------------
-- function setDragonsSortData
-------------------------------------
function ServerData_Dragons:setDragonsSortData(doid)
    local struct_dragon_object = self:getDragonDataFromUid(doid)
    local t_sort_data = self:makeDragonsSortData(struct_dragon_object)
    self.m_lSortData[doid] = t_sort_data

    -- 개별 드래곤 최고 전투력 저장 (친구 드래곤 제외)
    local is_friend_dragon = g_friendData:checkFriendDragonFromDoid(doid)
    local combat_power = t_sort_data['combat_power']
    if (not is_friend_dragon) and (self.m_dragonBestCombatPower < combat_power) then
        self.m_dragonBestCombatPower = combat_power
        self.m_bUpdatePower = true
    end

    return t_sort_data
end

-------------------------------------
-- function makeDragonsSortData
-------------------------------------
function ServerData_Dragons:makeDragonsSortData(struct_dragon_object)

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[struct_dragon_object['did']]

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(struct_dragon_object)

    local t_sort_data = {}
    t_sort_data['doid'] = doid
    t_sort_data['did'] = struct_dragon_object['did']
    t_sort_data['hp'] = status_calc:getFinalStat('hp')
    t_sort_data['def'] = status_calc:getFinalStat('def')
    t_sort_data['atk'] = status_calc:getFinalStat('atk')
    t_sort_data['attr'] = attributeStrToNum(t_dragon['attr'])
    t_sort_data['lv'] = struct_dragon_object['lv']
    t_sort_data['grade'] = struct_dragon_object['grade']
    t_sort_data['evolution'] = struct_dragon_object['evolution']
    t_sort_data['rarity'] = dragonRarityStrToNum(t_dragon['rarity'])
    t_sort_data['friendship'] = struct_dragon_object:getFlv()
    t_sort_data['combat_power'] = struct_dragon_object:getCombatPower()
    t_sort_data['updated_at'] = struct_dragon_object['updated_at']

    return t_sort_data
end



T_DRAGON_SORT = {}

T_DRAGON_SORT['normal'] = function(a, b)
    local t_data_a = a['data']
    local t_data_b = b['data']
    
    if (t_data_a['did'] > t_data_b['did']) then
        return true
    elseif (t_data_a['did'] < t_data_b['did']) then
        return false
    end

    return false
end

T_DRAGON_SORT['lv'] = function(a, b)
    local t_data_a = a['data']
    local t_data_b = b['data']
    
    if (t_data_a['lv'] > t_data_b['lv']) then
        return true
    elseif (t_data_a['lv'] < t_data_b['lv']) then
        return false
    end

    

    return false
end

-------------------------------------
-- function getDragonAnimator
-- @brief 클래스의 기능을 빌리고 맴버 변수를 활용하는 함수(get)
-------------------------------------
function ServerData_Dragons:getDragonAnimator(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)
    
    if (not t_dragon_data) then
        return nil
    end

    local animator = self:makeDragonAnimator(t_dragon_data)

    return animator
end


-------------------------------------
-- function makeDragonAnimator
-- @brief 클래스의 기능을 빌리지 않고 순수 파라미터로 동작하는 함수(make)
-------------------------------------
function ServerData_Dragons:makeDragonAnimator(t_dragon_data)
    local did = t_dragon_data['did']
    local evolution = t_dragon_data['evolution']

    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)

    local res = t_dragon['res']
    local attr = t_dragon['attr']

    local animator = AnimatorHelper:makeDragonAnimator(res, evolution, attr)

    animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))

    return animator
end

-------------------------------------
-- function getNumOfDragonsByDid
-- @brief
-------------------------------------
function ServerData_Dragons:getNumOfDragonsByDid(did)
    local did = tonumber(did)

    if self.m_bDirtyNumOfDragonsByDid then
        local l_dragons = self.m_serverData:getRef('dragons')
        self.m_mNumOfDragonsByDid = {}

        for i,v in pairs(l_dragons) do
            local did_ = tonumber(v['did'])

            if (not self.m_mNumOfDragonsByDid[did_]) then
                self.m_mNumOfDragonsByDid[did_] = 0
            end

            self.m_mNumOfDragonsByDid[did_] = (self.m_mNumOfDragonsByDid[did_] + 1)
        end

        self.m_bDirtyNumOfDragonsByDid = false
    end

    local number = self.m_mNumOfDragonsByDid[did] or 0
    return number
end

-------------------------------------
-- function getDragonsByDid
-- @brief 해당 did의 드래곤들 반환
-------------------------------------
function ServerData_Dragons:getDragonsByDid(did)
    local dragon_dictionary = self:getDragonsListRef()
    local did = tonumber(did)
    local ret_dictionary = {}
    for key,value in pairs(dragon_dictionary) do
        local _did = tonumber(value['did'])
        if (_did == did) then
            ret_dictionary[key] = value
        end
    end

    return ret_dictionary
end

-------------------------------------
-- function getBestDragonByDid
-- @brief 해당 did의 드래곤중 전투력 높은 드래곤 반환
-------------------------------------
function ServerData_Dragons:getBestDragonByDid(did)
    local ret_dictionary = self:getDragonsByDid(did)
    local struct_dragon_data
    local combat_power = 0
    for k, v in pairs(ret_dictionary) do
        local _combat_power = v:getCombatPower()
        if (combat_power < _combat_power) then
            struct_dragon_data = v
            combat_power = _combat_power
        end
    end

    return struct_dragon_data
end

-------------------------------------
-- function getDragonSupportRequstTargetList
-- @brief 희귀도별 드래곤 지원 요청을 할 수 있는 리스트
--        보유한 드래곤에 한함
-------------------------------------
function ServerData_Dragons:getDragonSupportRequstTargetList(dragon_rarity)
    local l_dragons = self.m_serverData:getRef('dragons')

    local table_dragon = TableDragon()

    local l_ret = {}

    for i,v in pairs(l_dragons) do
        local did = v['did']
        local rarity = table_dragon:getValue(did, 'rarity')

        if rarity == dragon_rarity then
            l_ret[i] =  v
        end
    end

    return l_ret
end

-------------------------------------
-- function setLastChangeTimeStamp
-- @breif 마지막으로 데이터가 변경된 시간 갱신
-------------------------------------
function ServerData_Dragons:setLastChangeTimeStamp()
    self.m_lastChangeTimeStamp = ServerTime:getInstance():getCurrentTimestampSeconds()
end

-------------------------------------
-- function getLastChangeTimeStamp
-------------------------------------
function ServerData_Dragons:getLastChangeTimeStamp()
    return self.m_lastChangeTimeStamp
end

-------------------------------------
-- function checkChange
-------------------------------------
function ServerData_Dragons:checkChange(timestamp)
    if (self.m_lastChangeTimeStamp ~= timestamp) then
        return true
    end

    return false
end

-------------------------------------
-- function getDragonsCnt
-------------------------------------
function ServerData_Dragons:getDragonsCnt()
    -- 드래곤 카운트에 슬라임 추가됨
    --local slime_cnt = g_slimesData.m_slimesCnt or 0
    --return self.m_dragonsCnt + slime_cnt

    -- @sgkim 2020.10.16 드래곤 인벤토리에서 슬라임 수 제거
    return self.m_dragonsCnt
end

-------------------------------------
-- function checkMaximumDragons
-------------------------------------
function ServerData_Dragons:checkMaximumDragons(ignore_func, manage_func)
    local dragons_cnt = self:getDragonsCnt()
    local inven_type = 'dragon'
    local max_cnt = g_inventoryData:getMaxCount(inven_type)
    if (dragons_cnt < max_cnt) then
        if ignore_func then
            ignore_func()
        end
    else
        UI_NotificationFullInventoryPopup('dragon', dragons_cnt, max_cnt, ignore_func, manage_func)
    end
end

-------------------------------------
-- function checkDragonSummonMaximum
-- @brief 드래곤 소환 최대치 확인
-- @return bool true : 소환 가능
--              false : 소환 불가능 (안내 팝업 띄움)
-------------------------------------
function ServerData_Dragons:checkDragonSummonMaximum(summon_cnt)
    local summon_cnt = (summon_cnt or 0)
    local dragons_cnt = self:getDragonsCnt()
    local MAXIMUM = 600
    if (MAXIMUM < (dragons_cnt + summon_cnt)) then
        local msg = Str('더는 드래곤을 획득 할 수 없습니다.\n드래곤 보유 공간을 확보해 주세요.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return false
    end

    return true
end


-------------------------------------
-- function possibleGoodbye
-- @brief 작별 가능한지 체크
-------------------------------------
function ServerData_Dragons:possibleGoodbye(doid)
	local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
	if (not possible) then
		return possible, msg
	end

    local t_dragon_data = self:getDragonDataFromUid(doid)
	local did = t_dragon_data['did']

	-- 슬라임 체크
	if (t_dragon_data.m_objectType == 'slime') then
        return false, Str('작별할 수 없는 드래곤입니다.')
    end

	-- 자코 체크
	if (TableDragon:isUnderling(did)) then
		return false, Str('작별할 수 없는 드래곤입니다.') 
	end

	local dragon_name = TableDragon:getDragonName(did)

	-- 3성 번고/땅스마트 작별 못하게 막음
	local birth = t_dragon_data:getBirthGrade()
	local grade = t_dragon_data:getGrade()
	if (birth > grade) then
		return false, Str('{1}은 {2}성 이상이어야 작별할 수 있습니다.', dragon_name, birth) 
	end

    if (t_dragon_data:getRarity() == 'myth') then
        return false, Str('작별할 수 없는 드래곤입니다.') 
    end

	-- 인연포인트 최대 갯수 체크
    -- @kwkang 20-11-17 기존 로직은 현재 가지고 있는 인연포인트만 검사
    -- (현재 가지고 있는 인연포인트 + 얻을 인연포인트) 로 검사하도록 변경
	local relation = g_bookData:getBookData(did):getRelation()
	local add_relation = TableDragon:getRelationPoint(did)
    local max = TableDragonReinforce:getTotalExp()
    local relation_sum = relation + add_relation 

	if (relation_sum > max) then
		return false, Str('{1}의 인연 포인트를 {2}개 이상 보유하고 있어 작별할 수 없습니다.', dragon_name, max)
	end

    return true
end

-------------------------------------
-- function possibleConversion
-- @brief 변환 가능한지 체크
-------------------------------------
function ServerData_Dragons:possibleConversion(doid)
	local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
	if (not possible) then
		return possible, msg
	end

    local t_dragon_data = self:getDragonDataFromUid(doid)
	local did = t_dragon_data['did']

	-- 슬라임 체크
	if (t_dragon_data.m_objectType == 'slime') then
        return false, Str('슬라임은 선택할 수 없습니다.')
    end

	-- 자코 체크
	if (TableDragon:isUnderling(did)) then
		return false, Str('몬스터는 변환할 수 없습니다.') 
	end

    -- 희귀 미만 (2성 드래곤)은 선택 불가
    if (TableDragon:getBirthGrade(did) < 3) then
        return false, Str('변환할 수 없습니다.') 
    end

	local dragon_name = TableDragon:getDragonName(did)

	-- 3성 번고/땅스마트 작별 못하게 막음
	local birth = t_dragon_data:getBirthGrade()
	local grade = t_dragon_data:getGrade()
	if (birth > grade) then
		return false, Str('변환할 수 없습니다.') 
	end

    return true
end

-------------------------------------
-- function possibleMaterialDragon
-- @brief 재료 드래곤으로 사용 가능한지 여부 : 리더나 잠금 상태를 제외한다
-------------------------------------
function ServerData_Dragons:possibleMaterialDragon(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false, ''
    end

    -- -- 신화 드래곤 체크
    -- if (t_dragon_data:getRarity() == 'myth') then
    --    return false, Str('작별할 수 없는 드래곤입니다.') 
    -- end


	-- 잠금 체크
	if (self:isLockDragon(doid)) then
		return false, Str('잠금 상태입니다.')
	end

    -- 리더로 설정된 드래곤인지 체크
    if self:isLeaderDragon(doid) then
        return false, Str('대표드래곤으로 설정된 드래곤입니다.')
    end

    -- 콜로세움 정보 확인
    if IS_ARENA_NEW_OPEN() and HAS_ARENA_NEW_SEASON() then
        if g_arenaNewData then
            local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo() -- return : StructUserInfoArena
            if struct_user_info then
                -- 덱
                local l_pvp_deck = struct_user_info:getDefenseDeck_dragonList(true) -- param : use_doid
                if table.find(l_pvp_deck, doid) then
                    return false, Str('콜로세움 덱에 설정된 드래곤입니다.')
                end
            end
        end
    end
    
    local clan_war_deck = g_deckData:getDeck('clanwar')

    if table.find(clan_war_deck, doid) then
        return false, Str('클랜전 덱에 설정된 드래곤입니다.')
    end
    
    return true
end

-------------------------------------
-- function possibleDragonLevelUp
-- @breif 레벨업이 가능한 상태인지 여부
-------------------------------------
function ServerData_Dragons:possibleDragonLevelUp(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return false
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return false, Str('슬라임은 레벨업할 수 없습니다.')
    end

    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local max_lv = TableGradeInfo:getMaxLv(grade)
    
    if (lv >= max_lv) then
        return false, Str('{1}등급 최대레벨 {2}에 달성하였습니다.', grade, max_lv)
    end

    return true
end

-------------------------------------
-- function impossibleLevelupForever
-- @breif 레벨업이 절대 불가능한지 판별 -> 6성 60렙
-------------------------------------
function ServerData_Dragons:impossibleLevelupForever(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return true
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return true, Str('슬라임은 레벨업할 수 없습니다.')
    end

    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local max_lv = TableGradeInfo:getMaxLv(grade)

    if (grade >= MAX_DRAGON_GRADE) then
        if (lv >= max_lv) then
            return true, Str('{1}등급 최대레벨 {2}에 달성하였습니다.', grade, max_lv)
        end
    end

    return false
end

-------------------------------------
-- function possibleUpgradeable
-- @brief
-------------------------------------
function ServerData_Dragons:possibleUpgradeable(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return false
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return false, Str('슬라임은 승급할 수 없습니다.')
    end

    local grade = t_dragon_data['grade']
    local eclv = t_dragon_data['eclv']
    local level = t_dragon_data['lv']

    -- 최대 등급 체크
    if TableGradeInfo:isMaxGrade(grade) then
        return false, Str('최고 등급의 드래곤입니다.')
    end

    -- 최대 레벨 체크
    local is_max_level, max_lv = TableGradeInfo:isMaxLevel(grade, level)
    if (not is_max_level) then
        return false, Str('등급별 최대 레벨 {1}에서 승급이 가능합니다.', max_lv)
    end

    return true
end

-------------------------------------
-- function impossibleUpgradeForever
-- @brief
-------------------------------------
function ServerData_Dragons:impossibleUpgradeForever(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return true
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return true, Str('슬라임은 승급할 수 없습니다.')
    end

    local grade = t_dragon_data['grade']

    -- 최대 등급 체크
    if TableGradeInfo:isMaxGrade(grade) then
        return true, Str('최고 등급의 드래곤입니다.')
    end

    return false
end

-------------------------------------
-- function impossibleFriendshipForever
-- @brief
-------------------------------------
function ServerData_Dragons:impossibleFriendshipForever(doid)
    local t_dragon_data = self:getDragonObject(doid)
    if (not t_dragon_data) then
        return true
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return true, Str('슬라임은 친밀도를 올릴 수 없습니다.')
    end

    if (not t_dragon_data['friendship']) then
        return true, ''
    end

    if (t_dragon_data['friendship']['flv'] == 9) then
        return true, Str('더 이상 친밀도를 올릴 수 없습니다.')
    end
    
    return false
end

-------------------------------------
-- function possibleDragonEvolution
-- @brief 진화 가능 여부
-------------------------------------
function ServerData_Dragons:possibleDragonEvolution(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return false
    end

	local did = t_dragon_data['did']
	if (TableDragon:isUnderling(did)) then
		return false, Str('몬스터는 진화 할 수 없습니다.') 
	end

    if (t_dragon_data.m_objectType == 'slime') then
        return false, Str('슬라임은 진화할 수 없습니다.')
    end

	local grade = t_dragon_data:getGrade()
	local evolution = t_dragon_data:getEvolution()
	local birth_grade = TableDragon:getValue(did, 'birthgrade')
	local rarity = t_dragon_data:getRarity()

    if (rarity == 'myth') then
        -- 성룡 체크
	    if (evolution >= MAX_DRAGON_EVOLUTION) then
		    return false, Str('더이상 진화 할 수 없습니다.')
        else
            return true
	    end

	-- 해치는 태생등급 이상인 경우 진화 가능
	elseif (evolution == 1) and (grade < birth_grade) then
		return false, Str('{1}성으로 승급해야 진화가 가능합니다.', birth_grade)

	-- 해츨링은 태생등급 + 1 이상인 경우 진화 가능
	elseif (evolution == 2) and (grade < birth_grade + 1) then
		return false, Str('{1}성으로 승급해야 진화가 가능합니다.', birth_grade + 1)

	end

	-- 성룡 체크
	if (evolution >= MAX_DRAGON_EVOLUTION) then
		return false, Str('더이상 진화 할 수 없습니다.')
	end

    return true
end

-------------------------------------
-- function impossibleEvolutionForever
-- @brief 진화 절대 불가
-------------------------------------
function ServerData_Dragons:impossibleEvolutionForever(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return true
    end

	local did = t_dragon_data['did']
	if (TableDragon:isUnderling(did)) then
		return true, Str('몬스터는 진화 할 수 없습니다.') 
	end

    if (t_dragon_data.m_objectType == 'slime') then
        return true, Str('슬라임은 진화할 수 없습니다.')
    end


	-- 성룡 체크
    local evolution = t_dragon_data:getEvolution()
	if (evolution >= MAX_DRAGON_EVOLUTION) then
		return true, Str('더이상 진화 할 수 없습니다.')
	end

    return false
end

-------------------------------------
-- function possibleDragonSkillEnhance
-- @brief 스킬 업그레이드 가능 여부
-------------------------------------
function ServerData_Dragons:possibleDragonSkillEnhance(doid)
	if (not self:haveSkillSpareLV(doid)) then
		return false, Str('현재 스킬이 최대 레벨입니다.')
	end

    local impossible, msg = self:impossibleSkillEnhanceForever(doid)
    return (not impossible), msg
end

-------------------------------------
-- function impossibleSkillEnhanceForever
-- @brief 스킬 업그레이드 가능 여부
-------------------------------------
function ServerData_Dragons:impossibleSkillEnhanceForever(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return true
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return true, Str('슬라임은 스킬 레벨업을 할 수 없습니다.')
    end

	if (not self:haveSkillSpareLV(doid) and self:isMaxEvolution(doid)) then
		return true, Str('모든 스킬이 최대 레벨입니다.')
	end

    return false
end

-------------------------------------
-- function possibleDragonMasteryLevelUp
-- @brief 특성 레벨업 가능 여부
-------------------------------------
function ServerData_Dragons:possibleDragonMasteryLevelUp(doid)
	local dragon_obj = self:getDragonObject(doid)

    if (not dragon_obj) then
        return false
    end

    local mastery_level = dragon_obj:getMasteryLevel()
    if (MAX_DRAGON_MASTERY <= mastery_level) then
        local msg = Str('최대 특성 레벨의 드래곤입니다.')
        return false, msg
    end

    return true
end

-------------------------------------
-- function setSkillMovePrice
-- @brief 스킬 이전 비용 (서버에서 받도록 수정)
-------------------------------------
function ServerData_Dragons:setSkillMovePrice(ret)
   self.m_mSkillMovePrice['4'] = ret['skillmove_price4'] or 1400
   self.m_mSkillMovePrice['5'] = ret['skillmove_price5'] or 2800
end

-------------------------------------
-- function isReleasedDragon
-------------------------------------
function ServerData_Dragons:isReleasedDragon(did)
    if (not did) then return false end

    local t_dragon = TableDragon():get(tonumber(did), true)
    if (not t_dragon) then return false end

    if (t_dragon['test'] == 2) then
        return true

    elseif (t_dragon['test'] == 1 and self.m_mReleasedDragonsByDid[tostring(did)]) then
        return true
    end

    return false
end

-------------------------------------
-- function setReleasedDragons
-- @brief 출시 드래곤 정보
-------------------------------------
function ServerData_Dragons:setReleasedDragons(ret)
    local list = ret['new_dragons'] or {}

    for _, did in pairs(list) do
        self.m_mReleasedDragonsByDid[tostring(did)] = true
    end
end

-------------------------------------
-- function haveSkillSpareLV
-- @brief 여분의 스킬 레벨 공간이 있는지..
-------------------------------------
function ServerData_Dragons:haveSkillSpareLV(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)
	local t_dragon = TableDragon():get(t_dragon_data['did'])
	local table_dragon_skill_modify = TableDragonSkillModify()

    local evolution = t_dragon_data['evolution']
	
	-- active 부터 진화도까지
	for i = 0, evolution do
		local key = i

		-- 애초에 0이었으면... 
		if (key == 0) then
			key = 'active'
		end

		local skill_id = t_dragon['skill_' .. key]
		local max_lv = table_dragon_skill_modify:getMaxLV(skill_id)
		local curr_lv = t_dragon_data['skill_' .. i]

		-- 한개라도 현재 레밸이 최대레벨보다 낮은것이 있다면 여분 스킬 있는것으로 판명
		if (curr_lv < max_lv) then
			return true
		end
	end
 
	return false
end

-------------------------------------
-- function isSkillEnhanced
-- @brief 한번이라도 스킬강화를 했는지
-------------------------------------
function ServerData_Dragons:isSkillEnhanced(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)
	local t_dragon = TableDragon():get(t_dragon_data['did'])
	local table_dragon_skill_modify = TableDragonSkillModify()

    local evolution = t_dragon_data['evolution']
	
	-- active 부터 진화도까지
	for i = 0, evolution do
		local key = i

		-- 애초에 0이었으면... 
		if (key == 0) then
			key = 'active'
		end

		local skill_id = t_dragon['skill_' .. key]
		local max_lv = table_dragon_skill_modify:getMaxLV(skill_id)
		local curr_lv = t_dragon_data['skill_' .. i]

		-- 한개라도 현재 레밸이 2이상인 경우 스킬 강화된 드래곤으로 판명
		if (curr_lv > 1) then
			return true
		end
	end
 
	return false
end

-------------------------------------
-- function impossibleReinforcementForever
-- @brief 드래곤 강화
-------------------------------------
function ServerData_Dragons:impossibleReinforcementForever(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return true
    end

	local did = t_dragon_data['did']
	if (TableDragon:isUnderling(did)) then
		return true, Str('몬스터는 강화 할 수 없습니다.')
	end

    if (t_dragon_data.m_objectType == 'slime') then
        return true, Str('슬라임은 강화할 수 없습니다.')
    end

	if (t_dragon_data:isMaxRlv()) then
		return true, Str('최대 강화 레벨의 드래곤입니다.')
	end

    if (t_dragon_data:getRarity() == 'myth') then
        return true, Str('신화 등급 드래곤은 강화할 수 없습니다.') 
    end

    return false
end

-------------------------------------
-- function request_dragonsInfo
-- @breif
-------------------------------------
function ServerData_Dragons:request_dragonsInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_highlightData:cleanNewDoidMap()

        -- 드래곤 정보 갱신
        self.m_dragonsCnt = 0
        g_serverData:applyServerData({}, 'dragons') -- 로컬 세이브 데이터 초기화
        self:applyDragonData_list(ret['dragons'])
        g_slimesData:applySlimeData_list(ret['slimes'] or {})

        -- 새로 획득한 드래곤 확인
        g_highlightData:loadNewDoidMap()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getDragonObject
-- @brief 드래곤 오브젝트 리턴 (슬라임 포함)
-------------------------------------
function ServerData_Dragons:getDragonObject(oid)
    local object = nil

    -- 드래곤에서 검색
    object = self.m_serverData:get('dragons', oid)
    if (object) then
        return object
    end

    -- 슬라임에서 검색
    object = g_slimesData:getSlimeObject(oid)
    if (object) then
        return object
    end

    return object
end

-------------------------------------
-- function haveLeaderSkill
-- @brief leader skill 있는 드래곤 여부
-------------------------------------
function ServerData_Dragons:haveLeaderSkill(doid)
	if (not doid) then
		return false
	end

	local t_dragon_data = self:getDragonDataFromUid(doid)
    if (not t_dragon_data) then
        return false
    end

	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')

	if (skill_info) and (skill_info:isActivated()) then
		return true
	end

	return false
end

-------------------------------------
-- function isSameDid
-- @brief 동종 동속성 드래곤 검사!
-------------------------------------
function ServerData_Dragons:isSameDid(doid_a, doid_b)
    if (not doid_a) or (not doid_b) then
        return false
    end

    -- 내 덱에서 검사
    local t_dragon_data = self:getDragonDataFromUidRef(doid_a)
    -- 없으면 친구 검사
    if (not t_dragon_data) then
        t_dragon_data = g_friendData:getDragonDataFromDoid(doid_a)
    end
    -- 없으면 정말 없는것..
    if (not t_dragon_data) then
        return false
    end
    local did_a = t_dragon_data:getDid()
    
    t_dragon_data = self:getDragonDataFromUidRef(doid_b)
    if (not t_dragon_data) then
        t_dragon_data = g_friendData:getDragonDataFromDoid(doid_a)
    end
    if (not t_dragon_data) then
        return false
    end
    local did_b = t_dragon_data:getDid()

    return (did_a == did_b)
end

-------------------------------------
-- function request_dragonLock
-------------------------------------
function ServerData_Dragons:request_dragonLock(doids, soids, lock, cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
		if (ret['modified_dragons']) then
			for _, t_dragon in ipairs(ret['modified_dragons']) do
				self:applyDragonData(t_dragon)
			end
		end
		
		if (ret['modified_slimes']) then
			for _, t_slime in ipairs(ret['modified_slimes']) do
				g_slimesData:applySlimeData(t_slime)
			end
		end

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/lock')
    ui_network:setParam('uid', uid)
	ui_network:setParam('doids', doids)
	ui_network:setParam('soids', soids)
	ui_network:setParam('lock', lock)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getBestCombatPower
-------------------------------------
function ServerData_Dragons:getBestCombatPower()
	return self.m_dragonBestCombatPower
end

-------------------------------------
-- function request_updatePower
-------------------------------------
function ServerData_Dragons:request_updatePower(cb_func)
    -- 업데이트 할 시점이 아닌 경우 바로 콜백 호출
    if (not self.m_bUpdatePower) then
		if (cb_func) then
			cb_func()
		end
        return
    end

	-- 유저 ID
    local uid = g_userData:get('uid')

    -- 최고 전투력
    local combat_power = self.m_dragonBestCombatPower

    local function success_cb(ret)
		self:response_updatePower(ret, cb_func)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/update_power')
    ui_network:setLoadingMsg(Str('전투 능력 동기화 중...'))
    ui_network:setParam('uid', uid)
    ui_network:setParam('dragon_power', combat_power)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_updatePower
-------------------------------------
function ServerData_Dragons:response_updatePower(ret, cb_func)
    self.m_bUpdatePower = false

	-- 콜백
	if (cb_func) then
		cb_func(ret)
	end
end

-------------------------------------
-- function response_recallDragons
---@param recall_info table
-------------------------------------
    -- ['full_popup']='';
    -- ['event_type']='event_recall';
    -- ['t_name']='드래곤 리콜';
    -- ['package_name']='';
    -- ['feature']='';
    -- ['start_date_timestamp']=1665446400000;
    -- ['banner']='';
    -- ['url']='';
    -- ['ui_priority']='';
    -- ['target_app_version']='';
    -- ['icon']='';
    -- ['end_date_timestamp']=1666310400000;
    -- ['target_server']='';
    -- ['list_id']=197;
    -- ['target_language']='';
    -- ['lobby_banner']='';
    -- ['user_lv']='';
    -- ['end_date']='2022-10-21 00:00:00';
    -- ['start_date']='2022-10-11 00:00:00';
    -- ['event_id']='';
function ServerData_Dragons:response_recallDragons(recall_info, success_cb)
    self.m_structRecallList = {}

    if isTable(recall_info) then
        local event_type = recall_info['event_type']
        local event = g_eventData:getEventInByEventType(event_type)

        if isTable(event) then
            local start_time = event['start_date_timestamp']
            local end_time = event['end_date_timestamp']
            
            for did, is_recalled in pairs(recall_info['did_list']) do    
                if (is_recalled == 1) then
                    local temp = {
                        did = tonumber(did),
                        is_recalled = is_recalled,
                        start_time_millisec = start_time,
                        end_time_millisec = end_time
                    }
                    local struct_recall = StructRecall(temp)
                    
                    if (table.count(struct_recall:getTargetDragonList()) > 0) then
                        table.insert(self.m_structRecallList, struct_recall) 
                    end
                end
            end

            table.sort(self.m_structRecallList, function(a, b)
                return (a['end_time_millisec'] < b['end_time_millisec'])
            end)
        end

        if (success_cb ~= nil) then
            success_cb()
        end
    end
end

-------------------------------------
-- function isRecallNotiVisible
---@return boolean
-------------------------------------
function ServerData_Dragons:isRecallNotiVisible()
    return self.m_bRecallNoti
end
-------------------------------------
-- function setRecallNotiVisible
---@param is_visible boolean
-------------------------------------
function ServerData_Dragons:setRecallNotiVisible(is_visible)
    self.m_bRecallNoti = is_visible
end

-------------------------------------
-- function getRecallList
---@return table
-------------------------------------
function ServerData_Dragons:getRecallList()
    return self.m_structRecallList
end

-------------------------------------
-- function isRecallExist
---@return boolean
-------------------------------------
function ServerData_Dragons:isRecallExist()
    -- 리콜 리스트가 비었거나
    if table.isEmpty(self.m_structRecallList) == true then
        return false
    end

    -- 첫 번째 요소가 없거나
    ---@type StructRecall
    local struct_recall = table.getFirst(self.m_structRecallList)
    if struct_recall == nil then
        return false
    end

    -- 첫 번째 요소의 리콜이 가능하지 않거나
    if struct_recall:isAvailable() == false then
        return false
    end

    return true
end

-------------------------------------
-- function isDragonRecallTarget
---@param doid string
---@return boolean
-------------------------------------
function ServerData_Dragons:isDragonRecallTarget(doid)
    local struct_dragon_object = self:getDragonDataFromUidRef(doid)
    if struct_dragon_object then
        local did = struct_dragon_object:getDid()

        for index, struct_recall in ipairs(self.m_structRecallList) do
            if (struct_recall:getTargetDid() == did) and struct_recall:isAvailable(doid) then
                return true
            end
        end
    end
    
    return false
end

-------------------------------------
-- function dragonMaterialWarning
-- @brief 드래곤이 판매,재료로 사용,작별 등등..될 때 경고 메시지 확인 (성장시켜놓은 드래곤)
-- @param oid : object_id 드래곤이나 슬라임의 오브젝트 ID
-------------------------------------
function ServerData_Dragons:dragonMaterialWarning(oid, next_func, t_warning, warning_msg)
    local t_warning = t_warning or {}
    local object = self:getDragonObject(oid)
    local warning_message = warning_msg

    -- 경고 메세지가 없을 경우 재료로 사용한다고 설정 
    if (not warning_msg) then
        warning_message = '재료로 선택하시겠습니까?'
    end
    
    -- 슬라임의 경우 재료 전용이므로 pass
    if (object:getObjectType() == 'slime') then
        next_func()
        return
    end

    local msg = ''
    local warning = false
    local function add_msg(str)
        if (msg == '') then
            msg = str
        else
            msg = msg .. ', ' .. str
        end
    end

	-- 조합 재료 체크 (조합 재료라면 이후 조건은 체크하지않음)
	if (not t_warning['pass_comb']) then
		local did = object:getDid()
		local comb_did = TableDragonCombine:getCombinationDid(did)
		if (comb_did) then
			local combine_name = TableDragon:getDragonNameWithAttr(comb_did)
			local msg = Str('{@DEEPSKYBLUE}{1}{@DESC}의 조합 재료인 드래곤입니다.', combine_name)
            local submsg = Str(warning_message)

			return MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, next_func)
		end
	end

    -- 진화
    local warning_evolution = t_warning['evolution'] or 2
    if (warning_evolution <= object:getEvolution()) then
        local evolution = object:getEvolution()
        local evolution_str = evolutionName(evolution)
        add_msg(evolution_str)
        warning = true
    end

    -- 등급
    local warning_grade = t_warning['grade'] or 4
    if (warning_grade <= object:getGrade()) then
        add_msg(Str('{1}성', object:getGrade()))
        warning = true
    end

    -- 레벨
    local warning_lv = t_warning['lv'] or 10
    if (warning_lv <= object:getLv()) then
        add_msg(Str('{1} 레벨', object:getLv()))
        warning = true
    end

    -- 친밀도
    local warning_flv = t_warning['flv'] or 2
    local flv = (object:getFlv() + 1) -- 데이터는 0부터 유저에게는 1부터 노출됨
    if (warning_flv <= flv) then
        add_msg(Str('친밀도 {1} 단계', flv))
        warning = true
    end

    -- 룬
    local l_rune_obj = object:getRuneObjectList()
    local rune_cnt = table.count(l_rune_obj)
    if (1 <= rune_cnt) then
        add_msg(Str('룬 {1}개 장착', rune_cnt))
        warning = true
    end

    if (warning == true) then
        local name = object:getDragonNameWithEclv()
        local default_msg = ''
        
        -- 경고 메세지가 없을 경우 재료로 사용한다고 설정
        if (not warning_msg) then
            default_msg = Str('재료로 사용한 드래곤은 사라집니다.')
        end
        
        local msg_ = default_msg .. '\n' .. name .. ' : ' .. msg
        local submsg = Str(warning_message)
        return MakeSimplePopup2(POPUP_TYPE.YES_NO, msg_, submsg, next_func)
    else
        if next_func then
            next_func()
        end
    end
end


-------------------------------------
-- function dragonStateStr
-- 드래곤의 현재 상태(레벨이나 룬 등)와 관련하여 
-- 문자열로 반환. dragonMaterialWarning 과 코드 중복 있음
-- @param oid : object_id, t_warning : 무시해도 되는 조건들 
-- @return '원더드래곤 : 성룡, 6성, 60레벨, 친밀도 10단계, 룬 6개 장착'
-------------------------------------
function ServerData_Dragons:dragonStateStr(oid, t_warning)
	local t_warning = t_warning or {}
	local object = self:getDragonObject(oid)
	local msg = ''

	local function add_msg(str)
        if (msg == '') then
            msg = str
        else
            msg = msg .. ', ' .. str
        end
    end

	-- 진화
    local warning_evolution = t_warning['evolution'] or 2
    if (warning_evolution <= object:getEvolution()) then
        local evolution = object:getEvolution()
        local evolution_str = evolutionName(evolution)
        add_msg(evolution_str)
    end

    -- 등급
    local warning_grade = t_warning['grade'] or 4
    if (warning_grade <= object:getGrade()) then
        add_msg(Str('{1}성', object:getGrade()))
    end

    -- 레벨
    local warning_lv = t_warning['lv'] or 10
    if (warning_lv <= object:getLv()) then
        add_msg(Str('{1} 레벨', object:getLv()))
    end

    -- 친밀도
    local warning_flv = t_warning['flv'] or 2
    local flv = (object:getFlv() + 1) -- 데이터는 0부터 유저에게는 1부터 노출됨
    if (warning_flv <= flv) then
        add_msg(Str('친밀도 {1} 단계', flv))
    end

    -- 룬
    local l_rune_obj = object:getRuneObjectList()
    local rune_cnt = table.count(l_rune_obj)
    if (1 <= rune_cnt) then
        add_msg(Str('룬 {1}개 장착', rune_cnt))
    end

    local name = object:getDragonNameWithEclv()
	local result = name
	if (not (msg == '')) then
		result = result .. ' : ' .. msg
	end

	return result
end

-------------------------------------
-- function request_skillMove
-------------------------------------
function ServerData_Dragons:request_skillMove(src_doid, dst_doid, cb_func)
	-- 유저 ID
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        self.m_serverData:networkCommonRespone(ret)

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/skill_move')
    ui_network:setParam('uid', uid)
    ui_network:setParam('src_doid', src_doid)
    ui_network:setParam('dst_doid', dst_doid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_instantSkillLevelUp
-- @brief 신화 드래곤 스킬 레벨업 티켓
---@param mail_id string
---@param dragon_object_id string
---@param cb_func function
-------------------------------------
function ServerData_Dragons:request_instantSkillLevelUp(mail_id, dragon_object_id, cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['modified_dragon'])

        -- 갱신
        g_serverData:networkCommonRespone(ret)

        if (cb_func) then
            cb_func(ret)
        end
    end
    
    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/skillup')
    ui_network:setParam('uid', uid)
	ui_network:setParam('mid', mail_id)
    ui_network:setParam('doid', dragon_object_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_goodbye
-- @brief 드래곤 작별
-- @param target string 'exp', 'relation', 'mastery', 'memory'
-- @param doids string 드래곤 오브젝트 ID를 ','로 연결한 문자열
-- @param cb_func function(ret)
-------------------------------------
function ServerData_Dragons:request_goodbye(target, doids, cb_func)
	local uid = g_userData:get('uid')
	
    local function success_cb(ret)
        -- 인연포인트 (전체 갱신)
	    if (ret['relation']) then
		    g_bookData:applyRelationPoints(ret['relation'])
	    end

        -- 룬을 장착한 드래곤이 있을 시 룬 반환
        if (ret['returned_runes']) then
            g_runesData:applyRuneData_list(ret['returned_runes'])
        end

	    -- 작별한 드래곤 삭제
	    if ret['deleted_dragons_oid'] then
		    for _, doid in pairs(ret['deleted_dragons_oid']) do
			    g_dragonsData:delDragonData(doid)
		    end
	    end

        -- 재화 갱신 (dragon_exp, mastery, memory)
        g_serverData:networkCommonRespone(ret)

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/goodbye')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
	ui_network:setParam('target', target)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
	ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_dragonCombine
-- @brief 슈퍼 슬라임 합성 요청
-- @param doids 는 doid concat한 것
-- doids : a,b,c,d-e,f,g,h-i,j,k,l (doid는 ','로 구분. 각 합성 정보는 '-'로 구분)
-------------------------------------
function ServerData_Dragons:request_dragonCombine(doids, cb_func)
	-- 유저 ID
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        -- 재화 갱신
        self.m_serverData:networkCommonRespone(ret)

        -- 재료로 사용된 드래곤에 장착된 룬 삭제
        if ret['deleted_rune_oids'] then
            g_runesData:deleteRuneData_list(ret['deleted_rune_oids'])
        end

		-- 재료로 사용된 드래곤 삭제
		if ret['deleted_dragons_oid'] then
			for _, doid in pairs(ret['deleted_dragons_oid']) do
				g_dragonsData:delDragonData(doid)
			end
		end

        -- 재료로 사용된 슬라임 삭제
        if ret['deleted_slimes_oid'] then
            for _, soid in pairs(ret['deleted_slimes_oid']) do
                g_slimesData:delSlimeObject(soid)
            end
        end

        -- 획득한 슬라임 추가
        if ret['added_slimes'] then
            g_slimesData:applySlimeData_list(ret['added_slimes'])
        end

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/combine')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function request_recall
-- brief 리콜 요청
---@param doid number
---@param cb_func function
-------------------------------------
function ServerData_Dragons:request_recall(doid, cb_func)
	-- 유저 ID
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        -- 재화 갱신
        self.m_serverData:networkCommonRespone(ret)

        -- 룬을 장착한 드래곤이 있을 시 룬 반환
        if (ret['returned_runes']) then
            g_runesData:applyRuneData_list(ret['returned_runes'])
        end

		-- 재료로 사용된 드래곤 삭제
		if ret['deleted_dragons_oid'] then
			for _, doid in pairs(ret['deleted_dragons_oid']) do
				g_dragonsData:delDragonData(doid)
			end
		end

        -- 리콜 정보 갱신
        g_dragonsData:response_recallDragons(ret['recall_info']) 

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end
    -- 특정 리턴값 처리
    local function response_status_cb(ret)
        if (ret['status'] == -1651) or (ret['status'] == -1364) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('종료되었습니다.'))
            return true
        elseif (ret['status'] == -3051) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('이미 리콜을 한 대상입니다.'))
            return true
        end

        return false
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/reset')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:request()
end


-------------------------------------
-- function request_mastery_lvup
-- @brief 특성 레벨업
-------------------------------------
function ServerData_Dragons:request_mastery_lvdown(doid, success_cb)
    local uid = g_userData:get('uid')

    --[[
    -- 에러코드 처리
    local function response_status_cb(ret)
        return true
    end

    -- 통신실패 처리
    local function response_fail_cb(ret)
    end
    --]]

    local function success(ret)

        -- 드래곤 정보 갱신
        g_dragonsData:applyDragonData(ret['dragon_info'])

        
        local dragon_data = g_dragonsData:getDragonDataFromUid(ret['dragon_info']['id'])

        -- 재화 갱신 - ret['mastery_material']
        g_serverData:networkCommonRespone_addedItems(ret)


        if (success_cb ~= nil) then
            success_cb(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/mastery_lvdown')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    --ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(function(ret) success(ret) end)
    --ui_network:setFailCB(fail_cb)
    ui_network:request()
end