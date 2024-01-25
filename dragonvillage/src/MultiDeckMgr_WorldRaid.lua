local PARENT = MultiDeckMgr
-------------------------------------
-- class MultiDeckMgr_WorldRaid
-------------------------------------
MultiDeckMgr_WorldRaid = class(PARENT, {
    m_deckCount = 'number',
})


-------------------------------------
-- function makeDeckMap_worldRaid
-- @breif Multi 덱 map생성 (리스트일 경우 sort 시간 오래걸림)
-------------------------------------
function MultiDeckMgr_WorldRaid:makeDeckMap_worldRaid(deck_count)
    self.m_deckCount = deck_count
    for pos = 1, self.m_deckCount do
        --self.m_tDeckMap_1 = {}
        --local deck_map = self[string.format('m_tDeckMap_%d', pos)]
        self[string.format('m_tDeckMap_%d', pos)] = {}
        local str = string.format('world_raid_%d', pos)
        local l_deck = g_deckData:getDeck(str)
        for k, v in pairs(l_deck) do
            local doid = v
            if (doid) then
                self[string.format('m_tDeckMap_%d', pos)][doid] = k
            end
        end
    end
end

-------------------------------------
-- function getDeckMap
-- @breif 선택한 위치 덱 Map
-------------------------------------
function MultiDeckMgr_WorldRaid:getDeckMap(pos)
    local target = self[string.format('m_tDeckMap_%s', pos)]
    return target
end

-------------------------------------
-- function getDeckDragonCnt
-- @breif 선택한 덱 셋팅된 드래곤 수
-------------------------------------
function MultiDeckMgr_WorldRaid:getDeckDragonCnt(pos)    
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
function MultiDeckMgr_WorldRaid:clearDeckMap(pos)
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
function MultiDeckMgr_WorldRaid:addRaidDragon(pos, doid)
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
function MultiDeckMgr_WorldRaid:deleteRaidDragon(doid)
    for pos = 1 , self.m_deckCount do
        local str = string.format('m_tDeckMap_%d', pos)
        local target = self[str]
        if target ~= nil then
            target[doid] = nil
        end
    end
end
-------------------------------------
-- function deleteRaidDragon
-- @breif Multi 덱 해당 드래곤 삭제 
-------------------------------------
function MultiDeckMgr_WorldRaid:getDeckName(pos)
    if pos == 'up' then
        pos = 1
    elseif pos == 'down' then
        pos = 2
    end

    return 'world_raid_' .. pos
end

-------------------------------------
-- function checkSameDidAnoterDeck_Raid
-- @brief 다른 위치 덱 - 동종 동속성 드래곤 검사 
-------------------------------------
function MultiDeckMgr_WorldRaid:checkSameDidAnoterDeck_Raid(doid)
    if (not doid) then
        return false
    end
    --l
    local deck_name = g_deckData:getSelectedDeckName()
    local deck_no = pl.stringx.replace(deck_name, 'world_raid_', '')
    deck_no = tonumber(deck_no)
    
    for pos = 1,self.m_deckCount do        
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
function MultiDeckMgr_WorldRaid:getUsingDidTable()
    local table_dragon = {}
    for pos = 1,3 do
        local str = string.format('m_tDeckMap_%d', pos)
        local target = self[str]
        if target ~= nil then
            for k, _ in pairs(target) do
                if k ~= nil then
                    table_dragon[k] = string.format('world_raid_%d', pos)
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
function MultiDeckMgr_WorldRaid:isSettedDragon(doid)
    -- 3 공격대
    for pos= 1, self.m_deckCount do
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
-- function setMainDeck
-- @brief 메인덱 설정 (수동전투 선택) (up or down)
-------------------------------------
function MultiDeckMgr_WorldRaid:setMainDeck(pos)
    if pos == 1 then
        self.m_main_deck = 'up'
    elseif pos == 2 then
        self.m_main_deck = 'down'
    end
    
    g_settingData:applySettingData(pos, self.m_mode, 'main_deck')
end

-------------------------------------
--- @function getDeckCount
-------------------------------------
function MultiDeckMgr_WorldRaid:getDeckCount()
    return self.m_deckCount
end

-------------------------------------
-- function getAnotherPos
-------------------------------------
function MultiDeckMgr_WorldRaid:getAnotherPos(pos)
    local pos = (pos == 1) and 'down' or 'up'
    return pos
end

-------------------------------------
-- function checkDeckCondition
-- @brief 상단덱 하단덱 출전 조건 체크
-------------------------------------
function MultiDeckMgr_WorldRaid:checkDeckCondition()
    local toast_func = function(pos)
        local team_name = self:getTeamName(pos)
        local msg = Str('{1}에 최소 1명 이상은 출전시켜야 합니다', team_name)
        UIManager:toastNotificationRed(msg)
    end

    for pos= 1, self.m_deckCount do
        local deck_cnt = self:getDeckDragonCnt(pos)
        if (deck_cnt <= 0) then
            toast_func(pos)
            return false
        end
    end

    return true
end

-------------------------------------
-- function sort_multi_deck_raid
-- @breif 1, 2공격대에 설정된 드래곤을 정렬시 우선
-------------------------------------
function MultiDeckMgr_WorldRaid:sort_multi_deck_raid(a, b)
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
