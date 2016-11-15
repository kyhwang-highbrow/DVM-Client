-------------------------------------
-- class DragonAutoSetHelper
-------------------------------------
DragonAutoSetHelper = class({
        m_stageID = 'number',
        m_lDragonList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonAutoSetHelper:init()
end

-------------------------------------
-- function setStageID
-------------------------------------
function DragonAutoSetHelper:setStageID(stage_id)
    self.m_stageID = stage_id
end

-------------------------------------
-- function setDragonList
-------------------------------------
function DragonAutoSetHelper:setDragonList(l_dragon_list)
    self.m_lDragonList = clone(l_dragon_list)
end

-------------------------------------
-- function getAutoDeck
-------------------------------------
function DragonAutoSetHelper:getAutoDeck()
    local stage_id = self.m_stageID
    local l_dragon_list = self.m_lDragonList
    local l_deck = {}
    local l_ret_deck = {}
    
    do -- 드래곤 5마리 선출
        -- 1. 현재 스테이지에 적용된 attr에 따라 유리한 드래곤을 4마리 픽업함
        self:step_01_attr_pickup(l_dragon_list, l_deck, stage_id)

        -- 2. A단계에서 속성 유리 드래곤이 4마리가 안될 경우, 레벨 높은 순으로 나머지를 픽업함 동등 레벨일 경우 랜덤 
        self:step_02_attr_pickup(l_dragon_list, l_deck)

        -- 3. 5번째 드래곤을 추가 (힐러 최소 1명이 되도록)
        self:step_03_healer_pickup(l_dragon_list, l_deck)
    end

    do -- 포지션 설정
        -- 전열
        self:sort_front(l_deck, l_ret_deck)

        -- 중열
        self:sort_middle(l_deck, l_ret_deck)

        -- 후열
        self:sort_rear(l_deck, l_ret_deck)
    end

    return l_ret_deck
end

-------------------------------------
-- function step_01_attr_pickup
-- @brief 현재 스테이지에 적용된 attr에 따라 유리한 드래곤을 4마리 픽업함
-------------------------------------
function DragonAutoSetHelper:step_01_attr_pickup(l_dragon_list, l_deck, stage_id)
    -- 스테이지 정보 얻어옴
    local table_stage_desc = TableStageDesc()
    local t_stage_desc = table_stage_desc:get(stage_id)

    -- 드래곤 테이블
    local table_dragon = TableDragon()

    -- 스테이지의 속성을 얻어옴
    local attr = t_stage_desc['attr']

    -- 상성이 좋은 속성을 얻어옴
    local l_attr = getAttrDisadvantageList(attr)
    local advantage_attr = l_attr[1]

    -- 속성이 맞는 드래곤 저장
    local l_temp = {}
    for i,v in pairs(l_dragon_list) do
        local t_dragon = table_dragon:get(v['did'])
        if (t_dragon['attr'] == advantage_attr) then
            table.insert(l_temp, v)
        end
    end
    table.sort(l_temp, function(a, b)
        return a['lv'] > b['lv']
    end)

    -- 4마리
    for i=1, 4 do
        local t_data = l_temp[i]
        if t_data then
            table.insert(l_deck, t_data)
            l_dragon_list[t_data['id']] = nil
        end
    end
end

-------------------------------------
-- function step_02_attr_pickup
-- @brief A단계에서 속성 유리 드래곤이 4마리가 안될 경우, 레벨 높은 순으로 나머지를 픽업함
--        동등 레벨일 경우 랜덤
-------------------------------------
function DragonAutoSetHelper:step_02_attr_pickup(l_dragon_list, l_deck)
    local count = table.count(l_deck)

    if (count >= 4) then
        return
    end

    local l_temp = {}
    for i,v in pairs(l_dragon_list) do
        table.insert(l_temp, v)
    end
    table.sort(l_temp, function(a, b)
        return a['lv'] > b['lv']
    end)

    for i,t_data in ipairs(l_temp) do
        table.insert(l_deck, t_data)
        l_dragon_list[t_data['id']] = nil
        count = (count + 1)

        if (count >= 4) then
            break
        end
    end
end

-------------------------------------
-- function step_03_healer_pickup
-- @brief 5번째 드래곤을 추가 (힐러 최소 1명이 되도록)
-------------------------------------
function DragonAutoSetHelper:step_03_healer_pickup(l_dragon_list, l_deck)
    -- 드래곤 테이블
    local table_dragon = TableDragon()

    -- 4명까지 수집한 덱에 힐러가 있는지 확인
    local exist_healer = false
    for i,v in pairs(l_deck) do
        local t_dragon = table_dragon:get(v['did'])
        if (t_dragon['role'] == 'healer') then
            exist_healer = true
            break
        end
    end

    -- 힐러가 없을 경우
    if (not exist_healer) then
        local l_temp = {}
        for i,v in pairs(l_dragon_list) do
            local t_dragon = table_dragon:get(v['did'])
            if (t_dragon['role'] == 'healer') then
                table.insert(l_temp, v)
            end
        end
        table.sort(l_temp, function(a, b)
            return a['lv'] > b['lv']
        end)

        -- 가장 레벨이 높은 힐러를 추가
        if l_temp[1] then
            table.insert(l_deck, l_temp[1])
            local id = l_temp[1]['id']
            l_dragon_list[id] = nil
        end
    end

    do -- 5명이 될때까지 레벨순으로 드래곤을 추가
        local count = table.count(l_deck)

        if (count >= 5) then
            return
        end

        local l_temp = {}
        for i,v in pairs(l_dragon_list) do
            table.insert(l_temp, v)
        end
        table.sort(l_temp, function(a, b)
            return a['lv'] > b['lv']
        end)

        for i,t_data in ipairs(l_temp) do
            table.insert(l_deck, t_data)
            l_dragon_list[t_data['id']] = nil
            count = (count + 1)

            if (count >= 5) then
                break
            end
        end
    end
end

-------------------------------------
-- function removeDragonData
-- @brief 리스트에서 해당 그래곤 데이터 삭제
-------------------------------------
function DragonAutoSetHelper:removeDragonData(l_deck, t_dragon_data)
    for i,v in pairs(l_deck) do
        if (v['id'] == t_dragon_data['id']) then
            table.remove(l_deck, i)
            break
        end
    end
end

-------------------------------------
-- function sort_front
-- @brief 픽업된 5마리 드래곤중 메인힐을 제외한 4마리 중 hp 값이 가장 높은 2마리를 전열에 1, 3 순서로 배치함
-------------------------------------
function DragonAutoSetHelper:sort_front(l_deck, l_ret_deck)
    -- 드래곤 테이블
    local table_dragon = TableDragon()

    local l_temp = clone(l_deck)

    do -- l_temp에서 메인 힐러 제외
        local l_healer = {}
        for i,v in pairs(l_temp) do
            local t_dragon = table_dragon:get(v['did'])
            if (t_dragon['role'] == 'healer') then
                table.insert(l_healer, v)
            end
        end
        table.sort(l_healer, function(a, b)
            return a['lv'] > b['lv']
        end)

        if l_healer[1] then
            for i,v in pairs(l_temp) do
                if (l_healer[1]['id'] == v['id']) then
                    table.remove(l_temp, i)
                    break
                end
            end
        end
    end

    -- 체력으로 정렬
    table.sort(l_temp, function(a_data, b_data)
        local a_sort_data = g_dragonsData:getDragonsSortData(a_data['id'])
        local b_sort_data = g_dragonsData:getDragonsSortData(b_data['id'])
        return a_sort_data['hp'] > b_sort_data['hp']
    end)

    -- 2마리를 전열에 1, 3 순서로 배치함
    for i=1,2 do
        local t_dragon = l_temp[i]
        local deck_idx
        if (i==1) then
            deck_idx = 1
        elseif (i==2) then
            deck_idx = 3
        end

        if t_dragon then
            l_ret_deck[deck_idx] = t_dragon
            self:removeDragonData(l_deck, t_dragon)
        end
    end
end

-------------------------------------
-- function sort_middle
-- @brief D에서 제외된 3마리 드래곤 중에서 atk가 가장 높은 1마리를 5에 배치함
-------------------------------------
function DragonAutoSetHelper:sort_middle(l_deck, l_ret_deck)
    -- 공격력으로 정렬
    table.sort(l_deck, function(a_data, b_data)
        local a_sort_data = g_dragonsData:getDragonsSortData(a_data['id'])
        local b_sort_data = g_dragonsData:getDragonsSortData(b_data['id'])
        return a_sort_data['atk'] > b_sort_data['atk']
    end)

    -- atk가 가장 높은 1마리를 5에 배치함
    if l_deck[1] then
        local t_dragon = l_deck[1]
        l_ret_deck[5] = t_dragon
        self:removeDragonData(l_deck, t_dragon)
    end
end

-------------------------------------
-- function sort_rear
-- @brief E단계에서 남은 두마리를 7, 9 순서에 랜덤 배치함
-------------------------------------
function DragonAutoSetHelper:sort_rear(l_deck, l_ret_deck)
    local sum_random = SumRandom()
    sum_random:addItem(1, 7)
    sum_random:addItem(1, 9)

    for i,v in pairs(l_deck) do
        local deck_idx = sum_random:getRandomValue(nil, true)
        l_ret_deck[deck_idx] = v
    end
end