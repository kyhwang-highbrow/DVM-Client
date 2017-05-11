local MAX_DRAGONS_CNT = 100

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
    end

    -- 드래곤 오브젝트 생성
    local dragon_obj = StructDragonObject(t_dragon_data)
    self.m_serverData:applyServerData(dragon_obj, 'dragons', doid)

    -- 드래곤 정렬 데이터 수정
    self:setDragonsSortData(doid)

    -- 드래곤 did별 갯수 갱신 필요
    self.m_bDirtyNumOfDragonsByDid = true

    -- 추가된 드래곤은 도감에 추가
    local did = t_dragon_data['did']
    g_collectionData:setDragonCollection(did)

    g_dragonUnitData:setDirty() -- 무리 버프 정보 갱신 필요
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

    g_dragonUnitData:setDirty() -- 무리 버프 정보 갱신 필요
    self:setLastChangeTimeStamp()
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
-- function possibleMaterialDragon
-- @brief 재료 드래곤으로 사용 가능한지 여부
-------------------------------------
function ServerData_Dragons:possibleMaterialDragon(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false, ''
    end

    -- 리더로 설정된 드래곤인지 체크
    if self:isLeaderDragon(doid) then
        return false, Str('리더로 설정된 드래곤입니다.')
    end

    -- 탐험 중인 드래곤인지 체크
    if g_explorationData:isExplorationUsedDragon(doid) then
        return false, Str('탐험 중인 드래곤입니다.')
    end

    return true
end

-------------------------------------
-- function getNumberOfRemainingSkillLevel
-- @brief 남은 드래곤 스킬 레벨 갯수 리턴
-------------------------------------
function ServerData_Dragons:getNumberOfRemainingSkillLevel(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    local skill_0 = (t_dragon_data['skill_0'] or 0) -- 최대 10
    local skill_1 = (t_dragon_data['skill_1'] or 0) -- 최대 10
    local skill_2 = (t_dragon_data['skill_2'] or 0) -- 최대 10
    local skill_3 = (t_dragon_data['skill_3'] or 0) -- 최대 1

    local total_skill_level = (skill_0 + skill_1 + skill_2 + skill_3)
    local num_of_remain_skill_level = (31 - total_skill_level)

    return num_of_remain_skill_level
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
-- function isMaxEclv
-- @brief 최대 초월 드래곤인지 확인
-------------------------------------
function ServerData_Dragons:isMaxEclv(dragon_object_id)
    local t_dragon_data = self:getDragonDataFromUid(dragon_object_id)
    local is_max_eclv = (t_dragon_data['eclv'] >= MAX_DRAGON_ECLV)
    return is_max_eclv
end

-------------------------------------
-- function getUpgradeMode
-- @brief 업그레이드 모드 리턴 (승급, 스킬 레벨업, 초월)
-------------------------------------
function ServerData_Dragons:getUpgradeMode(doid)
    local mode = 'max'

    -- 승급 (최대 등급이 아닐 경우)
    if (not self:isMaxGrade(doid)) then
        mode = 'upgrade'

    -- 스킬 레벨업 (레벨업 가능한 스킬이 남았을 경우)
    elseif (0 < self:getNumberOfRemainingSkillLevel(doid)) then
        mode = 'skill_lv_up'

    -- 초월 (최대등급, 스킬만렙일 경우 초월 가능)
    elseif (not self:isMaxEclv(doid)) then
        mode = 'eclv_up'
    end

    return mode
end

-------------------------------------
-- function checkSkillUpgradeable
-- @brief 스킬 업그레이드 가능 여부
-------------------------------------
function ServerData_Dragons:checkSkillUpgradeable(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    local evolution = t_dragon_data['evolution']
    local skill_0 = (t_dragon_data['skill_0'] or 0) -- 최대 10
    local skill_1 = (t_dragon_data['skill_1'] or 0) -- 최대 10
    local skill_2 = (t_dragon_data['skill_2'] or 0) -- 최대 10
    local skill_3 = (t_dragon_data['skill_3'] or 0) -- 최대 1

    if (evolution == 1) then
        if (20 <= (skill_0 + skill_1)) then
            return false, Str('해츨링이 되면 새로운 스킬을 습득할 수 있습니다.')
        end

    elseif (evolution == 2) then
        if (30 <= (skill_0 + skill_1 + skill_2)) then
            return false, Str('성룡이 되면 새로운 스킬을 습득할 수 있습니다.')
        end

    elseif (evolution == 3) then
        if (31 <= (skill_0 + skill_1 + skill_2 + skill_3)) then
            return false, Str('모든 스킬을 마스터하였습니다.')
        end

    end

    return true
end


-------------------------------------
-- function checkUpgradeable
-- @brief
-------------------------------------
function ServerData_Dragons:checkUpgradeable(doid)
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
    local is_max_level, max_lv = TableGradeInfo:isMaxLevel(grade, eclv, level)
    if (not is_max_level) then
        return false, Str('등급별 최대 레벨 {1}에서 승급이 가능합니다.', max_lv)
    end

    return true
end

-------------------------------------
-- function checkMaxUpgrade
-- @brief
-------------------------------------
function ServerData_Dragons:checkMaxUpgrade(doid)
    local t_dragon_data = self:getDragonObject(doid)

    if (not t_dragon_data) then
        return false
    end

    if (t_dragon_data.m_objectType == 'slime') then
        return false, Str('슬라임은 승급 할 수 없습니다.')
    end

    local grade = t_dragon_data['grade']

    -- 최대 등급 체크
    if TableGradeInfo:isMaxGrade(grade) then
        return false, Str('최고 등급의 드래곤입니다.')
    end

    return true
end

-------------------------------------
-- function checkEclvUpgradeable
-- @brief
-------------------------------------
function ServerData_Dragons:checkEclvUpgradeable(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false
    end

    local eclv = t_dragon_data['eclv']
    if (eclv < MAX_DRAGON_ECLV) then
        return true
    else
        return false, Str('최고 단계 초월의 드래곤입니다.')
    end
end

-------------------------------------
-- function getDragonsSortData
-------------------------------------
function ServerData_Dragons:getDragonsSortData(doid)
    if (not self.m_lSortData[doid]) then
        self:setDragonsSortData(doid)
    end

    return self.m_lSortData[doid]
end

-------------------------------------
-- function setDragonsSortData
-------------------------------------
function ServerData_Dragons:setDragonsSortData(doid)

    local t_dragon_data = self:getDragonDataFromUid(doid)

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    local status_calc = MakeOwnDragonStatusCalculator(doid)

    local t_sort_data = {}
    t_sort_data['doid'] = doid
    t_sort_data['did'] = t_dragon_data['did']
    t_sort_data['hp'] = status_calc:getFinalStat('hp')
    t_sort_data['def'] = status_calc:getFinalStat('def')
    t_sort_data['atk'] = status_calc:getFinalStat('atk')
    t_sort_data['attr'] = attributeStrToNum(t_dragon['attr'])
    t_sort_data['lv'] = t_dragon_data['lv']
    t_sort_data['grade'] = t_dragon_data['grade']
    t_sort_data['evolution'] = t_dragon_data['evolution']
    t_sort_data['rarity'] = dragonRarityStrToNum(t_dragon['rarity'])
    t_sort_data['friendship'] = t_dragon_data:getFlv()
    t_sort_data['combat_power'] = status_calc:getCombatPower()

    self.m_lSortData[doid] = t_sort_data
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
    return self.m_dragonsCnt
end

-------------------------------------
-- function checkMaximumDragons
-------------------------------------
function ServerData_Dragons:checkMaximumDragons(ignore_func, manage_func)
    local dragons_cnt = self:getDragonsCnt()
    
    if (dragons_cnt < MAX_DRAGONS_CNT) then
        if ignore_func then
            ignore_func()
        end
    else
        UI_NotificationFullInventoryPopup('dragon', dragons_cnt, MAX_DRAGONS_CNT, ignore_func, manage_func)
    end
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

    if (lv < max_lv) then
        return true
    else
        return false, Str('{1}등급 최대레벨 {2}에 달성하였습니다.', grade, max_lv)
    end
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
-- function getDragonResearchLevel
-- @breif 연구(research) 레벨
-------------------------------------
function ServerData_Dragons:getDragonResearchLevel(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return 0
    end

    local did = t_dragon_data['did']
    local research_lv = g_collectionData:getDragonResearchLevel_did(did)
    return research_lv
end

-------------------------------------
-- function checkResearchUpgradeable
-- @brief
-------------------------------------
function ServerData_Dragons:checkResearchUpgradeable(doid)
    local research_lv = self:getDragonResearchLevel(doid)

    -- 최대 등급 체크
    if (research_lv >= MAX_DRAGON_RESEARCH_LV) then
        return false, Str('최고 연구 단계의 드래곤입니다.')
    end

    return true
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
	local date = pl.Date()
	local curr_time = Timer:getServerTime()
	date:set(curr_time - (last_gift_at / 1000))
	
	-- n시간 이내라면 탈출
	local regen_hour = g_constant:get('UI', 'BATTLE_GIFT_STD', 'REGEN_HOUR')

	if (date:hour() < regen_hour) then
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
		ccdisplay('전투력 조건 불충족')
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
		ccdisplay('레벨 조건 불충족')
		return
	end

	-- 시간 조건 체크
	local l_time_check = {}
	local std_hour = g_constant:get('UI', 'BATTLE_GIFT_STD', 'HOUR')
	for i, v in pairs(l_lv_check) do
		local dragon_obj = self:getDragonDataFromUidRef(v['doid'])
		date:set(curr_time - (dragon_obj['played_at']/1000))
		if (date:hour() > std_hour) then
			table.insert(l_time_check, v) 
		end
	end

	-- 탈출 체크
	if (#l_time_check == 0) then
		ccdisplay('시간 조건 불충족')
		return
	end

	-- 랜덤으로 드래곤 추출
	dragon = table.getRandom(l_time_check)

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