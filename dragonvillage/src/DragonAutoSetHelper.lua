-------------------------------------
-- class DragonAutoSetHelper
-------------------------------------
DragonAutoSetHelper = class({
        m_stageID = 'number',
        m_formation = 'formation',
        m_lDragonList = 'list',

        m_lDragonPool = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function DragonAutoSetHelper:init(stage_id, formation, l_dragon_list)
    self.m_stageID = stage_id
    self.m_formation = formation
    self.m_lDragonList = l_dragon_list
end

-------------------------------------
-- function getAutoDeck
-------------------------------------
function DragonAutoSetHelper:getAutoDeck()
    -- 스테이지 정보 얻어옴
    local table_stage_desc = TableStageDesc()
    local stage_attr = table_stage_desc:getValue(self.m_stageID, 'attr')

    -- 1. 전투력 계산
    self.m_lDragonPool = {}
    local table_dragon = TableDragon()
    for doid,t_dragon_data_org in pairs(self.m_lDragonList) do

        local t_dragon_data = {}
        t_dragon_data['doid'] = doid
        t_dragon_data['did'] = t_dragon_data_org['did']

        -- 드래곤 테이블에서 필요한 정보 설정
        local did = t_dragon_data['did']
        t_dragon_data['attr'] = table_dragon:getValue(did, 'attr')
        t_dragon_data['role'] = table_dragon:getValue(did, 'role')

        -- 드래곤들의 개별 전투력 계산
        local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data_org)
        local combat_power = status_calc:getCombatPower()
        t_dragon_data['status_calc'] = status_calc
        t_dragon_data['combat_power'] = combat_power

        -- 상성 효과 얻어옴 (드래곤 속성이 스테이지 속성을 상대할 때)
        local t_attr_effect = getAttrSynastryEffect(t_dragon_data['attr'], stage_attr, 0)
        local rate = (t_attr_effect['damage'] or  0) / 100
        
        -- 'damage'속성 버프로 전투력 보정
        t_dragon_data['combat_power_adjust'] = combat_power * (1 + rate)

        -- 정렬을 위한 드래곤 풀
        table.insert(self.m_lDragonPool, t_dragon_data)
    end


    -- 2. 전투력이 가장 높은 힐러 픽
    local healder_dragon = nil
    do
        local function sort_func(a, b)
            -- 힐러 중 전투력이 높은 순으로 정렬
            if (a['role'] == 'healer') and (b['role'] == 'healer') then
                return a['combat_power_adjust'] > b['combat_power_adjust']
            elseif (a['role'] == 'healer') then
                return true
            elseif (b['role'] == 'healer') then
                return false
            end

            -- 힐러가 없을 경우 서포터 중 전투력이 높은 순으로 정렬
            if (a['role'] == 'supporter') and (b['role'] == 'supporter') then
                return a['combat_power_adjust'] > b['combat_power_adjust']
            elseif (a['role'] == 'supporter') then
                return true
            elseif (b['role'] == 'supporter') then
                return false
            end

            -- 힐러와 서포터가 모두 없을 경우 전투력이 높은 순으로 정렬
            return a['combat_power_adjust'] > b['combat_power_adjust']
        end
        table.sort(self.m_lDragonPool, sort_func)

        -- 첫 번째 드래곤을 힐러로 지정
        if self.m_lDragonPool[1] then
            healder_dragon = self.m_lDragonPool[1]
            table.remove(self.m_lDragonPool, 1)
        end
    end

    -- 3. 힐러역할이 지정되지 않았을 경우 드래곤이 0마리이기 때문에 리턴
    if (not healder_dragon) then
        return {}
    end


    -- 4. 전투력 높은 순서로 4명 선별
    do
        local function sort_func(a, b)
            return a['combat_power_adjust'] > b['combat_power_adjust']
        end
        table.sort(self.m_lDragonPool, sort_func)

        local l_temp = self.m_lDragonPool
        self.m_lDragonPool = {}

        -- 전투력 상위 4마리를 뽑되 동종동속성은 배제
        while ((table.count(self.m_lDragonPool) < 4) or (table.count(l_temp) > 0)) do
            if (not self:checkSameDid(l_temp[1], self.m_lDragonPool)) then
                table.insert(self.m_lDragonPool, l_temp[1])
            end
            table.remove(l_temp, 1)
        end
    end

    -- formation의 전위, 중위, 후위 정보 얻어옴
    local l_location_info = TableFormation:getLocationInfo(self.m_formation)

    -- 3. 체력이 가장 높은 탱커(front) 픽
    local l_tanker = {}
    do
        local l_front_location = l_location_info['front']
        local cnt = table.count(l_front_location)

        local function sort_func(a, b)
            return a['status_calc']:getFinalStat('hp') > b['status_calc']:getFinalStat('hp')
        end
        table.sort(self.m_lDragonPool, sort_func)

        for i=1, cnt do
            if (not self.m_lDragonPool[1]) then
                break
            end

            table.insert(l_tanker, self.m_lDragonPool[1])
            table.remove(self.m_lDragonPool, 1)
        end
    end

    -- 4. 중위 픽 (dealer)
    local l_dealer = {}
    do
        local l_middle_location = l_location_info['middle']
        local cnt = table.count(l_middle_location)

        local function sort_func(a, b)
            return a['status_calc']:getFinalStat('atk') > b['status_calc']:getFinalStat('atk')
        end
        table.sort(self.m_lDragonPool, sort_func)

        for i=1, cnt do
            if (not self.m_lDragonPool[1]) then
                break
            end

            table.insert(l_dealer, self.m_lDragonPool[1])
            table.remove(self.m_lDragonPool, 1)
        end
    end

    -- 5. 후위 픽 (supporter, healer)
    local l_supporter = {}
    do
        table.insert(l_supporter, healder_dragon)

        for i,v in pairs(self.m_lDragonPool) do
            table.insert(l_supporter, v)
        end
        self.m_lDragonPool = nil
    end


    local l_ret = self:makeDeckTable(l_location_info, l_tanker, l_dealer, l_supporter)
    return l_ret
end

-------------------------------------
-- function checkSameDid
-------------------------------------
function DragonAutoSetHelper:checkSameDid(t_dragon, l_dragon_list)
    local did = t_dragon['did']
    for _, t_dragon_x in pairs(l_dragon_list) do
        if (did == t_dragon_x['did']) then
            return true
        end
    end
    return false 
end

-------------------------------------
-- function makeDeckTable
-------------------------------------
function DragonAutoSetHelper:makeDeckTable(l_location_info, l_tanker, l_dealer, l_supporter)
    local l_deck = {}

    -- 전위에 탱커들 배치
    local l_front = l_location_info['front']
    for _,idx in ipairs(l_front) do
        if (#l_tanker <= 0) then
            break
        end

        local rand_num = math_random(1, #l_tanker)
        local data = l_tanker[rand_num]
        table.remove(l_tanker, rand_num)
        
        local doid = data['doid']
        local t_dragon_data = self.m_lDragonList[doid]
        l_deck[tonumber(idx)] = t_dragon_data
    end

    -- 중위에 딜러들 배치
    local l_middle = l_location_info['middle']
    for _,idx in ipairs(l_middle) do
        if (#l_dealer <= 0) then
            break
        end

        local rand_num = math_random(1, #l_dealer)
        local data = l_dealer[rand_num]
        table.remove(l_dealer, rand_num)
        
        local doid = data['doid']
        local t_dragon_data = self.m_lDragonList[doid]
        l_deck[tonumber(idx)] = t_dragon_data
    end

    -- 후위에 서포터(힐러)들 배치
    local l_rear = l_location_info['rear']
    for _,idx in ipairs(l_rear) do
        if (#l_supporter <= 0) then
            break
        end

        local rand_num = math_random(1, #l_supporter)
        local data = l_supporter[rand_num]
        table.remove(l_supporter, rand_num)
        
        local doid = data['doid']
        local t_dragon_data = self.m_lDragonList[doid]
        l_deck[tonumber(idx)] = t_dragon_data
    end

    return l_deck
end