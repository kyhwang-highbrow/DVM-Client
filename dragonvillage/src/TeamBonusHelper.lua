local MAX_CONDITION_COUNT = 5

-------------------------------------
-- table TeamBonusHelper
-------------------------------------
TeamBonusHelper = {}

-------------------------------------
-- function getAllTeamBonusDataFromDeck
-- @brief 파리미터의 덱으로 설정된 모든 팀보너스 정보를 가져온다
-------------------------------------
function TeamBonusHelper:getAllTeamBonusDataFromDeck(l_deck)
    local l_deck = l_deck or {}
    local table_teambonus = TableTeamBonus()
    local l_teambonus_data = {}
    local l_dragon_data = {}
    local l_ret = {}
    
    -- 모든 팀보너스를 위한 StructTeamBonus 생성
    for _, v in pairs(table_teambonus.m_orgTable) do
        local teambonus_data = StructTeamBonus(v)
        table.insert(l_teambonus_data, teambonus_data)
    end

    for _, v in pairs(l_deck) do
        -- 이미 StructDragonObject 리스트로 받은 경우
        if (type(v) == 'table') then
            local t_dragon_data = v
            table.insert(l_dragon_data, t_dragon_data)

        -- 덱에 포함된 드래곤들의 StructDragonObject 리스트를 생성
        else
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
            if (t_dragon_data) then
                table.insert(l_dragon_data, t_dragon_data)
            else
                error('no exist dragon_data : ' .. doid)
            end
        end            
    end

    -- 모든 팀보너스를 검사
    for _, teambonus_data in ipairs(l_teambonus_data) do
        teambonus_data:setFromDragonObjectList(l_dragon_data)
    end

    return l_teambonus_data
end

-------------------------------------
-- function getTeamBonusDataFromDid
-- @brief did로 적용될 수 있는 팀보너스 정보만 가져온다
-------------------------------------
function TeamBonusHelper:getTeamBonusDataFromDid(did)
    local table_teambonus = TableTeamBonus()
    local l_ret = {}
    
    -- 모든 팀보너스를 검사
    for _, teambonus_data in pairs(table_teambonus.m_orgTable) do
        local is_satisfy = self:checkConditionFromDid(teambonus_data, did)
        if (is_satisfy) then
            table.insert(l_ret, StructTeamBonus(teambonus_data))
        end
    end

    return l_ret
end

-------------------------------------
-- function getTeamBonusDataFromDeck
-- @brief 파리미터의 덱으로 적용될 수 있는 팀보너스 정보만 가져온다
-------------------------------------
function TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)
    local l_teambonus_data = self:getAllTeamBonusDataFromDeck(l_deck)
    local l_ret = {}

    for _, teambonus_data in ipairs(l_teambonus_data) do
        if (teambonus_data:isSatisfied()) then
            table.insert(l_ret, teambonus_data)
        end
    end

    return l_ret
end

-------------------------------------
-- function checkCondition
-- @brief 하나의 팀보너스에 대해 파라미터의 드래곤들이 조건을 만족하는지 검사
-------------------------------------
function TeamBonusHelper:checkCondition(t_teambonus, l_dragon_data)
    local condition_type = t_teambonus['condition_type']

    if (condition_type == 'did_attr_same') then
        return self:checkComplexCondition(t_teambonus, l_dragon_data)
    end
    
    local req_count = t_teambonus['condition_count']

    -- l_dragon_data내의 드래곤 중에서 해당 팀 보너스 효과를 받는 드래곤들을 저장하기 위한 리스트
    local l_valid_dragon_data = {}

    -- 이미 포함된 드래곤을 제외시키기 위한 맵
    local m_doid_to_except = {}
    local m_all_valid_dragon_data = {}
    local m_satisfiedCondition = {}
        
    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition and condition ~= '') then
            local is_exist, m_valid_dragon_data = self:findVaildDragonsFromCondition(condition_type, condition, l_dragon_data, m_doid_to_except)

            if (is_exist) then
                for idx, dragon_data in pairs(m_valid_dragon_data) do
                    m_doid_to_except[dragon_data['id']] = true

                    m_all_valid_dragon_data[idx] = m_valid_dragon_data[idx]
                end

                m_satisfiedCondition[i] = m_valid_dragon_data
            end
        end
    end

    -- 맵형태에서 리스트로 변환
    for _, dragon_data in pairs(m_all_valid_dragon_data) do
        table.insert(l_valid_dragon_data, dragon_data)
    end

    -- 조건 갯수 이상 충족 시 달성
    local achievement_count = table.count(m_satisfiedCondition)
    local b = (achievement_count >= req_count)

    return b, l_valid_dragon_data
end


