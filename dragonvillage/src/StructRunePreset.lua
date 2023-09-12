-- @inherit Structure
-- @caution getClassName(), getThis() 재정의 필요
local PARENT = Structure

-------------------------------------
---@class StructRunePreset:Structure
-------------------------------------
StructRunePreset = class(PARENT, {
    idx = 'number', -- 덱 번호
    l_runes = 'Map<idx, roid>',
    name = 'string',
})

local THIS = StructRunePreset
-------------------------------------
-- virtual function getClassName override
-------------------------------------
function StructRunePreset:getClassName()
    return 'StructRunePreset'
end

-------------------------------------
-- virtual function getThis override
-------------------------------------
function StructRunePreset:getThis()
    return THIS
end

-------------------------------------
-- function init
-------------------------------------
function StructRunePreset.create(t_data)
    local struct_rune_preset = StructRunePreset()
    -- 서버에서 전달 받은 key를 클라이언트 데이터에 적합하게 변경
    local t_key_change = {}
    struct_rune_preset:applyTableData(t_data, t_key_change)
    return struct_rune_preset
end

-------------------------------------
-- function createDefaultData
-------------------------------------
function StructRunePreset.createDefaultData(_idx)
    local struct_rune_preset = StructRunePreset()
    struct_rune_preset.l_runes = {}
    struct_rune_preset.idx = _idx
    struct_rune_preset.name = string.format('No. %d', _idx)
    return struct_rune_preset
end

-------------------------------------
-- function init
-------------------------------------
function StructRunePreset:init()
    self.idx = 0
end

-------------------------------------
-- function correctData
-------------------------------------
function StructRunePreset:correctData()
    for idx = 1,5 do
        local roid = self.l_runes[idx]
        if roid ~= nil and g_runesData:getRuneObject(roid) == nil then
            self.l_runes[idx] = nil
        end
    end
end

-------------------------------------
-- function setDeckMap
-------------------------------------
function StructRunePreset:setRunesMap(l_runes)
    self.l_runes = l_runes
end

-------------------------------------
-- function getRunesMap
-------------------------------------
function StructRunePreset:getRunesMap()
    return self.l_runes or {}
end

-------------------------------------
-- function getRunesIdMap
-------------------------------------
function StructRunePreset:getRunesIdMap()
    local id_map = {}

    for _, roid in pairs(self.l_runes) do
        local struct_rune_object = g_runesData:getRuneObject(roid)
        if struct_rune_object ~= nil then
            table.insert(id_map, struct_rune_object.rid)
        end
    end

    return id_map
end

-------------------------------------
-- function getRunesSetMap
-------------------------------------
function StructRunePreset:getRunesSetMap()
    local runes_map = self:getRunesIdMap()
    local active_set_map = TableRuneSet:runeSetAnalysis(runes_map)

    -- 0으로 세팅(count를 0부터 늘려가며 active_count와 비교하기 위해)
    for _ , v in pairs(active_set_map) do
        v['count'] = 0
    end

    return active_set_map
end

-------------------------------------
-- function setRune
-------------------------------------
function StructRunePreset:setRune(rune_slot, roid)
    self.l_runes[rune_slot] = roid
end

-------------------------------------
-- function getIndex
-------------------------------------
function StructRunePreset:getIndex()
    return self.idx
end

-------------------------------------
-- function setPresetDeckName
-------------------------------------
function StructRunePreset:setPresetDeckName(name)
    self.name = name
end

-------------------------------------
-- function getRunePresetName
-------------------------------------
function StructRunePreset:getRunePresetName()
    return self.name
end

-------------------------------------
-- function getJsonString
-------------------------------------
function StructRunePreset:getJsonString()
    local str = dkjson.encode(self)
    return str
end
