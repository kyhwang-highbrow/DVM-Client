-----------------------------------------------------------------------
-- https://perplelab.atlassian.net/wiki/x/QgDRDQ
-- 2018.01.10 sgkim 추천팀 기능 개편
-----------------------------------------------------------------------

-------------------------------------
-- class DragonAutoSetHelperNew
-------------------------------------
DragonAutoSetHelperNew = class({
        m_stageID = 'number',
        m_formation = 'formation',
        m_lDragonList = 'list',

        m_lDragonPool = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonAutoSetHelperNew:init(stage_id, formation, l_dragon_list)
    self.m_stageID = stage_id
    self.m_formation = formation
    self.m_lDragonList = l_dragon_list
end

-------------------------------------
-- function getAutoDeck
-------------------------------------
function DragonAutoSetHelperNew:getAutoDeck()
    -- 스테이지 정보 얻어옴
    local stage_attr 
    local game_mode = g_stageData:getGameMode(self.m_stageID)
    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        -- 인연 던전의 경우라면 해당 드래곤의 속성을 스테이지 속성으로 설정
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        if (t_dungeon_info) then
            local did = t_dungeon_info['dragon']
            stage_attr = TableDragon():getValue(did, 'attr')
        end
    else
        stage_attr = TableStageData():getValue(self.m_stageID, 'attr')
    end

    -- 1. 드래곤 풀 생성 (추천에 적합한 데이터 형태로 가공)
    --     내가 가진 드래곤의 추천 점수를 계산
    self.m_lDragonPool = self:makeDragonPoolList(self.m_lDragonList, stage_attr)

    do -- 추천 점수로 정렬
        local function sort_func(a, b)
            return a['score'] > b['score']
        end
        table.sort(self.m_lDragonPool, sort_func)

        -- 중복된 드래곤 제거
        self:removeDuplicateDragon(self.m_lDragonPool)
    end

    if (5 < table.count(self.m_lDragonPool)) then

        local fixed_doid_map = {}

        do -- 힐러 추가
            local _included, _doid = self:checkRole(self.m_lDragonPool, 'healer')
            if _included then
                fixed_doid_map[_doid] = true
            else
                self:findRole(self.m_lDragonPool, 'healer', fixed_doid_map)
            end
        end

        do -- 공격형 추가
            local _included, _doid = self:checkRole(self.m_lDragonPool, 'dealer')
            if _included then
                fixed_doid_map[_doid] = true
            else
                self:findRole(self.m_lDragonPool, 'dealer', fixed_doid_map)
            end
        end

        do -- 방어형 추가
            local _included, _doid = self:checkRole(self.m_lDragonPool, 'tanker')
            if _included then
                fixed_doid_map[_doid] = true
            else
                self:findRole(self.m_lDragonPool, 'tanker', fixed_doid_map)
            end
        end
    end

    -- 위치 지정
    local last_list = self:setDragonIndex(self.m_lDragonPool)

    -- 리턴 테이블 생성
    local t_temp_ret = {}
    for i,v in ipairs(last_list) do
        local _doid = v['doid']
        local dragon_obj = self.m_lDragonList[_doid]
        table.insert(t_temp_ret, dragon_obj)

        if (5<=i) then
            break
        end
    end

    return t_temp_ret
end

-------------------------------------
-- function checkRole
-- @brief 1~5 안에 해당 직업군의 드래곤이 있는지 확인
-------------------------------------
function DragonAutoSetHelperNew:checkRole(dragon_pool_list, role_str)
    local included = false
    local doid = nil

    for i=1, 5 do
        local t_data = dragon_pool_list[i]
        if t_data and (t_data['role'] == role_str) then
            included = true
            doid = t_data['doid']
            break
        end
    end

    return included, doid
end

-------------------------------------
-- function findRole
-- @brief 5순위 밖에서 특정 역할군의 드래곤을 5순위 안으로 넣어주는 함수
-------------------------------------
function DragonAutoSetHelperNew:findRole(dragon_pool_list, role_str, fixed_doid_map)
    -- 특정 역할 드래곤으로 교체될 드래곤 추출
    local target_dragon = nil
    local target_dragon_idx = nil
    for i=5, 1, -1 do
        local t_data = dragon_pool_list[i]
        if t_data then
            local _doid = t_data['doid']
            if (not fixed_doid_map[_doid]) then
                target_dragon = t_data
                target_dragon_idx = i
                break
            end
        end
    end

    if (not target_dragon) then
        return
    end

    -- 5순위 안에 들지 못했지만 특정 역할인 드래곤 추출
    local find_dragon = nil
    local find_dragon_idx = nil
    for i=6, table.count(dragon_pool_list) do
        local t_data = dragon_pool_list[i]
        if t_data and (t_data['role'] == role_str) then

            -- 교체될 드래곤의 70% 점수보단 높아야 변경
            if ((target_dragon['score'] * 0.7) <= t_data['score']) then
                find_dragon = t_data
                find_dragon_idx = i

                local _doid = t_data['doid']
                fixed_doid_map[_doid] = true
                break
            end
        end
    end

    -- 드래곤 풀에서 순서 조정
    if find_dragon_idx then
        table.remove(dragon_pool_list, find_dragon_idx)
        table.remove(dragon_pool_list, target_dragon_idx)
        
        table.insert(dragon_pool_list, target_dragon_idx, find_dragon)
        table.insert(dragon_pool_list, target_dragon)
    end
end

-------------------------------------
-- function makeDragonPoolList
-- @brief 드래곤 추천에 적합한 데이터로 변경하여 드래곤 풀을 생성
-------------------------------------
function DragonAutoSetHelperNew:makeDragonPoolList(dragon_obj_list, stage_attr)
    local dragon_pool_list = {}
    local table_dragon = TableDragon()

    for doid,t_dragon_data_org in pairs(dragon_obj_list) do

        -- 변수 선언
        local _doid = doid
        local _did = t_dragon_data_org['did']
        local _attr = table_dragon:getValue(_did, 'attr')
        local _role = table_dragon:getValue(_did, 'role')
        local _hp = 0
        local _def = 0
        local _combat_power = 0
        local _score = 0

        
        do -- 전투력
            local sort_data = g_dragonsData:getDragonsSortData(doid)
            _hp = sort_data['hp']
            _def = sort_data['def']
            _combat_power = sort_data['combat_power']
        end

        do -- 상성에 따라 가중치 적용
            local ret = getCounterAttribute(_attr, stage_attr)
            _score = _combat_power

            -- 상성
            if (ret == 1) then
                _score = math_floor(_score * 1.3)
            -- 역상성
            elseif (ret == -1) then
                _score = math_floor(_score * 0.7)
            -- 무상성
            else -- if(ret == 0) then

            end
        end

        -- 테이블 생성
        local t_dragon_data = {}
        t_dragon_data['doid'] = _doid
        t_dragon_data['did'] = _did
        t_dragon_data['attr'] = _attr
        t_dragon_data['role'] = _role
        t_dragon_data['hp'] = _hp
        t_dragon_data['def'] = _def
        t_dragon_data['combat_power'] = _combat_power
        t_dragon_data['score'] = _score


        -- 정렬을 위한 드래곤 풀
        table.insert(dragon_pool_list, t_dragon_data)
    end

    return dragon_pool_list
end

-------------------------------------
-- function removeDuplicateDragon
-- @breif 리스트에 did가 동일한 드래곤 제거
--        index가 앞쪽이면 전투력이 높다고 가정
-------------------------------------
function DragonAutoSetHelperNew:removeDuplicateDragon(dragon_pool_list)
    local t_dragon_id_map = {}
    local l_remove_idx = {}

    for i,v in pairs(dragon_pool_list) do
        local _did = v['did']
        
        -- 이미 존재하는 did이면 삭제 리스트에 추가
        if t_dragon_id_map[_did] then
            table.insert(l_remove_idx, 1, i)
        else
            t_dragon_id_map[_did] = true
        end
    end

    -- 중복된 did들 순차적으로 제거
    for i,v in ipairs(l_remove_idx) do
        table.remove(dragon_pool_list, v)
    end
end

-------------------------------------
-- function setDragonIndex
-- @breif 선택된 5종의 드래곤을 유효 생명력이 높은 순으로 전방부터 배치
-------------------------------------
function DragonAutoSetHelperNew:setDragonIndex(dragon_pool_list)
    local l_list = {}

    -- 1~5번 드래곤만 추출
    for i=1, 5 do
        local t_data = dragon_pool_list[i]
        if t_data then
            table.insert(l_list, t_data)
        end
    end

    -- 유효 생명력 공식으로 정렬
    local function sort_func(a, b)
        local a_score = a['hp'] / (1 - (a['def'] / (1200 + a['def'])))
        local b_score = b['hp'] / (1 - (b['def'] / (1200 + b['def'])))
        return a_score > b_score
    end
    table.sort(l_list, sort_func)

    return l_list
end