-------------------------------------
-- function checkComplexCondition
-- @brief 조건 개별로 검사가 불가능한 조건을 가진 경우를 처리하기 위함(did_attr_same)
-------------------------------------
function TeamBonusHelper:checkComplexCondition(t_teambonus, l_dragon_data)
    local condition_type = t_teambonus['condition_type']
    local req_count = t_teambonus['condition_count']
    local l_valid_dragon_data = {}
    local m_dragon_data_per_attr = {}
        
    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition and condition ~= '') then
            for _, dragon_data in ipairs(l_dragon_data) do
                local did = dragon_data['did']
                local did_ignore_attr = did - (did % 10)

                if (TableSlime:isSlimeID(did)) then
                    -- 슬라임의 경우 제외

                elseif (did_ignore_attr == condition) then
                    local attr = dragon_data:getAttr()

                    if (not m_dragon_data_per_attr[attr]) then
                        m_dragon_data_per_attr[attr] = {}
                    end

                    table.insert(m_dragon_data_per_attr[attr], dragon_data)
                end
            end
        end
    end

    local b = false

    -- 조건에 해당되어 버프를 적용해야하는 드래곤들을 리스트에 저장
    for attr, list in pairs(m_dragon_data_per_attr) do
        if (#list >= req_count) then
            for _, v in ipairs(list) do
                table.insert(l_valid_dragon_data, v)
            end

            b = true
        end
    end

    return b, l_valid_dragon_data
end

-------------------------------------
-- function checkConditionFromDid
-- @brief 하나의 팀보너스에 대해 did의 드래곤이 조건을 만족하는지 검사
-------------------------------------
function TeamBonusHelper:checkConditionFromDid(t_teambonus, did)
    local type = t_teambonus['condition_type']
    local table_dragon = TableDragon()
    local t_dragon = table_dragon:get(did)
    local is_satisfy = false

    for i = 1, MAX_CONDITION_COUNT do
        local condition = t_teambonus['condition_' .. i]
        if (condition and condition ~= '') then
            -- 속성 체크
            if (type == 'attr') then
                local attr = t_dragon['attr']
                is_satisfy = (condition == attr)

            -- 역할 체크
            elseif (type == 'role') then
                local role = t_dragon['role']
                is_satisfy = (condition == role)

            -- DID와 속성 체크
            elseif (type == 'did_attr' or type == 'did_attr_same') then
                for i = 1, 5 do
                    local _did = condition + i
                    if (table_dragon:exists(did)) then
                        if (did == _did) then
                            is_satisfy = true
                            break
                        end
                    end
                end

            -- DID 체크
            elseif (type == 'did') then
                if (condition == did) then
                    is_satisfy = true
                    break
                end
            end
        end
    end

    return is_satisfy
end

-------------------------------------
-- function findVaildDragonsFromCondition
-- @brief 파라미터의 조건에 해당하는 드래곤을 l_dragon_data내에서 찾음
-------------------------------------
function TeamBonusHelper:findVaildDragonsFromCondition(condition_type, condition, l_dragon_data, m_doid_to_except)
    if (not condition or condition == '') then
        return false
    end

    local m_doid_to_except = m_doid_to_except or {}

    local table_dragon = TableDragon()
    local m_valid_dragon_data = {}
    local is_exist = false

    for idx, dragon_data in ipairs(l_dragon_data) do
        local doid = dragon_data['id']
        local did = dragon_data['did']

        if (TableSlime:isSlimeID(did)) then
            -- 슬라임의 경우 제외

        elseif (not m_doid_to_except[doid]) then
            local t_dragon = TableDragon():get(did)

            if (condition_type == 'did_attr') then
                -- 조건 타입이 속성을 모두 포함한 특정 드래곤인 경우
                -- !!이 경우 해당하는 드래곤이 여러 마리가 될 수 있음
                local did_ignore_attr = did - (did % 10)
                if (did_ignore_attr == condition) then
                    m_valid_dragon_data[idx] = dragon_data
                    is_exist = true
                end

            elseif (t_dragon[condition_type] == condition) then
                m_valid_dragon_data[idx] = dragon_data
                is_exist = true
                break
            end
        end
    end

    return is_exist, m_valid_dragon_data
end

-------------------------------------
-- function applyTeamBonusToDragonInGame
-- @brief 인게임 내에서 드래곤에게 팀보너스를 적용
-- @param teambonus_data : StructTeamBonus 객체
-- @param dragon : Dragon 객체
-------------------------------------
function TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, dragon)
    if (not teambonus_data:findDidFromSatisfiedList(dragon.m_dragonID)) then
        return
    end

    if (teambonus_data:getType() == 'option') then
        for i = 1, 3 do
            local buff_type = teambonus_data.m_lSkill[i]
            local buff_value = teambonus_data.m_lValue[i]

            if (buff_type) then
                local t_option = TableOption():get(buff_type)
                if (t_option) then
                    --cclog('teambonus option name : ' .. Str(teambonus_data:getName()))
                    local status_type = t_option['status']
                    if (status_type) then
                        if (t_option['action'] == 'multi') then
                            dragon.m_statusCalc:addPassiveMulti(status_type, buff_value)
                        elseif (t_option['action'] == 'add') then
                            dragon.m_statusCalc:addPassiveAdd(status_type, buff_value)
                        end
                    end
                end
            end
        end
        
    elseif (teambonus_data:getType() == 'skill') then
        for i = 1, 3 do
            local skill_id = teambonus_data.m_lSkill[i]

            if (skill_id) then
                local t_skill = TableDragonSkill():get(skill_id)
                --cclog('teambonus skill name : ' .. Str(t_skill['t_name']))
                dragon:setSkillID(t_skill['chance_type'], skill_id, 1, 'new')
            end
        end
    end
end