local PARENT = MultiDeckMgr
-------------------------------------
-- class MultiDeckMgr_Raid
-------------------------------------
MultiDeckMgr_Raid = class(PARENT, {	
 })

 
-------------------------------------
-- function makeDeckMap_raid
-- @breif Multi 덱 map생성 (리스트일 경우 sort 시간 오래걸림)
-------------------------------------
function MultiDeckMgr_Raid:makeDeckMap_raid()
    self.m_tDeckMap_1 = {}
    self.m_tDeckMap_2 = {}
    self.m_tDeckMap_3 = {}

    -- 1 공격대
    do
        local l_deck = g_deckData:getDeck('league_raid_1')
        for k, v in pairs(l_deck) do
            local doid = v
            if (doid) then
                self.m_tDeckMap_1[doid] = k
            end
        end
    end

    -- 2 공격대
    do
        local l_deck = g_deckData:getDeck('league_raid_2')
        for k, v in pairs(l_deck) do
            local doid = v
            if (doid) then
                self.m_tDeckMap_2[doid] = k
            end
        end
    end

    -- 2 공격대
    do
        local l_deck = g_deckData:getDeck('league_raid_3')
        for k, v in pairs(l_deck) do
            local doid = v
            if (doid) then
                self.m_tDeckMap_3[doid] = k
            end
        end
    end
end


-------------------------------------
-- function getDeckMap
-- @breif 선택한 위치 덱 Map
-------------------------------------
function MultiDeckMgr_Raid:getDeckMap(pos)
    local target = self[string.format('m_tDeckMap_%s', pos)]
    return target
end

-------------------------------------
-- function getDeckDragonCnt
-- @breif 선택한 덱 셋팅된 드래곤 수
-------------------------------------
function MultiDeckMgr_Raid:getDeckDragonCnt(pos)
    local target = self[string.format('m_tDeckMap_%d', pos)]
    local cnt = 0
    for _, k in pairs(target) do
        if k ~= nil then
            cnt = cnt + 1
        end
    end
    return cnt
end

-------------------------------------
-- function clearDeckMap
-- @breif Multi 덱 Map 초기화 
-------------------------------------
function MultiDeckMgr_Raid:clearDeckMap(pos)
    local str = string.format('m_tDeckMap_%d', pos)
    local target = self[str]
    if target ~= nil then
        self[str] = {}
    end
end

-------------------------------------
-- function addRaidDragon
-- @breif Multi 덱 해당 드래곤 추가 
-------------------------------------
function MultiDeckMgr_Raid:addRaidDragon(pos, doid)
    local str = string.format('m_tDeckMap_%d', pos)
    local target = self[str]
    if target ~= nil then
        target[doid] = 1
    end
end

-------------------------------------
-- function deleteRaidDragon
-- @breif Multi 덱 해당 드래곤 삭제 
-------------------------------------
function MultiDeckMgr_Raid:deleteRaidDragon(doid)
    for pos = 1 , 3 do
        local str = string.format('m_tDeckMap_%d', pos)
        local target = self[str]
        if target ~= nil then
            target[doid] = nil
        end
    end
end

-------------------------------------
-- function checkSameDidAnoterDeck_Raid
-- @brief 다른 위치 덱 - 동종 동속성 드래곤 검사 
-------------------------------------
function MultiDeckMgr_Raid:checkSameDidAnoterDeck_Raid(doid)
    if (not doid) then
        return false
    end
    --local using_dids = g_leagueRaidData:getUsingDidTable()
    local deck_name = g_deckData:getSelectedDeckName()
    local deck_no = pl.stringx.replace(deck_name, 'league_raid_', '')
    deck_no = tonumber(deck_no)

    for pos = 1,3 do
        local target = self[string.format('m_tDeckMap_%d', pos)]
        if deck_no ~= pos then
            for e_doid, _ in pairs(target) do
                --cclog(doid, e_doid, g_dragonsData:isSameDid(doid, e_doid), not using_dids[doid] )
                if (g_dragonsData:isSameDid(doid, e_doid)) then
                    local team_name = Str('{1} 공격대', pos)
                    local msg = Str('{1} 출전중인 드래곤과 같은 드래곤은 동시에 출전할 수 없습니다.', team_name)
                    UIManager:toastNotificationRed(msg)
                    return true
                end
            end
        end
    end

    return false
end


-------------------------------------
-- function getUsingDidTable
-- @brief 다른 위치 덱 - 동종 동속성 드래곤 아이디 가져오기
-------------------------------------
function MultiDeckMgr_Raid:getUsingDidTable()
    local table_dragon = {}
    for pos = 1,3 do
        local str = string.format('m_tDeckMap_%d', pos)
        local target = self[str]
        if target ~= nil then
            for k, _ in pairs(target) do
                if k ~= nil then
                    table_dragon[k] = string.format('league_raid_%d', pos)
                end
            end
        end
    end

    return table_dragon
end

-------------------------------------
-- function isSettedDragon
-- @breif Multi 덱에 출전중인 드래곤인지
-------------------------------------
function MultiDeckMgr_Raid:isSettedDragon(doid)
--[[     local is_setted = self.m_tDeckMap_1[doid] or nil

    -- 1 공격대
    if (is_setted) then
        return is_setted, 1
    end

    -- 2 공격대
    local is_setted = self.m_tDeckMap_2[doid] or nil
    if (is_setted) then
        return is_setted, 2
    end
 ]]
    -- 3 공격대
    for pos= 1, 3 do
        local str = string.format('m_tDeckMap_%d', pos)
        local target = self[str]

        if target ~= nil then
            local is_setted = target[doid] or nil
            if (is_setted) then
                return true, pos
            end
        end
    end

    return false, 99
end

-------------------------------------
-- function sort_multi_deck_raid
-- @breif 1, 2공격대에 설정된 드래곤을 정렬시 우선
-------------------------------------
function MultiDeckMgr_Raid:sort_multi_deck_raid(a, b)
    local is_setted_1, num_1 = self:isSettedDragon(a['data']['id']) 
    local is_setted_2, num_2 = self:isSettedDragon(b['data']['id']) 

    if (is_setted_1) and (is_setted_2) then
        if num_1 == num_2 then
            return nil
        else
            return  num_1 < num_2
        end

    else
        if not is_setted_2 and not is_setted_1 then
            return nil
        else
            return num_1 < num_2
        end
    end
end
