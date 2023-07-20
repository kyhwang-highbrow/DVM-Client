-------------------------------------
-- class ServerData_DeckPreset
-------------------------------------
ServerData_DeckPreset = class({
    m_serverData = 'ServerData',
    m_presetMap = 'Map<Key, Value>',
})


-------------------------------------
-- function init
-------------------------------------
function ServerData_DeckPreset:init(server_data)
    self.m_serverData = server_data
    self.m_presetMap = {}
end

-------------------------------------
-- function getPresetDeckCategoryMap
-------------------------------------
function ServerData_DeckPreset:getPresetDeckCategoryMap()
    local map = {
        ['clan_raid'] = 6, 
        ['league_raid'] = 9, 
        ['arena'] = 3
    }
    return map
end

-------------------------------------
-- function getPresetDeckCategory
-------------------------------------
function ServerData_DeckPreset:getPresetDeckCategory(deck_key)
    local map = self:getPresetDeckCategoryMap()
    local deck_category = nil
    for key, _ in ipairs(map) do
        if string.find(deck_key, key) ~= nil then
            deck_category = key
            return deck_category, map[key]
        end
    end
    return deck_category
end

-------------------------------------
-- function makeDefaultDeck
-------------------------------------
function ServerData_DeckPreset:makeDefaultDeck(deck_key)
    local deck_category, make_count = self:getPresetDeckCategory(deck_key)
    if deck_category == nil then
        return
    end

    local l_deck, formation, deck_name, leader, tamer_id, formation_lv = g_deckData:getDeck(deck_key)
    local default_idx = 1
    local preset_deck_map = {}    

    for i = 1, make_count do        
        local struct_preset_deck = StructPresetDeck()
        if i == default_idx then
            struct_preset_deck.l_deck = l_deck
            struct_preset_deck.formation = formation
            struct_preset_deck.leader = leader
        end

        preset_deck_map[i] = struct_preset_deck
    end

    self:setPresetDeckMap(deck_category, preset_deck_map)
end

-------------------------------------
-- function applyPresetDeck
-------------------------------------
function ServerData_DeckPreset:applyPresetDeck(t_data)
    if t_data == nil then
        return
    end

    for deck_category_key, value in pairs(t_data) do
        local t_category_deck_data = dkjson.decode(value)
        self.m_presetMap[deck_category_key] = {}
        for idx, t_deck_value  in pairs(t_category_deck_data) do
            local struct_preset_deck = StructPresetDeck.create(t_deck_value)            
            self.m_presetMap[deck_category_key][idx] = struct_preset_deck
        end
    end
end

-------------------------------------
-- function setPresetDeckMap
-------------------------------------
function ServerData_DeckPreset:setPresetDeckMap(deck_key, deck_preset_map)
    self.m_presetMap[deck_key] = deck_preset_map
end

-------------------------------------
-- function getPresetDeckMap
-------------------------------------
function ServerData_DeckPreset:getPresetDeckMap(deck_key)
    return self.m_presetMap[deck_key] or {}
end

-------------------------------------
-- function getPresetDeck
-------------------------------------
function ServerData_DeckPreset:getPresetDeck(deck_key, idx)
    local deck_preset_map = self:getPresetDeckMap(deck_key)
    return deck_preset_map[idx] or StructPresetDeck()
end

-------------------------------------
-- function isExistPresetDeck
-------------------------------------
function ServerData_DeckPreset:isExistPresetDeck(deck_key)
    return self.m_presetMap[deck_key] ~= nil 
end

-------------------------------------
-- function request_info
-------------------------------------
function ServerData_DeckPreset:request_info(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyPresetDeck(ret['preset'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/preset/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end

-------------------------------------
-- function request_setPresetDeck
-------------------------------------
function ServerData_DeckPreset:request_setPresetDeck(deck_key, value, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyPresetDeck(ret['preset'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/preset/set')
    
    ui_network:setParam('uid', uid)
    ui_network:setParam('key', deck_key)
    ui_network:setParam('value', value)

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end