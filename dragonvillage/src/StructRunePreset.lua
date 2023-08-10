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
end

-------------------------------------
-- function init
-------------------------------------
function StructRunePreset:init()
    self.l_deck = {}
    self.idx = 0
end

-------------------------------------
-- function correctData
-------------------------------------
function StructRunePreset:correctData()
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
