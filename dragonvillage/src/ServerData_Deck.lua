-------------------------------------
-- class ServerData_Deck
-------------------------------------
ServerData_Deck = class({
        m_serverData = 'ServerData',

        m_mapDragonDeckInfo = 'map',

        m_selectedDeck = 'string', -- 현재 선택되어 있는 덱
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Deck:init(server_data)
    self.m_serverData = server_data
    self.m_selectedDeck = self.m_serverData:get('local', 'selected_deck') or 'adv'
end

-------------------------------------
-- function response_deckInfo
-- @brief users/get_deck에 해당하는 response이며 users/title에서 함께 받는 것으로 수정됨
-------------------------------------
function ServerData_Deck:response_deckInfo(l_deck)
    self.m_serverData:applyServerData(l_deck, 'deck')
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Deck:get(key)
    return self.m_serverData:get('deck', key)
end

-------------------------------------
-- function setDeck
-- @brief
-------------------------------------
function ServerData_Deck:setDeck(deck_name, t_deck)
    local l_deck = self.m_serverData:get('deck')

    local idx = nil
    for i,value in pairs(l_deck) do
        if (value['deckname'] == deck_name) then
            idx = i
            break
        end
    end

    if (not idx) then
        idx = #l_deck + 1
    end

    self.m_serverData:applyServerData(t_deck, 'deck', idx)
    self:resetDragonDeckInfo()
end

-------------------------------------
-- function getDeck
-- @brief
-------------------------------------
function ServerData_Deck:getDeck(deck_name)
    local l_deck, formation, deckname, leader, tamer_id = self:getDeck_core(deck_name)

    if (not tamer_id) or (0 == tamer_id) then
        tamer_id = g_tamerData:getCurrTamerID()
    end

    return l_deck, formation, deckname, leader, tamer_id
end

-------------------------------------
-- function getDeck_core
-- @brief
-------------------------------------
function ServerData_Deck:getDeck_core(deck_name)
    deck_name = deck_name or self.m_selectedDeck or 'adv'

    -- 콜로세움 (신규) 덱 예외처리
    if (deck_name == 'arena') then
        if (not g_arenaData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_arenaData.m_playerUserInfo:getDeck(deck_name)
        return l_doid, self:adjustFormationName(formation), deck_name, leader, tamer_id

    -- 콜로세움 덱 예외처리
    elseif (deck_name == 'pvp_atk') or (deck_name == 'pvp_def') then
        if (not g_colosseumData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_colosseumData.m_playerUserInfo:getDeck(deck_name)
        return l_doid, self:adjustFormationName(formation), deck_name, leader, tamer_id
    
    -- 친선전 덱 예외처리
    elseif (deck_name == 'fpvp_atk') then
        if (not g_friendMatchData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_friendMatchData.m_playerUserInfo:getDeck(deck_name)

        -- 덱 유효한지 검사 (친선전은 드래곤 삭제 가능)
        local t_ret = {}
        for i,v in pairs(l_doid) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end

        return t_ret, self:adjustFormationName(formation), deck_name, leader, tamer_id
    end

    local l_deck = self.m_serverData:get('deck')

    local t_deck
    local formation
	local leader
    local tamer_id
    for i, value in ipairs(l_deck) do
        if (value['deckname'] == deck_name) then
            t_deck = value['deck']
            formation = value['formation']
			leader = value['leader']
            tamer_id = value['tamer']
        end
    end

    if t_deck then
        local t_ret = {}
        for i,v in pairs(t_deck) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end
        
        return t_ret, self:adjustFormationName(formation), deck_name, leader, tamer_id
    end

    return {}, self:adjustFormationName('default'), deck_name, 1, tamer_id
end

-------------------------------------
-- function getDeck_lowData
-- @brief
-------------------------------------
function ServerData_Deck:getDeck_lowData(deck_name)
    local l_deck = self.m_serverData:get('deck')
    for i, value in ipairs(l_deck) do
        if (value['deckname'] == deck_name) then
            return value
        end
    end

    return nil
end

-------------------------------------
-- function adjustFormationName
-- @brief
-------------------------------------
function ServerData_Deck:adjustFormationName(formation)
    if (not formation) or (formation == 'default') then
        return 'attack'
    end

    return formation
end

-------------------------------------
-- function resetDragonDeckInfo
-- @breif 해당 드래곤이 덱에 설정되어있는지 여부
-------------------------------------
function ServerData_Deck:resetDragonDeckInfo()
    self.m_mapDragonDeckInfo = {}

    local l_deck = self:getDeck()

    for i,v in pairs(l_deck) do
        self.m_mapDragonDeckInfo[v] = i
    end
end

-------------------------------------
-- function isSettedDragon
-- @breif 해당 드래곤이 덱에 설정되어있는지 여부
-------------------------------------
function ServerData_Deck:isSettedDragon(doid)
    if (not self.m_mapDragonDeckInfo) then
        self:resetDragonDeckInfo()
    end

    if self.m_mapDragonDeckInfo[doid] then
        return self.m_mapDragonDeckInfo[doid]
    else
        return false
    end
end

-------------------------------------
-- function getSelectedDeckName
-------------------------------------
function ServerData_Deck:getSelectedDeckName()
    return self.m_selectedDeck
end

-------------------------------------
-- function setSelectedDeck
-------------------------------------
function ServerData_Deck:setSelectedDeck(deck_name)
    self.m_serverData:applyServerData(deck_name, 'local', 'selected_deck')
    self.m_selectedDeck = deck_name

    -- 이걸 해줘야 최초 진입시 모드별 셋팅된 덱을 가져옴 2018-01-09 ks
    self:resetDragonDeckInfo()
end

-------------------------------------
-- function getDeckCombatPower
-- @brief
-------------------------------------
function ServerData_Deck:getDeckCombatPower(deck_name)
    local combat_power = 0

    local l_deck = self:getDeck(deck_name)

    for _,doid in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if t_dragon_data then
            combat_power = combat_power + t_dragon_data:getCombatPower()
        end
    end

    return combat_power
end
