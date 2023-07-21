-------------------------------------
-- class ServerData_DeckPreset
-------------------------------------
ServerData_DeckPreset = class({
    m_serverData = 'ServerData',
    m_presetMap = 'Map<Key, Value>',
    m_presetSettingMap = 'Map<Key, Value>',
})


-------------------------------------
-- function init
-------------------------------------
function ServerData_DeckPreset:init(server_data)
    self.m_serverData = server_data
    self.m_presetMap = {}
    self.m_presetSettingMap = {}

    --self.m_presetSettingMap['clan_raid'] = 6
    --self.m_presetSettingMap['adv'] = 3
    self.m_presetSettingMap['league_raid'] = 9
    self.m_presetSettingMap['arena'] = 6
end

-------------------------------------
-- function getPresetDeckCategoryMap
-------------------------------------
function ServerData_DeckPreset:getPresetDeckCategoryMap()
    return self.m_presetSettingMap
end

-------------------------------------
-- function getPresetDeckCategory
-------------------------------------
function ServerData_DeckPreset:getPresetDeckCategory(deck_key)
    local map = self:getPresetDeckCategoryMap()
    for key, count in pairs(map) do
        if string.find(deck_key, key) ~= nil then
            return key, count
        end
    end
    return nil
end

-------------------------------------
-- function makeDefaultDeck
-------------------------------------
function ServerData_DeckPreset:makeDefaultDeck(deck_name, curr_deck_list)
    local deck_category, make_count = self:getPresetDeckCategory(deck_name)
    if deck_category == nil then
        return false
    end

    if self:isExistPresetDeckByDeckName(deck_name) == true then
        local preset_deck_map_exist = self:getPresetDeckMap(deck_category)
        if table.count(preset_deck_map_exist) == make_count then
            return false
        end
    end

    local preset_deck_map = {}
    for default_idx, curr_deck in ipairs(curr_deck_list) do        
        local struct_preset_deck = StructPresetDeck()
        struct_preset_deck.idx = default_idx
        struct_preset_deck.l_deck = curr_deck.l_deck
        struct_preset_deck.formation = curr_deck.formation
        struct_preset_deck.leader = curr_deck.leader           
        preset_deck_map[default_idx] = struct_preset_deck
    end

    for i = #curr_deck_list + 1, make_count do
        local struct_preset_deck = StructPresetDeck()
        struct_preset_deck.idx = i
        preset_deck_map[i] = struct_preset_deck
    end

    self:setPresetDeckMap(deck_category, preset_deck_map)
    return true
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
function ServerData_DeckPreset:setPresetDeckMap(deck_category, deck_preset_map)
    self.m_presetMap[deck_category] = deck_preset_map
end

-------------------------------------
-- function getPresetDeckMap
-------------------------------------
function ServerData_DeckPreset:getPresetDeckMap(deck_category)
    return clone(self.m_presetMap[deck_category]) or {}
end

-------------------------------------
-- function getPresetDeck
-------------------------------------
function ServerData_DeckPreset:getPresetDeck(deck_category, idx)
    local deck_preset_map = self:getPresetDeckMap(deck_category)
    return deck_preset_map[idx] or StructPresetDeck(idx)
end

-------------------------------------
-- function isExistPresetDeckByDeckName
-------------------------------------
function ServerData_DeckPreset:isExistPresetDeckByDeckName(deck_name)
    if IS_TEST_MODE() == false then
        return false
    end

    local deck_category, make_count = self:getPresetDeckCategory(deck_name)
    if deck_category == nil then
        return false
    end

    return self.m_presetMap[deck_category] ~= nil
end

-------------------------------------
-- function request_info
-------------------------------------
function ServerData_DeckPreset:request_info(finish_cb, fail_cb)
    if IS_TEST_MODE() == false then
        if finish_cb then
            finish_cb()
        end
        return
    end

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
function ServerData_DeckPreset:request_setPresetDeck(deck_category, value, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyPresetDeck(ret['modified_preset'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/preset/set')
    
    ui_network:setParam('uid', uid)
    ui_network:setParam('key', deck_category)
    ui_network:setParam('value', value)

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end