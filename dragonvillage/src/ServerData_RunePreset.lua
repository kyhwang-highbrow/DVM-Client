-------------------------------------
-- class ServerData_RunePreset
-------------------------------------
ServerData_RunePreset = class({
    m_serverData = 'ServerData',
    m_presetMap = 'Map<Key, Value>',
})


-------------------------------------
-- function init
-------------------------------------
function ServerData_RunePreset:init(server_data)
    self.m_serverData = server_data
    self.m_presetMap = {}
end

-------------------------------------
-- function makeDefaultPreset
-------------------------------------
function ServerData_RunePreset:makeDefaultPreset()
    local make_group_count = 4
    


    for idx = 1, make_group_count do
        local struct_group = StructRunePresetGroup.createDefaultData(idx)
        local group_key = string.format('rune_%d', idx)
        self.m_presetMap[group_key] = struct_group
    end
end

-------------------------------------
-- function applyPresetRune
-------------------------------------
function ServerData_RunePreset:applyPresetRune(t_data)
    if t_data == nil then
        return
    end

    for rune_group_id, value in pairs(t_data) do
        if string.find(rune_group_id, 'rune_') ~= nil then
            local t_rune_tab_data = dkjson.decode(value)
            self.m_presetMap[rune_group_id] = StructRunePresetGroup.create(t_rune_tab_data)
        end
    end
end

-------------------------------------
-- function setRunePresetGroup
-------------------------------------
function ServerData_RunePreset:setRunePresetGroup(rune_group_id, deck_preset_map)
    local key = string.format('rune_%d', rune_group_id)
    self.m_presetMap[key] = deck_preset_map
end

-------------------------------------
-- function getRunePresets
-------------------------------------
function ServerData_RunePreset:getRunePresets(rune_group_id)
    local key = string.format('rune_%d', rune_group_id)
    local m_preset = self:getRunePresetGroups()
    return m_preset[key]
end


-------------------------------------
-- function getRunePresetGroups
-------------------------------------
function ServerData_RunePreset:getRunePresetGroups()
    if table.count(self.m_presetMap) == 0 then
        self:makeDefaultPreset()
    end

    return self.m_presetMap
end


-------------------------------------
-- function request_setRunePreset
-------------------------------------
function ServerData_RunePreset:request_setRunePreset(rune_tab_id, value, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 룬 탭키
    local key = string.format('rune_%d', rune_tab_id)

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
    ui_network:setParam('key', key)
    ui_network:setParam('value', value)

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end