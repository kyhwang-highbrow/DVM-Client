-------------------------------------
-- class MultiDeckMgr
-------------------------------------
MultiDeckMgr = class({	
        -- 게임 모드 
        m_mode = '',

        -- 메인 (수동으로 전투가 가능한) 덱 (up or down) - 로컬에 저장
        m_main_deck = 'string',
        m_sub_data = '',

        -- 덱 map (임시 저장)
		m_tDeckMap_1 = 'map', -- 인게임 상단덱 (1공격대)
        m_tDeckMap_2 = 'map', -- 인게임 하단덱 (2공격대)
     })


-- 선택한 MULTI_DECK_MODE 이름 뒤에 _up, _down 으로 2개의 덱이 저장됨
-- ex) MULTI_DECK_MODE.CLAN_RAID : clan_raid_up, clan_raid_down

MULTI_DECK_MODE = {
    CLAN_RAID = 'clan_raid',        -- 클랜 던전
    ANCIENT_RUIN = 'ancient_ruin',  -- 고대 유적 던전
    EVENT_ARENA = 'grand_arena',    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
}

-------------------------------------
-- function init
-------------------------------------
function MultiDeckMgr:init(deck_mode, make_deck, sub_data)
	self.m_mode = deck_mode
    self.m_sub_data = sub_data

    -- 메인덱은 로컬에 저장
    self.m_main_deck = g_settingData:get(self.m_mode, 'main_deck') or 'up'

    -- up, down 덱 map생성
    if (make_deck) then
        self:makeDeckMap()
    end
end

-------------------------------------
-- function makeDeckMap
-- @breif Multi 덱 map생성 (리스트일 경우 sort 시간 오래걸림)
-------------------------------------
function MultiDeckMgr:makeDeckMap()
    self.m_tDeckMap_1 = {}
    self.m_tDeckMap_2 = {}

    -- 1 공격대
    do
        local deck_name = self:getDeckName('up')
        local l_deck = g_deckData:getDeck(deck_name)
        for k, v in pairs(l_deck) do
            local doid = v
            if (doid) then
                self.m_tDeckMap_1[doid] = k
            end
        end
    end

    -- 2 공격대
    do
        local deck_name = self:getDeckName('down')
        local l_deck = g_deckData:getDeck(deck_name)
        for k, v in pairs(l_deck) do
            local doid = v
            if (doid) then
                self.m_tDeckMap_2[doid] = k
            end
        end
    end
end

-------------------------------------
-- function getDeckMap
-- @breif 선택한 위치 덱 Map
-------------------------------------
function MultiDeckMgr:getDeckMap(pos)
    return (pos == 'up') and self.m_tDeckMap_1 or self.m_tDeckMap_2
end

-------------------------------------
-- function getAnotherDeckMap
-- @breif 선택한 다른 위치 덱 Map
-------------------------------------
function MultiDeckMgr:getAnotherDeckMap(pos)
    return (pos == 'up') and self.m_tDeckMap_2 or self.m_tDeckMap_1
end

-------------------------------------
-- function addDragon
-- @breif Multi 덱 해당 드래곤 추가 
-------------------------------------
function MultiDeckMgr:addDragon(pos, doid)
    local target = pos == 'up' and self.m_tDeckMap_1 or self.m_tDeckMap_2
    target[doid] = 1
end

-------------------------------------
-- function deleteDragon
-- @breif Multi 덱 해당 드래곤 삭제 
-------------------------------------
function MultiDeckMgr:deleteDragon(pos, doid)
    local target = pos == 'up' and self.m_tDeckMap_1 or self.m_tDeckMap_2
    target[doid] = nil
end

-------------------------------------
-- function clearDeckMap
-- @breif Multi 덱 Map 초기화 
-------------------------------------
function MultiDeckMgr:clearDeckMap(pos)
    if (pos == 'up') then
        self.m_tDeckMap_1 = {}
    else
        self.m_tDeckMap_2 = {}
    end
end

-------------------------------------
-- function getAnotherPos
-------------------------------------
function MultiDeckMgr:getAnotherPos(pos)
    local pos = (pos == 'up') and 'down' or 'up'
    return pos
end

-------------------------------------
-- function getDeckName
-------------------------------------
function MultiDeckMgr:getDeckName(pos)
    local pos = pos or 'up' -- or 'down'
    local deck_name
    -- 클랜던전 속성별 덱 추가
    if (self.m_sub_data) then
        deck_name = self.m_mode .. '_' .. self.m_sub_data
    end

    if (deck_name) then
        deck_name = deck_name.. '_' .. pos
    else
        deck_name = self.m_mode .. '_' .. pos
    end

    return deck_name
end

