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

    local l_ret = {}
    for _,v in pairs(l_dragons) do
        local unique_id = v['id']
        l_ret[unique_id] = clone(v)
    end

    return l_ret
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
-- @brief unique id로 드래곤 정보를 얻음
-------------------------------------
function ServerData_Dragons:getDragonDataFromUid(unique_id)
    local l_dragons = self.m_serverData:getRef('dragons')

    for _,v in pairs(l_dragons) do
        if (unique_id == v['id']) then
            return clone(v)
        end
    end

    return nil
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
    local l_dragons = self.m_serverData:getRef('dragons')
    local unique_id = t_dragon_data['id']

    local idx = nil

    for i,v in pairs(l_dragons) do
        if (unique_id == v['id']) then
            idx = i
            break
        end
    end

    -- 룬 효과 체크
    if t_dragon_data then
        t_dragon_data['rune_set'] = self:makeDragonRuneSetData(t_dragon_data)
    end

    -- 기존에 있는 드래곤이면 갱신
    if idx then
        self.m_serverData:applyServerData(t_dragon_data, 'dragons', idx)
    -- 기존에 없던 드래곤이면 추가
    else
        self.m_serverData:applyServerData(t_dragon_data, 'dragons', #l_dragons + 1)
        self.m_dragonsCnt = (self.m_dragonsCnt + 1)
    end

    -- 드래곤 정렬 데이터 수정
    self:setDragonsSortData(unique_id)

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
function ServerData_Dragons:delDragonData(dragon_object_id)
    local l_dragons = self.m_serverData:getRef('dragons')

    local idx = nil

    for i,v in pairs(l_dragons) do
        if (dragon_object_id == v['id']) then
            idx = i
            break
        end
    end

    if idx then
        self.m_serverData:applyServerData(nil, 'dragons', idx)
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
-- function checkUpgradeable
-- @brief
-------------------------------------
function ServerData_Dragons:checkUpgradeable(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false
    end

    local grade = t_dragon_data['grade']
    local eclv = t_dragon_data['eclv']
    local level = t_dragon_data['lv']

    -- 최대 등급 체크
    if (6 <= grade) then
        return false, Str('최고 등급의 드래곤입니다.')
    end

    -- 최대 레벨 체크
    local is_max_level = TableGradeInfo:isMaxLevel(grade, eclv, level)
    if (not is_max_level) then
        return false, Str('등급별 최대 레벨에서 승급이 가능합니다.')
    end

    return true
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
    t_sort_data['friendship'] = t_dragon_data['flv']

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
-- function getRuneBonusList
-- @brief 능력치 계산을 위해 doid에 해당하는 드래곤이 장착한
--        룬의 메인옵션, 서브옵션의 능력치를 합산한 테이블을 리턴
-------------------------------------
function ServerData_Dragons:getRuneBonusList(doid)
    local t_dragon_data = self:getDragonDataFromUid(doid)

    local l_runes = t_dragon_data['runes']

    local l_rune_obj_map = {}
    for i,v in pairs(l_runes) do
        local roid = v
        local t_rune_data = g_runesData:getRuneData(roid)
        l_rune_obj_map[roid] = t_rune_data
    end

    return self:makeRuneBonusList(t_dragon_data, l_rune_obj_map)
end

-------------------------------------
-- function makeRuneBonusList
-- @brief 능력치 계산을 위해 doid에 해당하는 드래곤이 장착한
--        룬의 메인옵션, 서브옵션의 능력치를 합산한 테이블을 리턴
-------------------------------------
function ServerData_Dragons:makeRuneBonusList(t_dragon_data, l_rune_obj_map)
    local l_runes = t_dragon_data['runes']

    local l_rune_bonus = {}

    for i,v in pairs(l_runes) do
        local roid = v
        if (roid ~= '') then
            local t_rune_data = l_rune_obj_map[roid]
            local t_rune_information = t_rune_data['information']

            -- 메인 옵션의 능력치 합산
            for _,data in pairs(t_rune_information['status']['mopt']) do
                local category = data['category']
                local value = data['value']

                if (not l_rune_bonus[category]) then
                    l_rune_bonus[category] = 0
                end
                l_rune_bonus[category] = (l_rune_bonus[category] + value)
            end

            -- 서브 옵션의 능력치 합산
            for _,data in pairs(t_rune_information['status']['sopt']) do
                local category = data['category']
                local value = data['value']

                if (not l_rune_bonus[category]) then
                    l_rune_bonus[category] = 0
                end
                l_rune_bonus[category] = (l_rune_bonus[category] + value)
            end
        end
    end

    return l_rune_bonus
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
    local t_dragon_data = self:getDragonDataFromUid(doid)

    if (not t_dragon_data) then
        return false
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