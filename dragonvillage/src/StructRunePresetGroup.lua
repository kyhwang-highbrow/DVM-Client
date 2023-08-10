-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructRunePresetGroup:Structure
-------------------------------------
StructRunePresetGroup = class(PARENT, {

    idx = 'number',
    l_preset = 'Map<idx, doid>',
    name = 'string',
})

local THIS = StructRunePresetGroup
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructRunePresetGroup:getClassName()
    return 'StructRunePresetGroup'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructRunePresetGroup:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructRunePresetGroup.create(t_data)
    local struct_rune_preset = StructRunePresetGroup()
    -- 서버에서 전달 받은 key를 클라이언트 데이터에 적합하게 변경
    local t_key_change = {}
    struct_rune_preset:applyTableData(t_data, t_key_change)
    struct_rune_preset.l_preset = {}

    local l_preset = t_data['l_preset'] or {}
    for idx, t_value in pairs(l_preset) do
        local struct_preset = StructRunePreset.create(t_value)
        struct_rune_preset.l_preset[idx] = struct_preset
    end

    return struct_rune_preset
end

-------------------------------------
-- function createDefaultData
-------------------------------------
function StructRunePresetGroup.createDefaultData(_idx)
    local struct_rune_preset_group = StructRunePresetGroup()
    struct_rune_preset_group.l_preset = {}
    struct_rune_preset_group.name = tostring(_idx)

    local make_preset_count = 6
    for idx = 1, make_preset_count do
        local struct_rune_preset = StructRunePreset.createDefaultData(_idx)
        struct_rune_preset_group.l_preset[idx] = struct_rune_preset
    end

    return struct_rune_preset_group
end

-------------------------------------
-- function init
-------------------------------------
function StructRunePresetGroup:init()
    self.l_preset = {}
end

-------------------------------------
-- function correctData
-------------------------------------
function StructRunePresetGroup:correctData()
    for idx, struct_rune_preset in pairs(self.l_preset) do
        struct_rune_preset:correctData()
    end
end

-------------------------------------
-- function setDeckMap
-------------------------------------
function StructRunePresetGroup:setRunesMap(l_runes)
    self.l_preset = l_runes
end

-------------------------------------
-- function getRunesMap
-------------------------------------
function StructRunePresetGroup:getRunesMap()
    return self.l_preset or {}
end