-------------------------------------
-- function setMainDeck
-- @brief 메인덱 설정 (수동전투 선택) (up or down)
-------------------------------------
function MultiDeckMgr:setMainDeck(pos)
    if (pos == 'up' or pos == 'down') then
        self.m_main_deck = pos
        g_settingData:applySettingData(pos, self.m_mode, 'main_deck')
    end
end

-------------------------------------
-- function getMainDeck
-- @brief 메인덱 (수동전투 가능한) (up or down)
-------------------------------------
function MultiDeckMgr:getMainDeck()
    return self.m_main_deck
end

-------------------------------------
-- function getTeamName
-------------------------------------
function MultiDeckMgr:getTeamName(pos)
    local pos = pos or 'up' -- or 'down'
    local team_name = (pos == 'up') and 
                      Str('1 공격대') or
                      Str('2 공격대') 
    return team_name
end

-------------------------------------
-- function getDeckDragonCnt
-- @breif 선택한 덱 셋팅된 드래곤 수
-------------------------------------
function MultiDeckMgr:getDeckDragonCnt(pos)
    local target = pos == 'up' and self.m_tDeckMap_1 or self.m_tDeckMap_2
    local cnt = 0
    for _, k in pairs(target) do
        cnt = cnt + 1
    end

    return cnt
end

-------------------------------------
-- function isSettedDragon
-- @breif Multi 덱에 출전중인 드래곤인지
-------------------------------------
function MultiDeckMgr:isSettedDragon(doid)
    local is_setted = self.m_tDeckMap_1[doid] or nil
    -- 1 공격대
    if (is_setted) then
        return is_setted, 1
    end

    -- 2 공격대
    local is_setted = self.m_tDeckMap_2[doid] or nil
    if (is_setted) then
        return is_setted, 2
    end

    return false, 99
end


-------------------------------------
-- function sort_multi_deck
-- @breif 1, 2공격대에 설정된 드래곤을 정렬시 우선
-------------------------------------
function MultiDeckMgr:sort_multi_deck(a, b)
    local is_setted_1, num_1 = self:isSettedDragon(a['data']['id']) 
    local is_setted_2, num_2 = self:isSettedDragon(b['data']['id']) 

    if (is_setted_1) and (is_setted_2) then
        return nil

    elseif (is_setted_1) then
        return true

    elseif (is_setted_2) then
        return false

    else
        return nil
    end
end


-------------------------------------
-- function checkSameDidAnoterDeck
-- @brief 다른 위치 덱 - 동종 동속성 드래곤 검사 
-------------------------------------
function MultiDeckMgr:checkSameDidAnoterDeck(sel_pos, doid)
    if (not doid) then
        return false
    end

    local another_deck = self:getAnotherDeckMap(sel_pos)
    for e_doid, _ in pairs(another_deck) do
        if (g_dragonsData:isSameDid(doid, e_doid)) then
            local another_pos = self:getAnotherPos(sel_pos)
            local team_name = self:getTeamName(another_pos)
            local msg = Str('{1} 출전중인 드래곤과 같은 드래곤은 동시에 출전할 수 없습니다.', team_name)
            UIManager:toastNotificationRed(msg)

            return true
        end
    end

    return false
end

-------------------------------------
-- function checkDeckCondition
-- @brief 상단덱 하단덱 출전 조건 체크
-------------------------------------
function MultiDeckMgr:checkDeckCondition()
    local toast_func = function(pos)
        local team_name = self:getTeamName(pos)
        local msg = Str('{1}에 최소 1명 이상은 출전시켜야 합니다', team_name)
        UIManager:toastNotificationRed(msg)
    end

    -- 상단 덱 체크
    do
        local pos = 'up'
        local deck_cnt = self:getDeckDragonCnt(pos)
        if (deck_cnt <= 0) then
            toast_func(pos)
            return false
        end
    end

    -- 하단 덱 체크
    do
        local pos = 'down'
        local deck_cnt = self:getDeckDragonCnt(pos)
        if (deck_cnt <= 0) then
            toast_func(pos)
            return false
        end
    end
    
    return true
end

-------------------------------------
-- function checkMultiDeckWithName
-- @brief 덱네임으로 멀티덱인지 검사
-------------------------------------
function CheckMultiDeckWithName(deck_name)
    local is_multi_deck = false
    local multi_deck_mgr

    -- 속성별 덱 검사
    local function check_attr_deck(_deck_name)
        local l_attr = getAttrTextList()
        for _, attr in ipairs(l_attr) do
            if string.find(_deck_name, attr) then
                return attr
            end
        end
        return nil
    end

    -- 멀티 덱 검사
    for _, mode in pairs(MULTI_DECK_MODE) do
        if string.find(deck_name, mode) then
            is_multi_deck = true
            local make_deck = true
            local sub_data = check_attr_deck(deck_name)
            multi_deck_mgr = MultiDeckMgr(mode, make_deck, sub_data)
            break
        end
    end

    return is_multi_deck, multi_deck_mgr
end