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
    self.m_selectedDeck = self.m_serverData:get('local', 'selected_deck') or '1'
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
function ServerData_Deck:setDeck(type, t_deck)
    local l_deck = self.m_serverData:get('deck')

    local idx = nil
    for i,value in pairs(l_deck) do
        if (value['deckname'] == type) then
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
function ServerData_Deck:getDeck(type)
    type = type or self.m_selectedDeck or '1'
    local l_deck = self.m_serverData:get('deck')

    local t_deck = nil
    local formation = nil
    for i,value in ipairs(l_deck) do
        if (value['deckname'] == type) then
            t_deck = value['deck']
            formation = value['formation']
        end
    end

    if t_deck then
        local t_ret = {}
        for i,v in pairs(t_deck) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end
        
        return t_ret, self:adjustFormationName(formation), type
    end

    return {}, self:adjustFormationName('default'), type
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
end