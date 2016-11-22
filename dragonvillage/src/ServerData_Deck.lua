-------------------------------------
-- class ServerData_Deck
-------------------------------------
ServerData_Deck = class({
        m_serverData = 'ServerData',

        m_mapDragonDeckInfo = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Deck:init(server_data)
    self.m_serverData = server_data
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
end

-------------------------------------
-- function getDeck
-- @brief
-------------------------------------
function ServerData_Deck:getDeck(type)
    local l_deck = self.m_serverData:get('deck')

    local t_deck = nil
    for i,value in ipairs(l_deck) do
        if (value['deckname'] == type) then
            t_deck = value['deck']
        end
    end

    if t_deck then
        local t_ret = {}
        for i,v in pairs(t_deck) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end
        
        return t_ret
    end

    return {}
end

-------------------------------------
-- function resetDragonDeckInfo
-- @breif 해당 드래곤이 덱에 설정되어있는지 여부
-------------------------------------
function ServerData_Deck:resetDragonDeckInfo()
    self.m_mapDragonDeckInfo = {}

    local l_deck = self:getDeck('1')

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