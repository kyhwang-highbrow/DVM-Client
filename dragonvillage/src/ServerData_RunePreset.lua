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
    local make_group_count = self:getPresetGroupCount()
    for idx = 1, make_group_count do
        local struct_group = StructRunePresetGroup.createDefaultData(idx)
        local group_key = 'rune_' .. idx
        self.m_presetMap[group_key] = struct_group
    end
end

-------------------------------------
-- function getPresetGroupCount
-------------------------------------
function ServerData_RunePreset:getPresetGroupCount()
    local make_group_count = 6
    return make_group_count
end

-------------------------------------
-- function applyPresetRune
-------------------------------------
function ServerData_RunePreset:applyPresetRune(t_data)
    if t_data == nil then
        return
    end

    if t_data['rune_preset'] == nil then
        return
    end

    local t_rune_prset = dkjson.decode(t_data['rune_preset'])
    for rune_group_id, value in pairs(t_rune_prset) do
        self.m_presetMap[rune_group_id] = StructRunePresetGroup.create(value)
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
    return m_preset[key].l_preset
end

-------------------------------------
-- function getRunePresetGroups
-------------------------------------
function ServerData_RunePreset:getRunePresetGroups()
    if table.count(self.m_presetMap) ~= self:getPresetGroupCount() then
        self:makeDefaultPreset()
    end

    return self.m_presetMap
end

-------------------------------------
-- function request_setRunePreset
-------------------------------------
function ServerData_RunePreset:request_setRunePreset(new_data, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:applyPresetRune(ret['modified_preset'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/preset/set')
    
    ui_network:setParam('uid', uid)
    ui_network:setParam('key', 'rune_preset')
    ui_network:setParam('value', dkjson.encode(new_data))

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end