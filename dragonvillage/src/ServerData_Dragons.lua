-------------------------------------
-- class ServerData_Dragons
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
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Dragons:init(server_data)
    self.m_serverData = server_data
    self.m_lSortData = {}
    self.m_mNumOfDragonsByDid = {}
    self.m_bDirtyNumOfDragonsByDid = true
    self.m_dragonsCnt = 0
    self.m_dragonBestCombatPower = 0
    self.m_bUpdatePower = false
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Dragons:get(key)
    return self.m_serverData:get('dragons', key)
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
        g_highlightData:addNewDoid(doid)
    end

    -- 룬 효과 체크
    if t_dragon_data then
        --t_dragon_data['rune_set'] = self:makeDragonRuneSetData(t_dragon_data)
        for i,roid in pairs(t_dragon_data['runes']) do
            if (roid ~= '') then
                g_runesData:applyEquippedRuneInfo(roid, doid)
            end
        end

        -- @analytics
        local did = t_dragon_data['did']
        if (TableDragon:getBirthGrade(did) == 5) then
            Analytics:firstTimeExperience('LegendDragon_Get')
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
        if g_chatClientSocket then
            g_chatClientSocket:globalUpdatePlayerUserInfo()
        end
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
            if g_chatClientSocket then
                g_chatClientSocket:globalUpdatePlayerUserInfo()
            end
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

    if (not t_sort_data) or (t_sort_data['updated_at'] ~= struct_dragon_object['updated_at']) then
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

    -- 개별 드래곤 최고 전투력 저장
    local combat_power = t_sort_data['combat_power']
    if (self.m_dragonBestCombatPower < combat_power) then
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
    t_sort_data['combat_power'] = status_calc:getCombatPower()
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
    self.m_lastChangeTimeStamp = Timer:getServerTime()
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
    local slime_cnt = g_slimesData.m_slimesCnt or 0
    return self.m_dragonsCnt + slime_cnt
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

	-- 잠금 체크
	if (self:isLockDragon(doid)) then
		return false, Str('잠금 상태입니다.')
	end

    -- 리더로 설정된 드래곤인지 체크
    if self:isLeaderDragon(doid) then
        return false, Str('리더로 설정된 드래곤입니다.')
    end

    -- 콜로세움 정보 확인
    if g_colosseumData then
        local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo() -- return : StructUserInfoColosseum
        if struct_user_info then
            -- 공격 덱
            local l_pvp_atk = struct_user_info:getAtkDeck_dragonList(true) -- param : use_doid
            if table.find(l_pvp_atk, doid) then
                return false, Str('콜로세움 공격덱에 설정된 드래곤입니다.')
            end

            -- 방어 덱
            local l_pvp_def =struct_user_info:getDefDeck_dragonList(true) -- param : use_doid
            if table.find(l_pvp_def, doid) then
                return false, Str('콜로세움 방어덱에 설정된 드래곤입니다.')
            end
        end
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
        return false, Str('슬라임은 레벨업 할 수 없습니다.')
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
        return true, Str('슬라임은 레벨업 할 수 없습니다.')
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
        return false, Str('슬라임은 승급 할 수 없습니다.')
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
        return true, Str('슬라임은 승급 할 수 없습니다.')
    end

    local grade = t_dragon_data['grade']

    -- 최대 등급 체크
    if TableGradeInfo:isMaxGrade(grade) then
        return true, Str('최고 등급의 드래곤입니다.')
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
        return false, Str('슬라임은 진화 할 수 없습니다.')
    end

	local grade = t_dragon_data:getGrade()
	local evolution = t_dragon_data:getEvolution()
	local birth_grade = TableDragon:getValue(did, 'birthgrade')

	-- 해치는 태생등급 이상인 경우 진화 가능
	if (evolution == 1) and (grade < birth_grade) then
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
        return true, Str('슬라임은 진화 할 수 없습니다.')
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
        return true, Str('슬라임은 스킬 강화 할 수 없습니다.')
    end

	if (not self:haveSkillSpareLV(doid) and self:isMaxEvolution(doid)) then
		return true, Str('모든 스킬이 최대 레벨입니다.')
	end

    return false
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
-- function request_dragonsInfo
-- @breif
-------------------------------------
function ServerData_Dragons:request_dragonsInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 드래곤 정보 갱신
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
-- function getBattleGiftDragon
-------------------------------------
function ServerData_Dragons:getBattleGiftDragon()
	local doid = g_localData:get('battle_gift_dragon')
	if (doid) then
		return self:getDragonDataFromUidRef(doid)
	end

	-- 지난 드래곤 선물 시간 체크
	local last_gift_at = g_userData:get('dragon_gift_at')
	local curr_time = Timer:getServerTime()
	local gap_hour = (curr_time - (last_gift_at / 1000)) / 60 / 60
	
	-- n시간 이내라면 탈출
	local regen_hour = g_constant:get('UI', 'BATTLE_GIFT_STD', 'REGEN_HOUR')

	if (gap_hour < regen_hour) then
		return
	end

	-- 드래곤 리스트(가공되어있음)
	local l_dragon = table.MapToList(self.m_lSortData)
		
	-- 전투력 탑 n을 뽑는다.
	table.sort(l_dragon, function(a, b)
		return a['combat_power'] > b['combat_power'] 
	end)
	local combat_n = g_constant:get('UI', 'BATTLE_GIFT_STD', 'COMBAT_TOP_N')
	local l_combat_top = table.getPartList(l_dragon, combat_n)

	-- 탈출 체크
	if (#l_combat_top == 0) then
		--ccdisplay('전투력 조건 불충족')
		return
	end

	-- 레벨 조건 체크
	local l_lv_check = {}
	local std_lv = g_constant:get('UI', 'BATTLE_GIFT_STD', 'LV')
	for i, v in pairs(l_combat_top) do
		if (v['lv'] >= std_lv) then
			table.insert(l_lv_check, v) 
		end
	end

	-- 탈출 체크
	if (#l_lv_check == 0) then
		--ccdisplay('레벨 조건 불충족')
		return
	end

	-- 시간 조건 체크
	local l_time_check = {}
	local std_hour = g_constant:get('UI', 'BATTLE_GIFT_STD', 'HOUR')
	for i, v in pairs(l_lv_check) do
		local dragon_obj = self:getDragonDataFromUidRef(v['doid'])
        if dragon_obj then
            local played_at = dragon_obj['played_at'] or 0
		    local gap_hour = (curr_time - (played_at/1000)) / 60 / 60
		    if (gap_hour > std_hour) then
			    table.insert(l_time_check, v) 
		    end
        end
	end

	-- 탈출 체크
	if (#l_time_check == 0) then
		--ccdisplay('시간 조건 불충족')
		return
	end

	-- 랜덤으로 드래곤 추출
	dragon = table.getRandom(l_time_check)

	-- 선물 드래곤 저장
	g_localData:applyLocalData(dragon['doid'], 'battle_gift_dragon')

	return dragon
end

-------------------------------------
-- function request_battleGift
-------------------------------------
function ServerData_Dragons:request_battleGift(did, cb_func)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
		-- 로컬에 저장한 doid 삭제
		g_localData:applyLocalData(nil, 'battle_gift_dragon')
		-- 선물 드래곤 본 시간 삭제
		g_localData:applyLocalData(nil, 'battle_gift_dragon_seen_at')

		-- 선물 받을 수 있는 시간 갱신
		g_userData:applyServerData(ret['dragon_gift_at'], 'dragon_gift_at')

		if (cb_func) then
			cb_func()
		end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/dragon/gift')
    ui_network:setParam('uid', uid)
	ui_network:setParam('did', did)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
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
-- function request_dragonGoodbye
-------------------------------------
function ServerData_Dragons:request_dragonGoodbye(src_doids, cb_func)
	-- 유저 ID
    local uid = g_userData:get('uid')

    local function success_cb(ret)
		-- 재료로 사용된 드래곤 삭제
		if ret['deleted_dragons_oid'] then
			for _, doid in pairs(ret['deleted_dragons_oid']) do
				g_dragonsData:delDragonData(doid)
			end
		end

		-- 획득한 인연포인트
		self.m_serverData:networkCommonRespone_addedItems(ret)

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/goodbye')
    ui_network:setParam('uid', uid)
    ui_network:setParam('src_doids', src_doids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function request_dragonSell
-------------------------------------
function ServerData_Dragons:request_dragonSell(doids, soids, cb_func)
	-- 유저 ID
    local uid = g_userData:get('uid')

    local function success_cb(ret)
		-- 판매 드래곤 삭제
		if ret['deleted_dragons_oid'] then
			for _, doid in pairs(ret['deleted_dragons_oid']) do
				g_dragonsData:delDragonData(doid)
			end
		end
		-- 판매 드래곤 삭제
		if ret['deleted_slimes_oid'] then
			for _, soid in pairs(ret['deleted_slimes_oid']) do
				g_slimesData:delSlimeObject(soid)
			end
		end

		-- 골드 갱신
		self.m_serverData:networkCommonRespone(ret)

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/sell')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doids', doids)
	ui_network:setParam('soids', soids)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
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
        self.m_bUpdatePower = false

		-- 콜백
		if (cb_func) then
			cb_func(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/update_power')
    ui_network:setLoadingMsg('전투 능력 동기화 중...')
    ui_network:setParam('uid', uid)
    ui_network:setParam('dragon_power', combat_power)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()

    return ui_network
end