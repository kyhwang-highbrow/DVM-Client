-------------------------------------
-- class ServerData_RunePreset
-------------------------------------
ServerData_RunePreset = class({
    m_serverData = 'ServerData',
    m_presetMap = 'Map<Key, Value>',
    m_presetMapHash = '',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_RunePreset:init(server_data)
    self.m_serverData = server_data
    self.m_presetMap = {}
    self.m_presetMapHash = nil
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
-- function setPresetGroupName
-------------------------------------
function ServerData_RunePreset:setPresetGroupName(group_idx, name)
    local rune_preset_group_map = self:getRunePresetGroups()
    local struct_preset_group = rune_preset_group_map['rune_' .. group_idx]
    struct_preset_group:setPresetGroupName(name)
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

function is_table_equal(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
       local v2 = t2[k1]
       if v2 == nil or not is_table_equal(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
       local v1 = t1[k2]
       if v1 == nil or not is_table_equal(v1,v2) then return false end
    end
    return true
 end

-------------------------------------
-- function isSameWithCurrentPresetMap
-------------------------------------
function ServerData_RunePreset:isSameWithCurrentPresetMap(preset_map)
    if is_table_equal(self.m_presetMap, preset_map) == true then
        return true
    end
    
    return false
end

-------------------------------------
-- function getRunePresetGroups
-------------------------------------
function ServerData_RunePreset:getRunePresetGroups()
    if table.count(self.m_presetMap) ~= self:getPresetGroupCount() then
        self:makeDefaultPreset()
    end

    -- 보정 처리(보유한 룬이 없을 경우)
    for key, struct_rune_preset_group in pairs(self.m_presetMap) do
        struct_rune_preset_group:correctData()
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
    ui_network:setParam('value', dkjson.encode(new_data or self.m_presetMap))

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
    return ui_network
end